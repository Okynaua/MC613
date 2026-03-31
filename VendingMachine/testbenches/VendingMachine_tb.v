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

    // ==================================================
    // 6. Teste com múltiplos valores seguidos
    // ==================================================
    #20;
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
    $display("\n==== FIM DA SIMULACAO ====");
    $finish;
end

endmodule