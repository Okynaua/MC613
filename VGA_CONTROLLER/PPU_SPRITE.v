module PPU_SPRITE(
	input [5:0] sprite_idx,
    input [9:0] sprite_x_pos,
	input [8:0] sprite_y_pos,
    input [9:0] x_pos,
	input [8:0] y_pos,
    input debug_mode,
    output [4:0] sprite_color_idx
);

reg [4:0] sprites [0:32767];

initial begin
    $readmemh("sprites/sprite0.hex", sprites, 0, 1023);
    $readmemh("sprites/sprite1.hex", sprites, 1024, 2047);
    $readmemh("sprites/sprite2.hex", sprites, 2048, 3071);
    $readmemh("sprites/sprite3.hex", sprites, 3072, 4095);
    $readmemh("sprites/sprite4.hex", sprites, 4096, 5119);
    $readmemh("sprites/sprite5.hex", sprites, 5120, 6143);
    $readmemh("sprites/sprite6.hex", sprites, 6144, 7167);
    $readmemh("sprites/sprite7.hex", sprites, 7168, 8191);
    $readmemh("sprites/sprite8.hex", sprites, 8192, 9215);
    $readmemh("sprites/sprite9.hex", sprites, 9216, 10239);
    $readmemh("sprites/sprite10.hex", sprites, 10240, 11263);
    $readmemh("sprites/sprite11.hex", sprites, 11264, 12287);
    $readmemh("sprites/sprite12.hex", sprites, 12288, 13311);
    $readmemh("sprites/sprite13.hex", sprites, 13312, 14335);
    $readmemh("sprites/sprite14.hex", sprites, 14336, 15359);
    $readmemh("sprites/sprite15.hex", sprites, 15360, 16383);
    $readmemh("sprites/sprite16.hex", sprites, 16384, 17407);
    $readmemh("sprites/sprite17.hex", sprites, 17408, 18431);
    $readmemh("sprites/sprite18.hex", sprites, 18432, 19455);
    $readmemh("sprites/sprite19.hex", sprites, 19456, 20479);
    $readmemh("sprites/sprite20.hex", sprites, 20480, 21503);
    $readmemh("sprites/sprite21.hex", sprites, 21504, 22527);
    $readmemh("sprites/sprite22.hex", sprites, 22528, 23551);
    $readmemh("sprites/sprite23.hex", sprites, 23552, 24575);
    $readmemh("sprites/sprite24.hex", sprites, 24576, 25599);
    $readmemh("sprites/sprite25.hex", sprites, 25600, 26623);
    $readmemh("sprites/sprite26.hex", sprites, 26624, 27647);
    $readmemh("sprites/sprite27.hex", sprites, 27648, 28671);
    $readmemh("sprites/sprite28.hex", sprites, 28672, 29695);
    $readmemh("sprites/sprite29.hex", sprites, 29696, 30719);
    $readmemh("sprites/sprite30.hex", sprites, 30720, 31743);
    $readmemh("sprites/sprite31.hex", sprites, 31744, 32767);
end


wire [9:0] x_sub;
wire [8:0] y_sub;
wire in_bounds;
wire [9:0] sprite_y_x_pos;
wire [14:0] sprite_addr;
wire [4:0] sprite_mem_color;
wire [4:0] debug_color;

assign x_sub = x_pos - sprite_x_pos;
assign y_sub = y_pos - sprite_y_pos;

assign in_bounds = (x_pos >= sprite_x_pos) &&
                   (y_pos >= sprite_y_pos) &&
                   (x_sub < 10'd32) &&
                   (y_sub < 9'd32);

assign sprite_y_x_pos = {y_sub[4:0], x_sub[4:0]};
assign sprite_addr = (sprite_idx[4:0] << 10) + sprite_y_x_pos;
assign sprite_mem_color = sprites[sprite_addr];

assign debug_color = (x_sub[4:0] == 5'd0 || x_sub[4:0] == 5'd31 ||
                      y_sub[4:0] == 5'd0 || y_sub[4:0] == 5'd31) ? 5'd3 :
                     (x_sub[3] ^ y_sub[3]) ? 5'd12 : 5'd9;

assign sprite_color_idx = !in_bounds         ? 5'd0 :
                          debug_mode          ? debug_color :
                          (sprite_idx < 6'd32) ? sprite_mem_color : 5'd0;

endmodule