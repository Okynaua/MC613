module VendingMachine(
	input wire CLOCK_50,            // Clock
    input wire [9:0] SW,       // Switches do produto [3:0] Switches do index do dinheiro [9:4]
    input wire [1:0] KEY,        // Bot~ao avançar [0] Bot~ao cancelar [1]
	output wire [6:0] HEX3,    // Display de 7 segmentos hex 3
	output wire [6:0] HEX2,    // Display de 7 segmentos hex 2
	output wire [6:0] HEX1,    // Display de 7 segmentos hex 1
	output wire [6:0] HEX0,    // Display de 7 segmentos hex 0
	output wire [6:0] HEX5,    // Display de 7 segmentos hex do produto
	output wire [1:0] LEDR	  //Led para troco pendente [1] Led para informar pagamento [0]
);


wire acc_reset;
wire acc_enable;
wire [10:0] product_value;
wire product_enable;
wire product_reset;
wire acc_is_zero;
wire [10:0] acc_value;
wire sub_is_zero;
wire sub_carry;
wire [10:0] sub_result;


acumulador_modulo MODULO_ACUMULADOR(
	.clk(CLOCK_50),            // Clock
	.index(SW[9:4]),  // Index do dinheiro
	.enable(acc_enable),         // M´aquina de estados vai determinar se pode usar o acumulador
	.reset(acc_reset),       // M´aquina de estados vai resetar o acumulador
	.is_zero(acc_is_zero),    // Acumulador est´a com 0
	.acumulador_out(acc_value)  // Valor acumulador
);


product_selection MODULO_PRODUCT(
	.clk(CLOCK_50),            // Clock
	.product(SW[3:0]),  // Código binário do produto
	.enable(product_enable),         // Máquina de estados vai determinar se pode escrever no registrador
	.syncReset(product_reset),       // Reset síncrono do registrador
	.productValue(product_value),    // Valor do produto
	.hexCode(HEX5)        // Código de 7 segmentos para o c´odigo bin´ario do produto
);


stateMachine MODULO_STATEMACHINE(
	.clk(CLOCK_50),                  
	.advance(KEY[0]),             	//Sinal bot~ao avançar
	.cancel(KEY[1]),              	//Sinal bot~ao cancelar
	.subtraction_carry(sub_carry),	//Se subtraction teve carry
	.subtraction_zero(sub_is_zero),		//Se inserido = valor produto
    .accumulator_zero(acc_is_zero),
	.product_enable(product_enable),     	//Ativar a escrita no registrador de produto
	.product_reset(product_reset),      	//Reseta o registrador de produto
	.pulse_acc_enable(acc_enable),    //Ativa a escrita no acumulador
	.acc_reset(acc_reset),          	//Reseta o acumuladro
	.change_led(LEDR[1]),			//Led para troco pendente
	.paid_led(LEDR[0])				//Led para informar pagamento
);


bin2decimal MODULO_BINTODECIMAL( 
	.bin(sub_result),
	.hex3(HEX3),
	.hex2(HEX2),
	.hex1(HEX1),
	.hex0(HEX0)
);


outValue MODULO_SAIDA(
	.productValue(product_value),
	.moneyInserted(acc_value),
	.subtractionCarry(sub_carry),
	.subtractionZero(sub_is_zero),  
	.muxOut(sub_result)         // Will go to hex displays
);

endmodule