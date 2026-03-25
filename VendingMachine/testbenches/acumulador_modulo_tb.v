module acumulador_modulo_tb;

reg clk_test;
reg [5:0] index_test;
reg enable_test;         				// Maquina de estados vai determinar se pode usar o acumulador
reg reset_test;       					// Maquina de estados vai resetar o acumulador
wire is_zero_test;    					// Acumulador esta com 0
wire [10:0] acumulador_out_test; 	// Valor acumulador

acumulador_modulo uut (
    .clk(clk_test),
    .index(index_test),
	 .enable(enable_test),
	 .reset(reset_test),
	 .is_zero(is_zero_test),
	 .acumulador_out(acumulador_out_test)
);

integer i;

	// Geração de clock (50M)
	initial begin
		clk_test = 0;
		forever #10 clk_test = ~clk_test;
	end
	
	initial begin
		$monitor("t=%0t | clk=%b | reset=%b | enable=%b | is_zero=%d | index=%d | acumulador_out=%d",
				 $time, clk_test, reset_test, enable_test, is_zero_test, index_test, acumulador_out_test);
	end

	initial begin
   $display("==== INICIO DA SIMULACAO ====");
    
	// Inicializando variaveis que serao utilizadas
	index_test = 0;
	enable_test = 0;
	reset_test = 0;
	 
	// 1. Teste de reset
	#20;
	$display("\n[TESTE] Ativando reset");
	reset_test = 1;
	#20;
	reset_test = 0;
	$display("[TESTE] Reset desativado");
	
	// 2. Teste de soma de nota acumulador_modulo
	#20;
	$display("\n[TESTE] Escrita: index = 100000");
	index_test = 6'b100000;
	enable_test = 1;
	#20;
	enable_test = 0;
	$display("[TESTE] Write desativado");
	
	// 3. Mudança sem enable
	#20;
	$display("\n[TESTE] Mudando entrada sem write (index = 100)");
	index_test = 6'b000100;
	#20;
	index_test = 6'b000010;
	#20;
	
	// 4. Soma de um novo valor
	$display("\n[TESTE] Escrita: index = 1");
	index_test = 6'b000001;
	enable_test = 1;
	#20;
	enable_test = 0;
	
	// 5. Testando o reset
	#20;
	$display("\n[TESTE] Ativando Reset");
	reset_test = 1;
	#20;
	reset_test = 0;
	$display("[TESTE] Reset desativado");
	
	// 6. Adicao de varios numeros sem destivar o add
	#20;
	$display("\n[TESTE] Escrita apos reset: index's = 010000, 000100, 001000");
	index_test = 6'b010000;
	enable_test = 1;
	#20;
	index_test = 6'b000100;
	#20;
	index_test = 6'b001000;
	#20;
	
	// 7. Testando possiveis erros do index
	$display("\n[TESTE] Erros do index2money, mais de um bit ativo, nenhum bit ativo");
	#20;
	index_test = 6'b000000;
	#20;
	index_test = 6'b110000;
	#20;
	index_test = 6'b000110;
	
	// 8. Valores válidos: 000001 até 100000
	$display("\n[TESTE] Testando todos os valores de dinheiro possiveis");
	 
    for (i = 0; i < 6; i = i + 1) begin
        index_test = 6'b000001 << i;
        #20;  // Aguarda para o sinal estabilizar
		  reset_test = 1;
		  #20;
		  reset_test = 0;
		  #20;
		  $display("index: %d | money: %d", index_test, acumulador_out_test);
    end
	
	

	$display("\n==== FIM DA SIMULACAO ====");
	
	$finish;
    
end

endmodule