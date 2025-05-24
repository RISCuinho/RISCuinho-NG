// RISCuinho-NG RISC-V Core (RV32I)
module riscuinho_core #(
    parameter XLEN = 32
) (
    input wire clk,
    input wire rst_n,
    // Interface de memória
    output reg [XLEN-1:0] mem_addr,
    inout wire [XLEN-1:0] mem_data,
    output reg mem_we,
    // Interface NVIC
    input wire [31:0] irq_lines,
    output reg [7:0] irq_ack,
    // Interface FPU
    output reg fpu_req,
    input wire fpu_ack,
    // Interface RS232
    output wire rs232_wr_en,
    output wire [7:0] rs232_wr_data,
    output wire rs232_rd_en,
    input wire [7:0] rs232_rd_data,
    input wire rs232_rd_valid
);
    // Endereço base do periférico RS232
    localparam RS232_ADDR = 32'h80000000;
    // Banco de registradores
    reg [XLEN-1:0] regs[0:31];
    // PC
    reg [XLEN-1:0] pc;
    // Estado da máquina de controle
    typedef enum logic [2:0] {
        FETCH, DECODE, EXECUTE, MEM, WB, IRQ
    } state_t;
    state_t state;

    // Instrução atual
    reg [31:0] instr;
    // Decodificação
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];
    // Imediatos
    wire [XLEN-1:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [XLEN-1:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [XLEN-1:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [XLEN-1:0] imm_u = {instr[31:12], 12'b0};
    wire [XLEN-1:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    // ALU
    reg [XLEN-1:0] alu_a, alu_b, alu_result;
    reg alu_branch;

    // Interrupção
    reg irq_pending;
    always @(*) begin
        irq_pending = |irq_lines;
    end

    // FPU
    reg [2:0] fpu_op;
    reg [31:0] fpu_a, fpu_b, fpu_result;
    reg fpu_active;

    // Memória
    reg [XLEN-1:0] mem_data_out;
    assign mem_data = (mem_we && mem_addr != RS232_ADDR) ? mem_data_out : {XLEN{1'bz}};
    wire [XLEN-1:0] mem_data_in = mem_data;

    // Sinais RS232
    assign rs232_wr_en = (mem_addr == RS232_ADDR) && mem_we;
    assign rs232_wr_data = mem_data_out[7:0];
    assign rs232_rd_en = (mem_addr == RS232_ADDR) && !mem_we;


    // Estado inicial
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 0;
            state <= FETCH;
            mem_we <= 0;
            fpu_req <= 0;
            irq_ack <= 0;
            for (i = 0; i < 32; i = i + 1) regs[i] <= 0;
        end else begin
            case (state)
                FETCH: begin
                    mem_addr <= pc;
                    mem_we <= 0;
                    state <= DECODE;
                end
                DECODE: begin
                    instr <= mem_data_in;
                    state <= (irq_pending) ? IRQ : EXECUTE;
                end
                IRQ: begin
                    // Simples: salva PC, sinaliza IRQ
                    regs[1] <= pc; // x1 como "ra"
                    irq_ack <= irq_lines[7:0];
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    alu_a <= regs[rs1];
                    alu_b <= (opcode == 7'b0010011 || opcode == 7'b0000011) ? imm_i : regs[rs2];
                    case (opcode)
                        7'b0110011: begin // R-type
                            case ({funct7, funct3})
                                {7'b0000000, 3'b000}: alu_result <= regs[rs1] + regs[rs2]; // ADD
                                {7'b0100000, 3'b000}: alu_result <= regs[rs1] - regs[rs2]; // SUB
                                {7'b0000000, 3'b111}: alu_result <= regs[rs1] & regs[rs2]; // AND
                                {7'b0000000, 3'b110}: alu_result <= regs[rs1] | regs[rs2]; // OR
                                {7'b0000000, 3'b100}: alu_result <= regs[rs1] ^ regs[rs2]; // XOR
                                // Extensão M (multiplicação/divisão)
                                {7'b0000001, 3'b000}: alu_result <= $signed(regs[rs1]) * $signed(regs[rs2]); // MUL
                                {7'b0000001, 3'b001}: alu_result <= ($signed(regs[rs1]) * $signed(regs[rs2])) >>> 32; // MULH
                                {7'b0000001, 3'b010}: alu_result <= ($signed(regs[rs1]) * $signed(regs[rs2])) >> 32; // MULHSU (simplificado)
                                {7'b0000001, 3'b011}: alu_result <= (regs[rs1] * regs[rs2]) >> 32; // MULHU
                                {7'b0000001, 3'b100}: alu_result <= (regs[rs2] != 0) ? $signed(regs[rs1]) / $signed(regs[rs2]) : 32'hFFFFFFFF; // DIV
                                {7'b0000001, 3'b101}: alu_result <= (regs[rs2] != 0) ? regs[rs1] / regs[rs2] : 32'hFFFFFFFF; // DIVU
                                {7'b0000001, 3'b110}: alu_result <= (regs[rs2] != 0) ? $signed(regs[rs1]) % $signed(regs[rs2]) : regs[rs1]; // REM
                                {7'b0000001, 3'b111}: alu_result <= (regs[rs2] != 0) ? regs[rs1] % regs[rs2] : regs[rs1]; // REMU
                                default: alu_result <= 0;
                            endcase
                            state <= WB;
                        end
                        7'b0010011: begin // I-type ALU
                            case (funct3)
                                3'b000: alu_result <= regs[rs1] + imm_i; // ADDI
                                3'b111: alu_result <= regs[rs1] & imm_i; // ANDI
                                3'b110: alu_result <= regs[rs1] | imm_i; // ORI
                                3'b100: alu_result <= regs[rs1] ^ imm_i; // XORI
                                default: alu_result <= 0;
                            endcase
                            state <= WB;
                        end
                        7'b0000011: begin // LW
                            mem_addr <= regs[rs1] + imm_i;
                            mem_we <= 0;
                            state <= MEM;
                        end
                        7'b0100011: begin // SW
                            mem_addr <= regs[rs1] + imm_s;
                            mem_data_out <= regs[rs2];
                            mem_we <= 1;
                            state <= FETCH;
                            pc <= pc + 4;
                        end
                        7'b1100011: begin // BEQ
                            alu_branch <= (regs[rs1] == regs[rs2]);
                            state <= WB;
                        end
                        7'b1101111: begin // JAL
                            regs[rd] <= pc + 4;
                            pc <= pc + imm_j;
                            state <= FETCH;
                        end
                        7'b1100111: begin // JALR
                            regs[rd] <= pc + 4;
                            pc <= (regs[rs1] + imm_i) & ~1;
                            state <= FETCH;
                        end
                        7'b0110111: begin // LUI
                            alu_result <= imm_u;
                            state <= WB;
                        end
                        7'b0001111: begin // FENCE (NOP)
                            state <= FETCH;
                            pc <= pc + 4;
                        end
                        7'b1010011: begin // FPU custom opcode
                            fpu_a <= regs[rs1];
                            fpu_b <= regs[rs2];
                            fpu_op <= funct3;
                            fpu_req <= 1;
                            fpu_active <= 1;
                            state <= MEM;
                        end
                        default: begin
                            state <= FETCH;
                            pc <= pc + 4;
                        end
                    endcase
                end
                MEM: begin
                    if (opcode == 7'b0000011) begin // LW
                        if (mem_addr == RS232_ADDR) begin
                            if (rs232_rd_valid)
                                regs[rd] <= {24'b0, rs232_rd_data};
                            else
                                regs[rd] <= 32'b0; // Se não há dado válido, retorna 0
                        end else begin
                            regs[rd] <= mem_data_in;
                        end
                        pc <= pc + 4;
                        state <= FETCH;
                    end else if (opcode == 7'b0100011) begin // SW
                        // Escrita: já é tratada via assign rs232_wr_en
                        pc <= pc + 4;
                        state <= FETCH;
                    end else if (opcode == 7'b1010011 && fpu_active) begin // FPU
                        if (fpu_ack) begin
                            regs[rd] <= fpu_result;
                            fpu_req <= 0;
                            fpu_active <= 0;
                            pc <= pc + 4;
                            state <= FETCH;
                        end
                    end else begin
                        state <= FETCH;
                        pc <= pc + 4;
                    end
                end
                WB: begin
                    if (opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0110111) begin
                        regs[rd] <= alu_result;
                        pc <= pc + 4;
                    end else if (opcode == 7'b1100011) begin // BEQ
                        if (alu_branch)
                            pc <= pc + imm_b;
                        else
                            pc <= pc + 4;
                    end
                    state <= FETCH;
                end
                default: state <= FETCH;
            endcase
        end
    end
endmodule
