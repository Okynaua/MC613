module PPU_OAM (
    input pixel_clk,
    input ppu_oam_write_en,
    input [3:0] ppu_oam_sel,
    input [8:0] ppu_oam_sx,
    input [8:0] ppu_oam_sy,
    input [5:0] ppu_oam_val,
    input [9:0] x_pos,
    input [8:0] y_pos,
    output [5:0] sprite_idx,
    output [9:0] sprite_x_pos,
    output [8:0] sprite_y_pos
);

reg [24:0] reg_bank [0:15];
integer i;

initial begin 
    reg_bank[0] = 25'b0000010111100000101000000;
    for (i = 1; i < 16; i++) begin
        reg_bank[i] = 25'd0;
    end
end

PPU_OAM_IDENTIFIER identifier(
    .x(x_pos),
    .y(y_pos),
    .reg_bank(reg_bank),
    .sprite_idx(sprite_idx),
    .sprite_x_pos(sprite_x_pos),
    .sprite_y_pos(sprite_y_pos)
);
endmodule