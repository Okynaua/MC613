`timescale 1ns/1ps

 module dram_controller_tb();
    reg clk;

    reg reset;
    reg [25:0] address;
    
    wire [7:0] data;

    reg req;
    reg wEn;

    wire data_valid;
    wire ready;
    wire [5:0] controller_state;

    wire cs;
    wire ras;
    wire cas;
    wire we;

    wire [1:0] ba;
    wire [12:0] a;
    wire [1:0] dqm;
    wire cke;


    initial clk = 0;
    always #3.5 clk = ~clk; // Clock de ~143MHz (período de 7ns)

    reg [7:0] data_out;
    wire [7:0] data_in = data;
    assign data = (wEn || !data_valid) ? data_out : 8'bz;


    wire [23:0] commandName;
    command2str getStr(
        .cs(cs),
        .ras(ras),
        .cas(cas),
        .we(we),
        .cmd(commandName)
    );

    dram_controler controller(
        .clk(clk),
        .reset(reset),
        .address(address),
        .data(data),
        .req(req),
        .wEn(wEn),
        .data_valid(data_valid),
        .ready(ready),
        .current_state(controller_state),
        .cs(cs),
        .ras(ras),
        .cas(cas),
        .we(we),
        .ba(ba),
        .a(a),
        .dqm(dqm),
        .cke(cke)
    );

    initial begin
        reset = 0;
        address = 26'b0;
        data_out = 8'b0;
        req = 0;
        wEn = 0;
        #220000;

        $stop;
    end

    initial begin
        $monitor("Tempo: %0t | reset: %b | address: %b | data: %b | req: %b | wEn: %b | data_valid: %b | ready: %b | controller_state: %d | commandName: %c%c%c | a: %b | dqm: %b | cke: %b", $time, reset, address, data, req, wEn, data_valid, ready, controller_state, commandName[23:16], commandName[15:8], commandName[7:0], a, dqm, cke);
    end
    
 endmodule

module command2str(
    input cs,
    input ras,
    input cas,
    input we,
    output [23:0] cmd  //3 bytes = 3 char
);

assign cmd = ({cs, ras, cas, we} == 4'b0111) ? 23'b010011100100111101010000 : // NOP
             ({cs, ras, cas, we} == 4'b0011) ? 23'b010000010100001001010100 : // ACT
             ({cs, ras, cas, we} == 4'b0101) ? 23'b010100100100010101000100 : // RED
             ({cs, ras, cas, we} == 4'b0010) ? 23'b010100000101001001000101 : // PRE
             ({cs, ras, cas, we} == 4'b0100) ? 23'b010101110101001001010100 : // WRT
             ({cs, ras, cas, we} == 4'b0001) ? 23'b010100100100010101000110 : // REF
             ({cs, ras, cas, we} == 4'b0000) ? 23'b010011010101001001010011 : // MRS
                                               23'b010001010101001001010010;  // ERR

endmodule