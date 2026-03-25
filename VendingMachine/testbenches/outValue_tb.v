module outValue_tb;

reg [10:0] productValue_test;
reg [10:0] moneyInserted_test;
wire subtractionCarry_test;
wire subtractionZero_test;
wire [10:0] muxOut_test;

// Instanciação do módulo
outValue uut (
    .productValue(productValue_test),
    .moneyInserted(moneyInserted_test),
    .subtractionCarry(subtractionCarry_test),
    .subtractionZero(subtractionZero_test),
    .muxOut(muxOut_test)
);

// Monitoramento automático
initial begin
    $monitor("t=%0t | product=%d | money=%d | subCarry=%b | subZero=%b | muxOut=%d",
              $time, productValue_test, moneyInserted_test,
              subtractionCarry_test, subtractionZero_test, muxOut_test);
end

initial begin
    $display("==== INICIO DA SIMULACAO ====");

    // Inicialização
    productValue_test = 0;
    moneyInserted_test = 0;

    // 1. Caso: valores iguais → resultado zero
    #10;
    $display("\n[TESTE] Valores iguais (produto = 100, dinheiro = 100)");
    productValue_test = 12'd100;
    moneyInserted_test = 12'd100;
    #20;

    // 2. Caso: dinheiro menor → resultado positivo
    $display("\n[TESTE] Dinheiro menor que produto (100 - 30)");
    productValue_test = 12'd100;
    moneyInserted_test = 12'd30;
    #20;

    // 3. Caso: dinheiro maior → resultado negativo (troco)
    $display("\n[TESTE] Dinheiro maior que produto (50 - 120)");
    productValue_test = 12'd50;
    moneyInserted_test = 12'd120;
    #20;

    // 4. Teste de borda: zero absoluto
    $display("\n[TESTE] Ambos zero");
    productValue_test = 12'd0;
    moneyInserted_test = 12'd0;
    #20;

    // 5. Overflow
    $display("\n[TESTE] Overflow");
    productValue_test = 12'd2047;
    moneyInserted_test = 12'd0;
    #20;

    // 6. Underflow
    $display("\n[TESTE] Underflow");
    productValue_test = 12'd0;
    moneyInserted_test = 12'd2047;
    #20;

    $display("\n==== FIM DA SIMULACAO ====");
    $finish;
end

endmodule