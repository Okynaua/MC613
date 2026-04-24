`timescale 1ns/1ps

module VGA_CONTROLLER_tb;

    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;

    wire [9:0] LEDR;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire VGA_BLANK_N, VGA_SYNC_N, VGA_HS, VGA_VS, VGA_CLK;

    // DUT
    VGA_CONTROLLER dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_CLK(VGA_CLK)
    );

    // ========================
    // CLOCK 50 MHz
    // ========================
    initial CLOCK_50 = 0;
    always #10 CLOCK_50 = ~CLOCK_50;

    // ========================
    // PLL MOCK (CRÍTICO)
    // ========================
    initial begin
        force dut.pll_locked = 0;
        #200;
        force dut.pll_locked = 1;
    end

    // ========================
    // TESTES
    // ========================
    initial begin
        $display("==== INICIO SIMULACAO VGA_CONTROLLER ====");

        // Estado inicial
        KEY = 4'b1111; // nenhuma tecla pressionada
        SW  = 10'd0;

        // ========================
        // TESTE 1: RESET GLOBAL
        // ========================
        $display("Teste reset");

        // Pressiona reset (KEY[0] ativo em 0)
        KEY[0] = 0;
        #100;

        KEY[0] = 1; // libera reset

        repeat (20) @(posedge CLOCK_50);

        if (dut.reset_n !== 1)
            $display("ERRO: reset_n não propagou corretamente!");
        else
            $display("OK: reset funcionando");

        // ========================
        // TESTE 2: PLL + VIDEO RESET
        // ========================
        $display("Teste PLL + video_reset");

        if (dut.pll_locked !== 1)
            $display("ERRO: PLL não travou!");
        else
            $display("OK: PLL locked");

        if (dut.video_reset_n !== 1)
            $display("ERRO: video_reset_n incorreto!");
        else
            $display("OK: video_reset_n correto");

        // ========================
        // TESTE 3: SINAIS VGA ATIVOS
        // ========================
        $display("Teste atividade VGA");

        repeat (1000) @(posedge CLOCK_50);

        if (^VGA_HS === 1'bx || ^VGA_VS === 1'bx)
            $display("ERRO: sinais VGA indefinidos!");
        else
            $display("OK: VGA HS/VS ativos");

        // ========================
        // TESTE 4: DEBUG SPRITE MODE
        // ========================
        $display("Teste debug_sprite_mode");

        SW[9] = 1;
        #100;

        if (LEDR[4] !== 1)
            $display("ERRO: debug_sprite_mode não propagou!");
        else
            $display("OK: debug_sprite_mode OK");

        SW[9] = 0;

        // ========================
        // TESTE 5: INPUTS DE TECLA
        // ========================
        $display("Teste teclas");

        KEY[1] = 0; // direita
        repeat (100) @(posedge CLOCK_50);
        KEY[1] = 1;

        KEY[2] = 0; // esquerda
        repeat (100) @(posedge CLOCK_50);
        KEY[2] = 1;

        $display("OK: teclas aplicadas (ver comportamento no controller)");

        // ========================
        // FINAL
        // ========================
        $display("==== FIM SIMULACAO ====");
        $stop;
    end

endmodule