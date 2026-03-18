module product2value (
    input wire [3:0] BIN,  // ID do Produto
    output wire [10:0] Value  // Valor em centavos
);

// Lógica combinacional usando atribuições em cascata
assign Value = (BIN == 4'b0000) ? 11'd125 : // 0
             (BIN == 4'b0001) ? 11'd300 : // 1
             (BIN == 4'b0010) ? 11'd175 : // 2
             (BIN == 4'b0011) ? 11'd450: // 3
             (BIN == 4'b0100) ? 11'd225 : // 4
             (BIN == 4'b0101) ? 11'd350 : // 5
             (BIN == 4'b0110) ? 11'd250 : // 6
             (BIN == 4'b0111) ? 11'd425 : // 7
             (BIN == 4'b1000) ? 11'd500 : // 8
             (BIN == 4'b1001) ? 11'd325 : // 9
             (BIN == 4'b1010) ? 11'd600 : // A
             (BIN == 4'b1011) ? 11'd275 : // B
             (BIN == 4'b1100) ? 11'd700 : // C
             (BIN == 4'b1101) ? 11'd475 : // D
             (BIN == 4'b1110) ? 11'd525 : // E
             (BIN == 4'b1111) ? 11'd800 : // F
                                11'd0;  // Default: apagado

endmodule