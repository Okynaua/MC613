module VendingMachine_tb;

// Entradas
reg CLOCK_50;
reg [9:0] SW;
reg [1:0] KEY;

// Saídas
wire [6:0] HEX3;
wire [6:0] HEX2;
wire [6:0] HEX1;
wire [6:0] HEX0;
wire [6:0] HEX5; 
wire [1:0] LEDR;

// Instância do DUT
VendingMachine uut (
    .CLOCK_50(CLOCK_50),
    .SW(SW),
    .KEY(KEY),
    .HEX3(HEX3),
    .HEX2(HEX2),
    .HEX1(HEX1),
    .HEX0(HEX0),
    .HEX5(HEX5),
    .LEDR(LEDR)
);

// Clock 50 MHz → período 20ns
initial begin
    CLOCK_50 = 0;
    forever #10 CLOCK_50 = ~CLOCK_50;
end

// Monitoramento
initial begin
    $monitor("t=%0t | SW=%b | KEY=%b | LEDR=%b | HEX5=%b",
              $time, SW, KEY, LEDR, HEX5);
end

// Testes
initial begin
    $display("==== INICIO DA SIMULACAO ====");

    // Inicialização
    SW = 0;
    KEY = 2'b11; // botões não pressionados (ativo em 0 normalmente)

    // ==================================================
    // 1. Reset inicial (via cancel)
    // ==================================================
    #20;
    $display("\n[TESTE] Reset via botao cancelar");
    KEY[1] = 0; // cancelar pressionado
    #20;
    KEY[1] = 1;
	 #50000000;

    // ==================================================
    // 2. Seleção de produto
    // ==================================================
    #20;
    $display("\n[TESTE] Selecionando produto (SW[3:0] = 3)");
    SW[3:0] = 4'b0011;

    // Pressiona avançar para registrar produto
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 3. Inserindo dinheiro
    // ==================================================
    #20;
    $display("\n[TESTE] Inserindo dinheiro");

    // Exemplo: 100000 (nota maior)
    #20;
    SW[9:4] = 6'b100000;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // Mais dinheiro
    #20;
    SW[9:4] = 6'b000001;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 4. Teste de pagamento completo
    // ==================================================
    #20;
    $display("\n[TESTE] Continuando insercao ate pagamento");

    #20;
    SW[9:4] = 6'b000010;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 5. Cancelamento no meio da operacao
    // ==================================================
    #40;
    $display("\n[TESTE] Cancelando operacao");
    KEY[1] = 0;
    #20;
    KEY[1] = 1;
	 #50000000

    // ==================================================
    // 6. Teste com múltiplos valores seguidos
    // ==================================================
    $display("\n[TESTE] Inserindo varios valores seguidos");

    SW[9:4] = 6'b010000;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    #20;
    SW[9:4] = 6'b001000;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    #20;
    SW[9:4] = 6'b000100;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 7. Teste de erro (index inválido)
    // ==================================================
    #20;
    $display("\n[TESTE] Index invalido");

    SW[9:4] = 6'b000000;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    #20;
    SW[9:4] = 6'b110000;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 8. Pagamento exato do produto 1(R$3) em 3xR$1
    // ==================================================

	 #20;
	 KEY[1] = 0;
	 #20;
	 KEY[1] = 1;
	 #50000000
    #20;
    $display("\nPagamento exato produto 1");

    //Seleção
    SW[3:0] = 4'b0001;
    KEY[0] = 0;
    #20;
    KEY[1] = 1;

    //Pagamento
    #20;
    SW[9:4] = 6'b010000;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 9. Pagamento com troco do produto 3(R$4,50) em 3xR$2,00
    // ==================================================

    #20;
    $display("\nPagamento com troco produto 3");

    //Seleção
    SW[3:0] = 4'b0011;
    KEY[0] = 0;
    #20;
    KEY[1] = 1;

    //Pagamento
    #20;
    SW[9:4] = 6'b100000;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;

    // ==================================================
    // 10. Cancelamento do produto A
    // ==================================================

    #20;
    $display("\nCancelamento do produto A");

    //Seleção
    SW[3:0] = 4'b1010;
    KEY[0] = 0;
    #20;
    KEY[1] = 1;

    //Cancelamento com um troquinho
    #20;
    SW[9:4] = 6'b000001;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;
    #20;
    KEY[1] = 0;
    #20;
    KEY[1] = 1;

    // ==================================================
    // 11. aleterar produto e inserções simultâneas
    // ==================================================

    #20;
    $display("\nConfesso que não entendi o que é pra fazer aqui");

    //Seleção
    SW[3:0] = 4'b1010;
    #20;
    SW[3:0] = 4'b1001;
    #20;
    SW[3:0] = 4'b1000;
    #20;
    SW[3:0] = 4'b0111;
    #20;
    SW[3:0] = 4'b0110;
    #20;
    SW[3:0] = 4'b0101;
    #20;
    SW[3:0] = 4'b0100;
    KEY[0] = 0;
    #20;
    KEY[1] = 1;

    //inserções
    #20;
    SW[9:4] = 6'b000001;
    SW[9:4] = 6'b000010;
    SW[9:4] = 6'b000100;
    SW[9:4] = 6'b001000;
    SW[9:4] = 6'b010000;
    SW[9:4] = 6'b100000;
    #20;
    KEY[0] = 0;
    #20;
    KEY[0] = 1;
    #20;
    KEY[1] = 0;
    #20;
    KEY[1] = 1;

    // ==================================================
    $display("\n==== FIM DA SIMULACAO ====");
    $finish;
end

endmodule