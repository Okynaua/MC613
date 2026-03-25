module register_tb;

	// Sinais do testbench
	reg clk;
	reg [10:0] inValue;
	reg syncReset;
	reg write;
	wire [10:0] outValue;

	// Instancia o DUT
	register uut (
		.clk(clk),
		.inValue(inValue),
		.reset(syncReset),
		.write(write),
		.outValue(outValue)
	);

	// Geração de clock (50Mhz)
	initial begin
		clk = 0;
		forever #10 clk = ~clk;
	end

	// Monitoramento contínuo
	initial begin
		$monitor("t=%0t | clk=%b | reset=%b | write=%b | in=%d | out=%d",
				 $time, clk, syncReset, write, inValue, outValue);
	end

	// Estímulos
	initial begin
		$display("==== INICIO DA SIMULACAO ====");

		// Inicialização
		inValue = 0;
		syncReset = 0;
		write = 0;

		// 1. Teste de reset
		#2;
		$display("\n[TESTE] Ativando reset");
		syncReset = 1;
		#20;
		syncReset = 0;
		$display("\n[TESTE] Reset desativado");

		// 2. Escrita no registrador
		#20;
		$display("\n[TESTE] Escrita: inValue = 25");
		inValue = 11'd25;
		write = 1;

		// 3. Mudança sem write (não deve alterar)
		#20;
		$display("\n[TESTE] Mudando entrada sem write (inValue = 100)");
		write = 0;
		inValue = 11'd100;
		#20;

		// 4. Nova escrita
		$display("\n[TESTE] Escrita: inValue = 100");
		write = 1;
		#20;
		write = 0;

		// 5. Reset durante operação
		#20;
		$display("\n[TESTE] Reset durante operacao");
		syncReset = 1;
		#20;
		syncReset = 0;

		// 6. Escrita após reset
		#20;
		$display("\n[TESTE] Escrita apos reset: inValue = 7");
		inValue = 11'd7;
		write = 1;
		#20;

		#20;
		$display("\n==== FIM DA SIMULACAO ====");
		$finish;
	end

endmodule