module IFACE (
    input clk, 
    input rst,
    input [9:0] SW,
    input [3:0] KEY,
	output wire [6:0] HEX0,   // Dado de entrada (escrita)
	output wire [6:0] HEX1,   // Dado de saída (leitura)
	output wire [6:0] HEX4,   // Endereço 1
	output wire [6:0] HEX5,   // Endereço 2
    output [25:0] address,    // Endereço da DRAM
    output req, // Comando dado
    output wEn, // Permissao para escrita
    input ready // Controlador pronto
);

    reg [7:0] data;
    reg [9:0] last_SW;

    assign last_SW = SW;

    always @(posedge clk or negedge rst) begin
        if (ready) begin
        end
    end