// Encapsula m´odulos para fazer a l´ogica de seleç~ao de produto.
module product_selection(
	input clk,            // Clock
	input [3:0] product,  // C´odigo bin´ario do produto
	input enable,         // M´aquina de estados vai determinar se pode escrever no registrador
	input syncReset,       // Reset s´incrono do registrador
	output [10:0] productValue,    // Valor do produto
	output [6:0] hexCode        // C´odigo de 7 segmentos para o c´odigo bin´ario do produto
);

	wire [10:0] outValue;
	
	Register productBin(
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
