module hex2bin_tb;

reg [6:0] test_input;
wire [3:0] test_output;

hex2bin uut (
	 .HEX(test_input),
    .BIN(test_output)
);

// Variável para o loop (deve ser integer)
integer i;

initial begin
    $display("==== INICIO hex2bin_tb ====");
    
    // Loop de 0 a 127
    for (i = 0; i < 128; i = i + 1) begin
        test_input = i;
        #10;  // Aguarda para o sinal estabilizar
		  if (test_output !== 4'bxxxx) begin
		   	$display("HEX: %b | BIN: %h", test_input, test_output);
		  end
    end
	 
	 $display("\n==== FIM hex2bin_tb ====");
    
    $finish;
end

endmodule