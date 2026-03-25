module bin2decimal_tb;

reg [10:0] bin_test;

wire [6:0] hex3_test;
wire [6:0] hex2_test;
wire [6:0] hex1_test;
wire [6:0] hex0_test;

bin2decimal uut (
    .bin(bin_test),
    .hex3(hex3_test),
    .hex2(hex2_test),
    .hex1(hex1_test),
    .hex0(hex0_test)
);

// Monitoramento contínuo
initial begin
    $monitor("t=%0t | BIN: %d | HEX: %b %b %b %b",
        $time, bin_test,
        hex3_test, hex2_test, hex1_test, hex0_test);
end

integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====\n");

    // Inicialização
    bin_test = 0;

    // 1. Teste sequencial de todos os valores
    $display("[TESTE] Valores sequenciais");
    for (i = 0; i <= 2047; i = i + 1) begin
        bin_test = i;
        #10;
    end

    $display("\n==== FIM DA SIMULACAO ====");

    $finish;
end

endmodule