`timescale 1ns/1ps

module dram_controller_write_tb();

reg clk;
reg reset;
reg req;
reg wEn;
reg [25:0] add;
reg [7:0] data_from_iface;

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

//======================================================
// Modelo simplificado da SDRAM
//======================================================

assign data =
    (current_state == dut.WRITE2 ||
     current_state == dut.WRITE3)
    ? 16'h005A
    : 16'hZZZZ;

//======================================================
// DUT
//======================================================

dram_controller dut(
    .clk(clk),
    .reset(reset),
    .add(add),
    .data(data),
    .data_from_iface(data_from_iface),
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

//======================================================
// Clock
//======================================================

always #10 clk = ~clk;

//======================================================
// Decodificação dos comandos SDRAM
//======================================================

reg [20*8:1] cmd_name;

always @(*) begin
    if      (!CS && !RAS &&  CAS &&  WE) cmd_name = "ACTIVATE";
    else if (!CS &&  RAS && !CAS && !WE) cmd_name = "WRITE";
    else if (!CS && !RAS &&  CAS && !WE) cmd_name = "PRECHARGE";
    else if (!CS &&  RAS &&  CAS &&  WE) cmd_name = "NOP";
    else                                 cmd_name = "OTHER";
end

//======================================================
// Nome dos estados
//======================================================

reg [20*8:1] state_name;

always @(*) begin
    case(current_state)

        dut.WRITE  : state_name = "WRITE";
        dut.WRITE1 : state_name = "WRITE1";
        dut.WRITE2 : state_name = "WRITE2";
        dut.WRITE3 : state_name = "WRITE3";
        dut.WRITE4 : state_name = "WRITE4";
        dut.WRITE5 : state_name = "WRITE5";
        dut.READY  : state_name = "READY";

        default    : state_name = "OTHER";

    endcase
end

//======================================================
// Monitor principal
//======================================================

initial begin
    $monitor(
        "T=%0t | %-8s | CMD=%-10s | ready=%b | req=%b | hs=%b | wEn=%b | WE=%b | data_if=%h",
        $time,
        state_name,
        cmd_name,
        ready,
		  req,
        handshake,
		  wEn,
        WE,
        data_from_iface
    );
end

//======================================================
// Sequência de teste
//======================================================

initial begin

    $display("\n==== INICIO dram_controller_write_tb ====\n");

    clk   = 0;
    reset = 1;
    req   = 0;
    wEn   = 1;

    add = 26'h000802;

    data_from_iface = 8'h5A;

    //--------------------------------------------------
    // Começa diretamente em READY
    //--------------------------------------------------

    force dut.current_state = dut.READY;

    #20;

    release dut.current_state;

    //--------------------------------------------------
    // Solicita escrita
    //--------------------------------------------------

    @(posedge clk);

    req = 1;

    wait(handshake);

    $display("\nPASSO 1: REQUISICAO ACEITA");

    req = 0;

    //--------------------------------------------------
    // ACTIVATE
    //--------------------------------------------------

    wait(current_state == dut.WRITE);
    @(posedge clk);

    $display("\nPASSO 2: ACTIVATE (linha selecionada)");

    //--------------------------------------------------
    // tRCD
    //--------------------------------------------------

    wait(current_state == dut.WRITE1);
    @(posedge clk);

    $display("\nPASSO 3: ESPERA tRCD");

    //--------------------------------------------------
    // WRITE
    //--------------------------------------------------

    wait(current_state == dut.WRITE2);
    @(posedge clk);

    $display("\nPASSO 4: COMANDO WRITE");

    //--------------------------------------------------
    // ENVIO DO DADO
    //--------------------------------------------------

    $display(
        "\nPASSO 5: DADO ENVIADO = %h",
        data_from_iface
    );

    //--------------------------------------------------
    // tDPL
    //--------------------------------------------------

    wait(current_state == dut.WRITE3);
    @(posedge clk);

    $display("\nPASSO 6: ESPERA tDPL");

    //--------------------------------------------------
    // PRECHARGE
    //--------------------------------------------------

    wait(current_state == dut.WRITE4);
    @(posedge clk);

    $display("\nPASSO 7: PRECHARGE");

    //--------------------------------------------------
    // tRP
    //--------------------------------------------------

    wait(current_state == dut.WRITE5);
    @(posedge clk);

    $display("\nPASSO 8: ESPERA tRP");

    //--------------------------------------------------
    // READY
    //--------------------------------------------------

    wait(current_state == dut.READY);

    repeat(4) @(posedge clk);

    $display("\n==== FIM dram_controller_write_tb ====");

    $finish;

end

endmodule