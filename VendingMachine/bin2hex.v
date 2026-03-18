// Módulo conversor de binário para display de 7 segmentos
// Entrada: 4 bits (0-15)
// Saída: 7 bits controlando os segmentos do display
module bin2hex (
    input wire [3:0] BIN,  // Entrada: número de 0 a 15
    output wire [6:0] HEX  // Saída: 7 segmentos (cada bit controla um segmento)
);

// Lógica combinacional usando atribuições em cascata
assign HEX = (BIN == 4'b0000) ? 7'b1000000 : // 0
             (BIN == 4'b0001) ? 7'b1111001 : // 1
             (BIN == 4'b0010) ? 7'b0100100 : // 2
             (BIN == 4'b0011) ? 7'b0110000 : // 3
             (BIN == 4'b0100) ? 7'b0011001 : // 4
             (BIN == 4'b0101) ? 7'b0010010 : // 5
             (BIN == 4'b0110) ? 7'b0000010 : // 6
             (BIN == 4'b0111) ? 7'b1111000 : // 7
             (BIN == 4'b1000) ? 7'b0000000 : // 8
             (BIN == 4'b1001) ? 7'b0010000 : // 9
             (BIN == 4'b1010) ? 7'b0001000 : // A
             (BIN == 4'b1011) ? 7'b0000011 : // B
             (BIN == 4'b1100) ? 7'b1000110 : // C
             (BIN == 4'b1101) ? 7'b0100001 : // D
             (BIN == 4'b1110) ? 7'b0000110 : // E
             (BIN == 4'b1111) ? 7'b0001110 : // F
                                7'b1111111;  // Default: apagado

endmodule