module top_level (
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

assign DRAM_CLK = internal_clk;

//wires to connect controller and iface
wire wEn, req, ready, data_valid;
wire [25:0] address;

dram_iface interface(
    .clk(internal_clk),
    .ready(ready),
    .data_valid(data_valid),
    .reset(KEY[0]),
    .write_req(KEY[3]),
    .SW(SW),
    .data(DRAM_DQ[7:0]),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX4(HEX4),
    .HEX5(HEX5),
    .address(address),
    .req(req),
    .wEn(wEn),
    .current_state(LEDR[9:7])
);
dram_controller controller(
    .clk(internal_clk),
    .reset(KEY[0]),
    .address(address),
    .data(DRAM_DQ[7:0]),
    .req(req),
    .wEn(wEn),
    .data_valid(data_valid),
    .ready(ready),
    .current_state(LEDR[5:0]),
    .cs(DRAM_CS_N),
    .ras(DRAM_RAS_N),
    .cas(DRAM_CAS_N),
    .we(DRAM_WE_N),
    .ba(DRAM_BA),
    .a(DRAM_ADDR),
    .dqm({DRAM_UDQM, DRAM_LDQM}),
    .cke(DRAM_CKE)
);
pll_143MHz pll(
    .refclk(CLOCK_50),
    .rst(pll_reset),
    .outclk_0(internal_clk),
    .outclk_1(ns3_delayed_clk),  
    .locked(locked)
);
endmodule
