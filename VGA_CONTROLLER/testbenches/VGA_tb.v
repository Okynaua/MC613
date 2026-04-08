`timescale 1ns/1ns

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
    reg [7:0] r_top;
    reg [7:0] g_top;
    reg [7:0] b_top;

    integer row_count;
    integer vs_pulse_count;
    reg prev_vga_hs;
    reg prev_vga_vs;

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
        if (x_pos < 10'd80) begin
            r_top = 8'hff; g_top = 8'h00; b_top = 8'h00;
        end else if (x_pos < 10'd160) begin
            r_top = 8'hff; g_top = 8'hff; b_top = 8'h00;
        end else if (x_pos < 10'd240) begin
            r_top = 8'h00; g_top = 8'hff; b_top = 8'h00;
        end else if (x_pos < 10'd320) begin
            r_top = 8'h00; g_top = 8'hff; b_top = 8'hff;
        end else if (x_pos < 10'd400) begin
            r_top = 8'h00; g_top = 8'h00; b_top = 8'hff;
        end else if (x_pos < 10'd480) begin
            r_top = 8'hff; g_top = 8'h00; b_top = 8'hff;
        end else if (x_pos < 10'd560) begin
            r_top = 8'hff; g_top = 8'hff; b_top = 8'hff;
        end else begin
            r_top = 8'h20; g_top = 8'h20; b_top = 8'h20;
        end

        if (y_pos < 9'd240) begin
            r_ch = r_top;
            g_ch = g_top;
            b_ch = b_top;
        end else begin
            r_ch = ~r_top;
            g_ch = ~g_top;
            b_ch = ~b_top;
        end
    end

    initial begin
        $display("==== VGA TB START ====\n");

        CLOCK_50 = 1'b0;
        reset_n = 1'b0;
        row_count = 0;
        vs_pulse_count = 0;
        prev_vga_hs = 1'b1;
        prev_vga_vs = 1'b1;

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

            if (video_active && (x_pos[6:0] == 7'd0)) begin
                $display("x=%0d y=%0d rgb=(%0d,%0d,%0d)", x_pos, y_pos, r_ch, g_ch, b_ch);
            end

            if (VGA_HS !== prev_vga_hs) begin
                $display("HS -> %b at t=%0t x=%0d y=%0d", VGA_HS, $time, x_pos, y_pos);
                prev_vga_hs = VGA_HS;
            end

            if (VGA_VS !== prev_vga_vs) begin
                $display("VS -> %b at t=%0t x=%0d y=%0d", VGA_VS, $time, x_pos, y_pos);
                if (VGA_VS == 1'b0) begin
                    vs_pulse_count = vs_pulse_count + 1;
                end
                prev_vga_vs = VGA_VS;
            end

            if (vs_pulse_count >= 4 && x_pos == 10'd0 && y_pos == 9'd0) begin
                #1000
                $display("\n==== VGA TB END ====\n");
                $finish;
            end
        end
    end

endmodule