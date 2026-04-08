module PPU_OAM_IDENTIFIER(
	input [9:0] x,
	input [8:0] y,
	input [24:0] mem [0:15],
	output reg [5:0] sprite_idx
);

	integer i;
	
	reg [24:0] temp;
	reg [9:0] s_x;
	reg [8:0] s_y;
	
	always @(*) begin
		sprite_idx = 6'b000000;
		
		for (i = 0; i < 16; i = i + 1) begin
			temp = mem[i];
			
			s_x = temp[9:0];   
			s_y = temp[18:10];
			if ((x >= s_x && x < s_x + 10'd32) && 
            (y >= s_y && y < s_y + 9'd32)) begin
				sprite_idx = temp[24:19];
			end
		end
	end

endmodule