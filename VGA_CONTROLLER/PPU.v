module PPU(
	input [9:0] x_pos,
	input [8:0] y_pos,
	input video_active,
	input [3:0] bg_val,
    input debug_sprite_mode,
    input pixel_clk,
    input ppu_oam_write_en,
    input [3:0] ppu_oam_sel,
    input [9:0] ppu_oam_sx,
    input [8:0] ppu_oam_sy,
    input [5:0] ppu_oam_val,
	output [4:0] bg_x_pos,
    output [3:0] bg_y_pos,
	output [7:0] r_ch,
	output [7:0] g_ch,
	output [7:0] b_ch
);


	wire [5:0] sprite_idx;
    wire [9:0] sprite_x_pos;
	wire [8:0] sprite_y_pos;
    wire [4:0] sprite_color_idx;
    wire [4:0] bg_color_idx;
    wire [4:0] color_idx;


    POS_BG POS_BG(
        .x_pos(x_pos),
        .y_pos(y_pos),
        .bg_x_pos(bg_x_pos),
        .bg_y_pos(bg_y_pos)
    );

    PPU_OAM PPU_OAM(
        .sprite_idx(sprite_idx),
        .sprite_x_pos(sprite_x_pos),
        .sprite_y_pos(sprite_y_pos),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .ppu_oam_write_en(ppu_oam_write_en),
        .ppu_oam_sel(ppu_oam_sel),
        .ppu_oam_sx(ppu_oam_sx),
        .ppu_oam_sy(ppu_oam_sy),
        .ppu_oam_val(ppu_oam_val),
        .pixel_clk(pixel_clk)
    );

    PPU_SPRITE PPU_SPRITE(
        .sprite_idx(sprite_idx),
        .sprite_x_pos(sprite_x_pos),
        .sprite_y_pos(sprite_y_pos),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .debug_mode(debug_sprite_mode),
        .sprite_color_idx(sprite_color_idx)
    );

    PPU_TILE PPU_TILE(
        .bg_value(bg_val),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .bg_color_idx(bg_color_idx)
    );

    PPU_COMPOSITOR PPU_COMPOSITOR(
        .sprite_color_idx(sprite_color_idx),
        .bg_color_idx(bg_color_idx),
        .video_active(video_active),
        .color_idx(color_idx)
    );

    PPU_COLOR_LUT PPU_COLOR_LUT(
        .color_idx(color_idx),
        .r_ch(r_ch),
        .g_ch(g_ch),
        .b_ch(b_ch)
    );
	
endmodule