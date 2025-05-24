// Memória RAM compartilhada entre os cores (Dual-Port RAM)
module shared_mem #(
    parameter XLEN = 32,
    parameter MEM_SIZE = 16384 // número de palavras
) (
    input wire clk,
    // Porta A
    input wire [XLEN-1:0] addr_a,
    inout wire [XLEN-1:0] data_a,
    input wire we_a,
    // Porta B
    input wire [XLEN-1:0] addr_b,
    inout wire [XLEN-1:0] data_b,
    input wire we_b
);
    // Memória interna
    reg [XLEN-1:0] mem [0:MEM_SIZE-1];
    reg [XLEN-1:0] data_a_out, data_b_out;

    // Inicialização da memória por arquivo HEX
    initial begin
        $readmemh("sim/algorithms/mem_init.hex", mem);
    end

    // Porta A
    assign data_a = (!we_a) ? data_a_out : {XLEN{1'bz}};
    always @(posedge clk) begin
        if (we_a && !(we_b && addr_a == addr_b))
            mem[addr_a[($clog2(MEM_SIZE))-1:0]] <= data_a;
        data_a_out <= mem[addr_a[($clog2(MEM_SIZE))-1:0]];
    end

    // Porta B
    assign data_b = (!we_b) ? data_b_out : {XLEN{1'bz}};
    always @(posedge clk) begin
        if (we_b && !(we_a && addr_a == addr_b))
            mem[addr_b[($clog2(MEM_SIZE))-1:0]] <= data_b;
        data_b_out <= mem[addr_b[($clog2(MEM_SIZE))-1:0]];
    end
endmodule
