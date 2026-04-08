module VGA_CONTROLLER (
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,
    output wire [7:0]  VGA_R,
    output wire [7:0]  VGA_G,
    output wire [7:0]  VGA_B,
    output wire        VGA_BLANK_N,
    output wire        VGA_SYNC_N,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire        VGA_CLK
);

    wire _unused_key = &KEY;

    wire pixel_clk;
    wire pll_locked;

    wire [9:0] x_pos;
    wire [8:0] y_pos;
    wire video_active;

    wire [7:0] r_ch;
    wire [7:0] g_ch;
    wire [7:0] b_ch;

    wire vga_reset_n = pll_locked;

    PLL pll_inst (
        .refclk(CLOCK_50),
        .rst(1'b0),
        .outclk_0(pixel_clk),
        .locked(pll_locked)
    );

    VGA vga_inst (
        .pixel_clk(pixel_clk),
        .reset_n(vga_reset_n),
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

    // 8 vertical color bars on top half, inverted bars on bottom half.
    // This verifies both horizontal (x) and vertical (y) counting.
    reg [7:0] r_top;
    reg [7:0] g_top;
    reg [7:0] b_top;

    always @* begin
        if (x_pos < 10'd80) begin
            r_top = 8'hff; g_top = 8'h00; b_top = 8'h00; // red
        end else if (x_pos < 10'd160) begin
            r_top = 8'hff; g_top = 8'hff; b_top = 8'h00; // yellow
        end else if (x_pos < 10'd240) begin
            r_top = 8'h00; g_top = 8'hff; b_top = 8'h00; // green
        end else if (x_pos < 10'd320) begin
            r_top = 8'h00; g_top = 8'hff; b_top = 8'hff; // cyan
        end else if (x_pos < 10'd400) begin
            r_top = 8'h00; g_top = 8'h00; b_top = 8'hff; // blue
        end else if (x_pos < 10'd480) begin
            r_top = 8'hff; g_top = 8'h00; b_top = 8'hff; // magenta
        end else if (x_pos < 10'd560) begin
            r_top = 8'hff; g_top = 8'hff; b_top = 8'hff; // white
        end else begin
            r_top = 8'h20; g_top = 8'h20; b_top = 8'h20; // dark gray
        end
    end

    assign r_ch = (y_pos < 9'd240) ? r_top : ~r_top;
    assign g_ch = (y_pos < 9'd240) ? g_top : ~g_top;
    assign b_ch = (y_pos < 9'd240) ? b_top : ~b_top;

endmodule