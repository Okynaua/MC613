module accumulator(
	input clk,             // Entrada de Clock
	input [10:0] inValue,  // Entrada que será possivelmente somada
	input syncReset,       // Reset sincrono
	input add,             // Enabler da soma
	output [10:0] outValue // Valor de saida / Valor no registrador
);
	wire [10:0] sum;
	
	assign sum = inValue + outValue;

	register accReg(
		.clk(clk),
		.inValue(sum),
		.syncReset(syncReset),
		.write(add),
		.outValue(outValue)
	);
	
endmodule