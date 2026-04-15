module VGA_CONTROLLER (
	input  wire        CLOCK_50,
	input  wire [3:0]  KEY,
	input  wire [9:0]  SW,
	output wire [9:0]  LEDR,
	output wire [7:0]  VGA_R,
	output wire [7:0]  VGA_G,
	output wire [7:0]  VGA_B,
	output wire        VGA_BLANK_N,
	output wire        VGA_SYNC_N,
	output wire        VGA_HS,
	output wire        VGA_VS,
	output wire        VGA_CLK
);

	// DE1-SoC keys are active-low.
	wire reset_n = KEY[0];

	wire pixel_clk;
	wire pll_locked;

	wire [9:0] x_pos;
	wire [8:0] y_pos;
	wire       video_active;

	wire [4:0] bg_x_pos;
	wire [3:0] bg_y_pos;
	wire [3:0] bg_val;

	wire [7:0] r_ch;
	wire [7:0] g_ch;
	wire [7:0] b_ch;

	wire ppu_oam_write_en;
	wire [3:0] ppu_oam_sel;
	wire [9:0] ppu_oam_sx;
	wire [8:0] ppu_oam_sy;
	wire [5:0] ppu_oam_val;
	wire debug_sprite_mode;

	// Keep video path in reset until PLL lock is stable.
	wire video_reset_n = reset_n & pll_locked;

	PLL pll_inst (
		.refclk(CLOCK_50),
		.rst(~reset_n),
		.outclk_0(pixel_clk),
		.locked(pll_locked)
	);

	VGA vga_inst (
		.pixel_clk(pixel_clk),
		.reset_n(video_reset_n),
		.r_ch(r_ch),
		.g_ch(g_ch),
		.b_ch(b_ch),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.video_active(video_active),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_BLANK_N(VGA_BLANK_N),
		.VGA_SYNC_N(VGA_SYNC_N),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_CLK(VGA_CLK)
	);

	// OAM write controls (can be mapped to controls later).
	assign ppu_oam_write_en = 1'b0;
	assign ppu_oam_sel = 4'd0;
	assign ppu_oam_sx = 10'd0;
	assign ppu_oam_sy = 9'd0;
	assign ppu_oam_val = 6'd0;
	assign debug_sprite_mode = SW[9];

	BG_DATA bg_data_inst (
		.bgdata_sel(SW[1:0]),
		.bg_x_pos(bg_x_pos),
		.bg_y_pos(bg_y_pos),
		.bg_val(bg_val)
	);

	PPU ppu_inst (
		.x_pos(x_pos),
		.y_pos(y_pos),
		.video_active(video_active),
		.bg_val(bg_val),
		.debug_sprite_mode(debug_sprite_mode),
		.pixel_clk(pixel_clk),
		.ppu_oam_write_en(ppu_oam_write_en),
		.ppu_oam_sel(ppu_oam_sel),
		.ppu_oam_sx(ppu_oam_sx),
		.ppu_oam_sy(ppu_oam_sy),
		.ppu_oam_val(ppu_oam_val),
		.bg_x_pos(bg_x_pos),
		.bg_y_pos(bg_y_pos),
		.r_ch(r_ch),
		.g_ch(g_ch),
		.b_ch(b_ch)
	);

	// Debug outputs.
	assign LEDR[0] = pll_locked;
	assign LEDR[1] = video_active;
	assign LEDR[3:2] = SW[1:0];
	assign LEDR[4] = debug_sprite_mode;
	assign LEDR[9:5] = 5'd0;

endmodule
