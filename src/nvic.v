// Gerenciador de interrupções estilo NVIC (um por core)
module nvic (
    input wire clk,
    input wire rst_n,
    input wire [31:0] irq_lines,
    output reg [7:0] irq_ack
);
    // Implementação básica do NVIC
endmodule
