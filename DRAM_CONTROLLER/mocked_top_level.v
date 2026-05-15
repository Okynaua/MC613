//módulo criado para testar o dram_iface
module mocked_top_level( 
    input CLOCK_50,
    input [3:0] KEY,       //represents the key inputs from the board (KEY[3] wEn and KEY[0] reset)
    input [9:0] SW,        //represents input switcher from the board
    output [6:0] HEX0,     //represents hex displays from the board
    output [6:0] HEX1,     //
    output [6:0] HEX4,     //
    output [6:0] HEX5,     //
    output [9:0] LEDR
);


parameter SREADY      = 2'b00,
          READING   = 2'b10,
          WRITING  = 2'b11;

reg [15:0] memory;
reg [1:0] current_state = SREADY;


wire req, wEn;
wire [25:0] address;

reg ready;
reg data_valid;

//Logic to use data as inout
wire [7:0] modata;
reg [7:0] modata_out = 8'b11110101;
wire [7:0] modata_in;
assign modata = (!wEn) ? modata_out : 8'bz;
assign modata_in = modata;

wire [2:0] iface_state;

dram_iface interface(
    .clk(CLOCK_50),
    .ready(ready),
    .data_valid(data_valid),
    .reset(KEY[0]),
    .write_req(KEY[3]),
    .SW(SW),
    .data(modata),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .address(address),
    .req(req),
    .wEn(wEn),
    .CS(iface_state)
);

//debug leds
assign  LEDR[0] = ready,
        LEDR[1] = data_valid,
        LEDR[2] = KEY[0],
        LEDR[3] = req,
        LEDR[4] = wEn,
        LEDR[5] = current_state[0],
        LEDR[6] = current_state[1],
        LEDR[7] = iface_state[0],
        LEDR[8] = iface_state[1],
        LEDR[9] = iface_state[2];

always @(posedge CLOCK_50) begin
    if (!KEY) begin
        current_state <= SREADY;
        ready <= 1;
    end else begin
        case(current_state)
            SREADY: begin
                ready <= 1;
                data_valid <= 1; 
                if (req) begin
                    ready <= 0; // Abaixa o ready IMEDIATAMENTE ao ver req
                    current_state <= (wEn) ? WRITING : READING;
                end
            end
            READING: begin
                // Simula latência de memória: fica aqui enquanto req estiver alto
                modata_out <= SW ? memory[15:8] : memory[7:0];
                if (!req) current_state <= SREADY;
            end
            WRITING: begin
                if (SW) memory[15:8] <= modata_in;
                else      memory[7:0]  <= modata_in;
                if (!req) current_state <= SREADY;
            end
        endcase
    end
end
endmodule