`timescale 1ns/1ps

module dram_iface_tb();

    reg clk;
    reg ready;
    reg reset;
    reg write_req;
    reg handshake;
    reg [9:0] SW;
    reg [7:0] data_in;

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
	 
    // -----------------------------------------
    // HEX -> BIN
    // -----------------------------------------

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
	 
	 function [127:0] state_name;
	 	  input [2:0] state;
		  begin
			   case (state)
					 3'b100: state_name = "READY";
					 3'b000: state_name = "REQ_READ";
					 3'b010: state_name = "WAIT_READ";
					 3'b001: state_name = "REQ_WRITE";
					 3'b011: state_name = "WAIT_WRITE";
			   endcase
		  end
	 endfunction

    //------------------------------------------
    // Monitor
    //------------------------------------------
	
    initial begin
        $monitor(
            "Tempo=%0t | state=%s | ready=%b | req=%b | wEn=%b | hs=%b | addr=%h | SW=%b | data_in=%02h | data_out=%02h | HEX=[%h%h %h%h]",
            $time,
            state_name(current_state),
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


    initial begin
	 $display("==== INICIO dram_iface_tb ====");

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
		  wait(current_state == dut.REQ_READ);

        @(posedge clk);
        handshake = 1;

        // controlador aceitou requisição

        @(posedge clk);
        handshake = 0;

        // espera a FSM entrar em WAIT_READ
		  wait(current_state == dut.WAIT_READ);

        ready = 0;

		  // simula controlador ocupado
        repeat(4) @(posedge clk);

        // dado retornado pelo controlador

        data_in = 8'h0A;
        ready = 1;

        // espera voltar para READY
		  wait(current_state == dut.READY);

        //--------------------------------------------------
        // TESTE 2
        // Escrita
        //--------------------------------------------------

        SW[3:0] = 4'h5;

        $display("\n=== ESCRITA DO VALOR 5 ===\n");

        // Pulso do botão KEY3
        // ativo baixo

		  // garante que a leitura anterior terminou
		  wait(current_state == dut.READY);
		  
        @(posedge clk);
        write_req = 0;
		  
		  // mantém pressionado por alguns clocks
		  repeat(3) @(posedge clk);

        write_req = 1;

        // sincronizador interno precisa de alguns clocks

		  // escrita detectada
		  wait(current_state == dut.REQ_WRITE);

		  @(posedge clk);
		  handshake = 1;

		  @(posedge clk);
		  handshake = 0;

		  // espera WAIT_WRITE
		  wait(current_state == dut.WAIT_WRITE);

		  ready = 0;

		  repeat(4) @(posedge clk);

		  ready = 1;

		  // FSM deve iniciar leitura automática
		  wait(current_state == dut.REQ_READ);

		  @(posedge clk);
		  handshake = 1;

		  @(posedge clk);
		  handshake = 0;

		  // leitura em andamento
		  wait(current_state == dut.WAIT_READ);

		  ready = 0;

		  repeat(4) @(posedge clk);

		  data_in = 8'h05;
		  ready = 1;

		  // espera tudo terminar
		  wait(current_state == dut.READY);

        //--------------------------------------------------
        // TESTE 3
        // Nova mudança de endereço
        //--------------------------------------------------

        $display("\n=== NOVA LEITURA ===\n");

		  SW[9:4] = 6'h2A;

		  wait(current_state == dut.REQ_READ);

		  @(posedge clk);
		  handshake = 1;

		  @(posedge clk);
		  handshake = 0;

		  wait(current_state == dut.WAIT_READ);

		  ready = 0;

		  repeat(4) @(posedge clk);

		  data_in = 8'h06;
		  ready = 1;

		  wait(current_state == dut.READY);

        //--------------------------------------------------
        // Final
        //--------------------------------------------------

        $display("\n==== FIM dram_face_tb ====");

        $finish;
    end

endmodule