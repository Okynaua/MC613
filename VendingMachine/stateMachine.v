module stateMachine(
	input clk,                  
	input advance,             	//Sinal bot~ao avançar
	input cancel,              	//Sinal bot~ao cancelar
	input subtraction_carry,	//Se subtraction teve carry
	input subtraction_zero,		//Se inserido = valor produto
	input accumulator_zero,     //Se inserido = 0ss
	output reg product_enable,     	//Ativar a escrita no registrador de produto
	output reg product_reset,      	//Reseta o registrador de produto
	output pulse_acc_enable,    //Ativa a escrita no acumulador
	output reg acc_reset,          	//Reseta o acumuladro
	output reg change_led,			//Led para troco pendente
	output reg paid_led				//Led para informar pagamento
);
	//definiç~ao dos 4 estados poss´iveis
	localparam selection = 2'b00;
	localparam insertion = 2'b01;
	localparam sold = 2'b10;
	localparam canceled = 2'b11;


	//Registrador do Estado atual instanciado
	reg [1:0] currentState = selection; 
	reg [1:0] nextState;

	always @(posedge clk) begin
		currentState <= nextState;
	end
	
	//Contador de tempo instanciado
	wire secondElapsed;           //Define o sinal do segundo passado
	reg resetTimer;             //Reseta o contador de tempo
	espera_1s timer(
		.clk(clk),
		.reset(resetTimer),
		.pulse_out(secondElapsed)
	);
	
	
	//l´ogica para os bot~oes advance e cancel contarem como 1 pulso de ativaç~ao
	reg last_pulse_advance;
	reg last_pulse_cancel;

	always @(posedge clk) begin
		last_pulse_advance <= advance;
		last_pulse_cancel <= cancel;
	end
	wire pulse_advance = (advance == 1'b1) && (last_pulse_advance == 1'b0);
	wire pulse_cancel = (cancel == 1'b1) && (last_pulse_cancel == 1'b0);

	reg acc_enable;
	reg last_acc_enable;
	always @(posedge clk) begin
		last_acc_enable <= acc_enable;
	end
	assign pulse_acc_enable = (acc_enable == 1'b1) && (last_acc_enable == 1'b0);


	//L´ogica de pr´oximo estado
	always @(*) begin
		acc_enable = 1'b0;
		acc_reset = 1'b0;
		product_reset = 1'b0;
		product_enable = 1'b0;
		resetTimer = 1'b0;
		change_led = 1'b0;
		paid_led = 1'b0;
		nextState = currentState;

		case (currentState)
			selection: begin
				product_enable = 1'b1;
				if(pulse_advance) begin
					nextState = insertion;
				end
			end
			insertion: begin
				if(pulse_cancel) begin
					nextState = canceled;
				end else if (pulse_advance) begin
					acc_enable = 1'b1;
				end

				if(subtraction_carry || subtraction_zero) begin
					nextState = sold;
				end
			end
			sold: begin
				change_led = subtraction_carry;
				paid_led = 1'b1;
				resetTimer = 1'b1;
				if (secondElapsed) begin
					acc_reset = 1'b1;
					product_reset = 1'b1;
					change_led = 1'b0;
					paid_led = 1'b0;
					nextState = selection;
				end
			end
			canceled: begin
				if (accumulator_zero) begin
					acc_reset = 1'b1;
					product_reset = 1'b1;
					nextState = selection;
				end else begin
					change_led = 1'b1;
					resetTimer = 1'b1;
				end

				if (secondElapsed) begin
					acc_reset = 1'b1;
					product_reset = 1'b1;
					change_led = 1'b0;
					nextState = selection;
				end
			end
		endcase
	end
endmodule