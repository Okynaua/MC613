module IFACE (
    input clk, 
    input rst,
    input [9:0] SW,
    input [3:0] KEY,
	output wire [6:0] HEX0,   // Dado de entrada (escrita)
	output wire [6:0] HEX1,   // Dado de saída (leitura)
	output wire [6:0] HEX4,   // Endereço 1
	output wire [6:0] HEX5,   // Endereço 2
);

    always @(posedge clk or negedge reset_n) begin

    end