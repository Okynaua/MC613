module multiplexer(
	input selector,
	input [10:0] Value,
	input [10:0] NegValue,
	output [10:0] outValue
);

assign outValue = (selector == 1'b0) ? Value : // Sem Carry n~ao negativa
						(selector == 1'b1) ? NegValue : // Com Carry negativa
												11'd0;  // Default: 0

endmodule