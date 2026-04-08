module BG_DATA(
	input [1:0] bgdata_sel,
	input [4:0] bg_x_pos,
	input [3:0] bg_y_pos,
    output [3:0] bg_val
);

reg [3:0] bg0 [0:511];
reg [3:0] bg1 [0:511];
reg [3:0] bg2 [0:511];
reg [3:0] bg3 [0:511];
wire [8:0] bg_xy_pos;

initial begin
    $readmemh("bg0.hex", bg0);
    $readmemh("bg1.hex", bg1);
    $readmemh("bg2.hex", bg2);
    $readmemh("bg3.hex", bg3);
end



assign bg_xy_pos = (bg_x_pos << 4) + bg_y_pos;


assign bg_val = (bgdata_sel == 2'b00) ? bg0[bg_xy_pos] :
                (bgdata_sel == 2'b01) ? bg1[bg_xy_pos] :
                (bgdata_sel == 2'b10) ? bg2[bg_xy_pos] :
                (bgdata_sel == 2'b11) ? bg3[bg_xy_pos] :
                0;

	
endmodule