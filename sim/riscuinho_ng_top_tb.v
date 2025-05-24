// Testbench para RISCuinho-NG Top
`timescale 1ns/1ps
module riscuinho_ng_top_tb;
    reg clk, rst_n;
    integer i;
    
    riscuinho_ng_top uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        #50 rst_n = 1;
    end

    // Monitoramento e checagem automática dos resultados
    initial begin
        $dumpfile("../sim/riscuinho_ng_top_tb.vcd");
        $dumpvars(0, riscuinho_ng_top_tb);
        // Tempo máximo de simulação
        #100000;
        automatic int errors = 0;
        // Checagem para test_fpu
`ifdef TEST_FPU
        $display("[TEST] FPU");
        if (uut.mem_inst.mem[32'h200>>2] !== 32'h41700000) begin $display("FPU ADD FAIL: %h", uut.mem_inst.mem[32'h200>>2]); errors=errors+1; end else $display("FPU ADD OK");
        if (uut.mem_inst.mem[32'h204>>2] !== 32'h40a00000) begin $display("FPU SUB FAIL: %h", uut.mem_inst.mem[32'h204>>2]); errors=errors+1; end else $display("FPU SUB OK");
        if (uut.mem_inst.mem[32'h208>>2] !== 32'h42480000) begin $display("FPU MUL FAIL: %h", uut.mem_inst.mem[32'h208>>2]); errors=errors+1; end else $display("FPU MUL OK");
        if (uut.mem_inst.mem[32'h20c>>2] !== 32'h40000000) begin $display("FPU DIV FAIL: %h", uut.mem_inst.mem[32'h20c>>2]); errors=errors+1; end else $display("FPU DIV OK");
`endif
        // Checagem para test_muldiv
`ifdef TEST_MULDIV
        $display("[TEST] MUL/DIV");
        if (uut.mem_inst.mem[32'h100>>2] !== 32'h3cfa639) begin $display("MUL FAIL: %h", uut.mem_inst.mem[32'h100>>2]); errors=errors+1; end else $display("MUL OK");
        // Adicione demais checagens conforme esperado
`endif
        // Checagem para fatorial
`ifdef TEST_FATORIAL
        $display("[TEST] FATORIAL");
        if (uut.mem_inst.mem[1] !== 32'd479001600) begin $display("FATORIAL FAIL: %0d", uut.mem_inst.mem[1]); errors=errors+1; end else $display("FATORIAL OK");
`endif
        // Checagem para fibonacci
`ifdef TEST_FIBONACCI
        $display("[TEST] FIBONACCI");
        if (uut.mem_inst.mem[2] !== 32'd832040) begin $display("FIBONACCI FAIL: %0d", uut.mem_inst.mem[2]); errors=errors+1; end else $display("FIBONACCI OK");
`endif
        // Checagem para bubblesort (arr[0]...arr[9]=0..9)
`ifdef TEST_BUBBLESORT
        $display("[TEST] BUBBLESORT");
        for (i=0; i<10; i=i+1) if (uut.mem_inst.mem[i] !== i) begin $display("BUBBLESORT FAIL: arr[%0d]=%0d", i, uut.mem_inst.mem[i]); errors=errors+1; end
        if (errors==0) $display("BUBBLESORT OK");
`endif
        // Checagem para quicksort (arr[0]...arr[9]=1..10)
`ifdef TEST_QUICKSORT
        $display("[TEST] QUICKSORT");
        for (i=0; i<10; i=i+1) if (uut.mem_inst.mem[i] !== (i+1)) begin $display("QUICKSORT FAIL: arr[%0d]=%0d", i, uut.mem_inst.mem[i]); errors=errors+1; end
        if (errors==0) $display("QUICKSORT OK");
`endif
        // Checagem para binsearch (target=7, arr[6]=7)
`ifdef TEST_BINSEARCH
        $display("[TEST] BINSEARCH");
        if (uut.mem_inst.mem[6] !== 7) begin $display("BINSEARCH FAIL: arr[6]=%0d", uut.mem_inst.mem[6]); errors=errors+1; end else $display("BINSEARCH OK");
`endif
        // Checagem para matmul (C[0][0]=30, C[2][2]=50)
`ifdef TEST_MATMUL
        $display("[TEST] MATMUL");
        if (uut.mem_inst.mem[18] !== 30) begin $display("MATMUL FAIL: C[0][0]=%0d", uut.mem_inst.mem[18]); errors=errors+1; end else $display("MATMUL C[0][0] OK");
        if (uut.mem_inst.mem[26] !== 50) begin $display("MATMUL FAIL: C[2][2]=%0d", uut.mem_inst.mem[26]); errors=errors+1; end else $display("MATMUL C[2][2] OK");
`endif
        // Checagem para fft (real[0] esperado: valor simulado)
`ifdef TEST_FFT
        $display("[TEST] FFT");
        // Exemplo: checar apenas se não travou
        if (uut.mem_inst.mem[0] === 32'bx) begin $display("FFT FAIL: real[0] indefinido"); errors=errors+1; end else $display("FFT OK");
`endif
        // Checagem para primos (is_prime[97]=1, is_prime[98]=0, is_prime[99]=0)
`ifdef TEST_PRIMOS
        $display("[TEST] PRIMOS");
        if (uut.mem_inst.mem[97] !== 1) begin $display("PRIMOS FAIL: is_prime[97]=%0d", uut.mem_inst.mem[97]); errors=errors+1; end
        if (uut.mem_inst.mem[98] !== 0) begin $display("PRIMOS FAIL: is_prime[98]=%0d", uut.mem_inst.mem[98]); errors=errors+1; end
        if (uut.mem_inst.mem[99] !== 0) begin $display("PRIMOS FAIL: is_prime[99]=%0d", uut.mem_inst.mem[99]); errors=errors+1; end
        if (errors==0) $display("PRIMOS OK");
`endif
        // Checagem para bigmul (res=80846638416, parte baixa)
`ifdef TEST_BIGMUL
        $display("[TEST] BIGMUL");
        if (uut.mem_inst.mem[3] !== 32'd80846638416) begin $display("BIGMUL FAIL: res[31:0]=%0d", uut.mem_inst.mem[3]); errors=errors+1; end else $display("BIGMUL OK");
`endif
        // Checagem para dijkstra (dist[4]=3)
`ifdef TEST_DIJKSTRA
        $display("[TEST] DIJKSTRA");
        if (uut.mem_inst.mem[9] !== 3) begin $display("DIJKSTRA FAIL: dist[4]=%0d", uut.mem_inst.mem[9]); errors=errors+1; end else $display("DIJKSTRA OK");
`endif
        if (errors == 0)
            $display("\n==== TODOS OS TESTES PASSARAM! ====");
        else
            $display("\n==== %0d ERROS ENCONTRADOS! ====", errors);
        $finish;
    end
endmodule
