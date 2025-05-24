// RISCuinho-NG Top Module
// Integração: 2 cores, memória compartilhada, 2 NVICs, FPU

module riscuinho_ng_top #(
    parameter XLEN = 32,
    parameter MEM_SIZE = 16384
) (
    input wire clk,
    input wire rst_n
);
    // Endereço base do periférico RS232
    localparam RS232_ADDR = 32'h80000000;

    // Sinais Core 0
    wire [XLEN-1:0] core0_mem_addr;
    wire [XLEN-1:0] core0_mem_data;
    wire core0_mem_we;
    wire [31:0] core0_irq_lines;
    wire [7:0] core0_irq_ack;
    wire core0_fpu_req;
    wire core0_fpu_ack;
    // Sinais para RS232 core0
    wire core0_rs232_wr_en = (core0_mem_addr == RS232_ADDR) && core0_mem_we;
    wire [7:0] core0_rs232_wr_data = core0_mem_data[7:0];
    wire core0_rs232_rd_en = (core0_mem_addr == RS232_ADDR) && !core0_mem_we;
    wire [7:0] core0_rs232_rd_data;
    wire core0_rs232_rd_valid;
    // Sinais Core 1
    wire [XLEN-1:0] core1_mem_addr;
    wire [XLEN-1:0] core1_mem_data;
    wire core1_mem_we;
    wire [31:0] core1_irq_lines;
    wire [7:0] core1_irq_ack;
    wire core1_fpu_req;
    wire core1_fpu_ack;
    // Sinais para RS232 core1
    wire core1_rs232_wr_en = (core1_mem_addr == RS232_ADDR) && core1_mem_we;
    wire [7:0] core1_rs232_wr_data = core1_mem_data[7:0];
    wire core1_rs232_rd_en = (core1_mem_addr == RS232_ADDR) && !core1_mem_we;
    wire [7:0] core1_rs232_rd_data;
    wire core1_rs232_rd_valid;

    // Sinais FPU
    wire [31:0] fpu_op_a, fpu_op_b, fpu_result;
    wire [2:0] fpu_op;
    wire fpu_req, fpu_ack;

    // Instância dos dois cores
    riscuinho_core core0 (
        .clk(clk), .rst_n(rst_n),
        .mem_addr(core0_mem_addr),
        .mem_data(core0_mem_data),
        .mem_we(core0_mem_we),
        .irq_lines(core0_irq_lines),
        .irq_ack(core0_irq_ack),
        .fpu_req(core0_fpu_req),
        .fpu_ack(core0_fpu_ack)
    );
    riscuinho_core core1 (
        .clk(clk), .rst_n(rst_n),
        .mem_addr(core1_mem_addr),
        .mem_data(core1_mem_data),
        .mem_we(core1_mem_we),
        .irq_lines(core1_irq_lines),
        .irq_ack(core1_irq_ack),
        .fpu_req(core1_fpu_req),
        .fpu_ack(core1_fpu_ack)
    );

    // Instância do periférico RS232 (compartilhado)
    rs232_sim rs232_inst (
        .clk(clk), .rst_n(rst_n),
        // Core0
        .wr_en(core0_rs232_wr_en),
        .wr_data(core0_rs232_wr_data),
        .rd_en(core0_rs232_rd_en),
        .rd_data(core0_rs232_rd_data),
        .rd_valid(core0_rs232_rd_valid)
        // (Para mais de um core, pode-se multiplexar ou replicar instâncias)
    );

    // Memória compartilhada (dual-port)
    shared_mem #(.XLEN(XLEN), .MEM_SIZE(MEM_SIZE)) mem_inst (
        .clk(clk),
        // Porta A: core0
        .addr_a(core0_mem_addr),
        .data_a(core0_mem_data),
        .we_a(core0_mem_we),
        // Porta B: core1
        .addr_b(core1_mem_addr),
        .data_b(core1_mem_data),
        .we_b(core1_mem_we)
    );

    // NVIC para cada core
    nvic nvic0 (
        .clk(clk), .rst_n(rst_n),
        .irq_lines(core0_irq_lines),
        .irq_ack(core0_irq_ack)
    );
    nvic nvic1 (
        .clk(clk), .rst_n(rst_n),
        .irq_lines(core1_irq_lines),
        .irq_ack(core1_irq_ack)
    );

    // FPU compartilhada (arbitragem simples: prioridade core0)
    assign fpu_req = core0_fpu_req ? 1'b1 : core1_fpu_req;
    assign fpu_op_a = core0_fpu_req ? core0_mem_data : core1_mem_data;
    assign fpu_op_b = core0_fpu_req ? core0_mem_data : core1_mem_data;
    assign fpu_op   = 3'b000; // Exemplo: operação fixa, expandir conforme protocolo
    assign core0_fpu_ack = (core0_fpu_req) ? fpu_ack : 1'b0;
    assign core1_fpu_ack = (!core0_fpu_req && core1_fpu_req) ? fpu_ack : 1'b0;

    fpu fpu_inst (
        .clk(clk), .rst_n(rst_n),
        .req(fpu_req), .ack(fpu_ack),
        .op_a(fpu_op_a), .op_b(fpu_op_b), .fpu_op(fpu_op), .result(fpu_result)
    );

    // (Expandir sinais de controle/resultado da FPU conforme protocolo do core)

endmodule
