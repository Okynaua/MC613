module outBinValue(
	input [12:0] productValue,
	input [12:0] moneyInserted,
	output [11:0] muxOut
);
	wire [12:0] subtraction;

	assign subtraction = productValue - moneyInserted;

	wire [12:0] twoComplement;
	
	assign twoComplement = -subtraction;
	
	Multiplexer mux(
		.selector(subtraction[12]),
		.NegValue(twoComplement),
		.Value(substraction)
		.outValue(muxOut)
	);
	

endmodule