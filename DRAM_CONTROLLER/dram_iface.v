module dram_iface(
    input clk,
    input reset,
    input ready,
    input [9:0] SW,
    input [3:0] KEY,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [25:0] address,
    inout [7:0] data,
    output reg req,
    output reg wEn,
    output ready_led
);

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

wire [6:0] hex0, hex1, hex4, hex5;

bin2hex getHex0(
    .BIN(data_in[3:0]),
    .HEX(hex0)
);
bin2hex getHex1(
    .BIN(data_out[3:0]),
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

assign address = {SW[9], 1'b0, SW[8], SW[7], SW[6], 19'b0, SW[5], SW[4]}; 
assign HEX0 = hex0;
assign HEX1 = hex1;
assign HEX4 = hex4;
assign HEX5 = hex5;
assign data_out = {4'b0, SW[3:0]};
assign ready_led = ready;


reg [2:0] current_state = READY;
reg [9:0] previousSW;

initial begin
    previousSW <= SW;
end

always @(posedge clk) begin
    if (ready) begin
        previousSW <= SW;
    end

    if (reset) begin
        current_state <= READY;
        req <= 0;
        wEn <= 0;
        previousSW <= SW;

    end else begin
        
        case(current_state)

            READY: begin
                wEn <= 0;
                req <= 0;

                if (previousSW[9:4] != SW[9:4] && ready) begin 
                    current_state <= REQ_READ;
                end else if (!KEY[3] && ready) begin
                    current_state <= REQ_WRITE;
                end
            end

            REQ_READ: begin
                wEn <= 0;
                req <= 1;
                current_state <= WAIT_READ;
            end

            WAIT_READ: begin
                wEn <= 0;
                req <= 0;

                if (ready)begin
                    current_state <= READY;
                end
                
            end

            REQ_WRITE: begin
                wEn <= 1;
                req <= 1;
                current_state <= WAIT_WRITE;
            end

            WAIT_WRITE: begin
                wEn <= 0;
                req <= 0;
                
                if(ready)begin
                    current_state <= REQ_READ;
                end
            end

            default: current_state <= READY;
        endcase
    end
end

endmodule

