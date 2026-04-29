module PPU_COLOR_LUT_tb;

reg [4:0] color_idx;
wire [7:0] r_ch, g_ch, b_ch;

// Instancia o DUT
PPU_COLOR_LUT dut (
    .color_idx(color_idx),
    .r_ch(r_ch),
    .g_ch(g_ch),
    .b_ch(b_ch)
);

reg [23:0] expected_colors [0:31];

integer i;

initial begin
    $readmemh("colors.hex", expected_colors);

	 $display("
    // Loop testando todos os índices
    for (i = 0; i < 32; i = i + 1) begin
        color_idx = i;
        #5; // espera propagação

        if ({r_ch, g_ch, b_ch} !== expected_colors[i]) begin
            $display("ERRO em idx %0d: esperado=%h, obtido=%h",
                     i, expected_colors[i], {r_ch, g_ch, b_ch});
        end else begin
            $display("[OK] idx %0d: %h", i, expected_colors[i]);
        end
    end

    $display("Teste finalizado");
    $finish;
end

endmodule