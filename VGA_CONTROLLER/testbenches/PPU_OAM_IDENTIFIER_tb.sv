module PPU_OAM_IDENTIFIER_tb;

// Entradas
reg [9:0] x;
reg [8:0] y;
reg [24:0] reg_bank [0:15];

// Saída
wire [5:0] sprite_idx;

integer error_count;
localparam integer LABEL_W = 8*96;

// Instância do DUT
PPU_OAM_IDENTIFIER uut (
    .x(x),
    .y(y),
    .reg_bank(reg_bank),
    .sprite_idx(sprite_idx)
);

// Monitoramento
initial begin
    $monitor("t=%0t | x=%d y=%d | sprite_idx=%d",
              $time, x, y, sprite_idx);
end

// Task de verificação
task expect_signal;
    input [5:0] observed;
    input [5:0] expected;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (observed !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=%d obtido=%d (t=%0t)", label, expected, observed, $time);
    end else begin
        $display("[OK] %0s | valor=%d", label, observed);
    end
end
endtask

// Inicialização da memória
task clear_reg_bank;
    integer i;
begin
    for (i = 0; i < 16; i = i + 1) begin
        reg_bank[i] = 25'd0;
    end
end
endtask

// Testes
initial begin
    $display("==== INICIO DA SIMULACAO PPU_OAM_IDENTIFIER ====");

    error_count = 0;
    clear_reg_bank();

    // ==================================================
    // 1. Nenhum sprite ativo
    // ==================================================
    $display("\n[TESTE] Nenhum sprite ativo");

    x = 10'd100;
    y = 9'd100;

    #5;
    expect_signal(sprite_idx, 6'd0, "Sem sprite ativo");

    // ==================================================
    // 2. Um sprite ativo
    // ==================================================
    $display("\n[TESTE] Um sprite ativo");

    // Sprite 0: posição (50,50), ID = 3
    reg_bank[0][9:0]   = 10'd50;   // s_x
    reg_bank[0][18:10] = 9'd50;    // s_y
    reg_bank[0][24:19] = 6'd3;     // ID

    x = 10'd60;
    y = 9'd60;

    #5;
    expect_signal(sprite_idx, 6'd3, "Dentro do sprite 0");

    // ==================================================
    // 3. Fora do sprite
    // ==================================================
    $display("\n[TESTE] Fora do sprite");

    x = 10'd10;
    y = 9'd10;

    #5;
    expect_signal(sprite_idx, 6'd0, "Fora de qualquer sprite");

    // ==================================================
    // 4. Múltiplos sprites (prioridade = último válido)
    // ==================================================
    $display("\n[TESTE] Multiplos sprites sobrepostos");

    // Sprite 1: mesma área, ID = 5
    reg_bank[1][9:0]   = 10'd50;
    reg_bank[1][18:10] = 9'd50;
    reg_bank[1][24:19] = 6'd5;

    x = 10'd60;
    y = 9'd60;

    #5;
    expect_signal(sprite_idx, 6'd5, "Sprite mais prioritario (ultimo no loop)");

    // ==================================================
    // 5. Teste de borda (limite do sprite)
    // ==================================================
    $display("\n[TESTE] Borda do sprite");

    // Sprite 2: posição (100,100), ID = 7
    reg_bank[2][9:0]   = 10'd100;
    reg_bank[2][18:10] = 9'd100;
    reg_bank[2][24:19] = 6'd7;

    // Dentro (limite inferior)
    x = 10'd100;
    y = 9'd100;

    #5;
    expect_signal(sprite_idx, 6'd7, "Borda inclusiva inferior");

    // Fora (limite superior)
    x = 10'd132; // 100 + 32
    y = 9'd132;

    #5;
    expect_signal(sprite_idx, 6'd0, "Borda superior exclusiva");

    // ==================================================
    // Resultado final
    // ==================================================
    if (error_count == 0) begin
        $display("\n==== FIM DA SIMULACAO: TODOS OS TESTES PASSARAM ====");
    end else begin
        $display("\n==== FIM DA SIMULACAO: %0d FALHAS ====", error_count);
    end

    $finish;
end

endmodule