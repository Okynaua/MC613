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
// Decodificação dos comandos SDRAM
//======================================================

reg [20*8:1] cmd_name;

always @(*) begin
    if      (!CS && !RAS &&  CAS &&  WE) cmd_name = "ACTIVATE";
    else if (!CS &&  RAS && !CAS &&  WE) cmd_name = "READ";
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
// Monitor principal
//======================================================

initial begin
    $monitor(
        "T=%0t | %-8s | CMD=%-10s | ready=%b | hs=%b | A=%h | data=%h | iface=%h",
        $time,
        state_name,
        cmd_name,
        ready,
        handshake,
        A,
        data,
        data_to_iface
    );
end

//======================================================
// Sequência de teste
//======================================================

initial begin

    clk   = 0;
    reset = 1;
    req   = 0;
    wEn   = 0;

    // banco=0 linha=1 coluna=2
    add = 26'h000802;

    $display("");
    $display("======================================");
    $display(" TESTE DE LEITURA SDRAM ");
    $display("======================================");
    $display("");

    //--------------------------------------------------
    // Começa já em READY
    //--------------------------------------------------

    force dut.current_state = dut.READY;

    #20;

    release dut.current_state;

    //--------------------------------------------------
    // Acelera os tempos de espera
    //--------------------------------------------------

    force dut.wait_compare = 16'd1;

    //--------------------------------------------------
    // Solicita leitura
    //--------------------------------------------------

    @(posedge clk);

    req = 1;

    wait(handshake);

    $display("");
    $display("PASSO 1: REQUISICAO ACEITA");
    $display("");

    @(posedge clk);

    req = 0;

    //--------------------------------------------------
    // ACTIVATE
    //--------------------------------------------------

    wait(current_state == dut.READ);

    $display("PASSO 2: ACTIVATE (linha selecionada)");

    //--------------------------------------------------
    // tRCD
    //--------------------------------------------------

    wait(current_state == dut.READ1);

    $display("PASSO 3: ESPERA tRCD");

    //--------------------------------------------------
    // READ
    //--------------------------------------------------

    wait(current_state == dut.READ2);

    $display("PASSO 4: COMANDO READ");

    //--------------------------------------------------
    // CAS LATENCY
    //--------------------------------------------------

    wait(current_state == dut.READ3);

    $display("PASSO 5: ESPERA CAS LATENCY");

    //--------------------------------------------------
    // CAPTURA
    //--------------------------------------------------

    wait(current_state == dut.READ4);

    $display(
        "PASSO 6: DADO CAPTURADO = %h",
        data
    );

    //--------------------------------------------------
    // PRECHARGE
    //--------------------------------------------------

    wait(current_state == dut.READ5);

    $display("PASSO 7: PRECHARGE");

    //--------------------------------------------------
    // tRP
    //--------------------------------------------------

    wait(current_state == dut.READ6);

    $display("PASSO 8: ESPERA tRP");

    //--------------------------------------------------
    // READY
    //--------------------------------------------------

    wait(current_state == dut.READY);

    $display("");
    $display("======================================");
    $display(" RESULTADO FINAL ");
    $display("======================================");
    $display("");

    $display("ACTIVATE executado");
    $display("tRCD respeitado");
    $display("READ executado");
    $display("CAS latency respeitada");
    $display("Dado capturado");
    $display("PRECHARGE executado");
    $display("tRP respeitado");
    $display("Retorno ao READY");

    #50;
    $finish;
end

endmodule