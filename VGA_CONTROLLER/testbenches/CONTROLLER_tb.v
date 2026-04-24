module CONTROLLER_tb;

// Entradas
reg clk;
reg [2:0] KEY;
reg [9:0] SW;

// Saídas
wire ppu_oam_write_en;
wire [3:0] ppu_oam_sel;
wire [9:0] ppu_oam_sx;
wire [8:0] ppu_oam_sy;
wire [5:0] ppu_oam_val;
wire debug_sprite_mode;
wire reset_n;

integer error_count;
localparam integer LABEL_W = 8*96;

// DUT
CONTROLLER uut (
    .clk(clk),
    .KEY(KEY),
    .SW(SW),
    .ppu_oam_write_en(ppu_oam_write_en),
    .ppu_oam_sel(ppu_oam_sel),
    .ppu_oam_sx(ppu_oam_sx),
    .ppu_oam_sy(ppu_oam_sy),
    .ppu_oam_val(ppu_oam_val),
    .debug_sprite_mode(debug_sprite_mode),
    .reset_n(reset_n)
);

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Task expect
task expect_val;
    input [31:0] observed;
    input [31:0] expected;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (observed !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=%0d obtido=%0d (t=%0t)", label, expected, observed, $time);
    end else begin
        $display("[OK] %0s | valor=%0d", label, observed);
    end
end
endtask

// =========================
// TESTES
// =========================
initial begin
    $display("==== INICIO CONTROLLER_tb ====");
    error_count = 0;

    // Inicialização
    KEY = 3'b111; // não pressionado
    SW  = 10'b0;

    // ==================================================
    // 1. Reset
    // ==================================================
    $display("\n[TESTE] Reset");

    KEY[0] = 0; #10; // reset ativo
    KEY[0] = 1; #10; // libera reset

    expect_val(ppu_oam_sx, 320, "posicao inicial X");
    expect_val(ppu_oam_sy, 352, "posicao inicial Y");
    expect_val(ppu_oam_sel, 1, "sprite selecionado");

    // ==================================================
    // 2. Escrita inicial (init burst)
    // ==================================================
    $display("\n[TESTE] Init write");

    repeat (8) begin
        @(posedge clk);
        if (ppu_oam_write_en !== 1)
            $display("[ERRO] write inicial não ativo");
    end

    // ==================================================
    // 3. Mudança de SW (update burst)
    // ==================================================
    $display("\n[TESTE] Update por SW");

    SW[1:0] = 2'b10; #10;

    // espera começar update
    repeat (10) @(posedge clk);

    if (ppu_oam_write_en)
        $display("[OK] update ativado");
    else
        $display("[ERRO] update não ativado");

    // ==================================================
    // 4. Movimento para direita
    // ==================================================
    $display("\n[TESTE] Mover direita");

    // força contador para acelerar
    force uut.oam_move_counter = 416_666;

    KEY[1] = 0; // direita 
	 repeat (5) @(posedge clk) ;
	 KEY[1] = 1;

    release uut.oam_move_counter;

    #10;
    if (ppu_oam_sx > 320)
        $display("[OK] moveu para direita");
    else
        $display("[ERRO] nao moveu direita");

    // ==================================================
    // 5. Movimento para esquerda
    // ==================================================
    $display("\n[TESTE] Mover esquerda");
	 
    KEY[0] = 0; #10; // reset ativo
    KEY[0] = 1; #10; // libera reset

    force uut.oam_move_counter = 416_666;

    KEY[2] = 0; // esquerda
    repeat (5) @(posedge clk);
    KEY[2] = 1;

    release uut.oam_move_counter;

    #10;
    if (ppu_oam_sx < 321)
        $display("[OK] moveu para esquerda");
    else
        $display("[ERRO] nao moveu esquerda");

    // ==================================================
    // 6. Limites
    // ==================================================
    $display("\n[TESTE] Limites");

    force uut.oam_sx_reg = 607;
    force uut.oam_move_counter = 416_666;

    KEY[1] = 0; @(posedge clk); KEY[1] = 1;

    if (ppu_oam_sx > 607)
        $display("[ERRO] ultrapassou limite direito");
    else
        $display("[OK] limite direito respeitado");

    release uut.oam_sx_reg;
    release uut.oam_move_counter;

    // ==================================================
    // RESULTADO FINAL
    // ==================================================
    if (error_count == 0)
        $display("\n==== TODOS OS TESTES PASSARAM ====");
    else
        $display("\n==== %0d ERROS ====", error_count);

    $finish;
end

endmodule