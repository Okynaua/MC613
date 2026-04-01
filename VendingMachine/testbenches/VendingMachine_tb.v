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
    KEY[0] = 0;
    @(negedge CLOCK_50);
    KEY[0] = 1;
end
endtask

// Task para pressionar cancelar
task press_cancel;
begin
    @(negedge CLOCK_50);
    KEY[1] = 0;
    @(negedge CLOCK_50);
    KEY[1] = 1;
end
endtask

// Task para pular o tempo de espera
task pulse_timeout;
begin
    force uut.MODULO_STATEMACHINE.secondElapsed = 1'b1;
    @(posedge CLOCK_50);
    release uut.MODULO_STATEMACHINE.secondElapsed;
    @(posedge CLOCK_50);
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
	 pulse_timeout();
	 
    $display("Selecionando outro produto (SW[3:0] = B)");
    SW[3:0] = 4'b1011;
	 #40;
	 expect_signal(HEX5, 7'b0000011, "HEX5 com produto B");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = F)");
    SW[3:0] = 4'b1111;
	 #40;
	 expect_signal(HEX5, 7'b0001110, "HEX5 com produto F");
	 
    $display("\n[TESTE] Selecionando produto (SW[3:0] = 1)");
    SW[3:0] = 4'b0001;
	 #40;
	 expect_signal(HEX5, 7'b1111001, "HEX5 com produto 1");
	 
	 $display("\n[TESTE] Pressiona avancar para registrar produto");
	 press_advance();

    // ==================================================
    // 2. Produto 1, pagamento exato (3x R$1,00)
    // ==================================================
    #20;
    $display("\n[TESTE] Produto 1, pagamento exato (3x R$1,00)");
	
	 // R$3,00
	
    #20;
	 $display("Insere R$1,00");
    SW[9:4] = 6'b010000;
    press_advance(); // R$2,00
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b1000000, "HEX1 com 0");
	 expect_signal(HEX2, 7'b0100100, "HEX2 com 2");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");

    #20;
	 $display("Insere R$1,00");
    press_advance(); // R$1,00
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b1000000, "HEX1 com 0");
	 expect_signal(HEX2, 7'b1111001, "HEX2 com 1");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 
    #20;
	 $display("Insere R$1,00");
    press_advance();
	 pulse_timeout();
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b1000000, "HEX1 com 0");
	 expect_signal(HEX2, 7'b1000000, "HEX2 com 0");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 expect_signal(LEDR, 2'b01, "LED LIBERACAO com 1 e LED TROCO COM 0");

    // ==================================================
    // 3. Produto 3, pagamento com troco (3x R$2,00)
    // ==================================================
   
    $display("\n[TESTE] Produto 3, pagamento com troco (3x R$2,00)");
	 pulse_timeout();
	 
    $display("Selecionando produto (SW[3:0] = 3)");
    SW[3:0] = 4'b0011;
	 #40;
	 expect_signal(HEX5, 7'b0110000, "HEX5 com produto 3");
	 
	 $display("Pressiona avancar para registrar produto");
	 press_advance();
	 
	 // Inserir dinheiro
	 
	 // R$4,50
	
    #20;
	 $display("Insere R$2,00");
    SW[9:4] = 6'b100000; // R$2,00
    press_advance(); // R$2,50
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b0010010, "HEX1 com 5");
	 expect_signal(HEX2, 7'b0100100, "HEX2 com 2");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");

    #20;
	 $display("Insere R$2,00");
    press_advance(); // R$0,50
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b0010010, "HEX1 com 5");
	 expect_signal(HEX2, 7'b1000000, "HEX2 com 0");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 
    #20;
	 $display("Insere R$2,00");
    press_advance();
	 pulse_timeout(); // R$1,50 de troco
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b0010010, "HEX1 com 5");
	 expect_signal(HEX2, 7'b1111001, "HEX2 com 1");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 expect_signal(LEDR, 2'b11, "LED LIBERACAO com 1 e LED TROCO COM 1");
	 

    // ==================================================
    // 4. Produto A, cancelamento
    // ==================================================
   
    $display("\n[TESTE] Produto A, cancelamento");
	 pulse_timeout();
	 
    $display("Selecionando produto (SW[3:0] = A)");
    SW[3:0] = 4'b1010;
	 #40;
	 expect_signal(HEX5, 7'b0001000, "HEX5 com produto A");
	 
	 $display("Pressiona avancar para registrar produto");
	 press_advance();
	 
    #20;
	 $display("Insere R$2,00");
    SW[9:4] = 6'b100000; // R$2,00
    press_advance(); // R$4,00
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b1000000, "HEX1 com 0");
	 expect_signal(HEX2, 7'b0011001, "HEX2 com 4");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");

    #20;
	 $display("Insere R$0,25");
	 SW[9:4] = 6'b000100; // R$0,25
    press_advance(); // R$3,75
	 expect_signal(HEX0, 7'b0010010, "HEX0 com 5");
	 expect_signal(HEX1, 7'b1111000, "HEX1 com 7");
	 expect_signal(HEX2, 7'b0110000, "HEX2 com 3");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 
	 #20;
	 $display("Insere R$0,25");
    press_advance(); // R$3,50
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b0010010, "HEX1 com 5");
	 expect_signal(HEX2, 7'b0110000, "HEX2 com 3");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 
	 #20;
	 $display("Cancela");
	 press_cancel(); // R$2,50
	 expect_signal(HEX0, 7'b1000000, "HEX0 com 0");
	 expect_signal(HEX1, 7'b0010010, "HEX1 com 5");
	 expect_signal(HEX2, 7'b0100100, "HEX2 com 2");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 expect_signal(LEDR, 2'b10, "LED LIBERACAO com 0 e LED TROCO COM 1");

    // ========================================================
    // 5. Produto 4, alterar produto e inserções simultaneas
    // ========================================================
   
    $display("\n[TESTE] Produto 4, alterar produto e inserções simultaneas");
	 pulse_timeout();
	 
    $display("Selecionando produto (SW[3:0] = 4)");
    SW[3:0] = 4'b0100;
	 #40;
	 expect_signal(HEX5, 7'b0011001, "HEX5 com produto 4");
	 
	 $display("Pressiona avancar para registrar produto");
	 press_advance();
	 
	 // Produto nao deve mudar
    $display("Selecionando produto (SW[3:0] = 1)");
    SW[3:0] = 4'b0001;
	 #40;
	 expect_signal(HEX5, 7'b0011001, "HEX5 com produto 4");
	 
    $display("Selecionando produto (SW[3:0] = B)");
    SW[3:0] = 4'b1011;
	 #40;
	 expect_signal(HEX5, 7'b0011001, "HEX5 com produto 4");
	 
    #20;
	 $display("Insere R$2,00 e R$0,50 (invalido)");
    SW[9:4] = 6'b101000; // R$2,00 e R$0,50 (invalido)
    press_advance(); // R$2,25
	 expect_signal(HEX0, 7'b0010010, "HEX0 com 5");
	 expect_signal(HEX1, 7'b0100100, "HEX1 com 2");
	 expect_signal(HEX2, 7'b0100100, "HEX2 com 2");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 
	 
    #20;
	 $display("Insere R$2,00 e R$0,50 (invalido)");
    SW[9:4] = 6'b010001; // R$1,00 e R$0,05 (invalido)
    press_advance(); // R$2,25
	 expect_signal(HEX0, 7'b0010010, "HEX0 com 5");
	 expect_signal(HEX1, 7'b0100100, "HEX1 com 2");
	 expect_signal(HEX2, 7'b0100100, "HEX2 com 2");
	 expect_signal(HEX3, 7'b1000000, "HEX3 com 0");
	 
	 
	 #20;
	 $display("Cancela");
	 press_cancel();
	 expect_signal(LEDR, 2'b00, "LED LIBERACAO com 0 e LED TROCO COM 0");
	 


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