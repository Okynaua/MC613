module PPU_OAM_IDENTIFIER(
	input logic [9:0] x,
	input logic [8:0] y,
	input logic [24:0] reg_bank [0:15],
	output logic [5:0] sprite_idx,
	output logic [9:0] sprite_x_pos,
	output logic [8:0] sprite_y_pos
);

	integer i;
	
	logic [24:0] temp;
	logic [9:0] s_x;
	logic [8:0] s_y;
	
	always @(*) begin
		sprite_idx = 6'b000000;
		
		for (i = 0; i < 16; i = i + 1) begin
			temp = reg_bank[i];
			
			s_x = temp[9:0];   
			s_y = temp[18:10];
			if ((x >= s_x && x < s_x + 10'd32) && 
            (y >= s_y && y < s_y + 9'd32)) begin
				sprite_idx = temp[24:19];
				sprite_x_pos = s_x;
				sprite_y_pos = s_y;
			end
		end
	end
endmodule