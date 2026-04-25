`timescale 1ns / 1ps
module VGA_CONTROLLER_tb;
    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;

    wire [9:0] LEDR;
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire VGA_BLANK_N;
    wire VGA_SYNC_N;
    wire VGA_HS;
    wire VGA_VS;
    wire VGA_CLK;

    // Variáveis auxiliares
    integer initial_x, initial_y;
    integer new_x, new_y;
    integer errors = 0;
	 
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

    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Tarefa para capturar posiçao do sprite0
    task read_sprite0_pos;
        output [9:0] captured_x;
        output [8:0] captured_y;
        integer timeout;
        begin
            timeout = 0;   
            while (!(dut.ppu_oam_write_en == 1'b1 && dut.ppu_oam_sel == 4'd0) && timeout < 20000000) begin
                #10;
                timeout = timeout + 10;
            end           
            if (timeout >= 20000000) begin
                $display("  [AVISO] Timeout! O Controller nao acionou o write_en. Lendo os valores parados no fio...");
            end           
            captured_x = dut.ppu_oam_sx;
            captured_y = dut.ppu_oam_sy;
            #50; 
        end
    endtask

    initial begin
        $display("==== INICIANDO SIMULACAO DO VGA_CONTROLLER ====");

        // estado Inicial
        KEY = 4'b1111; // Botões não pressionados
        SW  = 10'b0;

        // reset
        #100;
        KEY[0] = 1'b0; 
        #200;
        KEY[0] = 1'b1; 
        
        $display("[INFO] Reset aplicado. Aguardando lock do PLL...");
        
        // Aguarda estabilização do PLL
        #5000;
        if (LEDR[0]) 
            $display("[OK] PLL estabilizado (LEDR[0] = 1).");
        else 
            $display("[AVISO] PLL ainda nao estabilizou, simulacao pode falhar.");

        // capturando posiçao do sprite
        $display("\n[INFO] Capturando posicao inicial do Sprite 0...");
        read_sprite0_pos(initial_x, initial_y);
        $display("[INFO] Posicao Inicial -> X: %0d, Y: %0d", initial_x, initial_y);

        // movendo
        $display("\n[INFO] Apertando botao para a Direita (KEY[1])...");
        KEY[1] = 1'b0;
        
        // Esperando
        #17000000;     
        KEY[1] = 1'b1;

        $display("[INFO] Lendo nova posicao...");
        read_sprite0_pos(new_x, new_y);
        
        if (new_x > initial_x && new_y == initial_y) begin
            $display("[OK] Sprite moveu para a direita com sucesso! Novo X: %0d", new_x);
        end else begin
            $display("[ERRO] Falha no movimento para a direita. X obtido: %0d, Y obtido: %0d", new_x, new_y);
            errors = errors + 1;
        end

        // Atualiza a referência para o próximo teste
        initial_x = new_x;
        initial_y = new_y;

        // Movendo para o outro lado
        $display("\n[INFO] Apertando botao para Esquerda (KEY[2])...");
        KEY[2] = 1'b0;
        
        #17000000;
        KEY[2] = 1'b1;
        $display("[INFO] Lendo nova posicao...");
        read_sprite0_pos(new_x, new_y);

        if (new_x < initial_x && new_y == initial_y) begin
            $display("[OK] Sprite moveu para a esquerda com sucesso! Novo X: %0d", new_x);
        end else begin
            $display("[ERRO] Falha no movimento para baixo. Y obtido: %0d, X obtido: %0d", new_y, new_x);
            errors = errors + 1;
        end

        // ===============================
        // Resultado Final
        // ===============================
        $display("\n================================================");
        if (errors == 0)
            $display("TODOS OS TESTES DE MOVIMENTO PASSARAM!");
        else
            $display("TOTAL DE ERROS: %0d", errors);
        $display("================================================\n");

        $finish;
    end

endmodule