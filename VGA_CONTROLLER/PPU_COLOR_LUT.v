module PPU_COLOR_LUT(
	input [4:0] color_idx,
    output [7:0] r_ch,
    output [7:0] g_ch,
    output [7:0] b_ch
);

reg [23:0] colors [0:31];


initial begin
    $readmemh("colors.hex", colors);
end

wire [23:0] rgb = colors[color_idx];

assign b_ch = rgb[7:0];
assign g_ch = rgb[15:8];
assign r_ch = rgb[23:16];
	
endmodule