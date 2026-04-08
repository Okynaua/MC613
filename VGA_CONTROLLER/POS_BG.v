module POS_BG(
	input x_pos,
	input y_pos,
	output bg_x_pos,
	output bg_y_pos
);

    assign bg_x_pos = x_pos >> 5;
	assign bg_y_pos = y_pos >> 5;

	
endmodule