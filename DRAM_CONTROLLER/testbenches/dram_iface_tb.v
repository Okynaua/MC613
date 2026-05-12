`timescale 1ns/1ps

module dram_iface_tb;

	// Clock and reset
	reg clk;
	reg rst;

	// Board inputs as described by I/O table
	reg [9:0] SW = 10'b1111111111;       // switches (partial address / data)
	reg [3:0] KEY = 4'b0000;      // buttons (KEY[3] = write, KEY[0] = reset)

	// DUT outputs / inouts
	wire [6:0] HEX0, HEX1, HEX4, HEX5;
	wire [25:0] address;
	wire req;
	wire wEn;
	wire [7:0] data;    // bidirectional data bus
	reg ready;          // ready from controller (input to DUT)
    wire ready_led;

	// Testbench drive for the bidir bus. When tb_driving=1 TB drives 'data', otherwise tri-state.
	reg tb_driving;
	reg [7:0] tb_data_out;
	assign data = tb_driving ? tb_data_out : 8'bz;
    reg data_valid = 0;

	// Test helper variables
	integer cycles;
	integer rc;
	integer errors_final;
	integer sampled_addr_int;
	integer sampled_addr_w_int;
	integer expected_read;
	integer expected_write;

	// Instantiate DUT (module not yet implemented in repo). Keep ports matching description.
	// If your `dram_iface` has different port names/ordering, update this instantiation accordingly.
	dram_iface dut (
		.clk(clk),
		.reset(rst),
		.ready(ready),
		.SW(SW),
		.KEY(KEY),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX4(HEX4),
		.HEX5(HEX5),
		.address(address),
		.data(data),
		.req(req),
		.wEn(wEn),
        .data_valid(data_valid),
        .ready_led(ready_led)
	);

	// State machine monitoring helpers
	localparam [2:0] READY_STATE      = 3'b100;
	localparam [2:0] REQ_READ_STATE   = 3'b000;
	localparam [2:0] WAIT_READ_STATE  = 3'b010;
	localparam [2:0] REQ_WRITE_STATE  = 3'b001;
	localparam [2:0] WAIT_WRITE_STATE = 3'b011;

	function [79:0] state_display_name;
		input [2:0] s;
		case (s)
			READY_STATE:      state_display_name = "READY     ";
			REQ_READ_STATE:   state_display_name = "REQ_READ  ";
			WAIT_READ_STATE:  state_display_name = "WAIT_READ ";
			REQ_WRITE_STATE:  state_display_name = "REQ_WRITE ";
			WAIT_WRITE_STATE: state_display_name = "WAIT_WRITE";
			default:          state_display_name = "UNKNOWN   ";
		endcase
	endfunction

	// Clock generation
	initial begin
		clk = 0;
		forever #5 clk = ~clk; // 100MHz-ish (10ns period)
	end

	// Convenience: timeout macro
	localparam integer TIMEOUT = 10000;

	// Helper tasks
	task reset_dut();
	begin
		$display("[%0t] TB: Aplicando reset", $time);
		rst = 1'b0;
		KEY = 4'b1111; // assume unpressed buttons default high
		tb_driving = 0;
		tb_data_out = 8'h00;
		SW = 10'b0;
		ready = 1'b0;
		#20;
		rst = 1'b1;
		#20;
		rst = 1'b0;
		#20;
	end
	endtask

	// Wait helper with timeout
	task wait_for(input cond, input integer max_cycles, output integer cycles_done);
	integer c;
	begin
		c = 0;
		cycles_done = -1;
		while (!cond && c < max_cycles) begin
			@(posedge clk);
			c = c + 1;
		end
		if (cond) cycles_done = c; else cycles_done = -1;
	end
	endtask

	// Simulate controller responding to requests: when TB sees req asserted from DUT, it will lower ready for some cycles
	// and for read operations the TB will drive the data bus with `resp_data` before raising ready back.
	task controller_respond(input [7:0] resp_data, input integer busy_cycles, input drive_data_on_read);
	begin
        @(posedge clk)
        if (req)begin
            // Controller grabs request: indicate busy
            ready = 1'b0;
            
            if (drive_data_on_read) begin
                // allow DUT to release bus, then drive read data
                tb_driving = 1;
                tb_data_out = resp_data;
                data_valid = 0;
            end
            repeat (busy_cycles) @(posedge clk);
            data_valid = drive_data_on_read;
            @(posedge clk);
            if (drive_data_on_read) begin
                tb_driving = 0; // release bus when done
            end
            ready = 1'b1; // signal completion
            data_valid = 1'b0;
            @(posedge clk);
        end
	end
	endtask

	// 7-seg helper (matches VendingMachine/bin2hex.v mapping)
	function [6:0] nibble_to_7seg;
		input [3:0] n;
		begin
			nibble_to_7seg = (n == 4'b0000) ? 7'b1000000 : // 0
			                 (n == 4'b0001) ? 7'b1111001 : // 1
			                 (n == 4'b0010) ? 7'b0100100 : // 2
			                 (n == 4'b0011) ? 7'b0110000 : // 3
			                 (n == 4'b0100) ? 7'b0011001 : // 4
			                 (n == 4'b0101) ? 7'b0010010 : // 5
			                 (n == 4'b0110) ? 7'b0000010 : // 6
			                 (n == 4'b0111) ? 7'b1111000 : // 7
			                 (n == 4'b1000) ? 7'b0000000 : // 8
			                 (n == 4'b1001) ? 7'b0010000 : // 9
			                 (n == 4'b1010) ? 7'b0001000 : // A
			                 (n == 4'b1011) ? 7'b0000011 : // B
			                 (n == 4'b1100) ? 7'b1000110 : // C
			                 (n == 4'b1101) ? 7'b0100001 : // D
			                 (n == 4'b1110) ? 7'b0000110 : // E
			                 (n == 4'b1111) ? 7'b0001110 : // F
			                                    7'b1111111;  // Default: off
		end
	endfunction

	// Test scenarios
	initial begin
		errors_final = 0;

		$display("==== INICIO dram_iface_tb ====");

		// initial conditions
		clk = 0;
		tb_driving = 0;
		tb_data_out = 8'h00;
		ready = 0;
		KEY = 4'b1111;

		// Reset
		reset_dut();
		if (dut.current_state !== READY_STATE) begin
			$display("[ERRO] DUT nao esta no estado READY apos reset (estado=%s)", state_display_name(dut.current_state));
			errors_final = errors_final + 1;
		end else $display("[OK] DUT esta no estado READY apos reset");

		// Bring controller ready for operations
		ready = 1'b1;

		// ----------------------
		// Test 1: Read request flow
		// Assumptions: Changing SW (address switches) while ready==1 should cause a read request.
		// The dram_iface should assert `req` and `wEn` should be low for reads.
		// ----------------------
		$display("\n[TESTE] Fluxo de requisicao de leitura");
		// set an address via SW
		SW = 10'b00_0010_0000; // partial addr
		KEY = 4'b1111; // ensure write button not pressed
        repeat (2) @(posedge clk);
		if (dut.current_state !== REQ_READ_STATE) begin
			$display("[ERRO] DUT nao transitou para REQ_READ apos mudança em SW (estado=%s)", state_display_name(dut.current_state));
			errors_final = errors_final + 1;
		end else $display("[OK] DUT transitou para REQ_READ");

		repeat (3) @(posedge clk);
		if (dut.current_state !== WAIT_READ_STATE) begin
			$display("[ERRO] DUT nao transitou para WAIT_READ (estado=%s)", state_display_name(dut.current_state));
			errors_final = errors_final + 1;
		end else $display("[OK] DUT transitou para WAIT_READ");

		// Wait for DUT to assert req (with timeout)
		cycles = 0;
		while (!req && cycles < 200) begin @(posedge clk); cycles = cycles + 1; end
		if (!req) begin
			$display("[ERRO] DUT nao ativou req para leitura (timeout)");
			errors_final = errors_final + 1;
		end else begin
			if (wEn !== 1'b0) begin
				$display("[ERRO] DUT ativou req mas wEn nao é 0 para leitura (wEn=%b)", wEn);
				errors_final = errors_final + 1;
			end else begin
				$display("[OK] DUT ativou req para leitura, wEn=%b, endereco=%h", wEn, address[9:0]);
			end
			// Sample address when request asserted
			sampled_addr_int = address;
			// expected read value
			expected_read = 8'h5A;
			// Simulate controller: respond with read data 0x5A after 5 cycles
			fork
				controller_respond(8'h5A, 5, 1);
			join

			// after ready returns, ensure req deasserts
			@(posedge clk);
			if (req) begin
				$display("[ERRO] req ainda está ativo apos ready do controlador (esperava desativado)");
			end else begin
				$display("[OK] Leitura concluida, req desativado");
			end

			// Validate HEX outputs: HEX1 should show low nibble of read data; HEX4/HEX5 show parts of address (lower byte nibbles)
			if (HEX1 !== nibble_to_7seg(expected_read[3:0])) begin
				$display("[ERRO] HEX1 incorreto: esperado %b obtido %b", nibble_to_7seg(expected_read[3:0]), HEX1);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX1 mostra nibble baixo lido %h", expected_read[3:0]);

			if (HEX4 !== nibble_to_7seg(sampled_addr_int[3:0])) begin
				$display("[ERRO] HEX4 incorreto (addr [3:0]): esperado %b obtido %b", nibble_to_7seg(sampled_addr_int[7:4]), HEX4);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX4 mostra nibble do endereco %h", sampled_addr_int[7:4]);

			if (HEX5 !== nibble_to_7seg(sampled_addr_int[7:4])) begin
				$display("[ERRO] HEX5 incorreto (addr [7:4]): esperado %b obtido %b", nibble_to_7seg(sampled_addr_int[3:0]), HEX5);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX5 mostra nibble do endereco %h", sampled_addr_int[3:0]);
		end

		// small gap
		repeat (4) @(posedge clk);

		// ----------------------
		// Test 2: Write request flow
		// Assumptions: Pressing KEY[3] while ready==1 should request a write and wEn==1.
		// Data is sent via SW[3:0] (address in SW[9:4]).
		// ----------------------
		$display("\n[TESTE] Fluxo de requisicao de escrita");

		// Prepare write: put data into SW[3:0]
		expected_write = 4'hA; 
		SW = 10'b00_0010_0000 | expected_write[3:0]; // partial addr + data
		// Simulate pressing the write button (active-low)
		KEY = 4'b0111; 

        // Wait for updated read
		repeat (2) @(posedge clk);
		if (dut.current_state !== REQ_WRITE_STATE) begin
			$display("[ERRO] DUT nao transitou para REQ_WRITE ao pressionar KEY (estado=%s)", state_display_name(dut.current_state));
			errors_final = errors_final + 1;
		end else $display("[OK] DUT transitou para REQ_WRITE");

		@(posedge clk);
		// release KEY[3] so we don't trigger multiple writes if ready is 1
		KEY = 4'b1111;

		if (dut.current_state !== WAIT_WRITE_STATE) begin
			$display("[ERRO] DUT nao transitou para WAIT_WRITE (estado=%s)", state_display_name(dut.current_state));
			errors_final = errors_final + 1;
		end else $display("[OK] DUT transitou para WAIT_WRITE");

		// Wait for req
		cycles = 0;
		while (!req && cycles < 200) begin @(posedge clk); cycles = cycles + 1; end
		if (!req) begin
			$display("[ERRO] DUT nao ativou req para escrita (timeout)");
			errors_final = errors_final + 1;
		end else begin
			if (wEn !== 1'b1) begin
				$display("[ERRO] DUT ativou req para escrita mas wEn!=1 (wEn=%b)", wEn);	
				errors_final = errors_final + 1;
			end else begin
				$display("[OK] DUT ativou req para escrita, wEn=%b, endereco=%h, dados no barramento=%h", wEn, address[9:0], data);
			end

			// Sample address when request asserted
			sampled_addr_w_int = address;

			// Controller accepts write: busy for 3 cycles (no data driven by controller)
			fork
				controller_respond(8'h00, 3, 0);
			join

			// After wait_write completes, the FSM should automatically transition to REQ_READ
			@(posedge clk);
			if (dut.current_state !== REQ_READ_STATE) begin
				$display("[ERRO] DUT nao transitou para REQ_READ apos WAIT_WRITE (estado=%s)", state_display_name(dut.current_state));
				errors_final = errors_final + 1;
			end else $display("[OK] DUT transitou para REQ_READ apos escrita");

			@(posedge clk);
			if (dut.current_state !== WAIT_READ_STATE) begin
				$display("[ERRO] DUT nao transitou para WAIT_READ apos escrita/leitura (estado=%s)", state_display_name(dut.current_state));
				errors_final = errors_final + 1;
			end else $display("[OK] DUT transitou para WAIT_READ apos escrita");

			// Simulate controller responding to the automatic read request
			// We drive the data we just "wrote" (expected_write) to verify the internal update
			fork
				controller_respond({4'b0, expected_write[3:0]}, 2, 1);
			join

			// After done
			@(posedge clk);
			if (req) begin
				$display("[ERRO] req ainda está ativo apos ciclo escrita-leitura (esperava desativado)");
			end else begin
				$display("[OK] Ciclo escrita-leitura concluido, req desativado");
			end

			// Validate HEX outputs: 
			// HEX1 should show the data we sent to the controller (data_out[3:0])
			// HEX0 should show the data we just read back from the controller (data_in[3:0])
			if (HEX1 !== nibble_to_7seg(expected_write[3:0])) begin
				$display("[ERRO] HEX1 incorreto (dados escritos): esperado %b obtido %b", nibble_to_7seg(expected_write[3:0]), HEX1);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX1 mostra dados escritos %h", expected_write[3:0]);

			if (HEX0 !== nibble_to_7seg(expected_write[3:0])) begin
				$display("[ERRO] HEX0 incorreto (dados relidos): esperado %b obtido %b", nibble_to_7seg(expected_write[3:0]), HEX0);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX0 mostra dados relidos %h", expected_write[3:0]);

			if (HEX4 !== nibble_to_7seg(sampled_addr_w_int[3:0])) begin
				$display("[ERRO] HEX4 incorreto (addr [3:0]) na escrita: esperado %b obtido %b", nibble_to_7seg(sampled_addr_w_int[3:0]), HEX4);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX4 mostra nibble do endereco %h", sampled_addr_w_int[3:0]);

			if (HEX5 !== nibble_to_7seg(sampled_addr_w_int[7:4])) begin
				$display("[ERRO] HEX5 incorreto (addr [7:4]) na escrita: esperado %b obtido %b", nibble_to_7seg(sampled_addr_w_int[7:4]), HEX5);
				errors_final = errors_final + 1;
			end else $display("[OK] HEX5 mostra nibble do endereco %h", sampled_addr_w_int[7:4]);
		end

		// Release TB drive and buttons
		tb_driving = 0;
		tb_data_out = 8'h00;
		KEY = 4'b1111;

		// Final check / summary
		if (errors_final == 0) begin
			$display("\n==== dram_iface_tb: TODOS OS TESTES PASSARAM ====");
		end else begin
			$display("\n==== dram_iface_tb: %0d ERROS ====", errors_final);
		end

		$finish;
	end

endmodule
