// Simulador de porta RS232 para RISCuinho-NG
// Escreve dados enviados em um arquivo rs232.out
// Lê dados de um arquivo rs232.in (se existir)

module rs232_sim(
    input wire clk,
    input wire rst_n,
    input wire wr_en,           // Sinal de escrita (envio)
    input wire [7:0] wr_data,   // Dado a ser enviado
    input wire rd_en,           // Sinal de leitura (recepção)
    output reg [7:0] rd_data,   // Dado recebido
    output reg rd_valid         // Dado recebido válido
);

    integer fout, fin;
    reg [7:0] in_buf;
    reg in_valid;

    initial begin
        fout = $fopen("../sim/rs232.out", "w");
        rd_data = 8'd0;
        rd_valid = 1'b0;
        in_valid = 1'b0;
    end

    // Escrita no arquivo (envio)
    always @(posedge clk) begin
        if (!rst_n) begin
            // Reset
            rd_data <= 8'd0;
            rd_valid <= 1'b0;
        end else begin
            if (wr_en) begin
                $fwrite(fout, "%c", wr_data);
                $fflush(fout);
            end
        end
    end

    // Leitura do arquivo (recepção, modo assíncrono)
    always @(posedge clk) begin
        if (!rst_n) begin
            rd_data <= 8'd0;
            rd_valid <= 1'b0;
            in_valid <= 1'b0;
        end else if (rd_en) begin
            if (!in_valid && $fopen("../sim/rs232.in", "r")) begin
                fin = $fopen("../sim/rs232.in", "r");
                if (fin) begin
                    if ($fscanf(fin, "%c", in_buf) == 1) begin
                        rd_data <= in_buf;
                        rd_valid <= 1'b1;
                        in_valid <= 1'b1;
                        $fclose(fin);
                        // Remove o arquivo após leitura (sincronização assíncrona)
                        void'($system("rm -f ../sim/rs232.in"));
                    end else begin
                        rd_valid <= 1'b0;
                        $fclose(fin);
                    end
                end else begin
                    rd_valid <= 1'b0;
                end
            end else begin
                rd_valid <= 1'b0;
            end
        end else begin
            rd_valid <= 1'b0;
            in_valid <= 1'b0;
        end
    end

endmodule
