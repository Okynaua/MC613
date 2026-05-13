`timescale 1ns/1ps

module dram_controller_tb;

// ======================================================
// SINAIS
// ======================================================

reg clk;
reg reset;

reg [25:0] address;
reg [8:0] data;

reg req;
reg wEn;

wire data_valid;
wire ready;

wire cs, ras, cas, we;
wire [1:0] ba;
wire [12:0] a;
wire [1:0] dqm;
wire cke;

wire [5:0] current_state;

// ======================================================
// DUT
// ======================================================

dram_controller dut (
    .clk(clk),
    .reset(reset),
    .address(address),
    .data(data),
    .req(req),
    .wEn(wEn),
    .data_valid(data_valid),
    .ready(ready),
    .current_state(current_state),
    .cs(cs),
    .ras(ras),
    .cas(cas),
    .we(we),
    .ba(ba),
    .a(a),
    .dqm(dqm),
    .cke(cke)
);

// ======================================================
// CLOCK
// ======================================================

initial clk = 0;
always #5 clk = ~clk;

// ======================================================
// HELPERS
// ======================================================

integer cycles;

task wait_state(input [5:0] st, input integer max_cycles);
begin
    cycles = 0;
    while (current_state !== st && cycles < max_cycles) begin
        @(posedge clk);
        cycles = cycles + 1;
    end

    if (current_state !== st)
        $display("[ERRO] timeout esperando estado %d", st);
    else
        $display("[OK] estado atingido: %d em %0d ciclos", st, cycles);
end
endtask

// ======================================================
// RESET
// ======================================================

task reset_dut;
begin
    reset = 1;
    req   = 0;
    wEn   = 0;
    address = 0;
    data = 0;

    repeat (5) @(posedge clk);
    reset = 0;

    repeat (5) @(posedge clk);
end
endtask

// ======================================================
// TESTE PRINCIPAL
// ======================================================

initial begin

    $display("\n==== INICIO TESTBENCH DRAM CONTROLLER ====");

    // ======================================================
    // RESET / INIT
    // ======================================================

    reset_dut();

    if (ready !== 0)
        $display("[ERRO] INIT deveria ter ready = 0");
    else
        $display("[OK] INIT ready = 0");

    wait_state(6'd62, 100000); // READY

    if (ready !== 1)
        $display("[ERRO] READY nao ativado");
    else
        $display("[OK] READY ativo");

    // ======================================================
    // READY TEST
    // ======================================================

    $display("\n==== TESTE READY ====");

    if (req !== 0)
        $display("[ERRO] req deveria ser 0 em READY");

    // ======================================================
    // READ TEST
    // ======================================================

    $display("\n==== TESTE READ ====");

    address = 26'h123456;
    req = 1;
    wEn = 0;

    @(posedge clk);
    req = 0;

    wait_state(6'd30, 200);

    if (ready !== 0)
        $display("[ERRO] READ deveria setar ready = 0");

    // ACTIVATE
    wait_state(6'd31, 50);

    // READ command
    wait_state(6'd32, 50);

    // CAS latency
    wait_state(6'd34, 50);

    // Data capture (checa comportamento indireto)
    if (data_valid !== 0)
        $display("[INFO] data_valid ativo durante READ");

    // PRECHARGE
    wait_state(6'd35, 50);

    wait_state(6'd36, 50);

    wait_state(6'd62, 200);

    $display("[OK] READ completo");

    // ======================================================
    // WRITE TEST
    // ======================================================

    $display("\n==== TESTE WRITE ====");

    address = 26'hABCDE;
    data = 9'h1AA;

    req = 1;
    wEn = 1;

    @(posedge clk);
    req = 0;

    wait_state(6'd40, 200);

    wait_state(6'd41, 50);

    wait_state(6'd42, 50);

    wait_state(6'd43, 50);

    wait_state(6'd44, 50);

    wait_state(6'd45, 50);

    wait_state(6'd62, 200);

    $display("[OK] WRITE completo");

    // ======================================================
    // REFRESH TEST
    // ======================================================

    $display("\n==== TESTE REFRESH ====");

    wait_state(6'd50, 200);

    wait_state(6'd51, 200);

    wait_state(6'd52, 200);

    wait_state(6'd53, 200);

    wait_state(6'd54, 200);

    wait_state(6'd55, 200);

    wait_state(6'd62, 500);

    $display("[OK] REFRESH completo");

    // ======================================================
    // FINAL
    // ======================================================

    $display("\n==== FIM DOS TESTES DRAM CONTROLLER ====");

    $finish;
end

endmodule