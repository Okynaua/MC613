module acumulador_modulo_tb;

reg clk_test;
reg [5:0] index_test;
reg enable_test;         				// Maquina de estados vai determinar se pode usar o acumulador
reg reset_test;       					// Maquina de estados vai resetar o acumulador
wire is_zero_test;    					// Acumulador esta com 0
wire [11:0] acumulador_out_test; 	// Valor acumulador

acumulador_modulo_tb uut (
    .clk(clk_test),
    .index(index_test),
	 .enable(enable_test),
	 .reset(reset_test),
	 .is_zero(is_zero_test),
	 .acumulador_out(acumulador_out_test)
);

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
	is_zero_test = 0;
	 
	// 1. Teste de reset
	#20;
	$display("\n[TESTE] Ativando reset");
	reset_test = 1;
	#20;
	reset_test = 0;
	$display("[TESTE] Reset desativado");
	
	// 2. Teste de soma no Acumulador
	#20;
	$display("\n[TESTE] Escrita: inValue = 25");
	index_test = 6'b10000;
	enable_test = 1;
	#20;
	add_test = 0;
	$display("[TESTE] Write desativado");
	
	// 3. Mudança sem add (não deve alterar)
	#20;
	$display("\n[TESTE] Mudando entrada sem write (inValue = 100)");
	inValue_test = 11'd100;
	#20;
	
	// 4. Soma de um novo valor
	$display("\n[TESTE] Escrita: inValue = 150");
	inValue_test = 11'd150;
	add_test = 1;
	#20;
	add_test = 0;
	
	// 5. Testando o reset
	#20
	$display("\n[TESTE] Ativando Reset");
	reset_test = 1;
	#20;
	reset_test = 0;
	$display("[TESTE] Reset desativado");
	
	// 6. Adicao de varios numeros sem destivar o add
	#20;
	$display("\n[TESTE] Escrita apos reset: inValue = 7");
	inValue_test = 11'd7;
	add_test = 1;
	#20;
	inValue_test = 11'd100;
	#20;
	inValue_test = 11'd360;
	#20
	inValue_test = 11'd29;
	
	#20;
	$display("\n==== FIM DA SIMULACAO ====");
	
	$finish;
    
end

endmodule