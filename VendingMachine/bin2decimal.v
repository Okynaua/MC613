module bin24hex(
	input [10:0] bin,
	output [6:0] hex3,
	output [6:0] hex2,
	output [6:0] hex1,
	output [6:0] hex0
);
	wire [15:0] bcd;
	
	bin11_to_bcd get4bcd(
		.bin(bin),
		.bcd(bcd)
	);
	
	bin2hex gethex3(
		.BIN(bcd[15:12]),
		.HEX(hex3)
	);
	
	bin2hex gethex2(
		.BIN(bcd[11:8]),
		.HEX(hex2)
	);
	
	bin2hex gethex1(
		.BIN(bcd[7:4]),
		.HEX(hex1)
	);
	
	bin2hex gethex0(
		.BIN(bcd[3:0]),
		.HEX(hex0)
	);
	
endmodule
	