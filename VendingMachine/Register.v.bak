module register(
	input clk,
	input [10:0] inValue,
	input syncReset,
	input write,
	output reg [10:0] outValue
);

	always @(posedge clk) begin
		if(syncReset) begin
			outValue <= 11'd0;
		end else if(write) begin
			outValue <= inValue
		end
	end

endmodule