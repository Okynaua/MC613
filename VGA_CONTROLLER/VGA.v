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

    // Valores constantes
    assign VGA_R = r_ch;
    assign VGA_G = g_ch;
    assign VGA_B = b_ch;
    assign VGA_SYNC_N = 1'b1;

    // Horizontal timing: 640 active + 16 front porch + 96 sync + 48 back porch
    wire [9:0] h_video_count;
    wire [4:0] h_front_count;
    wire [6:0] h_sync_count;
    wire [5:0] h_back_count;
    wire h_video_overflow;
    wire h_front_overflow;
    wire h_sync_overflow;
    wire h_back_overflow;

    wire h_front_phase = h_video_overflow || (h_front_count != 0);
    wire h_sync_phase  = h_front_overflow || (h_sync_count != 0);
    wire h_back_phase  = h_sync_overflow || (h_back_count != 0);
    wire h_video_phase = ~(h_front_phase || h_sync_phase || h_back_phase);

    COUNTER #(
        .COUNTER_SIZE(10),
        .COUNTER_COMPARE_V(639)
    ) video_active_h_counter (
        .clk(pixel_clk),
        .rst(~reset_n || ~h_video_phase),
        .counter_value(h_video_count),
        .overflow(h_video_overflow)
    );

    COUNTER #(
        .COUNTER_SIZE(5),
        .COUNTER_COMPARE_V(15)
    ) front_porch_h_counter (
        .clk(pixel_clk),
        .rst(~reset_n || ~h_front_phase),
        .counter_value(h_front_count),
        .overflow(h_front_overflow)
    );

    COUNTER #(
        .COUNTER_SIZE(7),
        .COUNTER_COMPARE_V(95)
    ) sync_pulse_h_counter (
        .clk(pixel_clk),
        .rst(~reset_n || ~h_sync_phase),
        .counter_value(h_sync_count),
        .overflow(h_sync_overflow)
    );

    COUNTER #(
        .COUNTER_SIZE(6),
        .COUNTER_COMPARE_V(47)
    ) back_porch_h_counter (
        .clk(pixel_clk),
        .rst(~reset_n || ~h_back_phase),
        .counter_value(h_back_count),
        .overflow(h_back_overflow)
    );

    // Vertical timing: 480 active + 11 front porch + 2 sync + 31 back porch
    wire [8:0] v_video_count;
    wire [3:0] v_front_count;
    wire [1:0] v_sync_count;
    wire [4:0] v_back_count;
    wire v_video_overflow;
    wire v_front_overflow;
    wire v_sync_overflow;
    wire v_back_overflow;

    wire v_front_phase = v_video_overflow || (v_front_count != 0);
    wire v_sync_phase  = v_front_overflow || (v_sync_count != 0);
    wire v_back_phase  = v_sync_overflow || (v_back_count != 0);
    wire v_video_phase = ~(v_front_phase || v_sync_phase || v_back_phase);

    COUNTER #(
        .COUNTER_SIZE(9),
        .COUNTER_COMPARE_V(479)
    ) video_active_v_counter (
        .clk(h_back_overflow),
        .rst(~reset_n || ~v_video_phase),
        .counter_value(v_video_count),
        .overflow(v_video_overflow)
    );

    COUNTER #(
        .COUNTER_SIZE(4),
        .COUNTER_COMPARE_V(10)
    ) front_porch_v_counter (
        .clk(h_back_overflow),
        .rst(~reset_n || ~v_front_phase),
        .counter_value(v_front_count),
        .overflow(v_front_overflow)
    );

    COUNTER #(
        .COUNTER_SIZE(2),
        .COUNTER_COMPARE_V(1)
    ) sync_pulse_v_counter (
        .clk(h_back_overflow),
        .rst(~reset_n || ~v_sync_phase),
        .counter_value(v_sync_count),
        .overflow(v_sync_overflow)
    );

    COUNTER #(
        .COUNTER_SIZE(5),
        .COUNTER_COMPARE_V(30)
    ) back_porch_v_counter (
        .clk(h_back_overflow),
        .rst(~reset_n || ~v_back_phase),
        .counter_value(v_back_count),
        .overflow(v_back_overflow)
    );

    // Output positions
    assign x_pos = h_video_count;
    assign y_pos = v_video_count;

    // Visible area and sync outputs
    assign video_active = h_video_phase && v_video_phase;
    assign VGA_BLANK_N = video_active;
    assign VGA_HS = ~h_sync_phase;
    assign VGA_VS = ~v_sync_phase;

    // Pixel clock output
    assign VGA_CLK = pixel_clk;

endmodule