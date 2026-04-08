module COUNTER #(
    parameter COUNTER_SIZE = 10,
    parameter COUNTER_COMPARE_V = 799
) (
    input clk,
    input rst,
    output reg overflow,
    output counter_value
);

reg [COUNTER_SIZE - 1:0] current_value;

always @(posedge clk) begin
    if (rst) begin
        current_value <= 0;
        overflow <= 0;
    end else if (current_value == COUNTER_COMPARE_V) begin
        overflow <= 1;
    end else begin
        current_value <= current_value + 1;
        overflow <= 0;
    end
end
    
endmodule