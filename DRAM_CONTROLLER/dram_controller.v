module dram_controler(
	input clk,                  
	input reset,
	input [25:0] address, // address[25] = byte selector, address[24:23] = ba, address[22:10] = a[12:0] line selector, a[12:0] = {0, 0, a[10], address[9:0] column selector}
	inout [8:0] data,	
	input req,
    input wEn, 
    output reg data_valid,
	output reg ready,
    output reg [5:0] current_state;
    //Memory pins
    output reg cs,
    output reg ras,
    output reg cas,
    output reg we          
    output reg [1:0] ba;   //bank selector
    output reg [12:0] a;   //memory address
    output reg [1:0] dqm;  //byte disable
    output cke;
);

parameter   INIT    = 6'd00, INIT1    = 6'd01, INIT2    = 6'd02, INIT3    = 6'd03, INIT4    = 6'd04, INIT5    = 6'd05, INIT6    = 6'd06, INIT7    = 6'd07, INIT8    = 6'd08, INIT9    = 6'd09, INIT10    = 6'd10, INIT11    = 6'd11, INIT12    = 6'd12, INIT13    = 6'd13, INIT14    = 6'd14, INIT15    = 6'd15, INIT16    = 6'd16, INIT17    = 6'd17, INIT18    = 6'd18, INIT19    = 6'd19, INIT20    = 6'd20, INIT21    = 6'd21,
            READ    = 6'd30, READ1    = 6'd31, READ2    = 6'd32, READ3    = 6'd33, READ4    = 6'd34, READ5    = 6'd35, READ6    = 6'd36, 
            WRITE   = 6'd40, WRITE1   = 6'd41, WRIT2    = 6'd42, WRITE3   = 6'd43, WRITE4   = 6'd44, WRITE5   = 6'd45,
            REFRESH = 6'd50, REFRESH1 = 6'd51, REFRESH1 = 6'd52, REFRESH1 = 6'd53, REFRESH1 = 6'd54, REFRESH1 = 6'd55,
            READY   = 6'd62,
            WAIT    = 6'd63;

assign cke = 1;

wire [7:0] data_out;
wire [7:0] data_in;
assign data = (!wEn && data_valid) ? data_out : 8'bz;
assign data_in = data;

reg [4:0] after_wait_state  //When exiting wait state, the controller will go to after_wait_state

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
    refresh_compare <= 1017;  //refresh needs to happen 8192 times in 60ms, that is, it needs to happen every 60*10^-3/8192 = 7.3242 micros, with that, 143 Mhz * 7,3242 micros = clock cycles needed = 1047.3606
    //No Operation
    cs <= 0;
    ras <= 1;
    cas <= 1;
    we <= 1;
    //Sets initial values as 0
    a <= 13'b0;
    dqm <= 2'b0;
    ba <= 2'b0;
    //
    ready = 0;
    data_valid = 0;
end

always @(posedge clk)begin
    if(reset)begin
        wait_reset <= 1;
        refresh_reset <= 1;
        data_valid <= 0;
        ready <= 0;
        current_state <= INIT;
    
    end else if(refresh_overflow && ready)begin
        cs <= 0;
        ras <= 1;
        cas <= 1;
        we <= 1;
        refresh_reset <= 1;

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
                refresh_reset <= 0;
                ready <= 1;
                data_valid <= 1;
                if(req && !wEn)begin
                    ready <= 0;
                    data_valid <= 0;      //this gives power over data to the memory instead of the controller
                    current_state <= READ;
                end else if(req && wEn)begin
                    ready <= 0;
                    data_valid <= 1;      //this gives power over data to the controller instead of the memory
                    data_out <= data_in;  //keeps the value to be written
                    current_state <= WRITE;
                end 
            end

            READ: begin
                //Bank Activate (ACT)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 1;
                ba[1:0] <= address[24:23];
                a[12:0] <= address[22:10];

                current_state <= READ1; //tCMH = 0.8ns
            end
            READ1: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd3; //tRCD = 15ns
                after_wait_state <= READ2;
                current_state <= WAIT;
            end
            READ2: begin
                //READ
                cs <= 0;
                ras <= 1;
                cas <= 0;
                we <= 1;
                a[12:0] <= {3'b0, address[9:0]};

                current_state <= READ3; //tCMH = 0.8ns
            end
            READ3: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd1; //CAS Latency - 2, since the WAIT state takes up 2 cycles time more than needed, I think
                after_wait_state <= READ4;
                current_state <= WAIT;
            end

            READ4: begin
                //Data capture
                data_out <= data_in;

                current_state <= READ5;
            end
            READ5: begin
                //Precharge All Banks (PALL)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 0;
                a[10] <= 1;

                current_state <= READ6; //tCMH = 0.8ns
            end
            READ6: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                data_out <= data_in;
                wait_compare <= 16'd3; //tRP = 15ns
                after_wait_state <= READY;
                current_state <= WAIT;
            end

            WRITE: begin
                //Bank Activate (ACT)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 1;
                ba[1:0] <= address[24:23];
                a[12:0] <= address[22:10];

                current_state <= WRITE; //tCMH = 0.8ns
            end
            WRITE1: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd3; //tRCD = 15ns
                after_wait_state <= WRITE2;
                current_state <= WAIT;
            end
            WRITE2: begin
                //WRITE
                cs <= 0;
                ras <= 1;
                cas <= 0;
                we <= 0;
                a[12:0] <= {3'b0, address[9:0]};

                current_state <= WRITE3; //tCMH = 0.8ns
            end
            WRITE3: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd3; //tRAS - tRCD = 37 - 15 = 22ns
                after_wait_state <= WRITE4;
                current_state <= WAIT;
            end
            WRITE4: begin
                //Precharge All Banks (PALL)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 0;
                a[10] <= 1;

                current_state <= WRITE5; //tCMH = 0.8ns
            end
            WRITE5: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                data_out <= data_in;
                wait_compare <= 16'd3; //tRP = 15ns
                after_wait_state <= READY;
                current_state <= WAIT;
            end

            REFRESH: begin
                //Precharge All Banks(PALL)
                cs <= 0;
                ras <= 0;
                cas <= 1;
                we <= 0;
                a[10] <= 1; //indicates that all the banks will be precharged

                current_state <= REFRESH1; //tCMH = 0.8ns
            end
            REFRESH1: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd3; //tRP = 15ns
                after_wait_state <= INIT4;
                current_state <= WAIT;
            end
            REFRESH2: begin
                //Auto Refresh (REF) 1
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= REFRESH3; //tCMH = 0.8ns
            end
            REFRESH3: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= REFRESH4;
                current_state <= WAIT;
            end
            REFRESH4: begin
                //Auto Refresh (REF) 1
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= REFRESH5; //tCMH = 0.8ns
            end
            REFRESH5: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= READY;
                current_state <= WAIT;
            end

            INIT: begin 
                //No operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd30000;  //Just a pretty number that is more than 28600
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

                wait_compare <= 16'd3; //tRP = 15ns
                after_wait_state <= INIT2;
                current_state <= WAIT;
            end
            INIT2: begin
                //Auto Refresh (REF) 1
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT3; //tCMH = 0.8ns
            end
            INIT3: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT4;
                current_state <= WAIT;
            end
            INIT4: begin
                //Auto Refresh (REF) 2
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT5; //tCMH = 0.8ns
            end
            INIT5: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT6;
                current_state <= WAIT;
            end
            INIT6: begin
                //Auto Refresh (REF) 3
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT7; //tCMH = 0.8ns
            end
            INIT7: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT8;
                current_state <= WAIT;

            end
            INIT8: begin
                //Auto Refresh (REF) 4
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT9; //tCMH = 0.8ns
            end
            INIT9: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT10;
                current_state <= WAIT;

            end
            INIT10: begin
                //Auto Refresh (REF) 5
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT11; //tCMH = 0.8ns
            end
            INIT11: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT12;
                current_state <= WAIT;
            end
            INIT12: begin
                //Auto Refresh (REF) 6
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT13; //tCMH = 0.8ns
            end
            INIT13: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT14;
                current_state <= WAIT;
            end
            INIT14: begin
                //Auto Refresh (REF) 7
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT15; //tCMH = 0.8ns
            end
            INIT15: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT16;
                current_state <= WAIT;
            end
            INIT16: begin
                //Auto Refresh (REF) 8
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT17; //tCMH = 0.8ns
            end
            INIT17: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT18;
                current_state <= WAIT;
            end
            INIT18: begin
                //Auto Refresh (REF) 9
                cs <= 0;
                ras <= 0;
                cas <= 0;
                we <= 1;

                current_state <= INIT19; //tCMH = 0.8ns
            end
            INIT19: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd9; //tRC = 60ns
                after_wait_state <= INIT20;
                current_state <= WAIT;
            end
            
            INIT20: begin
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


                current_state <= INIT21; //tAH = 0.8ns
            end
            INIT21: begin
                //No Operation (NOP)
                cs <= 0;
                ras <= 1;
                cas <= 1;
                we <= 1;

                wait_compare <= 16'd2; //tMRD = 2 cycles
                after_wait_state <= READY;
                current_state <= WAIT;
            end
            
        endcase
    end

end


endmodule