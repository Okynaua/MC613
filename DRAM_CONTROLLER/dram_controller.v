module dram_controler(
	input clk,                  
	input reset,
	input [25:0] address, // address[25] = byte selector, address[24:23] = ba, address[22:10] = a[12:0] line selector, a[12:0] = {0, 0, a[10], address[9:0] column selector}
	inout [8:0] data,	
	input req,
    input wEn, 
    output reg data_valid,
	output reg ready,
    output reg cs,
    output reg ras,
    output reg cas,
    output reg we
    output reg [1:0] ba;
    output reg [12:0] a;
    output reg [1:0] dqm;
);

parameter   WAIT    = 5'd0,
            INIT    = 5'd1,
            READ
            WRITE
            REFRESH
            READY   = 5'b11111;
            

reg [4:0] current_state, after_wait_state, after_refresh_state;     //When exiting wait state, the controller will go to after_wait_state

reg wait_reset;
reg wait_compare;
wire wait_overflow;
wire wait_value;
counter wait_counter(
    .clk(clk),
    .rst(wait_reset),
    .counter_compare(wait_compare),
    .overflow(wait_overflow),
    .counter_value(wait_value)
);

reg refresh_reset;
reg refresh_compare;
wire refresh_overflow;
wire refresh_value;
counter refresh_counter(
    .clk(clk),
    .rst(refresh_reset),
    .counter_compare(refresh_compare),
    .overflow(refresh_overflow),
    .counter_value(refresh_value)
);

initial begin
    current_state <= INIT;
    wait_reset <= 1;
    refresh_reset <= 1;
    refresh_compare <= 8;
    cs <= 0;
    ras <= 1;
    cas <= 1;
    we <= 1;
    a <= 13'b0;
    dqm <= 2'b0;
    ba <= 2'b0;
end

always @(posedge clk)begin
    if(reset)begin
        wait_reset <= 1;
        refresh_reset <= 0;
        data_valid <= 0;
        ready <= 0;
        current_state <= INIT;
    
    end else if(refresh_overflow)begin
        cs <= 0;
        ras <= 1;
        cas <= 1;
        we <= 1;

        after_refresh_state <= current_state;
        current_state <= REFRESH;
    
    end else begin
        case(current_state) 
            WAIT: begin
                wait_reset <= 0;
                wait_compare <= wait_compare;
                if(wait_overflow)begin
                    wait_reset <= 1;
                    current_state <= after_wait_state;
                end
            end

            READY: begin
                ready <= 1;
                data_valid <= 1;
                if(req && !wEn)begin
                    ready <= 0;
                    data_valid <= 0;
                    current_state <= READ;
                end else if(req && wEn)begin
                    ready <= 0;
                    data_valid <= 0;
                    current_state <= WRITE;
                end 
            end

            REFRESH: begin
                
            end

            INIT: begin 
                //No operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd100;  //Just a good number to secure good initialization
                after_wait_state <= INIT1;
                current_state <= WAIT;
            end
            INIT1: begin
                //Precharge All Banks(PALL)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 0;
                a[10] <= 1; //indicates that all the banks will be precharged

                wait_compare <= 16'd3; //tRP
                after_wait_state <= INIT2;
                current_state <= WAIT;
            end
            INIT2: begin
                //Auto Refresh (REF) 1
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT3;
            end
            INIT3: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT4;
                current_state <= WAIT;

            end
            INIT4: begin
                //Auto Refresh (REF) 2
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT5;
            end
            INIT5: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT6;
                current_state <= WAIT;

            end
            INIT6: begin
                //Auto Refresh (REF) 3
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT7;
            end
            INIT7: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT8;
                current_state <= WAIT;

            end
            INIT8: begin
                //Auto Refresh (REF) 4
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT9;
            end
            INIT9: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT10;
                current_state <= WAIT;

            end
            INIT10: begin
                //Auto Refresh (REF) 5
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT11;
            end
            INIT11: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT12;
                current_state <= WAIT;

            end
            INIT12: begin
                //Auto Refresh (REF) 6
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT13;
            end
            INIT13: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT14;
                current_state <= WAIT;

            end
            INIT14: begin
                //Auto Refresh (REF) 7
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT15;
            end
            INIT15: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT16;
                current_state <= WAIT;

            end
            INIT16: begin
                //Auto Refresh (REF) 8
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT17;
            end
            INIT17: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT18;
                current_state <= WAIT;

            end
            INIT18: begin
                //Auto Refresh (REF) 9
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT19;
            end
            INIT19: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC
                after_wait_state <= INIT20;
                current_state <= WAIT;
            end
            
            INIT21: begin
                //Mode Register Set (MRS)
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 0;
                ba <= 2'b0;
                a[12:10] <= 0   //See page 26
                a[9] <= 1;
                a[8:7] <= 2'b0;
                a[6:4] <= 3'b011;
                a[3] <= 0;
                a[2:0] <= 3'b0;


                current_state <= INIT23;
            end
            INIT22: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd3; //tRC
                after_wait_state <= INIT23;
                current_state <= WAIT;
            end
            INIT23: begin
                //Bank Active(ACT)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 1;
                ba <= 2'b0;      //actives row 0 from bank 0
                a[12:0] = 13'b0;

                wait_compare <= 16'd50;   //Just a long wait before it all
                after_wait_state <= READY;
                current_state <= WAIT;
            end
            
        endcase
    end

end


endmodule