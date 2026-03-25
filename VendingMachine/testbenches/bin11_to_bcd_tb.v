module bin11_to_bcd_tb;

reg [10:0] test_input;
wire [15:0] test_output;

bin11_to_bcd uut (
    .bin(test_input),
    .bcd(test_output)	
);

// Variável para o loop
integer i;

initial begin
    $display("==== INICIO DA SIMULACAO ====\n");
    
    // Vamos testar alguns valores relevantes
    for (i = 0; i <= 2047; i = i + 1) begin
        test_input = i;
        #10;  // Aguarda estabilizar
        
        $display("BIN: %d | BCD: %b | Milhar:%d Centena:%d Dezena:%d Unidade:%d",
            test_input,
            test_output,
            test_output[15:12],
            test_output[11:8],
            test_output[7:4],
            test_output[3:0]
        );
    end
	
    $display("\n==== FIM DA SIMULACAO ====");
    
    $finish;
end

endmodule