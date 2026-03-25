module multiplexer_tb;

reg selector_test;
reg [10:0] value_test;
reg [10:0] negValue_test;

wire [10:0] outValue_test;

multiplexer uut (
    .selector(selector_test),
    .Value(value_test),
    .NegValue(negValue_test),
    .outValue(outValue_test)
);

// Monitoramento contínuo
initial begin
    $monitor("t=%0t | sel=%b | Value=%d | NegValue=%d | out=%d",
        $time, selector_test, value_test, negValue_test, outValue_test);
end

integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====\n");

    // Inicialização
    selector_test = 0;
    value_test = 0;
    negValue_test = 0;

    // 1. Teste básico selector = 0
    #10;
    $display("\n[TESTE] selector = 0 (deve escolher Value)");
    value_test = 11'd25;
    negValue_test = 11'd100;
    selector_test = 0;
    #20;

    // 2. Teste selector = 1
    $display("\n[TESTE] selector = 1 (deve escolher NegValue)");
    selector_test = 1;
    #20;

    // 3. Variação de valores com selector fixo
    $display("\n[TESTE] Variando entradas com selector = 0");
    selector_test = 0;

    for (i = 0; i < 5; i = i + 1) begin
        value_test = i * 10;
        negValue_test = i * 100;
        #20;
    end


    $display("\n==== FIM DA SIMULACAO ====");

    $finish;
end

endmodule