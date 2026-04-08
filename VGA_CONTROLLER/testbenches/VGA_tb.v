`timescale 1ns/1ps

module VGA_tb;

    reg CLOCK_50;
    reg reset_n;

    wire pixel_clk;
    wire pll_locked;

    wire [9:0] x_pos;
    wire [8:0] y_pos;
    wire video_active;

    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire VGA_BLANK_N;
    wire VGA_SYNC_N;
    wire VGA_HS;
    wire VGA_VS;
    wire VGA_CLK;

    reg [7:0] r_ch;
    reg [7:0] g_ch;
    reg [7:0] b_ch;

    integer row_count;

    PLL pll_inst (
        .refclk(CLOCK_50),
        .rst(~reset_n),
        .outclk_0(pixel_clk),
        .locked(pll_locked)
    );

    VGA dut (
        .pixel_clk(pixel_clk),
        .reset_n(reset_n),
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

    always begin
        CLOCK_50 = 1'b0;
        #10;
        CLOCK_50 = 1'b1;
        #10;
    end

    always @* begin
        r_ch = horizontal_red(x_pos, y_pos);
        g_ch = horizontal_green(x_pos, y_pos);
        b_ch = horizontal_blue(x_pos, y_pos);
    end

    function [7:0] horizontal_red;
        input [9:0] x;
        input [8:0] y;
        reg [7:0] hue_red;
        reg [7:0] desaturation;
        begin
            hue_red = 8'd255 - ((x * 8'd255) / 10'd639);
            desaturation = (y * 8'd255) / 9'd479;
            horizontal_red = hue_red + (((8'd255 - hue_red) * desaturation) / 8'd255);
        end
    endfunction

    function [7:0] horizontal_green;
        input [9:0] x;
        input [8:0] y;
        reg [7:0] desaturation;
        begin
            desaturation = (y * 8'd255) / 9'd479;
            horizontal_green = desaturation;
        end
    endfunction

    function [7:0] horizontal_blue;
        input [9:0] x;
        input [8:0] y;
        reg [7:0] hue_blue;
        reg [7:0] desaturation;
        begin
            hue_blue = (x * 8'd255) / 10'd639;
            desaturation = (y * 8'd255) / 9'd479;
            horizontal_blue = hue_blue + (((8'd255 - hue_blue) * desaturation) / 8'd255);
        end
    endfunction

    initial begin
        $display("==== VGA TB START ====\n");

        CLOCK_50 = 1'b0;
        reset_n = 1'b0;
        row_count = 0;

        #200;
        reset_n = 1'b1;

        wait (pll_locked == 1'b1);
        $display("PLL locked at t=%0t", $time);

        wait (video_active == 1'b1);

        forever begin : frame_loop
            @(posedge pixel_clk);

            if (video_active && (x_pos == 10'd0)) begin
                $display("\nrow=%0d y=%0d", row_count, y_pos);
                row_count = row_count + 1;
            end

            if (video_active && (x_pos[3:0] == 4'd0) && (y_pos[2:0] == 3'd0)) begin
                $display("x=%0d y=%0d rgb=(%0d,%0d,%0d)", x_pos, y_pos, r_ch, g_ch, b_ch);
            end

            if (row_count >= 24 && x_pos == 10'd0 && y_pos == 9'd0) begin
                $display("\n==== VGA TB END ====\n");
                $finish;
            end
        end
    end

endmodule