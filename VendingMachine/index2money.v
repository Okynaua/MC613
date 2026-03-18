0module index2money(
	input wire [5:0] index,
	output wire [10:0] money
);

assign Value = (index == 6'b000001) ? 11'd005 :  // SW[4] 5 centavos
               (index == 6'b000010) ? 11'd010 : // SW[5] 10 centavos
               (index == 6'b000100) ? 11'd025 : // SW[6]	25 centavos
               (index == 6'b001000) ? 11'd050 : // SW[7]	50 centavos
               (index == 6'b010000) ? 11'd100 : // SW[8]	1 real
               (index == 6'b100000) ? 11'd200 : // SW[9]	2 reais
                                         11'd0; // Default: apagado

endmodule

