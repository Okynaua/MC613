module COUNTER #(
    parameter COUNTER_SIZE = 10,
    parameter COUNTER_COMPARE_V = 799
) (
    input clk,
    input rst,
    output reg overflow,
    output reg [COUNTER_SIZE - 1:0] counter_value
);

initial begin
    counter_value <= 0;
end

always @(posedge clk) begin
    if (rst) begin
        counter_value <= 0;
        overflow <= 0;
    end else if (counter_value == COUNTER_COMPARE_V) begin
        counter_value <= 0;
        overflow <= 1;
    end else begin
        counter_value <= counter_value + 1;
        overflow <= 0;
    end
end
    
endmodule