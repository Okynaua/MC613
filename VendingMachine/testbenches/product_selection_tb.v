module product_selection_tb;

reg clk_test;
reg [3:0] product_test;
reg enable_test;
reg reset_test;

wire [10:0] productValue_test;
wire [6:0] hexCode_test;

product_selection uut (
    .clk(clk_test),
    .product(product_test),
    .enable(enable_test),
    .reset(reset_test),
    .productValue(productValue_test),
    .hexCode(hexCode_test)
);

// Clock
initial begin
    clk_test = 0;
    forever #10 clk_test = ~clk_test;
end

// Monitoramento contínuo
initial begin
    $monitor("t=%0t | clk=%b | reset=%b | enable=%b | product=%d | value=%d | hex=%b",
        $time, clk_test, reset_test, enable_test,
        product_test, productValue_test, hexCode_test);
end

integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====\n");

    // Inicialização
    product_test = 0;
    enable_test = 1;
    reset_test = 0;

    // 1. Escrita de produtos
    $display("\n[TESTE] Escrita de produtos");

    for (i = 0; i < 16; i = i + 1) begin
		  #20
        product_test = i;
    end

    // 2. Mudanca sem enable (não deve alterar registrador)
    #20;
    $display("\n[TESTE] Mudanca sem enable");
	 enable_test = 0;
    for (i = 0; i < 16; i = i + 1) begin
		  #20
        product_test = i;
    end
    #40;

    // 3. Escrita novamente
    $display("\n[TESTE] Escrita com enable");
	 product_test = 4'd7;
    enable_test = 1;
    #20;
    enable_test = 0;

    #20;
    $display("\n==== FIM DA SIMULACAO ====");

    $finish;
end

endmodule