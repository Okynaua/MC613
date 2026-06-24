`timescale 1ns/1ps

module dram_iface_tb;

    // Entradas
    reg clk;
    reg ready;
    reg reset;
    reg write_req;
    reg handshake;
    reg [9:0] SW;
    reg [7:0] data_in;

    // Saídas
    wire [7:0] data_out;
    wire [6:0] HEX0;
    wire [6:0] HEX1;
    wire [6:0] HEX4;
    wire [6:0] HEX5;
    wire [25:0] address;
    wire req;
    wire wEn;
    wire [2:0] current_state;

    //------------------------------------------
    // DUT
    //------------------------------------------
    dram_iface dut (
        .clk(clk),
        .ready(ready),
        .reset(reset),
        .write_req(write_req),
        .handshake(handshake),
        .SW(SW),
        .data_in(data_in),
        .data_out(data_out),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .address(address),
        .req(req),
        .wEn(wEn),
        .current_state(current_state)
    );

    //------------------------------------------
    // Clock 50 MHz
    //------------------------------------------
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
	 
    // =====================================================
    // HEX -> BIN
    // =====================================================

    wire [3:0] BIN0, BIN1, BIN4, BIN5;

    hex2bin getBin0 (
        .HEX(HEX0),
        .BIN(BIN0)
    );

    hex2bin getBin1 (
        .HEX(HEX1),
        .BIN(BIN1)
    );

    hex2bin getBin4 (
        .HEX(HEX4),
        .BIN(BIN4)
    );

    hex2bin getBin5 (
        .HEX(HEX5),
        .BIN(BIN5)
    );

    //------------------------------------------
    // Monitor
    //------------------------------------------
	
    initial begin
        $monitor(
            "Tempo=%0t | state=%b | ready=%b | req=%b | wEn=%b | hs=%b | addr=%h | SW=%03h | data_in=%02h | data_out=%02h | HEX=[%h%h %h%h]",
            $time,
            current_state,
            ready,
            req,
            wEn,
            handshake,
            address,
            SW,
            data_in,
            data_out,
            BIN5,
            BIN4,
            BIN1,
            BIN0
        );
    end

    //------------------------------------------
    // Estímulos
    //------------------------------------------
    initial begin

        // valores iniciais
        ready      = 1;
        handshake  = 0;
        write_req  = 1;     // botão solto (ativo baixo)
        reset      = 0;     // reset ativo
        SW         = 10'b0;
        data_in    = 8'h00;

        //--------------------------------------------------
        // RESET
        //--------------------------------------------------
        #20;
        reset = 1;

        $display("\n=== RESET FINALIZADO ===\n");

        //--------------------------------------------------
        // TESTE 1
        // Mudança de endereço -> leitura automática
        //--------------------------------------------------

        #20;

        SW[9:4] = 6'h01;

        $display("\n=== ALTERACAO DE ENDERECO ===\n");

        // iface deve entrar em REQ_READ

        #20;
        handshake = 1;

        // controlador aceitou requisição

        #10;
        handshake = 0;

        // leitura em andamento

        ready = 0;

        #40;

        // dado retornado pelo controlador

        data_in = 8'h0A;

        ready = 1;

        #40;

        //--------------------------------------------------
        // TESTE 2
        // Escrita
        //--------------------------------------------------

        SW[3:0] = 4'h5;

        $display("\n=== ESCRITA DO VALOR 5 ===\n");

        // Pulso do botão KEY3
        // ativo baixo

        #20;
        write_req = 0;

        #20;
        write_req = 1;

        // sincronizador interno precisa de alguns clocks

        #60;

        // controlador aceita escrita

        handshake = 1;

        #10;
        handshake = 0;

        ready = 0;

        #50;

        // escrita concluída

        ready = 1;

        //--------------------------------------------------
        // após WAIT_WRITE
        // FSM deve iniciar REQ_READ automaticamente
        //--------------------------------------------------

        #20;

        handshake = 1;

        #10;
        handshake = 0;

        ready = 0;

        #40;

        data_in = 8'h05;

        ready = 1;

        #50;

        //--------------------------------------------------
        // TESTE 3
        // Nova mudança de endereço
        //--------------------------------------------------

        $display("\n=== NOVA LEITURA ===\n");

        SW[9:4] = 6'h2A;

        #30;

        handshake = 1;

        #10;
        handshake = 0;

        ready = 0;

        #50;

        data_in = 8'h06;

        ready = 1;

        #50;

        //--------------------------------------------------
        // Final
        //--------------------------------------------------

        $display("\n=== FIM DA SIMULACAO ===\n");

        $finish;
    end

endmodule