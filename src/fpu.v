// Unidade de ponto flutuante (FPU) compartilhada
module fpu (
    input wire clk,
    input wire rst_n,
    input wire req,
    output reg ack,
    input wire [31:0] op_a,
    input wire [31:0] op_b,
    input wire [2:0] fpu_op,
    output reg [31:0] result
);
    // Operações suportadas:
    // 000: add, 001: sub, 010: mul, 011: div
    reg [31:0] a, b;
    reg [2:0] op;
    reg busy;

    // Conversores para real (SystemVerilog)
    real fa, fb, fres;
    function real bits2float(input [31:0] bits);
        bits2float = $bitstoreal({32'b0, bits});
    endfunction
    function [31:0] float2bits(input real val);
        float2bits = $realtobits(val)[31:0];
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ack <= 0;
            result <= 0;
            busy <= 0;
        end else begin
            ack <= 0;
            if (req && !busy) begin
                a <= op_a;
                b <= op_b;
                op <= fpu_op;
                busy <= 1;
            end else if (busy) begin
                fa = bits2float(a);
                fb = bits2float(b);
                case (op)
                    3'b000: fres = fa + fb; // add
                    3'b001: fres = fa - fb; // sub
                    3'b010: fres = fa * fb; // mul
                    3'b011: fres = (fb != 0.0) ? fa / fb : 32'h7fc00000; // div (NaN on div0)
                    default: fres = 0.0;
                endcase
                result <= float2bits(fres);
                ack <= 1;
                busy <= 0;
            end
        end
    end
endmodule
