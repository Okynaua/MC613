module stateMachine(
	input clk,
	input advance,
	input cancel,
	input [11:0] subtraction,
	output product_enable,
	output product_reset,
	output acc_enable,
	output acc_reset
);

	wire [1:0] currentState;
	assign currentState = 2'b00;
	
	wire secondPassed;
	wire resetTimer;


	espera_1s timer(
		.clk(clk),
		.reset(resetTimer),
		.pulse_out(secondPassed)
	);

	