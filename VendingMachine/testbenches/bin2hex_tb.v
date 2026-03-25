module bin2hex_tb;

reg [3:0] test_input;
wire [6:0] test_output;

bin2hex uut (
    .BIN(test_input),
    .HEX(test_output)
);

// Variável para o loop (deve ser integer)
integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====");
    
    // Loop de 0 a 15
    for (i = 0; i < 16; i = i + 1) begin
        test_input = i;
        #10;  // Aguarda para o sinal estabilizar
        $display("BIN: %d | HEX: %b", test_input, test_output);
    end
	 
	 $display("\n==== FIM DA SIMULACAO ====");
    
    $finish;
end

endmodule