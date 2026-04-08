module VGA_CONTROLLER (
    // Entradas de Controle de Clock e Reset
    input  wire        pixel_clk,     // Clock de 25.175 MHz gerado pelo PLL
    input  wire        reset_n,       // Reset assíncrono (ativo baixo)

    // Entradas de Cor (vindos da PPU)
    input  wire [7:0]  r_in,          // Intensidade do vermelho do pixel atual
    input  wire [7:0]  g_in,          // Intensidade do verde do pixel atual
    input  wire [7:0]  b_in,          // Intensidade do azul do pixel atual

    // Saidas de Controle Interno (enviados para a PPU)
    output wire [9:0]  pixel_x,       // Coordenada X atual
    output wire [9:0]  pixel_y,       // Coordenada Y atual
    output wire        video_active,  // '1' se estiver dentro da área visível

    // Saidas Físicas (conectadas aos pinos da DE1-SoC)
    output wire [7:0]  VGA_R,         // Saída VGA Vermelha
    output wire [7:0]  VGA_G,         // Saída VGA Verde
    output wire [7:0]  VGA_B,         // Saída VGA Azul
    output wire        VGA_HS,        // Sincronismo Horizontal
    output wire        VGA_VS,        // Sincronismo Vertical
    output wire        VGA_BLANK_N,   // Fora da área visível (0 no blanking)
    output wire        VGA_SYNC_N,    // Sincronização de vídeo (fixo em '1')
    output wire        VGA_CLK        // Clock do pixel
);

endmodule