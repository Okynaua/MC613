module espera_1s(
    input clk,              // Clock de 50MHz
    input reset,            // Reset (reinicia a contagem)
    output reg pulse_out    // O pulso de 1 segundo
);

    reg [25:0] contador = 26'd0;
    reg pronto = 1'b1; // Flag para travar a contagem após o pulso

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            contador  <= 26'd0;
            pulse_out <= 1'b0;
            pronto    <= 1'b0;
        end else if (!pronto) begin
            if (contador >= 26'd49_999_999) begin
                pulse_out <= 1'b1;   // Envia o pulso
                pronto    <= 1'b1;   // Trava o sistema
            end else begin
                contador  <= contador + 1'b1;
                pulse_out <= 1'b0;
            end
        end else begin
            // Após o pulso ser enviado, garante que a saída volte a 0
            pulse_out <= 1'b0;
        end
    end

endmodule