module register(
	input clk,							// Clock para a atualizar ou nao o reg
	input [10:0] inValue,			// Entrada do reg
	input reset,					// Entrada de reset do reg
	input write,						// Entrada para mudar o valor do reg
	output reg [10:0] outValue		// Valor do reg propriamente dito
);
	always @(posedge clk) begin  	// Quando o reset for ativado, o outValue e resetado
		if(write) begin
			outValue <= inValue;
		end
	end
	
	always @(*) begin
		if(syncReset) begin
			outValue <= 11'd0;
		end
	end

endmodule
