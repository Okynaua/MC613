module acumulador_modulo(
	input clk,            // Clock
	input [5:0] index,  // Index do dinheiro
	input enable,         // M´aquina de estados vai determinar se pode usar o acumulador
	input reset,       // M´aquina de estados vai resetar o acumulador
	output is_zero,    // Acumulador est´a com 0
	output [11:0] acumulador_out  // Valor acumulador
);

	wire [10:0] money;
	
	
	index2money idx2m (
		.index(index),
		.money(money)	
	);
	
	Accumulator acumulador(
		.clk(clk),
		.inValue(money),
		.syncReset(reset),
		.add(enable),
		.outValue(acumulador_out)
	);
	
	is_zero is0 (
		.Value(acumulador_out),
		.out(is_zero)	
	);

endmodule
