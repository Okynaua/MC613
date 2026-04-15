module PPU_COMPOSITOR_tb;

reg [4:0] sprite_color_idx, bg_color_idx;
reg videoactive;
wire [4:0] color_idx;

PPU_COMPOSITOR dut(
	.sprite_color_idx(sprite_color_idx),
	.bg_color_idx(bg_color_idx),
	.videoactive(videoactive),
   .color_idx(color_idx)
);

integer errors = 0;

task check;
    input [4:0] expected;
    begin
        #1;
        if (color_idx !== expected) begin
            $display("ERRO: video=%b sprite=%b bg=%b -> esperado=%b obtido=%b",
                     videoactive, sprite_color_idx, bg_color_idx,
                     expected, color_idx);
            errors = errors + 1;
        end else begin
            $display("[OK] video=%b sprite=%b bg=%b -> %b",
                     videoactive, sprite_color_idx, bg_color_idx,
                     color_idx);
        end
    end
endtask

initial begin
    $display("==== INICIO DOS TESTES ====");

    // ================================
    // 1. Sem sprite (sprite = 0)
    // ================================
    videoactive = 1;
    sprite_color_idx = 5'b00000;
    bg_color_idx = 5'b10101;
    check(bg_color_idx);

    // ================================
    // 2. Com sprite (sprite != 0)
    // ================================
    videoactive = 1;
    sprite_color_idx = 5'b01010;
    bg_color_idx = 5'b10101;
    check(sprite_color_idx);

    // ================================
    // 3. Video inativo (sempre 0)
    // ================================
    videoactive = 0;
    sprite_color_idx = 5'b11111;
    bg_color_idx = 5'b10101;
    check(5'b00000);

    // Teste extra (garantia)
    videoactive = 0;
    sprite_color_idx = 5'b00000;
    bg_color_idx = 5'b11111;
    check(5'b00000);

    // ================================
    // Resultado final
    // ================================
    if (errors == 0)
        $display("TODOS OS TESTES PASSARAM ✅");
    else
        $display("TOTAL DE ERROS: %0d ❌", errors);

    $finish;
end

endmodule


