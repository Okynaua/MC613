`timescale 1ns/1ps

module dram_controller_read_tb();

reg clk;
reg reset;
reg req;
reg wEn;
reg [25:0] add;

wire [7:0] data_to_iface;
wire [15:0] data;
wire handshake;
wire ready;
wire [5:0] current_state;

wire CS;
wire RAS;
wire CAS;
wire WE;
wire [12:0] A;

assign data = 16'hABCD;   // dado retornado pela SDRAM

dram_controller dut(
    .clk(clk),
    .reset(reset),
    .add(add),
    .data(data),
    .data_from_iface(8'h00),
    .data_to_iface(data_to_iface),
    .req(req),
    .wEn(wEn),
    .handshake(handshake),
    .ready(ready),
    .current_state(current_state),

    .CS(CS),
    .RAS(RAS),
    .CAS(CAS),
    .WE(WE),
    .BA(),
    .A(A),
    .DQM(),
    .CKE()
);

always #10 clk = ~clk;

//======================================================
// Decodificacao dos comandos SDRAM
//======================================================

reg [20*8:1] cmd_name;

always @(*) begin
    if      (!CS && !RAS &&  CAS &&  WE) cmd_name = "ACTIVATE";
    else if (!CS &&  RAS && !CAS &&  WE) cmd_name = "READ";
    else if (!CS && !RAS &&  CAS && !WE) cmd_name = "PRECHARGE";
    else if (!CS &&  RAS &&  CAS &&  WE) cmd_name = "NOP";
    else if (!CS && !RAS && !CAS &&  WE) cmd_name = "AUTO REFRESH";
    else                                 cmd_name = "OTHER";
end

//======================================================
// Nome dos estados READ
//======================================================

reg [20*8:1] state_name;

always @(*) begin
    case(current_state)
        dut.READ   : state_name = "READ";
        dut.READ1  : state_name = "READ1";
        dut.READ2  : state_name = "READ2";
        dut.READ3  : state_name = "READ3";
        dut.READ4  : state_name = "READ4";
        dut.READ5  : state_name = "READ5";
        dut.READ6  : state_name = "READ6";
        dut.READY  : state_name = "READY";
        default    : state_name = "OTHER";
    endcase
end

//======================================================
// Monitor
//======================================================

initial begin
    $monitor(
        "T=%0t | %-8s | CMD=%-10s | ready=%b | hs=%b | data=%h | iface=%h",
        $time,
        state_name,
        cmd_name,
        ready,
        handshake,
        data,
        data_to_iface
    );
end

//======================================================
// Sequência de teste
//======================================================

initial begin
	 $display("\n==== INICIO dram_controller_init_tb ====\n");

    clk   = 0;
    reset = 1;
    req   = 0;
    wEn   = 0;

    // banco=0 linha=1 coluna=2
    add = 26'h000802;

    //--------------------------------------------------
    // Começa já em READY
    //--------------------------------------------------

    force dut.current_state = dut.READY;

    #20;

    release dut.current_state;

    //--------------------------------------------------
    // Solicita leitura
    //--------------------------------------------------

    @(posedge clk);

    req = 1;

    wait(handshake);

    $display("\nPASSO 1: REQUISICAO ACEITA");

    req = 0;

    //--------------------------------------------------
    // ACTIVATE
    //--------------------------------------------------

    wait(current_state == dut.READ);
	 @(posedge clk);
    $display("\nPASSO 2: ACTIVATE (linha selecionada)");

    //--------------------------------------------------
    // tRCD
    //--------------------------------------------------

    wait(current_state == dut.READ1);
	 @(posedge clk);
    $display("\nPASSO 3: ESPERA tRCD");

    //--------------------------------------------------
    // READ
    //--------------------------------------------------

    wait(current_state == dut.READ2);
	 @(posedge clk);
    $display("\nPASSO 4: COMANDO READ");

    //--------------------------------------------------
    // CAS LATENCY
    //--------------------------------------------------

    wait(current_state == dut.READ3);
	 @(posedge clk);
    $display("\nPASSO 5: ESPERA CAS LATENCY");

    //--------------------------------------------------
    // CAPTURA
    //--------------------------------------------------

    wait(current_state == dut.READ4);
	 @(posedge clk);
    $display(
        "\nPASSO 6: DADO CAPTURADO = %h",
        data
    );

    //--------------------------------------------------
    // PRECHARGE
    //--------------------------------------------------

    wait(current_state == dut.READ5);
	 @(posedge clk);
    $display("\nPASSO 7: PRECHARGE");

    //--------------------------------------------------
    // tRP
    //--------------------------------------------------

    wait(current_state == dut.READ6);
	 @(posedge clk);
    $display("\nPASSO 8: ESPERA tRP");

    //--------------------------------------------------
    // READY
    //--------------------------------------------------

    wait(current_state == dut.READY);
	 
	 repeat(4) @(posedge clk);	 

    #50;
	 $display("\n==== FIM dram_controller_read_tb ====");
	 
    $finish;
end

endmodule