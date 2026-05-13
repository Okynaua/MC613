`timescale 1ns/1ps

module dram_iface_tb();

    // =====================================================
    // PARAMETERS
    // =====================================================

    parameter LABEL_W = 1024;

    parameter READY      = 3'b100,
              REQ_READ   = 3'b000,
              WAIT_READ  = 3'b010,
              REQ_WRITE  = 3'b001,
              WAIT_WRITE = 3'b011;
				  
	 parameter BIN = 0,
				  HEX = 1;

    // =====================================================
    // CLOCK
    // =====================================================

    reg clk;

    initial clk = 0;
    always #3.5 clk = ~clk; // ~143 MHz

    // =====================================================
    // INPUTS
    // =====================================================

    reg ready;
    reg data_valid;
    reg reset;
    reg write_req;
    reg [9:0] SW;

    // =====================================================
    // OUTPUTS
    // =====================================================

    wire [6:0] HEX0;
    wire [6:0] HEX1;
    wire [6:0] HEX4;
    wire [6:0] HEX5;

    wire [25:0] address;
    wire req;
    wire wEn;
    wire [2:0] current_state;
	 
    // =====================================================
    // BIDIRECTIONAL DATA BUS
    // =====================================================

    reg  [7:0] data_mem;
    wire [7:0] data;

    // =====================================================
    // DUT
    // =====================================================

    dram_iface uut(
        .clk(clk),
        .ready(ready),
        .data_valid(data_valid),
        .reset(reset),
        .write_req(write_req),
        .SW(SW),
        .data(data),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .address(address),
        .req(req),
        .wEn(wEn),
        .current_state(current_state)
    );

    assign data = (wEn) ? 8'bz : data_mem;

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
		 input format;
	 begin
		 #1;

		 if (observed !== expected) begin
			  error_count = error_count + 1;

			  if (format == HEX)
					$display("[ERRO] %0s | esperado=0x%0h obtido=0x%0h (t=%0t)",
								label, expected, observed, $time);
			  else
					$display("[ERRO] %0s | esperado=%0b obtido=%0b (t=%0t)",
								label, expected, observed, $time);

		 end else begin

			  if (format == HEX)
					$display("[OK] %0s | valor=0x%0h (t=%0t)",
								label, observed, $time);
			  else
					$display("[OK] %0s | valor=%0b (t=%0t)",
								label, observed, $time);

		 end
	 end
	 endtask

    // =====================================================
    // TEST SEQUENCE
    // =====================================================

    initial begin

        $display("==== INICIO dram_iface_tb ====");

        error_count = 0;

        // Initial values
        ready      = 0;
        data_valid = 0;
        reset      = 0;
        write_req  = 1;
        SW         = 10'b0;
        data_mem   = 8'h00;

        // =====================================================
        // RESET TEST
        // =====================================================

        $display("\n==== TESTE RESET ====");

        #20;

        reset = 1;
        ready = 1;

        #20;

        expect_signal(current_state, READY,
                      "Estado READY apos reset", BIN);

        // =====================================================
        // READ TEST
        // =====================================================

        $display("\n==== TESTE LEITURA ====");

        SW[9:4] = 6'b101010;

        #20;

        expect_signal(current_state, REQ_READ,
                      "Mudanca para REQ_READ apos mudanca em SW[9:4]", BIN);

        expect_signal(wEn, 0,
                      "wEn=0 durante REQ_READ", BIN);

        expect_signal(req, 1,
                      "req=1 durante REQ_READ", BIN);

        expect_signal(
            address,
            {SW[9],1'b0,SW[8],SW[7],SW[6],19'b0,SW[5],SW[4]},
            "Endereco correto conforme projeto", BIN
        );
		  
        expect_signal(BIN4, {2'b0, SW[5], SW[4]},
                      "HEX4 mostra SW[5:4] conforme projeto", HEX);

        expect_signal(BIN5, SW[9:6],
                      "HEX5 mostra SW[9:6] conforme projeto", HEX);

        // Controller busy
        ready = 0;

        #20;

        expect_signal(current_state, WAIT_READ,
                      "Mudanca para WAIT_READ apos ready=0", BIN);

        // Must stay waiting
        #50;

        expect_signal(current_state, WAIT_READ,
                      "Permanece em WAIT_READ enquanto ready=0", BIN);

        // Memory returns data
        data_mem   = 8'hAB;
        ready      = 1;
        data_valid = 1;

        #20;

        expect_signal(current_state, READY,
                      "Mudanca para READY quando ready=1 e data_valid=1", BIN);

        expect_signal(BIN1, 4'hAB,
                      "HEX1 mostra dado lido da memoria", HEX);

        data_valid = 0;

        // =====================================================
        // WRITE TEST
        // =====================================================

        $display("\n==== TESTE ESCRITA ====");

        SW[3:0] = 4'hD;

        // KEY[3] active low
        write_req = 0;

        #20;

        expect_signal(current_state, REQ_WRITE,
                      "Mudanca para REQ_WRITE apos mudanca em KEY[3]", BIN);

        expect_signal(wEn, 1,
                      "wEn=1 durante REQ_WRITE", BIN);

        expect_signal(req, 1,
                      "req=1 durante REQ_WRITE", BIN);

        // Controller busy
        ready = 0;

        #20;

        expect_signal(current_state, WAIT_WRITE,
                      "Mudanca para WAIT_WRITE apos ready=0", BIN);

        // Must stay waiting
        #50;

        expect_signal(current_state, WAIT_WRITE,
                      "Permanece em WAIT_WRITE enquanto ready=0", BIN);

        // Finish write
        ready      = 1;
        data_valid = 1;

        #20;

        expect_signal(current_state, REQ_READ,
                      "Mudanca para REQ_READ apos ready=1 e data_valid=1", BIN);

        expect_signal(BIN0, 4'hD,
                      "HEX0 mostra dado escrito", HEX);

        data_valid = 0;
        write_req  = 1;

        // =====================================================
        // FINAL REPORT
        // =====================================================

        #100;

        $display("\n==== RESULTADO FINAL ====");

        if (error_count == 0) begin
            $display("[SUCESSO] Todos os testes passaram.");
        end
        else begin
            $display("[FALHA] Total de erros: %0d", error_count);
        end

        $display("\n==== FIM dram_iface_tb ====");

        $stop;
    end

    // =====================================================
    // MONITOR
    // =====================================================

    initial begin
        $monitor(
            "Tempo=%0t | state=%b | ready=%b | req=%b | wEn=%b | addr=%b | data=%h | HEX=%h%h %h%h",
            $time,
            current_state,
            ready,
            req,
            wEn,
            address,
            data,
            BIN5,
            BIN4,
            BIN1,
            BIN0
        );
    end

endmodule