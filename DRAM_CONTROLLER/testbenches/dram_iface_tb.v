`timescale 1ns/1ps

module dram_iface_tb;

	// Clock and reset
	reg clk;
	reg rst;

	// Board inputs as described by I/O table
	reg [9:0] SW;       // switches (partial address / data)
	reg [3:0] KEY;      // buttons (KEY[3] = write, KEY[0] = reset)

	// DUT outputs / inouts
	wire [6:0] HEX0, HEX1, HEX4, HEX5;
	wire [25:0] address;
	wire req;
	wire wEn;
	wire [7:0] data;    // bidirectional data bus
	reg ready;          // ready from controller (input to DUT)

	// Testbench drive for the bidir bus. When tb_driving=1 TB drives 'data', otherwise tri-state.
	reg tb_driving;
	reg [7:0] tb_data_out;
	assign data = tb_driving ? tb_data_out : 8'bz;

	// Instantiate DUT (module not yet implemented in repo). Keep ports matching description.
	// If your `dram_iface` has different port names/ordering, update this instantiation accordingly.
	dram_iface dut (
		.clk(clk),
		.rst(rst),
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
		.ready(ready)
	);

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
		$display("[%0t] TB: Applying reset", $time);
		rst = 1'b1;
		KEY = 4'b1111; // assume unpressed buttons default high
		tb_driving = 0;
		tb_data_out = 8'h00;
		SW = 10'b0;
		ready = 1'b0;
		#20;
		rst = 1'b0;
		#20;
		rst = 1'b1;
		#20;
	end
	endtask

	// Wait helper with timeout
	task wait_for(input logic cond, input integer max_cycles, output integer cycles_done);
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
	task controller_respond(input [7:0] resp_data, input integer busy_cycles, input bit drive_data_on_read);
	begin
		// Wait until DUT asserts req
		wait (req == 1);
		@(posedge clk);
		// Controller grabs request: indicate busy
		ready = 1'b0;
		if (drive_data_on_read) begin
			// allow DUT to release bus, then drive read data
			#1;
			tb_driving = 1;
			tb_data_out = resp_data;
		end
		repeat (busy_cycles) @(posedge clk);
		if (drive_data_on_read) begin
			tb_driving = 0; // release bus when done
		end
		ready = 1'b1; // signal completion
		@(posedge clk);
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
		integer cycles;
		integer rc;
		integer errors;
		errors = 0;

		$display("==== START dram_iface_tb ====");

		// initial conditions
		clk = 0;
		tb_driving = 0;
		tb_data_out = 8'h00;
		ready = 0;
		KEY = 4'b1111;

		// Reset
		reset_dut();

		// Bring controller ready for operations
		ready = 1'b1;

		// ----------------------
		// Test 1: Read request flow
		// Assumptions: Changing SW (address switches) while ready==1 should cause a read request.
		// The dram_iface should assert `req` and `wEn` should be low for reads.
		// ----------------------
		$display("\n[TEST] Read request flow");
		// set an address via SW
		SW = 10'b00_0101010; // partial addr
		KEY = 4'b1111; // ensure write button not pressed
		@(posedge clk);

		// Wait for DUT to assert req (with timeout)
		cycles = 0;
		while (!req && cycles < 200) begin @(posedge clk); cycles = cycles + 1; end
		if (!req) begin
			$display("[FAIL] DUT did not assert req for read (timeout)");
			errors = errors + 1;
		end else begin
			if (wEn !== 1'b0) begin
				$display("[FAIL] DUT asserted req but wEn is not 0 for read (wEn=%b)", wEn);
				errors = errors + 1;
			end else begin
				$display("[OK] DUT asserted req for read, wEn=%b, address=%h", wEn, address[9:0]);
			end
			// Sample address when request asserted
			reg [25:0] sampled_addr;
			sampled_addr = address;
			// expected read value
			reg [7:0] expected_read;
			expected_read = 8'h5A;
			// Simulate controller: respond with read data 0x5A after 5 cycles
			fork
				controller_respond(expected_read, 5, 1);
			join

			// after ready returns, ensure req deasserts
			@(posedge clk);
			if (req) begin
				$display("[WARN] req still asserted after controller ready (expected deassert)");
			end else begin
				$display("[OK] Read completed, req deasserted");
			end

			// Validate HEX outputs: HEX1 should show low nibble of read data; HEX4/HEX5 show parts of address (lower byte nibbles)
			if (HEX1 !== nibble_to_7seg(expected_read[3:0])) begin
				$display("[FAIL] HEX1 mismatch: expected %b got %b", nibble_to_7seg(expected_read[3:0]), HEX1);
				errors = errors + 1;
			end else $display("[OK] HEX1 shows read low nibble %h", expected_read[3:0]);

			if (HEX4 !== nibble_to_7seg(sampled_addr[7:4])) begin
				$display("[FAIL] HEX4 mismatch (addr [7:4]): expected %b got %b", nibble_to_7seg(sampled_addr[7:4]), HEX4);
				errors = errors + 1;
			end else $display("[OK] HEX4 shows address nibble %h", sampled_addr[7:4]);

			if (HEX5 !== nibble_to_7seg(sampled_addr[3:0])) begin
				$display("[FAIL] HEX5 mismatch (addr [3:0]): expected %b got %b", nibble_to_7seg(sampled_addr[3:0]), HEX5);
				errors = errors + 1;
			end else $display("[OK] HEX5 shows address nibble %h", sampled_addr[3:0]);
		end

		// small gap
		repeat (4) @(posedge clk);

		// ----------------------
		// Test 2: Write request flow
		// Assumptions: Pressing KEY[3] while ready==1 should request a write and wEn==1.
		// We'll place write data on SW/data as appropriate.
		// ----------------------
		$display("\n[TEST] Write request flow");

		// Prepare write: put data onto data bus (TB will drive during write phase to model board input)
		tb_driving = 1;
		tb_data_out = 8'hA5; // data to be written
		// Simulate pressing the write button (assume 1 = pressed; if your design uses active-low, invert)
		KEY = 4'b0111; // KEY[3]=0? If your board is active-low, site KEY[3]=0 means pressed; adapt as needed.
		// Also set SW to partial address
		SW = 10'b01_0011001;

		@(posedge clk);
		// Wait for req
		cycles = 0;
		while (!req && cycles < 200) begin @(posedge clk); cycles = cycles + 1; end
		if (!req) begin
			$display("[FAIL] DUT did not assert req for write (timeout)");
			errors = errors + 1;
		end else begin
			if (wEn !== 1'b1) begin
				$display("[FAIL] DUT asserted req for write but wEn!=1 (wEn=%b)", wEn);
				errors = errors + 1;
			end else begin
				$display("[OK] DUT asserted req for write, wEn=%b, address=%h, data driven=%h", wEn, address[9:0], tb_data_out);
			end

			// Sample address and write data when request asserted
			reg [25:0] sampled_addr_w;
			sampled_addr_w = address;
			reg [7:0] expected_write;
			expected_write = tb_data_out;
			// Controller accepts write: busy for 3 cycles (no data driven by controller)
			fork
				controller_respond(8'h00, 3, 0);
			join

			// After done
			@(posedge clk);
			if (req) begin
				$display("[WARN] req still asserted after write completion (expected deassert)");
			end else begin
				$display("[OK] Write completed, req deasserted");
			end

			// Validate HEX outputs: HEX0 should show low nibble of write data; HEX4/HEX5 show parts of address (lower byte nibbles)
			if (HEX0 !== nibble_to_7seg(expected_write[3:0])) begin
				$display("[FAIL] HEX0 mismatch (write low nibble): expected %b got %b", nibble_to_7seg(expected_write[3:0]), HEX0);
				errors = errors + 1;
			end else $display("[OK] HEX0 shows written low nibble %h", expected_write[3:0]);

			if (HEX4 !== nibble_to_7seg(sampled_addr_w[7:4])) begin
				$display("[FAIL] HEX4 mismatch (addr [7:4]) on write: expected %b got %b", nibble_to_7seg(sampled_addr_w[7:4]), HEX4);
				errors = errors + 1;
			end else $display("[OK] HEX4 shows address nibble %h", sampled_addr_w[7:4]);

			if (HEX5 !== nibble_to_7seg(sampled_addr_w[3:0])) begin
				$display("[FAIL] HEX5 mismatch (addr [3:0]) on write: expected %b got %b", nibble_to_7seg(sampled_addr_w[3:0]), HEX5);
				errors = errors + 1;
			end else $display("[OK] HEX5 shows address nibble %h", sampled_addr_w[3:0]);
		end

		// Release TB drive and buttons
		tb_driving = 0;
		tb_data_out = 8'h00;
		KEY = 4'b1111;

		// Final check / summary
		if (errors == 0) begin
			$display("\n==== dram_iface_tb: ALL TESTS PASSED ====");
		end else begin
			$display("\n==== dram_iface_tb: %0d ERRORS ====", errors);
		end

		$finish;
	end

endmodule
