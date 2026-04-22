module PPU_SPRITE_tb;

reg [5:0] sprite_idx;
reg [4:0] sprite_x_pos;
reg [3:0] sprite_y_pos;
reg [9:0] x_pos;
reg [8:0] y_pos;

wire [4:0] sprite_color_idx;

// DUT
PPU_SPRITE dut (
    .sprite_idx(sprite_idx),
    .sprite_x_pos(sprite_x_pos),
    .sprite_y_pos(sprite_y_pos),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .sprite_color_idx(sprite_color_idx)
);

integer errors = 0;

// tarefa de checagem
task check;
    input [4:0] expected;
    begin
        #1;
        if (sprite_color_idx !== expected) begin
            $display("ERRO: esperado=%b obtido=%b", expected, sprite_color_idx);
            errors = errors + 1;
        end else begin
            $display("[OK]: %b", sprite_color_idx);
        end
    end
endtask

initial begin
    $display("==== INICIO DOS TESTES SPRITE ====");

    // =========================================
    // Setup manual da memória (evita depender do .hex)
    // Vamos usar sprite_idx = 0
    // =========================================

    // pixel (0,0) do sprite -> valor 5'b10101
    dut.sprites[0] = 5'b10101;

    // pixel (1,0) -> valor 5'b01010
    dut.sprites[1] = 5'b01010;

    sprite_idx = 0;
    sprite_x_pos = 5;
    sprite_y_pos = 5;

    // =========================================
    // 1. Pixel COM sprite (dentro da área)
    // =========================================
    // posição exatamente no topo esquerdo do sprite
    x_pos = 5;
    y_pos = 5;

    check(5'b10101);

    // outro pixel dentro do sprite
    x_pos = 6; // deslocamento x = 1
    y_pos = 5;

    check(5'b01010);

    // =========================================
    // 2. Pixel SEM sprite (fora da área)
    // =========================================
    // posição fora do sprite (antes dele)
    x_pos = 0;
    y_pos = 0;

    check(5'b00000);

    // posição fora (depois dele)
    x_pos = 20;
    y_pos = 20;

    check(5'b00000);

    // =========================================
    // Resultado final
    // =========================================
    if (errors == 0)
        $display("TODOS OS TESTES PASSARAM ✅");
    else
        $display("TOTAL DE ERROS: %0d ❌", errors);

    $finish;
end

endmodule