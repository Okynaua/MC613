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
	reg [1:0] currentState; 
	reg [1:0] inputState;
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
	reg last_pulse_advance, reg last_pulse_cancel;
	always @(posedge clk) begin
		last_pulse_advance <= advance;
		last_pulse_cancel <= cancel;
	end
	wire pulse_advance = (advance == 1'b1) && (last_pulse_advance == 1'b0);
	wire pulse_cancel = (cancel == 1'b1) && (last_pulse_cancel == 1'b0);
	
	//L´ogica de pr´oximo estado
	always @(*) begin
		inputState = currentState;
		writeState = 0;
		
		case (currentState)
			selection: begin
				if(pulse_advance) begin
					inputState = insertion;
					writeState = 1;
				end
			end
			insertion: begin
				if(pulse_cancel) begin
					inputState = canceled;
					writeState = 1;
				end else if (subtraction <= 0) begin
					inputState = sold;
					writeState = 1;
				end
			end
			sold: begin
				if (secondPassed) begin
					inputState = selection;
					writeState = 1;
				end
			end
			canceled: begin
				if (secondPassed) begin
					inputState = selection;
					writeState = 1;
				end
			end
	end
endmodule