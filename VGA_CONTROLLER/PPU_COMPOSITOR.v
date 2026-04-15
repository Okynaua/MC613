module PPU_COMPOSITOR(
	input [4:0] sprite_color_idx,
	input [4:0] bg_color_idx,
	input videoactive,
    output [4:0] color_idx
);

assign color_idx = (videoactive==0)               ? 0:
                   (sprite_color_idx == 5'b00000) ? bg_color_idx:
                                                    sprite_color_idx;

	
endmodule