`timescale 1ns/1ps

module dram_controller_tb();

    // =====================================================
    // PARAMETERS
    // =====================================================

    parameter LABEL_W = 1024;

    parameter INIT     = 6'd00,
              INIT1    = 6'd01,
              INIT2    = 6'd02,
              INIT3    = 6'd03,
              INIT4    = 6'd04,
              INIT5    = 6'd05,
              INIT6    = 6'd06,
              INIT7    = 6'd07,
              INIT8    = 6'd08,
              INIT9    = 6'd09,
              INIT10   = 6'd10,
              INIT11   = 6'd11,
              INIT12   = 6'd12,
              INIT13   = 6'd13,
              INIT14   = 6'd14,
              INIT15   = 6'd15,
              INIT16   = 6'd16,
              INIT17   = 6'd17,
              INIT18   = 6'd18,
              INIT19   = 6'd19,
              INIT20   = 6'd20,
              INIT21   = 6'd21,

              READ     = 6'd30,
              READ1    = 6'd31,
              READ2    = 6'd32,
              READ3    = 6'd33,
              READ4    = 6'd34,
              READ5    = 6'd35,
              READ6    = 6'd36,

              WRITE    = 6'd40,
              WRITE1   = 6'd41,
              WRITE2   = 6'd42,
              WRITE3   = 6'd43,
              WRITE4   = 6'd44,
              WRITE5   = 6'd45,

              REFRESH  = 6'd50,
              REFRESH1 = 6'd51,
              REFRESH2 = 6'd52,
              REFRESH3 = 6'd53,
              REFRESH4 = 6'd54,
              REFRESH5 = 6'd55,

              READY    = 6'd62,
              WAIT     = 6'd63;

    parameter BIN = 0,
              HEX = 1,
				  DEC = 2;

    // =====================================================
    // CLOCK
    // =====================================================

    reg clk;

    initial clk = 0;
    always #3.5 clk = ~clk;

    // =====================================================
    // INPUTS
    // =====================================================

    reg reset;
    reg [25:0] address;
    reg req;
    reg wEn;

    // =====================================================
    // OUTPUTS
    // =====================================================

    wire data_valid;
    wire ready;
    wire [5:0] current_state;

    wire cs;
    wire ras;
    wire cas;
    wire we;

    wire [1:0] ba;
    wire [12:0] a;
    wire [1:0] dqm;
    wire cke;
	 
    // =====================================================
    // BIDIRECTIONAL DATA BUS
    // =====================================================

    reg  [7:0] memory_data;
    wire [7:0] data;

    assign data = (!wEn && data_valid) ? 8'bz : memory_data;

    // =====================================================
    // DUT
    // =====================================================

    dram_controller uut(
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

    // =====================================================
    // ERROR COUNTER
    // =====================================================

    integer error_count;

    // =====================================================
    // VERIFICATION TASK
    // =====================================================

		task expect_signal;
			 input [31:0] observed;
			 input [31:0] expected;
			 input [LABEL_W-1:0] label;
			 input [1:0] format;
		begin
			 #1;

			 if (observed !== expected) begin
				  error_count = error_count + 1;

				  case (format)

						HEX:
							 $display(
								  "[ERRO] %0s | esperado=0x%0h obtido=0x%0h (t=%0t)",
								  label, expected, observed, $time
							 );

						DEC:
							 $display(
								  "[ERRO] %0s | esperado=%0d obtido=%0d (t=%0t)",
								  label, expected, observed, $time
							 );

						default:
							 $display(
								  "[ERRO] %0s | esperado=%0b obtido=%0b (t=%0t)",
								  label, expected, observed, $time
							 );

				  endcase

			 end else begin

				  case (format)

						HEX:
							 $display(
								  "[OK] %0s | valor=0x%0h (t=%0t)",
								  label, observed, $time
							 );

						DEC:
							 $display(
								  "[OK] %0s | valor=%0d (t=%0t)",
								  label, observed, $time
							 );

						default:
							 $display(
								  "[OK] %0s | valor=%0b (t=%0t)",
								  label, observed, $time
							 );

				  endcase

			 end
		end
		endtask

    // =====================================================
    // TEST SEQUENCE
    // =====================================================

    initial begin

        $display("==== INICIO dram_controller_tb ====");

        error_count = 0;

        reset       = 1;
        address     = 26'b0;
        req         = 0;
        wEn         = 0;
        memory_data = 8'hAB;

        // =====================================================
        // RESET / INIT TEST
        // =====================================================

        $display("\n==== TESTE INIT ====");

        #20;

        reset = 0;

        #20;

        expect_signal(ready, 0,
                      "ready=0 durante INIT", BIN);

        expect_signal(current_state, WAIT,
                      "INIT entra em WAIT", DEC);

        // Aguarda INIT1
		  wait(current_state == INIT1);
		  @(negedge clk);
		  #1;

        #20;

        expect_signal(ras, 0,
                      "PRECHARGE enviado durante INIT", BIN);

        expect_signal(cas, 1,
                      "PRECHARGE possui cas=1", BIN);

        expect_signal(we, 0,
                      "PRECHARGE possui we=0", BIN);

        // Aguarda REFRESH
        wait(current_state == INIT2);
		  @(negedge clk);
		  #1;
		  
        expect_signal(ras, 0,
                      "REFRESH possui ras=0", BIN);
		  
		  @(negedge clk);
        expect_signal(cas, 0,
                      "REFRESH possui cas=0", BIN);

        expect_signal(we, 1,
                      "REFRESH possui we=1", BIN);
							 
		  

        // Aguarda MRS
        wait(current_state == INIT20);
		  @(negedge clk);
        #1;

        expect_signal(ras, 0,
                      "MRS possui ras=0", BIN);

        expect_signal(cas, 0,
                      "MRS possui cas=0", BIN);

        expect_signal(we, 0,
                      "MRS possui we=0", BIN);

        // Aguarda READY
        wait(current_state == READY);
		  @(negedge clk);
        #1;

        expect_signal(ready, 1,
                      "Transicao para READY apos INIT", BIN);

        // =====================================================
        // READY TEST
        // =====================================================

        $display("\n==== TESTE READY ====");

        expect_signal(req, 0,
                      "req=0 inicialmente", BIN);

        // =====================================================
        // READ TEST
        // =====================================================

        $display("\n==== TESTE READ ====");

        address = 26'b10110011100011110000111100;

        req = 1;
        wEn = 0;

        #20;

        expect_signal(current_state, READ,
                      "Transicao para READ", DEC);

        expect_signal(ready, 0,
                      "ready=0 durante READ", BIN);

        // ACTIVATE
        #20;

        expect_signal(ras, 0,
                      "ACTIVATE possui ras=0", BIN);

        expect_signal(cas, 1,
                      "ACTIVATE possui cas=1", BIN);

        expect_signal(we, 1,
                      "ACTIVATE possui we=1", BIN);

        expect_signal(ba, address[24:23],
                      "Banco correto no ACTIVATE", BIN);

        expect_signal(a, address[22:10],
                      "Linha correta no ACTIVATE", BIN);

        // READ command
        wait(current_state == READ2);

        #1;

        expect_signal(ras, 1,
                      "READ possui ras=1", BIN);

        expect_signal(cas, 0,
                      "READ possui cas=0", BIN);

        expect_signal(we, 1,
                      "READ possui we=1", BIN);

        expect_signal(a, {3'b0,address[9:0]},
                      "Coluna correta no READ", BIN);

        // Aguarda retorno
        wait(current_state == READ4);

        #1;

        expect_signal(current_state, READ4,
                      "Leitura apos CAS latency", DEC);

        // PRECHARGE
        wait(current_state == READ5);

        #1;

        expect_signal(ras, 0,
                      "PRECHARGE apos READ", BIN);

        expect_signal(we, 0,
                      "PRECHARGE possui we=0", BIN);

        // READY novamente
        wait(current_state == READY);

        #1;

        expect_signal(ready, 1,
                      "Retorno para READY apos READ", BIN);

        // =====================================================
        // WRITE TEST
        // =====================================================

        $display("\n==== TESTE WRITE ====");

        req = 1;
        wEn = 1;

        memory_data = 8'h5A;

        #20;

        expect_signal(current_state, WRITE,
                      "Transicao para WRITE", DEC);

        expect_signal(ready, 0,
                      "ready=0 durante WRITE", BIN);

        // ACTIVATE
        #20;

        expect_signal(ras, 0,
                      "ACTIVATE no WRITE possui ras=0", BIN);

        expect_signal(cas, 1,
                      "ACTIVATE no WRITE possui cas=1", BIN);

        expect_signal(we, 1,
                      "ACTIVATE no WRITE possui we=1", BIN);

        // WRITE command
        wait(current_state == WRITE2);

        #1;

        expect_signal(ras, 1,
                      "WRITE possui ras=1", BIN);

        expect_signal(cas, 0,
                      "WRITE possui cas=0", BIN);

        expect_signal(we, 0,
                      "WRITE possui we=0", BIN);

        expect_signal(a, {3'b0,address[9:0]},
                      "Coluna correta no WRITE", BIN);

        // PRECHARGE
        wait(current_state == WRITE4);

        #1;

        expect_signal(ras, 0,
                      "PRECHARGE apos WRITE", BIN);

        expect_signal(we, 0,
                      "PRECHARGE WRITE possui we=0", BIN);

        // READY novamente
        wait(current_state == READY);

        #1;

        expect_signal(ready, 1,
                      "Retorno para READY apos WRITE", BIN);

        // =====================================================
        // REFRESH TEST
        // =====================================================

        $display("\n==== TESTE REFRESH ====");

        // força refresh
        uut.refresh_counter.counter_value = 1017;

        #20;

        expect_signal(current_state, REFRESH,
                      "Entrada em REFRESH", DEC);

        expect_signal(ready, 0,
                      "ready=0 durante REFRESH", BIN);

        // AUTO REFRESH
        wait(current_state == REFRESH2);

        #1;

        expect_signal(ras, 0,
                      "AUTO REFRESH possui ras=0", BIN);

        expect_signal(cas, 0,
                      "AUTO REFRESH possui cas=0", BIN);

        expect_signal(we, 1,
                      "AUTO REFRESH possui we=1", BIN);

        // READY novamente
        wait(current_state == READY);

        #1;

        expect_signal(ready, 1,
                      "Retorno para READY apos REFRESH", BIN);

        // =====================================================
        // FINAL REPORT
        // =====================================================

        #100;

        $display("\n==== RESULTADO FINAL ====");

        if (error_count == 0)
            $display("[SUCESSO] Todos os testes passaram.");
        else
            $display("[FALHA] Total de erros: %0d", error_count);

        $display("\n==== FIM dram_controller_tb ====");

        $stop;
    end

    // =====================================================
    // MONITOR
    // =====================================================

    initial begin
        $monitor(
            "Tempo=%0t | state=%0d | ready=%b | req=%b | wEn=%b | cs=%b ras=%b cas=%b we=%b | ba=%b | a=%b | data=%h",
            $time,
            current_state,
            ready,
            req,
            wEn,
            cs,
            ras,
            cas,
            we,
            ba,
            a,
            data
        );
    end

endmodule