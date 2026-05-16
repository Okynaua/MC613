module dram_iface(
    input clk,
    input ready,           //states if the controller can receive requests
    input reset,           //KEY[0] active low
    input write_req,       //KEY[3] active low
    input handshake,
    input [9:0] SW,        //represents input switcher from the board
    input [7:0] data_in,
    output [7:0] data_out,
    output [6:0] HEX0,     //represents hex displays from the board
    output [6:0] HEX1,     //
    output [6:0] HEX4,     //
    output [6:0] HEX5,     //
    output [25:0] address, //{SW[9], 1'b0, SW[8], SW[7], SW[6], 19'b0, SW[5], SW[4]} as specified
    output reg req,        //states if the iface is sending a request
    output reg wEn,         //especifies writing request
    output reg [2:0] current_state
);

//Internal states
parameter READY      = 3'b100,
          REQ_READ   = 3'b000,
          WAIT_READ  = 3'b010,
          REQ_WRITE  = 3'b001,
          WAIT_WRITE = 3'b011;

reg [9:0] previousSW;             //Register to keep previous values from the switches
reg next_wEn, next_req;

//output assignements
assign address = {SW[9], 1'b0, SW[8], SW[7], SW[6], 19'b0, SW[5], SW[4]}; //as specified
assign data_out = {4'b0, SW[3:0]};                                        //it needs to be 8 bits but only will be controlled by 4 switches

//Converts 4 bit values to 7 segment display logic
wire [6:0] hex0, hex1, hex4, hex5;
bin2hex getHex0(
    .BIN(SW[3:0]),
    .HEX(hex0)
);
bin2hex getHex1(
    .BIN(data_in[3:0]),
    .HEX(hex1)
);
bin2hex getHex4(
    .BIN({2'b0, SW[5], SW[4]}),
    .HEX(hex4)
);
bin2hex getHex5(
    .BIN({SW[9:6]}),
    .HEX(hex5)
);
assign HEX0 = hex0;
assign HEX1 = hex1;
assign HEX4 = hex4;
assign HEX5 = hex5;

reg wr_req_sync0;
reg wr_req_sync1;
reg previousWrReq;
wire write_pulse = (!wr_req_sync1 && previousWrReq);

initial begin
    previousSW <= 10'b0;
	current_state <= READY;
    previousWrReq <= 1;
    next_req <= 0;
    next_wEn <= 0;
end

//Output combinational logic
always @(*) begin
    if (!reset) begin
        next_req = 0;
        next_wEn = 0;
    end else begin
        
        case(current_state)
            READY: begin
                next_wEn = 0;
                next_req = 0;
            end
            REQ_READ: begin
                next_wEn = 0;
                next_req = 1;
            end
            WAIT_READ: begin
                next_wEn = 0;
                next_req = 0;
            end
            REQ_WRITE: begin
                next_wEn = 1;
                next_req = 1;
            end
            WAIT_WRITE: begin
                next_wEn = 0;
                next_req = 0;
            end
        endcase
    end
end


//Next state sequencial logic
always @(posedge clk) begin
    previousWrReq <= write_req;
    wEn <= next_wEn;
    req <= next_req;
    if (!reset) begin
        wr_req_sync0  <= 1'b1;
        wr_req_sync1  <= 1'b1;
        previousWrReq <= 1'b1;
        current_state <= READY;
        previousSW <= SW;
    end else begin

        wr_req_sync0  <= write_req;
        wr_req_sync1  <= wr_req_sync0;
        previousWrReq <= wr_req_sync1;

        case(current_state)

            READY: begin
                if (previousSW[9:4] != SW[9:4]) begin 
                    current_state <= REQ_READ;
                end else if (write_pulse) begin
                    current_state <= REQ_WRITE;
                end
            end

            REQ_READ: begin
                if (handshake) begin
                    current_state <= WAIT_READ;
                end
            end

            WAIT_READ: begin
                if (ready) begin
                    previousSW <= SW;
                    current_state <= READY;
                end   
            end

            REQ_WRITE: begin
                if (handshake) begin
                    current_state <= WAIT_WRITE;
                end
            end

            WAIT_WRITE: begin
                if(ready)begin
                    current_state <= REQ_READ;
                end
            end

            default: current_state <= READY;
        endcase
    end
end
endmodule
