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

// Memórias de referência (carregadas com os mesmos .hex)
reg [3:0] ref_bg0 [0:299];
reg [3:0] ref_bg1 [0:299];
reg [3:0] ref_bg2 [0:299];
reg [3:0] ref_bg3 [0:299];

// Carregar arquivos
initial begin
    $readmemh("bg0.hex", ref_bg0);
    $readmemh("bg1.hex", ref_bg1);
    $readmemh("bg2.hex", ref_bg2);
    $readmemh("bg3.hex", ref_bg3);
end

// Monitoramento
initial begin
    $monitor("t=%0t | sel=%b | x=%d y=%d | bg_val=%d",
              $time, bgdata_sel, bg_x_pos, bg_y_pos, bg_val);
end

// Função de endereço
function [8:0] calc_addr;
    input [4:0] x;
    input [3:0] y;
begin
    calc_addr = ((y << 4) + (y << 2)) + x; // y*20 + x
end
endfunction

// Função para valor esperado
function [3:0] expected_val;
    input [1:0] sel;
    input [8:0] addr;
begin
    case (sel)
        2'b00: expected_val = ref_bg0[addr];
        2'b01: expected_val = ref_bg1[addr];
        2'b10: expected_val = ref_bg2[addr];
        2'b11: expected_val = ref_bg3[addr];
        default: expected_val = 4'd0;
    endcase
end
endfunction

// Task de verificação
task expect_bg;
    input [LABEL_W-1:0] label;
    reg [8:0] addr;
    reg [3:0] expected;
begin
    addr = calc_addr(bg_x_pos, bg_y_pos);
    expected = expected_val(bgdata_sel, addr);

    #1;
    if (bg_val !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | addr=%0d esperado=%0d obtido=%0d",
                  label, addr, expected, bg_val);
    end else begin
        $display("[OK] %0s | addr=%0d valor=%0d",
                  label, addr, bg_val);
    end
end
endtask

// Testes
initial begin
    $display("==== INICIO DA SIMULACAO BG_DATA (COM HEX) ====");

    error_count = 0;

    // Espera carregar memórias
    #10;

    // ==================================================
    // 1. Testes pontuais
    // ==================================================
    $display("\n[TESTE] Pontos fixos");

    bgdata_sel = 2'b00; bg_x_pos = 5'd0;  bg_y_pos = 4'd0;  #5; expect_bg("BG0 (0,0)");
    bgdata_sel = 2'b01; bg_x_pos = 5'd5;  bg_y_pos = 4'd2;  #5; expect_bg("BG1 (5,2)");
    bgdata_sel = 2'b10; bg_x_pos = 5'd10; bg_y_pos = 4'd7;  #5; expect_bg("BG2 (10,7)");
    bgdata_sel = 2'b11; bg_x_pos = 5'd19; bg_y_pos = 4'd14; #5; expect_bg("BG3 (19,14)");

    // ==================================================
    // 2. Teste de bordas
    // ==================================================
    $display("\n[TESTE] Bordas");

    bgdata_sel = 2'b00; bg_x_pos = 5'd19; bg_y_pos = 4'd0;  #5; expect_bg("Topo-direita");
    bgdata_sel = 2'b01; bg_x_pos = 5'd0;  bg_y_pos = 4'd14; #5; expect_bg("Base-esquerda");

    // ==================================================
    // 3. Varredura parcial
    // ==================================================
    $display("\n[TESTE] Varredura parcial");

    repeat (5) begin
        bgdata_sel = $random % 4;
        bg_x_pos   = $random % 20;
        bg_y_pos   = $random % 15;
        #5;
        expect_bg("Random test");
    end

    // ==================================================
    // 4. Troca de banco no mesmo ponto
    // ==================================================
    $display("\n[TESTE] Troca de background");

    bg_x_pos = 5'd3;
    bg_y_pos = 4'd3;

    bgdata_sel = 2'b00; #5; expect_bg("BG0");
    bgdata_sel = 2'b01; #5; expect_bg("BG1");
    bgdata_sel = 2'b10; #5; expect_bg("BG2");
    bgdata_sel = 2'b11; #5; expect_bg("BG3");

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