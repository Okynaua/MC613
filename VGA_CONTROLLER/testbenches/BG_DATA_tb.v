module BG_DATA_tb;

// Entradas
reg [1:0] bgdata_sel;
reg [4:0] bg_x_pos;
reg [3:0] bg_y_pos;

// Saída
wire [3:0] bg_val;

integer error_count;
localparam integer LABEL_W = 8*96;

// Instância do DUT
BG_DATA uut (
    .bgdata_sel(bgdata_sel),
    .bg_x_pos(bg_x_pos),
    .bg_y_pos(bg_y_pos),
    .bg_val(bg_val)
);

// Task de verificação
task expect_val;
    input [3:0] observed;
    input [3:0] expected;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (observed !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=%h obtido=%h (t=%0t)", label, expected, observed, $time);
    end else begin
        $display("[OK] %0s | valor=%h", label, observed);
    end
end
endtask

// =========================
// TESTES
// =========================
initial begin
    $display("==== INICIO BG_DATA_tb ====");

    error_count = 0;

    // ==================================================
    // 1. bg0
    // ==================================================
    $display("\n[TESTE] bg0");

    bgdata_sel = 2'b00;

    bg_x_pos = 0; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'h3, "bg0[0,0]");

    bg_x_pos = 5; bg_y_pos = 2; #5;
    expect_val(bg_val, 4'h3, "bg0[5,2]");

    // ==================================================
    // 2. bg1
    // ==================================================
    $display("\n[TESTE] bg1");

    bgdata_sel = 2'b01;

    bg_x_pos = 0; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'hA, "bg1[0,0]");

    bg_x_pos = 3; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'h8, "bg1[3,0]");

    // ==================================================
    // 3. bg2
    // ==================================================
    $display("\n[TESTE] bg2");

    bgdata_sel = 2'b10;

    bg_x_pos = 0; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'h7, "bg2[0,0]");

    bg_x_pos = 2; bg_y_pos = 5; #5;
	 expect_val(bg_val, 4'h7, "bg2[2,5]");

    // ==================================================
    // 4. bg3
    // ==================================================
    $display("\n[TESTE] bg3");

    bgdata_sel = 2'b11;

    bg_x_pos = 0; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'hD, "bg3[0,0]");

    bg_x_pos = 6; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'hC, "bg3[6,0]");

    // ==================================================
    // 5. fora dos limites
    // ==================================================
    $display("\n[TESTE] fora dos limites");

    bgdata_sel = 2'b00;

    bg_x_pos = 20; bg_y_pos = 0; #5;
    expect_val(bg_val, 4'h0, "x fora");

    bg_x_pos = 0; bg_y_pos = 15; #5;
    expect_val(bg_val, 4'h0, "y fora");

    bg_x_pos = 31; bg_y_pos = 15; #5;
    expect_val(bg_val, 4'h0, "x,y fora");

    // ==================================================
    // RESULTADO FINAL
    // ==================================================
    if (error_count == 0) begin
        $display("\n==== TODOS OS TESTES PASSARAM ====");
    end else begin
        $display("\n==== %0d ERROS ====", error_count);
    end

    $finish;
end

endmodule