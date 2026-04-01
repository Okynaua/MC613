module outValue_tb;

reg [10:0] productValue_test;
reg [10:0] moneyInserted_test;
reg returnInserted_test; // NOVO

wire subtractionCarry_test;
wire subtractionZero_test;
wire [10:0] muxOut_test;

// Instanciação do módulo
outValue uut (
    .productValue(productValue_test),
    .moneyInserted(moneyInserted_test),
    .returnInserted(returnInserted_test), // NOVO
    .subtractionCarry(subtractionCarry_test),
    .subtractionZero(subtractionZero_test),
    .muxOut(muxOut_test)
);

// Monitoramento automático
initial begin
    $monitor("t=%0t | product=%d | money=%d | return=%b | subCarry=%b | subZero=%b | muxOut=%d",
              $time, productValue_test, moneyInserted_test,
              returnInserted_test,
              subtractionCarry_test, subtractionZero_test, muxOut_test);
end

initial begin
    $display("==== INICIO DA SIMULACAO ====");

    // Inicialização
    productValue_test = 0;
    moneyInserted_test = 0;
    returnInserted_test = 0;

    // 1. Valores iguais
    #10;
    $display("\n[TESTE] Valores iguais (100, 100)");
    productValue_test = 100;
    moneyInserted_test = 100;
    returnInserted_test = 0;
    #20;

    // 2. Dinheiro menor
    $display("\n[TESTE] Dinheiro menor (100 - 30)");
    productValue_test = 100;
    moneyInserted_test = 30;
    returnInserted_test = 0;
    #20;

    // 3. Dinheiro maior (troco)
    $display("\n[TESTE] Dinheiro maior (50 - 120)");
    productValue_test = 50;
    moneyInserted_test = 120;
    returnInserted_test = 0;
    #20;

    // 4. Ambos zero
    $display("\n[TESTE] Ambos zero");
    productValue_test = 0;
    moneyInserted_test = 0;
    returnInserted_test = 0;
    #20;

    // 5. Overflow
    $display("\n[TESTE] Overflow");
    productValue_test = 2047;
    moneyInserted_test = 0;
    returnInserted_test = 0;
    #20;

    // 6. Underflow
    $display("\n[TESTE] Underflow");
    productValue_test = 0;
    moneyInserted_test = 2047;
    returnInserted_test = 0;
    #20;

    // 7. Retornar dinheiro inserido
    $display("\n[TESTE] returnInserted = 1 (deve devolver money)");
    productValue_test = 100;
    moneyInserted_test = 80;
    returnInserted_test = 1;
    #20;

    $display("\n==== FIM DA SIMULACAO ====");
    $finish;
end

endmodule