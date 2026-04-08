module POS_BG(
	input [9:0] x_pos,
	input [8:0] y_pos,
	output [4:0] bg_x_pos,
	output [3:0] bg_y_pos
);

    assign bg_x_pos = x_pos >> 5;
	assign bg_y_pos = y_pos >> 5;

	
endmodule