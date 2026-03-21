module product2value_tb;

reg [3:0] test_input;
wire [10:0] test_output;

product2value uut (
    .BIN(test_input),
    .Value(test_output)
);

// Variável para o loop (deve ser integer)
integer i;

initial begin
    $display("Testando product2value...");
    
    // Loop de 0 a 15
    for (i = 0; i < 16; i = i + 1) begin
        test_input = i;
        #10;  // Aguarda para o sinal estabilizar
        $display("Entrada: %h | Saída: %d", test_input, test_output);
    end
    
    $finish;
end

endmodule