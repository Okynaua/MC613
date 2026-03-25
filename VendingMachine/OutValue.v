module outValue(
	input [11:0] productValue,
	input [11:0] moneyInserted,
	output subtractionCarry,
	output subtractionZero,
	output [10:0] muxOut         // Will go to hex displays
);
	wire [11:0] subtraction;
	assign subtraction = productValue - moneyInserted;

	wire [11:0] twoComplement;
	
	assign twoComplement = -subtraction;
	assign subtractionCarry = subtraction[11];
	assign subtractionZero = (subtraction == 12'd0);
	
	Multiplexer mux(
		.selector(subtraction[11]),
		.NegValue(twoComplement[10:0]),
		.Value(subtraction[10:0]),
		.outValue(muxOut)
	);
	

endmodule
