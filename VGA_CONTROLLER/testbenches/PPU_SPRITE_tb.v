module PPU_SPRITE_tb;

reg [5:0] sprite_idx;
reg [9:0] sprite_x_pos; 
reg [8:0] sprite_y_pos;
reg [9:0] x_pos;
reg [8:0] y_pos;
reg debug_mode;

wire [4:0] sprite_color_idx;

reg [4:0] expected [0:32767];

PPU_SPRITE dut (
    .sprite_idx(sprite_idx),
    .sprite_x_pos(sprite_x_pos),
    .sprite_y_pos(sprite_y_pos),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .debug_mode(debug_mode),
    .sprite_color_idx(sprite_color_idx)
);

reg [8*100:1] filename;
integer errors = 0;
integer addr;
integer i;
integer j;

task check;
	input [4:0] expected_val;
	begin
	  #1;
	  if (sprite_color_idx !== expected_val) begin
			$display("[ERRO] sprite=%0d esperado=%h obtido=%h", sprite_idx, expected_val, sprite_color_idx);
			errors = errors + 1;
	  end else begin
			$display("[OK] sprite=%0d val=%h", sprite_idx, sprite_color_idx);
	  end
	end
endtask 

initial begin
    $display("==== TESTE PPU_SPRITE MULTI ====");
    
    debug_mode = 0; 
	 
    $readmemh("sprites/sprite0.hex", expected, 0,     1023);
    $readmemh("sprites/sprite1.hex", expected, 1024,  2047);
    $readmemh("sprites/sprite2.hex", expected, 2048,  3071);
    $readmemh("sprites/sprite3.hex", expected, 3072,  4095);
    $readmemh("sprites/sprite4.hex", expected, 4096,  5119);
    $readmemh("sprites/sprite5.hex", expected, 5120,  6143);
    $readmemh("sprites/sprite6.hex", expected, 6144,  7167);
    $readmemh("sprites/sprite7.hex", expected, 7168,  8191);
    $readmemh("sprites/sprite8.hex", expected, 8192,  9215);
    $readmemh("sprites/sprite9.hex", expected, 9216,  10239);
    $readmemh("sprites/spriteA.hex", expected, 10240, 11263);
    $readmemh("sprites/spriteB.hex", expected, 11264, 12287);
    $readmemh("sprites/spriteC.hex", expected, 12288, 13311);
    $readmemh("sprites/spriteD.hex", expected, 13312, 14335);
    $readmemh("sprites/spriteE.hex", expected, 14336, 15359);
    $readmemh("sprites/spriteF.hex", expected, 15360, 16383);
    $readmemh("sprites/sprite10.hex", expected, 16384, 17407);
    $readmemh("sprites/sprite11.hex", expected, 17408, 18431);
    $readmemh("sprites/sprite12.hex", expected, 18432, 19455);
    $readmemh("sprites/sprite13.hex", expected, 19456, 20479);
    $readmemh("sprites/sprite14.hex", expected, 20480, 21503);
    $readmemh("sprites/sprite15.hex", expected, 21504, 22527);
    $readmemh("sprites/sprite16.hex", expected, 22528, 23551);
    $readmemh("sprites/sprite17.hex", expected, 23552, 24575);
    $readmemh("sprites/sprite18.hex", expected, 24576, 25599);
    $readmemh("sprites/sprite19.hex", expected, 25600, 26623);
    $readmemh("sprites/sprite1A.hex", expected, 26624, 27647);
    $readmemh("sprites/sprite1B.hex", expected, 27648, 28671);
    $readmemh("sprites/sprite1C.hex", expected, 28672, 29695);
    $readmemh("sprites/sprite1D.hex", expected, 29696, 30719);
    $readmemh("sprites/sprite1E.hex", expected, 30720, 31743);
    $readmemh("sprites/sprite1F.hex", expected, 31744, 32767);
    
    #10;

    for (j = 0; j < 32768; j = j + 1) begin
      dut.sprites[j] = expected[j];
    end

	sprite_x_pos = 100;
	sprite_y_pos = 50;

	for (sprite_idx = 0; sprite_idx < 32; sprite_idx = sprite_idx + 1) begin

	  // -------------------------
	  // (0,0)
	  // -------------------------
	  x_pos = 100;
	  y_pos = 50;

	  addr = (sprite_idx * 1024) + 0;
	  check(expected[addr]);

	  // -------------------------
	  // (10,5)
	  // -------------------------
	  x_pos = 110;
	  y_pos = 55;

	  addr = (sprite_idx * 1024) + (5 * 32) + 10;
	  check(expected[addr]);

	  // -------------------------
	  // (31,31)
	  // -------------------------
	  x_pos = 131;
	  y_pos = 81;

	  addr = (sprite_idx * 1024) + (31 * 32) + 31;
	  check(expected[addr]);

	end

	// ===============================
	// Resultado
	// ===============================
	if (errors == 0)
	  $display("TODOS OS TESTES PASSARAM");
	else
	  $display("TOTAL DE ERROS: %0d", errors);

	$finish;
end

endmodule