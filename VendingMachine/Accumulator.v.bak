module accumulator(
	input clk,
	input [10:0] inValue,
	input syncReset,
	input add,
	output [10:0] outValue
);
	wire [10:0] sum;
	
	assign sum = inValue + outValue

	Register accReg(
		.clk(clk),
		.inValue(sum),
		.syncReset(syncReset),
		.write(add),
		.outValue(outValue)
	);
	
endmodule