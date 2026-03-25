module register(
	input clk,							// Clock para a atualizar ou nao o reg
	input [10:0] inValue,			// Entrada do reg
	input reset,					// Entrada de reset do reg
	input write,						// Entrada para mudar o valor do reg
	output reg [10:0] outValue		// Valor do reg propriamente dito
);
	always @(posedge clk or posedge reset) begin  	// Quando o reset for ativado, o outValue e resetado
		if(reset) begin
			outValue <= 11'd0;
		end else if(write) begin
			outValue <= inValue;
		end
	end
endmodule
