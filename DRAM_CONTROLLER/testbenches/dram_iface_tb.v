`timescale 1ns/1ps

module dram_iface_tb();

    reg clk;
    reg ready;
    reg data_valid;
    reg [3:0] key;
    reg [9:0] sw;
    wire wEn;
    wire req;
    wire [25:0] address;
    wire [6:0] hex0, hex1, hex4, hex5;
	 wire [2:0] iface_state;
	
    wire [7:0] modata;
    reg [7:0] modata_out;
    assign modata = (!wEn) ? modata_out : 8'bz;
    
    //143MHz clockS
    initial clk = 0;
    always #3.5 clk = ~clk;

    dram_iface interface(
        .clk(clk),
        .ready(ready),
        .data_valid(data_valid),
        .reset(key[0]),
        .write_req(key[3]),
        .SW(sw),
        .data(modata),
        .HEX0(hex0),
        .HEX1(hex1),
        .HEX4(hex4),
        .HEX5(hex5),
        .address(address),
        .req(req),
        .wEn(wEn),
		.current_state(iface_state)
    );
	 
	 wire [3:0] bin0, bin1, bin4, bin5;
	 hex2bin getBin0(
		.HEX(hex0),
		.BIN(bin0)
	 );
	 hex2bin getBin1(
		.HEX(hex1),
		.BIN(bin1)
	 );
	 hex2bin getBin4(
		.HEX(hex4),
		.BIN(bin4)
	 );
	 hex2bin getBin5(
		.HEX(hex5),
		.BIN(bin5)
	 );

	

    initial begin
        $display("Initializing Simulation");
        key = 4'b1111;
        sw  = 10'b0;
        ready = 1;
        data_valid = 1;
        modata_out = 8'd255;
		  #100;
        $display("Inicial Reset");
        key[0] = 0;
        #100; key = 4'b1111;
        #1000;

        $display("Reading");
        $display(" -> REQ_READ");
        sw = 10'd1023;
        #100;
        $display(" -> WAI_READ");
        ready = 0;
        data_valid = 0;
        #100;
        $display(" -> READY");
        ready = 1;
        data_valid = 1;
        #100;

        $display("Writing");
        $display(" -> REQ_WRITE");
        sw[3:0] = 4'b1010;
        #50;
        key[3] = 0;
        #100;
        key[3]=1;
        $display(" -> WAIT_WRITE");
        ready = 0;
        data_valid = 0;
        modata_out = modata;
        #100;
        $display(" -> REQ_READ");
        ready = 1;
        data_valid = 1;
        #100;
        ready = 0;
        data_valid = 0;
		  #100;
        $display(" -> WAIT_READ");
        ready = 1;
        data_valid = 1;




        #1000
        $stop;
    end

  
    initial begin
        $monitor("Tempo: %0t | SW: %b | KEY: %b | data: %b | ready: %b | data_valid: %b | wEn: %b | req: %b | address: %b | iface_state: %b | displays: %h %h  %h %h", $time, sw, key, modata, ready, data_valid, wEn, req, address, iface_state, bin5, bin4, bin1, bin0);
    end

endmodule