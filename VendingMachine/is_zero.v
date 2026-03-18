module is_zero(
	input [10:0] Value,
	output out
);

assign out = (Value == 11'b0) ? 1'b1 : 1'b0;

endmodule