`timescale 1ns/1ps

module counter_tb(); 

    reg clk;

    initial clk = 0;
    always #3.5 clk = ~clk; // Clock de ~143MHz (período de 7ns)

reg counter_reset;
reg [15:0] counter_compare;
wire counter_overflow;
wire [15:0] counter_value;
counter counter_test(
    .clk(clk),
    .rst(counter_reset),
    .counter_compare(counter_compare),
    .overflow(counter_overflow),
    .counter_value(counter_value)
);
   

    initial begin
        counter_reset = 1;
        #1000;

        counter_reset = 0;
        counter_compare = 16'b1111111111111111;
        #100;
        counter_reset = 1;
        #1000;

        counter_reset = 0;
        counter_compare = 16'b1111;
        #1000000

        $stop;
    end

    initial begin
        $monitor("Tempo: %0t | %d until %d | reset: %b | overflow: %b", $time, counter_value, counter_compare, counter_reset, counter_overflow);
    end

endmodule