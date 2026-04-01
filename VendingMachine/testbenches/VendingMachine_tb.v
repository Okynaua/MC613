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

integer error_count;
localparam integer LABEL_W = 8*96;

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
    $monitor("t=%0t | SW=%b | KEY=%b | LEDR=%b | HEX5=%b | HEX0=%b | HEX1=%b | HEX2=%b | HEX3=%b",
              $time, SW, KEY, LEDR, HEX5, HEX0, HEX1, HEX2, HEX3);
end


// Task para observar se o sinal é o esperado
task expect_signal;
    input [6:0] observed;
    input [6:0] expected;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (observed !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=%b obtido=%b (t=%0t)", label, expected, observed, $time);
    end else begin
        $display("[OK] %0s | valor=%b", label, observed);
    end
end
endtask

// Task para pressionar avançar
task press_advance;
begin
    @(negedge CLOCK_50);
    KEY[0] = 1;
    @(negedge CLOCK_50);
    KEY[0] = 0;
end
endtask

// Task para pressionar cancelar
task press_cancel;
begin
    @(negedge CLOCK_50);
    KEY[1] = 1;
    @(negedge CLOCK_50);
    KEY[1] = 0;
end
endtask

// Testes
initial begin
    $display("==== INICIO DA SIMULACAO ====");

    // Inicialização
    SW = 0;
    KEY = 2'b11; // botões não pressionados (ativos em 0)
    error_count = 0;

    // ==================================================
    // 1. Seleção de produto
    // ==================================================
    #20;
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = 5)");
    SW[3:0] = 4'b0101;
	 #40;
	 expect_signal(HEX5, 7'b0010010, "HEX5 com produto 5");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = 8)");
    SW[3:0] = 4'b1000;
	 #40;
	 expect_signal(HEX5, 7'b0000000, "HEX5 com produto 8");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = B)");
    SW[3:0] = 4'b1011;
	 #40;
	 expect_signal(HEX5, 7'b0000011, "HEX5 com produto B");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = F)");
    SW[3:0] = 4'b1111;
	 #40;
	 expect_signal(HEX5, 7'b0001110, "HEX5 com produto F");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = 3)");
    SW[3:0] = 4'b0011;
	 #40;
	 expect_signal(HEX5, 7'b0110000, "HEX5 com produto 3");

	 $display("\n[TESTE] Pressiona avancar para registrar produto");
	 press_advance();

    $display("Selecionando outro produto (SW[3:0] = B)");
    SW[3:0] = 4'b1011;
	 #40;
	 expect_signal(HEX5, 7'b0110000, "HEX5 com produto 3");
	 
	 $display("\n[TESTE] Pressiona cancelar para registrar outro produto");
	 press_cancel();
	 
    $display("Selecionando outro produto (SW[3:0] = B)");
    SW[3:0] = 4'b1011;
	 #40;
	 expect_signal(HEX5, 7'b0000011, "HEX5 com produto B");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = 3)");
    SW[3:0] = 4'b0011;
	 #40;
	 expect_signal(HEX5, 7'b0110000, "HEX5 com produto 3");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = F)");
    SW[3:0] = 4'b1111;
	 #40;
	 expect_signal(HEX5, 7'b0001110, "HEX5 com produto F");
	 
	 $display("\n[TESTE] Pressiona avancar para registrar produto");
	 press_advance();

    // ==================================================
    // 2. Inserindo dinheiro
    // ==================================================
    #20;
    $display("\n[TESTE] Inserindo dinheiro");

    // Exemplo: 100000 (nota maior)
    #20;
    SW[9:4] = 6'b100000;
    press_advance();

    // Mais dinheiro
    #20;
    press_advance();
	 
    #20;
    press_advance();

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
    
	 
    // Resultado final
    if (error_count == 0) begin
        $display("\n==== FIM DA SIMULACAO: TODOS OS TESTES PASSARAM ====");
    end else begin
        $display("\n==== FIM DA SIMULACAO: %0d FALHAS ====", error_count);
    end
	
    $finish;
end

endmodule