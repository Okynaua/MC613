module dram_controler(
	input clk,                  
	input reset,
	input [25:0] address, // address[25] = byte selector, address[24:23] = ba, address[22:10] = a[12:0] line selector, a[12:0] = {0, 0, a[10], address[9:0] column selector}
	inout [7:0] data,
    input [7:0] data_from_iface,
    output reg [7:0] data_to_iface,
	input req,
    input wEn, 
    output reg data_valid,
	output reg ready,
    output reg [5:0] current_state,
    //Memory pins
    output reg cs,
    output reg ras,
    output reg cas,
    output reg we,          
    output reg [1:0] ba,   //bank selector
    output reg [12:0] a,   //memory address
    output reg [1:0] dqm,  //byte disable
    output cke
);

parameter   INIT    = 6'd00, INIT1    = 6'd01, INIT2    = 6'd02, INIT3    = 6'd03, INIT4    = 6'd04, INIT5    = 6'd05, INIT6    = 6'd06, INIT7    = 6'd07, INIT8    = 6'd08, INIT9    = 6'd09, INIT10    = 6'd10, INIT11    = 6'd11, INIT12    = 6'd12, INIT13    = 6'd13, INIT14    = 6'd14, INIT15    = 6'd15, INIT16    = 6'd16, INIT17    = 6'd17, INIT18    = 6'd18, INIT19    = 6'd19, INIT20    = 6'd20, INIT21    = 6'd21,
            READ    = 6'd30, READ1    = 6'd31, READ2    = 6'd32, READ3    = 6'd33, READ4    = 6'd34, READ5    = 6'd35, READ6    = 6'd36, 
            WRITE   = 6'd40, WRITE1   = 6'd41, WRITE2   = 6'd42, WRITE3   = 6'd43, WRITE4   = 6'd44, WRITE5   = 6'd45,
            REFRESH = 6'd50, REFRESH1 = 6'd51, REFRESH2 = 6'd52, REFRESH3 = 6'd53, REFRESH4 = 6'd54, REFRESH5 = 6'd55,
            READY   = 6'd62;

assign cke = 1;

reg creep; //because the controller wants to have control
reg [7:0] data_to_mem;
wire [7:0] data_from_mem;
assign data = (creep) ? data_to_mem : 8'bz;
assign data_from_mem = data;

reg [5:0] next_state;

reg wait_reset;
reg [15:0] wait_compare;
wire wait_overflow;
wire [15:0] wait_value;
counter wait_counter(
    .clk(clk),
    .rst(wait_reset),
    .counter_compare(wait_compare),
    .overflow(wait_overflow),
    .counter_value(wait_value)
);

reg refresh_reset;
reg [15:0] refresh_compare;
wire refresh_overflow;
wire [15:0] refresh_value;
counter refresh_counter(
    .clk(clk),
    .rst(refresh_reset),
    .counter_compare(refresh_compare),
    .overflow(refresh_overflow),
    .counter_value(refresh_value)
);

initial begin
    current_state <= INIT;
    next_state <= INIT;
    creep <= 0;
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
    ready <= 0;
    data_valid <= 0;
    data_to_mem <= 0;
    data_to_iface <= 0;
end

always @(posedge clk)begin
    current_state <= next_state;
end

always @(*)begin
    if(!reset)begin
        wait_reset = 1;
        refresh_reset = 1;
        data_valid = 0;
        ready = 0;
        next_state = INIT;
    end else begin
        case(current_state) 

            READY: begin
                refresh_reset = 0;
                ready = 1;
                creep = 0;
                if(refresh_overflow)begin
                    //No Operation (NOP)
                    cs = 0;
                    ras = 1;
                    cas = 1;
                    we = 1;
                    refresh_reset = 1;

                    next_state = REFRESH;
                end else if(req && !wEn)begin
                    ready = 0;
                    next_state = READ;
                end else if(req && wEn)begin
                    ready = 0;
                    data_to_mem = data_from_iface;  //keeps the value to be written
                    next_state = WRITE;
                end 
            end

            READ: begin
                //Bank Activate (ACT)
                cs = 0;
                ras = 0;
                cas = 1;
                we = 1;
                ba[1:0] = address[24:23];
                a[12:0] = address[22:10];

                next_state = READ1; //tCMH = 0.8ns
            end
            READ1: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd3; //tRCD = 15ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = READ2;
                end
            end
            READ2: begin
                //READ
                cs = 0;
                ras = 1;
                cas = 0;
                we = 1;
                a[12:0] = {3'b0, address[9:0]};

                next_state = READ3; //tCMH = 0.8ns
            end
            READ3: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd3; //CAS Latency
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    data_to_iface = data_from_mem;  //data capture
                    next_state = READ5;
                end
            end
            READ5: begin
                //Precharge All Banks (PALL)
                cs = 0;
                ras = 0;
                cas = 1;
                we = 0;
                a[10] = 1;

                next_state = READ6; //tCMH = 0.8ns
            end
            READ6: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd3; //tRP = 15ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = READY;
                end
            end

            WRITE: begin
                //Bank Activate (ACT)
                cs = 0;
                ras = 0;
                cas = 1;
                we = 1;
                ba[1:0] = address[24:23];
                a[12:0] = address[22:10];

                next_state = WRITE1; //tCMH = 0.8ns
            end
            WRITE1: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd3; //tRCD = 15ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = WRITE2;
                end
            end
            WRITE2: begin
                //WRITE
                cs = 0;
                ras = 1;
                cas = 0;
                we = 0;
                a[12:0] = {3'b0, address[9:0]};
                creep = 1;

                next_state = WRITE3; //tCMH = 0.8ns
            end
            WRITE3: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd4; //tRAS - tRCD = 37 - 15 = 22ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = WRITE4;
                end
            end
            WRITE4: begin
                //Precharge All Banks (PALL)
                cs = 0;
                ras = 0;
                cas = 1;
                we = 0;
                a[10] = 1;

                next_state = WRITE5; //tCMH = 0.8ns
            end
            WRITE5: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd3; //tRP = 15ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = READY;
                end
            end

            REFRESH: begin
                //Precharge All Banks(PALL)
                cs = 0;
                ras = 0;
                cas = 1;
                we = 0;
                a[10] = 1; //indicates that all the banks will be precharged

                next_state = REFRESH1; //tCMH = 0.8ns
            end
            REFRESH1: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd3; //tRP = 15ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = REFRESH2;
                end
            end
            REFRESH2: begin
                //Auto Refresh (REF) 1
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = REFRESH3; //tCMH = 0.8ns
            end
            REFRESH3: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = REFRESH4;
                end
            end
            REFRESH4: begin
                //Auto Refresh (REF) 1
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = REFRESH5; //tCMH = 0.8ns
            end
            REFRESH5: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = READY;
                end
            end

            INIT: begin 
                //No operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd30000;  //Just a pretty number that is more than 28600
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT1;
                end
            end
            INIT1: begin
                //Precharge All Banks(PALL)
                cs = 0;
                ras = 0;
                cas = 1;
                we = 0;
                a[10] = 1; //indicates that all the banks will be precharged

                wait_compare = 16'd3; //tRP = 15ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT2;
                end
            end
            INIT2: begin
                //Auto Refresh (REF) 1
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT3; //tCMH = 0.8ns
            end
            INIT3: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT4;
                end
            end
            INIT4: begin
                //Auto Refresh (REF) 2
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT5; //tCMH = 0.8ns
            end
            INIT5: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT6;
                end
            end
            INIT6: begin
                //Auto Refresh (REF) 3
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT7; //tCMH = 0.8ns
            end
            INIT7: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT8;
                end

            end
            INIT8: begin
                //Auto Refresh (REF) 4
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT9; //tCMH = 0.8ns
            end
            INIT9: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT10;
                end

            end
            INIT10: begin
                //Auto Refresh (REF) 5
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT11; //tCMH = 0.8ns
            end
            INIT11: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT12;
                end
            end
            INIT12: begin
                //Auto Refresh (REF) 6
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT13; //tCMH = 0.8ns
            end
            INIT13: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT14;
                end
            end
            INIT14: begin
                //Auto Refresh (REF) 7
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT15; //tCMH = 0.8ns
            end
            INIT15: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT16;
                end
            end
            INIT16: begin
                //Auto Refresh (REF) 8
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT17; //tCMH = 0.8ns
            end
            INIT17: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT18;
                end
            end
            INIT18: begin
                //Auto Refresh (REF) 9
                cs = 0;
                ras = 0;
                cas = 0;
                we = 1;

                next_state = INIT19; //tCMH = 0.8ns
            end
            INIT19: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd9; //tRC = 60ns
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = INIT20;
                end
            end
            
            INIT20: begin
                //Mode Register Set (MRS)
                cs = 0;
                ras = 0;
                cas = 0;
                we = 0;
                ba = 2'b0;
                a[12:10] = 0;   //See page 26
                a[9] = 1;
                a[8:7] = 2'b0;
                a[6:4] = 3'b011;
                a[3] = 0;
                a[2:0] = 3'b0;


                next_state = INIT21; //tAH = 0.8ns
            end
            INIT21: begin
                //No Operation (NOP)
                cs = 0;
                ras = 1;
                cas = 1;
                we = 1;

                wait_compare = 16'd2; //tMRD = 2 cycles
                wait_reset = 0;
                if(wait_overflow)begin
                    wait_reset = 1;
                    next_state = READY;
                end
            end
            
        endcase
    end

end
endmodule
