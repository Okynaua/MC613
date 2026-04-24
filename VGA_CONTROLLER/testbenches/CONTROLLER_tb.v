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
integer prev_x;

// Instância do DUT
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

// Clock (20ns)
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// Monitor
initial begin
    $monitor("t=%0t | KEY=%b SW=%b | WE=%b SEL=%d SX=%d SY=%d VAL=%d",
              $time, KEY, SW,
              ppu_oam_write_en, ppu_oam_sel,
              ppu_oam_sx, ppu_oam_sy, ppu_oam_val);
end

// Task expect
task expect_signal;
    input observed;
    input expected;
    input [200*8:0] label;
begin
    #1;
    if (observed !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=%b obtido=%b (t=%0t)", label, expected, observed, $time);
    end else begin
        $display("[OK] %0s", label);
    end
end
endtask

// Pressionar direita
task press_right;
begin
    @(negedge clk);
    KEY[1] = 0;
    @(negedge clk);
    KEY[1] = 1;
end
endtask

// Pressionar esquerda
task press_left;
begin
    @(negedge clk);
    KEY[2] = 0;
    @(negedge clk);
    KEY[2] = 1;
end
endtask

// Reset
task do_reset;
begin
    @(negedge clk);
    KEY[0] = 0;
    @(negedge clk);
    KEY[0] = 1;
end
endtask

// Forçar movimento (bypass do contador lento)
task force_move_tick;
begin
    force uut.oam_move_counter = 416_666;
    @(posedge clk);
    release uut.oam_move_counter;
end
endtask

// =========================
// TESTES
// =========================
initial begin
    $display("==== INICIO DA SIMULACAO CONTROLLER ====");

    clk = 0;
    KEY = 3'b111;
    SW = 0;
    error_count = 0;

    // =========================
    // 1. RESET
    // =========================
    $display("\n[TESTE] Reset");
    do_reset();
    #99;

    expect_signal(ppu_oam_sx, 320, "Posicao inicial SX = 320");
	 expect_signal(ppu_oam_sy, 352, "Posicao inicial SY = 352");

    // =========================
    // 2. Escrita inicial
    // =========================
    $display("\n[TESTE] Escrita inicial ativa");
    #50;
    expect_signal(ppu_oam_write_en, 1, "Write enable durante init");

    // =========================
    // 3. Mudanca de sprite via SW
    // =========================
    $display("\n[TESTE] Mudanca de SW dispara update");

    SW[1:0] = 2'b10;
    #20;

    expect_signal(ppu_oam_write_en, 1, "Update iniciado");

	// =========================
	// 4. Movimento para direita
	// =========================
	$display("\n[TESTE] Movimento para direita");

	prev_x = ppu_oam_sx;

	force_move_tick();
	press_right();

	// Verifica escrita
	expect_signal(ppu_oam_write_en, 1, "Write ao mover direita");
	
	#20;

	// Verifica movimento correto
	if (ppu_oam_sx > prev_x) begin
		 $display("[OK] Movimento para direita: %0d -> %0d", prev_x, ppu_oam_sx);
	end else begin
		 error_count = error_count + 1;
		 $display("[ERRO] Movimento para direita nao ocorreu! %0d -> %0d", prev_x, ppu_oam_sx);
	end

	// =========================
	// 5. Movimento para esquerda
	// =========================
	$display("\n[TESTE] Movimento para esquerda");

	prev_x = ppu_oam_sx;

	force_move_tick();
	press_left();

	// Verifica escrita
	expect_signal(ppu_oam_write_en, 1, "Write ao mover esquerda");
	
	#20;

	// Verifica movimento correto
	if (ppu_oam_sx < prev_x) begin
		 $display("[OK] Movimento para esquerda: %0d -> %0d", prev_x, ppu_oam_sx);
	end else begin
		 error_count = error_count + 1;
		 $display("[ERRO] Movimento para esquerda nao ocorreu! %0d -> %0d", prev_x, ppu_oam_sx);
	end
	 
	 
    // =========================
    // 6. RESET
    // =========================
    $display("\n[TESTE] Reset");
    do_reset();
    #20;

    expect_signal(ppu_oam_sx, 320, "Posicao inicial SX = 320");
	 expect_signal(ppu_oam_sy, 352, "Posicao inicial SY = 352");

    // =========================
    // 7. Debug mode
    // =========================
    $display("\n[TESTE] Debug mode");

    SW[9] = 1;
    #10;
    expect_signal(debug_sprite_mode, 1, "Debug ativado");

    SW[9] = 0;
    #10;
    expect_signal(debug_sprite_mode, 0, "Debug desativado");

    // =========================
    // FINAL
    // =========================
    if (error_count == 0)
        $display("\n==== TODOS OS TESTES PASSARAM ====");
    else
        $display("\n==== %0d ERROS ====", error_count);

    $finish;
end

endmodule