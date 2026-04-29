module PPU_tb;

// ========================
// Entradas
// ========================
reg [9:0] x_pos;
reg [8:0] y_pos;
reg video_active;
reg [3:0] bg_val;

reg pixel_clk;
reg ppu_oam_write_en;
reg [3:0] ppu_oam_sel;
reg [9:0] ppu_oam_sx;
reg [8:0] ppu_oam_sy;
reg [5:0] ppu_oam_val;

// ========================
// Saídas
// ========================
wire [4:0] bg_x_pos;
wire [3:0] bg_y_pos;
wire [7:0] r_ch;
wire [7:0] g_ch;
wire [7:0] b_ch;

// ========================
// Controle
// ========================
integer error_count;
localparam integer LABEL_W = 8*96;

// ========================
// DUT
// ========================
PPU uut (
    .x_pos(x_pos),
    .y_pos(y_pos),
    .video_active(video_active),
    .bg_val(bg_val),
    .pixel_clk(pixel_clk),
    .ppu_oam_write_en(ppu_oam_write_en),
    .ppu_oam_sel(ppu_oam_sel),
    .ppu_oam_sx(ppu_oam_sx),
    .ppu_oam_sy(ppu_oam_sy),
    .ppu_oam_val(ppu_oam_val),
    .bg_x_pos(bg_x_pos),
    .bg_y_pos(bg_y_pos),
    .r_ch(r_ch),
    .g_ch(g_ch),
    .b_ch(b_ch),
	 .debug_sprite_mode(1'b0)
);

// ========================
// Clock
// ========================
always #5 pixel_clk = ~pixel_clk;

// ========================
// Monitor
// ========================
initial begin
    $monitor("t=%0t | x=%d y=%d | RGB=(%d,%d,%d)",
        $time, x_pos, y_pos, r_ch, g_ch, b_ch);
end

// ========================
// Task de verificação RGB
// ========================
task expect_rgb;
    input [7:0] r_exp, g_exp, b_exp;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (r_ch !== r_exp || g_ch !== g_exp || b_ch !== b_exp) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=(%d,%d,%d) obtido=(%d,%d,%d)",
            label, r_exp, g_exp, b_exp, r_ch, g_ch, b_ch);
    end else begin
        $display("[OK] %0s", label);
    end
end
endtask

// ========================
// Escrita na OAM
// ========================
task write_sprite;
    input [3:0] idx;
    input [9:0] sx;
    input [8:0] sy;
    input [5:0] val;
begin
    @(posedge pixel_clk);
    ppu_oam_sel      = idx;
    ppu_oam_sx       = sx;
    ppu_oam_sy       = sy;
    ppu_oam_val      = val;
    ppu_oam_write_en = 1;

	 #30
    ppu_oam_write_en = 0;
end
endtask

// ========================
// Inicialização
// ========================
initial begin
    pixel_clk = 0;
    error_count = 0;

    video_active = 0;
    bg_val = 0;

    ppu_oam_write_en = 0;
    ppu_oam_sel = 0;
    ppu_oam_sx = 0;
    ppu_oam_sy = 0;
    ppu_oam_val = 0;

    // ==================================================
    // 1. Tela inativa
    // ==================================================
    $display("\n[TESTE] Video inativo");

    x_pos = 100;
    y_pos = 100;
    video_active = 0;

    #10;
    expect_rgb(0,0,0,"Tela desligada");

    // ==================================================
    // 2. Apenas background
    // ==================================================
    $display("\n[TESTE] Background");

    video_active = 1;
    bg_val = 4'd2;

    x_pos = 30;
    y_pos = 0;

    #10;
    expect_rgb(8'h2A, 8'h10, 8'h5C, "Cor do background");

    // ==================================================
    // 3. Sprite ativo
    // ==================================================
    $display("\n[TESTE] Sprite sobre BG");

    write_sprite(1, 32, 0, 6'h23);

    x_pos = 62;
    y_pos = 0;

    #10;
    expect_rgb(8'hFF, 8'h9D, 8'h01, "Sprite visivel");

    // ==================================================
    // 4. Fora do sprite
    // ==================================================
    $display("\n[TESTE] Fora do sprite");

    x_pos = 32;
    y_pos = 32;

    #10;
    expect_rgb(8'h2A, 8'h10, 8'h5C, "BG sem sprite");


    // ==================================================
    // Resultado final
    // ==================================================
    if (error_count == 0) begin
        $display("\n==== TODOS OS TESTES PASSARAM ====");
    end else begin
        $display("\n==== %0d ERROS ====", error_count);
    end

    $finish;
end

endmodule