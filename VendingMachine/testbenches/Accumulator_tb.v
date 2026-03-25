module Accumulator_tb;

reg clk_test;             	// Entrada de Clock
reg [10:0] inValue_test;  	// Entrada que será possivelmente somada
reg syncReset_test;       	// Reset sincrono
reg add_test;             	// Enabler da soma
wire [10:0] outValue_test; // Valor de saida / Valor no registrador


Accumulator uut (
    .clk(clk_test),
    .inValue(inValue_test),
	 .syncReset(syncReset_test),
	 .add(add_test),
	 .outValue(outValue_test)
);

	// Geração de clock (50M)
	initial begin
		clk_test = 0;
		forever #10 clk_test = ~clk_test;
	end
	
	initial begin
		$monitor("t=%0t | clk=%b | reset=%b | add=%b | in=%d | out=%d",
				 $time, clk_test, syncReset_test, add_test, inValue_test, outValue_test);
	end

initial begin
   $display("==== INICIO DA SIMULACAO ====");
    
	// Inicializando variaveis que serao utilizadas
	inValue_test = 0;
	add_test = 0;
	syncReset_test = 0;
	 
	// 1. Teste de reset
	#20;
	$display("\n[TESTE] Ativando reset");
	syncReset_test = 1;
	#20;
	syncReset_test = 0;
	$display("[TESTE] Reset desativado");
	
	// 2. Teste de soma no Acumulador
	#20;
	$display("\n[TESTE] Escrita: inValue = 25");
	inValue_test = 11'd25;
	add_test = 1;
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
	syncReset_test = 1;
	#20;
	syncReset_test = 0;
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