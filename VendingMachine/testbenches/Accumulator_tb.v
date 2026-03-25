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
		clk = 0;
		forever #10 clk = ~clk;
	end
	
	initial begin
		$monitor("t=%0t | clk=%b | reset=%b | add=%b | in=%d | out=%d",
				 $time, clk_test, syncReset_test, add_test, inValue_test, outValue_test);
	end

initial begin
    $display("==== INICIO DA SIMULACAO ====");
    
    
    
    $finish;
end

endmodule