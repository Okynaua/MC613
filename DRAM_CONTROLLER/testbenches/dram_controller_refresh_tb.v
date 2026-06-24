`timescale 1ns/1ps

module dram_controller_refresh_tb();

reg clk;
reg reset;

wire [15:0] data;
wire [7:0] data_to_iface;

wire handshake;
wire ready;
wire [5:0] current_state;

wire CS;
wire RAS;
wire CAS;
wire WE;

dram_controller dut(
    .clk(clk),
    .reset(reset),
    .add(26'b0),
    .data(data),
    .data_from_iface(8'b0),
    .data_to_iface(data_to_iface),
    .req(1'b0),
    .wEn(1'b0),
    .handshake(handshake),
    .ready(ready),
    .current_state(current_state),
    .CS(CS),
    .RAS(RAS),
    .CAS(CAS),
    .WE(WE),
    .BA(),
    .A(),
    .DQM(),
    .CKE()
);

assign data = 16'hZZZZ;

always #10 clk = ~clk;

initial begin
    $display("\n==== INICIO dram_controller_refresh_tb ====\n");
	 
    clk = 0;
    reset = 1;
	 
	 $display("\n==== PRIMEIRO CICLO DE REFRESH ====");

    force dut.current_state = dut.READY;
    #20;
    release dut.current_state;

	 wait(current_state == dut.REFRESH);
	 @(posedge clk);
	 wait(current_state == dut.READY);

    #500;
	 
	 repeat(4) @(posedge clk);
	 
	 $display("\n==== SEGUNDO CICLO DE REFRESH ====");
	 
	 wait(current_state == dut.REFRESH);
	 @(posedge clk);
	 wait(current_state == dut.READY);
	 
	 #500;
	 
	 repeat(4) @(posedge clk);
	 
	 $display("\n==== TERCEIRO CICLO DE REFRESH ====");
	 
	 wait(current_state == dut.REFRESH);
	 @(posedge clk);
	 wait(current_state == dut.READY);
	 
	 #500;
	 
	 $display("\n==== FIM dram_controller_refresh_tb ====\n");
	 
    $finish;
end

//======================================================
// Decodificação dos comandos SDRAM
//======================================================

reg [20*8:1] cmd_name;

always @(*) begin
    if      (!CS && !RAS &&  CAS &&  WE) cmd_name = "ACTIVATE";
    else if (!CS &&  RAS && !CAS && !WE) cmd_name = "WRITE";
    else if (!CS && !RAS &&  CAS && !WE) cmd_name = "PRECHARGE";
    else if (!CS &&  RAS &&  CAS &&  WE) cmd_name = "NOP";
	 else if (!CS && !RAS && !CAS &&  WE) cmd_name = "AUTO REFRESH";
    else                                 cmd_name = "OTHER";
end


//======================================================
// Nome dos estados REFRESH
//======================================================

reg [20*8:1] state_name;

always @(*) begin

    case(current_state)

        dut.REFRESH  : state_name = "REFRESH";
        dut.REFRESH1 : state_name = "REFRESH1";
        dut.REFRESH2 : state_name = "REFRESH2";
        dut.REFRESH3 : state_name = "REFRESH3";
        dut.REFRESH4 : state_name = "REFRESH4";
        dut.REFRESH5 : state_name = "REFRESH5";
        dut.READY    : state_name = "READY";

        default      : state_name = "OTHER";

    endcase

end

//======================================================
// MONITOR
//======================================================

initial begin
    $monitor(
        "T=%0t | state=%0s | CMD=%-10s | CS=%b RAS=%b CAS=%b WE=%b",
        $time,
        state_name,
		  cmd_name,
        dut.CS,
        dut.RAS,
        dut.CAS,
        dut.WE
    );
end

endmodule