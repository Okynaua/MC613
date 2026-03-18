module product2value (
    input wire [3:0] BIN,  // ID do Produto
    output wire [10:0] Value  // Valor em centavos
);

// Lógica combinacional usando atribuições em cascata
assign Value = (BIN == 4'b0000) ? 11'd125 : // 0 - R$1,25
             (BIN == 4'b0001) ? 11'd300 : 	// 1 - R$3,00
             (BIN == 4'b0010) ? 11'd175 : 	// 2 - R$1,75
             (BIN == 4'b0011) ? 11'd450: 	// 3 - R$4,50
             (BIN == 4'b0100) ? 11'd225 : 	// 4 - R$2,25
             (BIN == 4'b0101) ? 11'd350 : 	// 5 - R$3,50
             (BIN == 4'b0110) ? 11'd250 : 	// 6 - R$2,50
             (BIN == 4'b0111) ? 11'd425 : 	// 7 - R$4,25
             (BIN == 4'b1000) ? 11'd500 : 	// 8 - R$5,00
             (BIN == 4'b1001) ? 11'd325 : 	// 9 - R$3,25
             (BIN == 4'b1010) ? 11'd600 : 	// A - R$6,00
             (BIN == 4'b1011) ? 11'd275 : 	// B - R$2,75
             (BIN == 4'b1100) ? 11'd700 : 	// C - R$7,00
             (BIN == 4'b1101) ? 11'd475 : 	// D - R$4,75
             (BIN == 4'b1110) ? 11'd525 : 	// E - R$5,25
             (BIN == 4'b1111) ? 11'd800 : 	// F - R$8,00
                                11'd0;  		// Default: apagado

endmodule