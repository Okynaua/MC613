module index2money_tb;

reg [5:0] test_input;
wire [10:0] test_output;

index2money uut (
    .index(test_input),
    .money(test_output)
);

// Variável para o loop (deve ser integer)
integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====");
	 
	 $display("\nTestando valores validos...");
    
    // Valores válidos: 000001 até 100000
	 
    for (i = 0; i < 6; i = i + 1) begin
        test_input = 6'b000001 << i;
        #10;  // Aguarda para o sinal estabilizar
		  $display("index: %b | money: %d", test_input, test_output);
    end

    $display("\nTestando valores invalidos...");

    // Caso inválido: nenhum ativo
    test_input = 6'b000000;
    #10;
	 $display("index: %b | money: %d", test_input, test_output);

		 for (i = 0; i < 64; i = i + 1) begin
			  test_input = i;

			  // Verifica se tem mais de 1 bit ativo
			  if ((test_input & (test_input - 1)) != 0) begin
					#10;
					$display("index: %b | money: %d", test_input, test_output);
			  end
		 end	 
		 
	 $display("\n==== FIM DA SIMULACAO ====");
    
    $finish;
end

endmodule