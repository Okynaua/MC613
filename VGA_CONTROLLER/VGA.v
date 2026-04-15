module VGA (
    // Entradas de Controle de Clock e Reset
    input  wire        pixel_clk,     // Clock de 25.175 MHz gerado pelo PLL
    input  wire        reset_n,       // Reset assíncrono (ativo baixo)

    // Entradas de Cor (vindos da PPU)
    input  wire [7:0]  r_ch,          // Intensidade do vermelho do pixel atual
    input  wire [7:0]  g_ch,          // Intensidade do verde do pixel atual
    input  wire [7:0]  b_ch,          // Intensidade do azul do pixel atual

    // Saidas de Controle Interno (enviados para a PPU)
    output wire [9:0]  x_pos,         // Coordenada X atual
    output wire [8:0]  y_pos,         // Coordenada Y atual
    output wire        video_active,  // '1' se estiver dentro da área visível

    // Saidas Físicas (conectadas aos pinos da DE1-SoC)
    output wire [7:0]  VGA_R,         // Saída VGA Vermelha
    output wire [7:0]  VGA_G,         // Saída VGA Verde
    output wire [7:0]  VGA_B,         // Saída VGA Azul
    output wire        VGA_BLANK_N,   // Fora da área visível (0 no blanking)
    output wire        VGA_SYNC_N,    // Sincronização de vídeo (fixo em '1')
    output wire        VGA_HS,        // Sincronismo Horizontal
    output wire        VGA_VS,        // Sincronismo Vertical
    output wire        VGA_CLK        // Clock do pixel
);

    localparam [9:0] H_VISIBLE = 10'd640;
    localparam [9:0] H_FRONT   = 10'd16;
    localparam [9:0] H_SYNC    = 10'd96;
    localparam [9:0] H_BACK    = 10'd48;
    localparam [9:0] H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK; // 800

    localparam [9:0] V_VISIBLE = 10'd480;
    localparam [9:0] V_FRONT   = 10'd11;
    localparam [9:0] V_SYNC    = 10'd2;
    localparam [9:0] V_BACK    = 10'd31;
    localparam [9:0] V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK; // 524

    wire [9:0] h_count;
    wire [9:0] v_count;
    wire h_line_overflow;
    wire v_frame_overflow;

    // Horizontal pixel counter: 0..799
    COUNTER #(
        .COUNTER_SIZE(10),
        .COUNTER_COMPARE_V(H_TOTAL - 1)
    ) h_counter (
        .clk(pixel_clk),
        .rst(~reset_n),
        .counter_value(h_count),
        .overflow(h_line_overflow)
    );

    // Vertical line counter: 0..523, increments once per completed line.
    COUNTER #(
        .COUNTER_SIZE(10),
        .COUNTER_COMPARE_V(V_TOTAL - 1)
    ) v_counter (
        .clk(h_line_overflow),
        .rst(~reset_n),
        .counter_value(v_count),
        .overflow(v_frame_overflow)
    );

    wire h_active = (h_count < H_VISIBLE);
    wire v_active = (v_count < V_VISIBLE);
    wire h_sync_active = (h_count >= (H_VISIBLE + H_FRONT)) && (h_count < (H_VISIBLE + H_FRONT + H_SYNC));
    wire v_sync_active = (v_count >= (V_VISIBLE + V_FRONT)) && (v_count < (V_VISIBLE + V_FRONT + V_SYNC));

    // Output positions
    assign x_pos = h_active ? h_count : 10'd0;
    assign y_pos = v_active ? v_count[8:0] : 9'd0;

    // Visible area and sync outputs
    assign video_active = h_active && v_active;
    assign VGA_BLANK_N = video_active;
    assign VGA_HS = ~h_sync_active;
    assign VGA_VS = ~v_sync_active;

    // During blanking, force RGB to black.
    assign VGA_R = video_active ? r_ch : 8'd0;
    assign VGA_G = video_active ? g_ch : 8'd0;
    assign VGA_B = video_active ? b_ch : 8'd0;
    assign VGA_SYNC_N = 1'b1;

    // Pixel clock output
    assign VGA_CLK = pixel_clk;

endmodule