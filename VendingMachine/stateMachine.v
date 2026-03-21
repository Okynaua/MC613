module stateMachine(
	input clk,                  
	input advance,             //Sinal bot~ao avançar
	input cancel,              //Sinal bot~ao cancelar
	input [11:0] subtraction,  //Resultado da subtraç~ao
	output product_enable,     //Ativar a escrita no registrador de produto
	output product_reset,      //Reseta o registrador de produto
	output acc_enable,         //Ativa a escrita no acumulador
	output acc_reset           //Reseta o acumuladro
);
	//definiç~ao dos 4 estados poss´iveis
	localparam selection = 2'b00;
	localparam insertion = 2'b01;
	localparam sold = 2'b10;
	localparam canceled = 2'b11;


	//Registrador do Estado atual instanciado
	wire reg [1:0] currentState; 
	wire [1:0] inputState;
	wire writeState;
	wire resetState;
	Register currentStateReg(
		.clk(clk),
		.invalue(inputState),
		.syncReset(resetState),
		.outValue(currentState)
	);
	
	//Contador de tempo instanciado
	wire secondPassed;           //Define o sinal do segundo passado
	wire resetTimer;             //Reseta o contador de tempo
	espera_1s timer(
		.clk(clk),
		.reset(resetTimer),
		.pulse_out(secondPassed)
	);
	
	
	//l´ogica para os bot~oes advance e cancel contarem como 1 pulso de ativaç~ao
	reg last_pulse_advance;
	reg last_pulse_cancel;
	always @(posedge clk) begin
		last_pulse_advance <= advance;
		last_pulse_cancel <= cancel;
	end
	wire pulse_advance;
	wire pulse_cancel;
	assign pulse_advance = (advance == 1'b1) && (last_pulse_advance == 1'b0);
	assign pulse_cancel = (cancel == 1'b1) && (last_pulse_cancel == 1'b0);
	
	always @(posedge clk or posedge advance or posedge cancel) begin
		//Avanço do estado selection para insertion
		if (last_pulse_advance and currentState == selection) begin
			inputState = insertion;
			writeState = 1;
			writeState = 0;

			product_enable = 0; //desativa a alteraç~ao de produto
		//Inserç~ao de dinheiro
		end else if (last_pulse_advance and currentState == insertion) begin
			acc_enable = 1;
			acc_enable = 0
		end
		if(currentState == insertion and subtraction < 0
		
		

	
		
	end
endmodule