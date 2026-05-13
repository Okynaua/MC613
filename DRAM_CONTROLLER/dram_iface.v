module dram_iface(
    input clk,
    input ready,           //states if the controller can receive requests
    input data_valid,       //states if the data from the controller is valid
    input reset,           //KEY[0] active low
    input write_req,       //KEY[3] active low
    input [9:0] SW,        //represents input switcher from the board
    inout [7:0] data,      //connected, eventually, to data input/output from the memory
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

//Logic to use data as inout
wire [7:0] data_out;
wire [7:0] data_in;
assign data = (wEn) ? data_out : 8'bz;
assign data_in = data;

//output assignements
assign address = {SW[9], 1'b0, SW[8], SW[7], SW[6], 19'b0, SW[5], SW[4]}; //as specified
assign data_out = {4'b0, SW[3:0]};                                        //it needs to be 8 bits but only will be controlled by 4 switches

reg [7:0] captured_data_in;       //Register to keep previouscvalid data_in values
reg [9:0] previousSW;             //Register to keep previous values from the switches

//Converts 4 bit values to 7 segment display logic
wire [6:0] hex0, hex1, hex4, hex5;
bin2hex getHex0(
    .BIN(SW[3:0]),
    .HEX(hex0)
);
bin2hex getHex1(
    .BIN(captured_data_in[3:0]),
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

initial begin
    previousSW <= SW;
	 current_state <= 3'b100;
end

always @(posedge clk) begin
    if (ready) begin
        previousSW <= SW;
    end

    if (!reset) begin
        current_state <= READY;
        req <= 0;
        wEn <= 0;
        previousSW <= SW;
        captured_data_in <= 8'b0;

    end else begin

        if(data_valid) begin
            captured_data_in <= data_in;
        end
        
        case(current_state)

            READY: begin
                wEn <= 0;
                req <= 0;

                if (previousSW[9:4] != SW[9:4] && ready) begin 
                    current_state <= REQ_READ;
                end else if (!write_req && ready) begin
                    current_state <= REQ_WRITE;
                end
            end

            REQ_READ: begin
                wEn <= 0;
                req <= 1;
                if (!ready) begin
                    current_state <= WAIT_READ;
                end
            end

            WAIT_READ: begin
                wEn <= 0;
                req <= 0;

                if (ready) begin
                    current_state <= READY;
                end
                
            end

            REQ_WRITE: begin
                wEn <= 1;
                req <= 1;
                if (!ready) begin
                    current_state <= WAIT_WRITE;
                end
            end

            WAIT_WRITE: begin
                wEn <= 0;
                req <= 0;
                
                if (ready) begin
                    current_state <= REQ_READ;
                end
            end

            default: current_state <= READY;
        endcase
    end
end

endmodule
