module PPU_SPRITE_tb;

reg [5:0] sprite_idx;
reg [4:0] sprite_x_pos;
reg [3:0] sprite_y_pos;
reg [9:0] x_pos;
reg [8:0] y_pos;

wire [4:0] sprite_color_idx;

reg [4:0] expected [0:32767];

PPU_SPRITE #(.IS_SIMULACAO(1)) dut (
    .sprite_idx(sprite_idx),
    .sprite_x_pos(sprite_x_pos),
    .sprite_y_pos(sprite_y_pos),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .sprite_color_idx(sprite_color_idx)
);

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
	
	for (i = 0; i < 32; i = i + 1) begin
	  $readmemh($sformatf("sprite%0d.hex", i), expected, i*1024, (i+1)*1024 - 1);
	end

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