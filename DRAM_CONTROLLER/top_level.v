module top_level(
    input CLOCK_50,
    input [9:0] SW,
    input [3:0] KEY,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX4,
    output [6:0] HEX5,
    output [9:0] LEDR,
    //dram pins
    output [12:0] DRAM_ADDR,
    output [1:0] DRAM_BA,
    output DRAM_CKE,
    inout [15:0] DRAM_DQ,
    output DRAM_LDQM,
    output DRAM_UDQM,
    output DRAM_CAS_N,
    output DRAM_CS_N,
    output DRAM_WE_N,
    output DRAM_RAS_N,
    output DRAM_CLK
);

//wires for pll
wire internal_clk, ns3_delayed_clk, locked, pll_reset;
assign pll_reset = 0;

assign DRAM_CLK = ns3_delayed_clk;

assign DRAM_DQ[15:8] = 8'bz;

//wires to connect controller and iface
wire wEn, req, ready, handshake;
wire [7:0] iface_data_in, iface_data_out;
wire [25:0] address;

dram_iface interface(
    .clk(internal_clk),
    .ready(ready),
    .reset(KEY[0]),
    .write_req(KEY[3]),
    .SW(SW),
    .data_in(iface_data_in),
    .data_out(iface_data_out),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .address(address),
    .req(req),
    .wEn(wEn),
    .current_state(LEDR[9:7]),
    .handshake(handshake)
);

dram_controller controller(
    .clk(internal_clk),
    .reset(KEY[0]),
    .add(address),
    .data_from_iface(iface_data_out),
    .data_to_iface(iface_data_in),
    .data(DRAM_DQ[7:0]),
    .req(req),
    .wEn(wEn),
    .ready(ready),
    .current_state(LEDR[5:0]),
    .CS(DRAM_CS_N),
    .RAS(DRAM_RAS_N),
    .CAS(DRAM_CAS_N),
    .WE(DRAM_WE_N),
    .BA(DRAM_BA),
    .A(DRAM_ADDR),
    .DQM({DRAM_UDQM, DRAM_LDQM}),
    .CKE(DRAM_CKE),
    .handshake(handshake)
);
pll_143MHz pll(
    .refclk(CLOCK_50),
    .rst(pll_reset),
    .outclk_0(internal_clk),
    .outclk_1(ns3_delayed_clk),  
    .locked(locked)
);
endmodule
