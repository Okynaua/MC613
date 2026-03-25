module outValue_tb;

reg [11:0] productValue_test;
reg [11:0] moneyInserted_test;

wire [11:0] subtraction_test;
wire [10:0] muxOut_test;

outValue uut (
    .productValue(productValue_test),
    .moneyInserted(moneyInserted_test),
    .subtraction(subtraction_test),
    .muxOut(muxOut_test)
);

// Monitoramento contínuo
initial begin
    $monitor("t=%0t | product=%d | money=%d | sub=%d | muxOut=%d",
        $time,
        productValue_test,
        moneyInserted_test,
        subtraction_test,
        muxOut_test
    );
end

integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====\n");

    // Inicialização
    productValue_test = 0;
    moneyInserted_test = 0;

    // 1. Caso básico (sem troco negativo)
    #10;
    $display("\n[TESTE] Sem negativo (produto > dinheiro)");
    productValue_test = 100;
    moneyInserted_test = 30;
    #20;

    // 2. Caso com negativo (troco)
    $display("\n[TESTE] Resultado negativo (troco)");
    productValue_test = 50;
    moneyInserted_test = 100;
    #20;

    // 3. Igualdade
    $display("\n[TESTE] Valores iguais");
    productValue_test = 200;
    moneyInserted_test = 200;
    #20;

    // 4. Variação gradual
    $display("\n[TESTE] Variacao gradual");

    for (i = 0; i < 5; i = i + 1) begin
        productValue_test = i * 50;
        moneyInserted_test = i * 30;
        #20;
    end

    // 5. Valores extremos
    $display("\n[TESTE] Valores extremos");

    productValue_test = 0;
    moneyInserted_test = 2047;
    #20;

    productValue_test = 2047;
    moneyInserted_test = 0;
    #20;

    // 6. Mudanças rápidas
    $display("\n[TESTE] Mudancas rapidas");

    productValue_test = 300;
    moneyInserted_test = 100; #10;

    moneyInserted_test = 400; #10;
    productValue_test = 50;   #10;

    moneyInserted_test = 50;  #10;
    productValue_test = 500;  #10;

    $display("\n==== FIM DA SIMULACAO ====");

    $finish;
end

endmodule