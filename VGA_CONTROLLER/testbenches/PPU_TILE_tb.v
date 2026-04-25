module PPU_TILE_tb;

reg [3:0] bg_value;
reg [9:0] x_pos;
reg [8:0] y_pos;
wire [4:0] bg_color_idx;

reg [4:0] expected [0:16383];

integer errors = 0;
integer addr;
integer i;

PPU_TILE dut (
    .bg_value(bg_value),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .bg_color_idx(bg_color_idx)
);

task check;		// Definindo laço de teste
    input [4:0] expected_val;
    begin
      #1;
      if (bg_color_idx !== expected_val) begin
            $display("[ERRO] tile=%h (x=%0d, y=%0d) esperado=%h obtido=%h", bg_value, x_pos, y_pos, expected_val, bg_color_idx);
            errors = errors + 1;
      end else begin
            $display("[OK] tile=%h (x=%0d, y=%0d) val=%h", bg_value, x_pos, y_pos, bg_color_idx);
      end
    end
endtask 

initial begin
    $display("==== TESTE PPU_TILE MULTI ====");
	 
    $readmemh("tiles/tile0.hex", expected, 0,     1023);
    $readmemh("tiles/tile1.hex", expected, 1024,  2047);
    $readmemh("tiles/tile2.hex", expected, 2048,  3071);
    $readmemh("tiles/tile3.hex", expected, 3072,  4095);
    $readmemh("tiles/tile4.hex", expected, 4096,  5119);
    $readmemh("tiles/tile5.hex", expected, 5120,  6143);
    $readmemh("tiles/tile6.hex", expected, 6144,  7167);
    $readmemh("tiles/tile7.hex", expected, 7168,  8191);
    $readmemh("tiles/tile8.hex", expected, 8192,  9215);
    $readmemh("tiles/tile9.hex", expected, 9216,  10239);
    $readmemh("tiles/tileA.hex", expected, 10240, 11263);
    $readmemh("tiles/tileB.hex", expected, 11264, 12287);
    $readmemh("tiles/tileC.hex", expected, 12288, 13311);
    $readmemh("tiles/tileD.hex", expected, 13312, 14335);
    $readmemh("tiles/tileE.hex", expected, 14336, 15359);
    $readmemh("tiles/tileF.hex", expected, 15360, 16383);
    
    #10;
    
    for (i = 0; i < 16; i = i + 1) begin
      bg_value = i;
      // Teste das bordas inferiores
      x_pos = 0;
      y_pos = 0;
      
      addr = (i * 1024) + ((y_pos & 31) * 32) + (x_pos & 31);
      check(expected[addr]);

      // Teste de numeros intermediarios
      x_pos = 10;
      y_pos = 5;
      
      addr = (i * 1024) + ((y_pos & 31) * 32) + (x_pos & 31);
      check(expected[addr]);

      // Testes de valores que estrapolam o tile
      x_pos = 100; // 100 & 31 = 4
      y_pos = 50;  // 50 & 31 = 18
      
      addr = (i * 1024) + ((y_pos & 31) * 32) + (x_pos & 31);
      check(expected[addr]);

    end

    // Imprimindo resultado
    if (errors == 0)
      $display("TODOS OS TESTES PASSARAM");
    else
      $display("TOTAL DE ERROS: %0d", errors);

    $finish;
end

endmodule