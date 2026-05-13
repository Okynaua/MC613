module counter #(
    parameter COUNTER_SIZE = 16
) (
    input clk,  
    input rst,                                     //async reset
    input [COUNTER_SIZE - 1:0] counter_compare,      
    output reg overflow,                           
    output reg [COUNTER_SIZE - 1:0] counter_value  
);

initial begin
    counter_value <= 0;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter_value <= 0;
        overflow <= 0;
    end else if (counter_value == counter_compare) begin
        counter_value <= 0;
        overflow <= 1;
    end else if(overflow) begin
        counter_value <= counter_value;
        overflow <= 1;
    end else begin
        counter_value <= counter_value + 1'b1;
        overflow <= 0;
    end
end
    
endmodule