module outBinValue(
	input [11:0] productValue,
	input [11:0] moneyInserted,
	output [10:0] muxOut
);
	wire [11:0] subtraction;

	assign subtraction = productValue - moneyInserted;

	wire [11:0] twoComplement;
	
	assign twoComplement = -subtraction;
	
	Multiplexer mux(
		.selector(subtraction[11]),
		.NegValue(twoComplement[10:0]),
		.Value(subtraction[10:0]),
		.outValue(muxOut)
	);
	

endmodule