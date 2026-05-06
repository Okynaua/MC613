module dram_controler(
	input clk,                  
	input rst,
	input [25:0] adress, 
	inout [8:0] data,	
	input req,
    input wEn, 
	output ready
);


    reg [15:0] counter_compare;
    reg clk_rst;
    reg counter_value;
    reg overflow;

    counter #(
        .COUNTER_SIZE(16)
    ) counter (
        .clk(clk),
        .rst(rst),
        .counter_compare(counter_compare - 1),
        .counter_value(counter_value),
        .overflow(overflow)
    );


	//definiç~ao dos estados poss´iveis
	localparam ready_state = 4'b0000;
	localparam refresh = 4'b0001;
    localparam wait_t = 4'b0010;	
    localparam refresh_precharge = 4'b0011;
    localparam refresh_auto1 = 4'b0100;
	localparam refresh_auto2 = 4'b0101;
    localparam captura_dados = 4'b0110;	
    localparam write = 4'b0111;
    localparam write_tDPL = 4'b1000;
	localparam precharge = 4'b1001;
    localparam wait_tRP = 4'b1010;	
    localparam wait_init = 4'b1011;
    localparam precharge_init = 4'b1100;
	localparam load_mode_register = 4'b1101;
    localparam wait_tMRD = 4'b1110;	
    localparam refresh_init = 4'b1111;


	//Registrador do Estado atual instanciado
	reg [3:0] current_state = ready_state;  //TEM QUE MUDAR PRA INIT
	reg [3:0] next_state = ready_state;
    reg [3:0] after_state;

	always @(posedge clk) begin
		current_state <= next_state;
	end


    reg counter_refresh; //ALERTA: EU NAO SEI FAZER
    reg CKE;
    reg CS=0;
    reg RAS=1;
    reg CAS=1;
    reg WE=1;
    reg [1:0] BA;
    reg [12:0] A;
	
    always @(*) begin
        CKE = 1;
		//acc_enable = 1'b0;
		//acc_reset = 1'b0;
		//product_reset = 1'b0;
		//product_enable = 1'b0;
		//resetTimer = 1'b1;
		//change_led = 1'b0;
		//paid_led = 1'b0;
		next_state = current_state;
		//return_inserted = 1'b0;

		case (current_state)
			ready_state: begin
                if(counter_refresh >= 1000) begin
                    next_state = refresh;
                end
				if(req) begin
                    //next_state = activate;
				end
			end

			wait_t: begin
                CS=0;
                RAS=1;
                CAS=1;
                WE=1;
                


                if(overflow) begin
                    next_state = after_state;
                end
			end


            refresh_precharge: begin
                CS=0;
                RAS=0;
                CAS=1;
                WE=0;
                A[10]=1;

                counter_compare = 3;
                after_state = refresh_auto1;
                clk_rst = 1;
                next_state = wait_t;


			end


			refresh_auto1: begin
				CS=0;
                RAS=0;
                CAS=0;
                WE=1;

                counter_compare = 9;
                after_state = refresh_auto2;
                clk_rst = 1;
                next_state = wait_t;
			end
            
            refresh_auto2: begin
				CS=0;
                RAS=0;
                CAS=0;
                WE=1;

                counter_compare = 9;
                after_state = ready;
                clk_rst = 1;
                next_state = wait_t;
			end


		endcase
	end
endmodule