// Encapsula módulos para fazer a lógica de seleç~ao de produto.
module product_selection(
	input clk,            // Clock
	input [3:0] product,  // Código binário do produto
	input enable,         // Máquina de estados vai determinar se pode escrever no registrador
	input syncReset,       // Reset síncrono do registrador
	output [10:0] productValue,    // Valor do produto
	output [6:0] hexCode        // Código de 7 segmentos para o c´odigo bin´ario do produto
);

	wire [10:0] outValue;
	
	register productBin(
		.clk(clk),
		.syncReset(syncReset),
		.write(enable),
		.inValue(product),
		.outValue(outValue)
	);
	
	bin2hex getHex(
		.BIN(outValue),
		.HEX(hexCode)
	);
	
	product2value getValue(
		.BIN(outValue),
		.Value(productValue),
	);
	
endmodule
