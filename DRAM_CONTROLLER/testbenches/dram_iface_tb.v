`timescale 1ns/1ps

module dram_iface_tb();

// ==========================================================
// SINAIS
// ==========================================================

reg clk;
reg ready;
reg data_valid;
reg [3:0] key;
reg [9:0] sw;

wire wEn;
wire req;
wire [25:0] address;
wire [6:0] hex0, hex1, hex4, hex5;
wire [2:0] iface_state;

wire [7:0] modata;
reg  [7:0] modata_out;

assign modata = (!wEn) ? modata_out : 8'bz;

// ==========================================================
// CONTROLE DE TESTE
// ==========================================================

integer error_count = 0;
localparam integer LABEL_W = 8*128;
integer cycles = 0;
integer sampled_addr_int;
integer sampled_addr_w_int;

// ==========================================================
// CLOCK
// ==========================================================

// 143 MHz
initial clk = 0;
always #3.5 clk = ~clk;

// ==========================================================
// DUT
// ==========================================================

dram_iface uut (
    .clk(clk),
    .ready(ready),
    .data_valid(data_valid),
    .reset(key[0]),
    .write_req(key[3]),
    .SW(sw),
    .data(modata),
    .HEX0(hex0),
    .HEX1(hex1),
    .HEX4(hex4),
    .HEX5(hex5),
    .address(address),
    .req(req),
    .wEn(wEn),
    .current_state(iface_state)
);

// ==========================================================
// HEX -> BIN
// ==========================================================

wire [3:0] bin0, bin1, bin4, bin5;

hex2bin getBin0 (
    .HEX(hex0),
    .BIN(bin0)
);

hex2bin getBin1 (
    .HEX(hex1),
    .BIN(bin1)
);

hex2bin getBin4 (
    .HEX(hex4),
    .BIN(bin4)
);

hex2bin getBin5 (
    .HEX(hex5),
    .BIN(bin5)
);

// ==========================================================
// MONITORAMENTO
// ==========================================================

initial begin
    $monitor(
        "t=%0t | SW=%b | KEY=%b | data=%b | ready=%b | data_valid=%b | wEn=%b | req=%b | addr=%b | state=%b | HEX=%h%h %h%h",
        $time,
        sw,
        key,
        modata,
        ready,
        data_valid,
        wEn,
        req,
        address,
        iface_state,
        bin5,
        bin4,
        bin1,
        bin0
    );
end

// ==========================================================
// TASK DE VERIFICACAO
// ==========================================================

task expect_signal;
    input [31:0] observed;
    input [31:0] expected;
    input [LABEL_W-1:0] label;
begin
    #1;

    if (observed !== expected) begin
        error_count = error_count + 1;

        $display(
            "[ERRO] %0s | esperado=%0b obtido=%0b (t=%0t)",
            label,
            expected,
            observed,
            $time
        );
    end
    else begin
        $display(
            "[OK] %0s | valor=%0b",
            label,
            observed
        );
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

// Wait helper with timeout
task wait_for(input target1, input target2, input integer max_cycles, output integer cycles_done);
integer c;
begin
    c = 0;
    cycles_done = -1;

    while (target1 !== target2 && c < max_cycles) begin
        @(posedge clk);
        c = c + 1;
    end

    if (target1 === target2)
        cycles_done = c;
end
endtask

// ==========================================================
// RESET PADRAO
// ==========================================================

task reset_dut;
begin
    key = 4'b1111;

    #20;
    key[0] = 0;

    #50;
    key[0] = 1;

    #50;
end
endtask

// ======================================================
// TESTES
// ======================================================

initial begin

    $display("==== INICIO DA SIMULACAO DRAM_IFACE ====");

    error_count = 0;

    // Valores iniciais
    key         = 4'b1111;
    sw          = 10'd0;
    ready       = 1'b0;
    data_valid  = 1'b0;
    modata_out  = 8'h00;

    // ======================================================
    // RESET
    // ======================================================

    $display("\n[TESTE] Reset");

    reset_dut();

    expect_signal(iface_state, 3'b100, "Estado READY apos reset");

    // Controlador pronto
    ready = 1'b1;

    // ======================================================
    // TESTE 1: LEITURA
    // ======================================================

    $display("\n[TESTE] Fluxo de requisicao de leitura");

    sw = 10'b00_0010_0000;
    key = 4'b1111;

    repeat (2) @(posedge clk);

    expect_signal(
        iface_state,
        3'b000,
        "Transicao para REQ_READ"
    );
	 
	 ready = 1'b0;
	 
    // Espera req
    cycles = 0;
	 
	wait_for(iface_state, 3'b010, 200, cycles);

	if (cycles == -1) begin
		 $display("[ERRO] Transicao para WAIT_READ NAO ocorreu");
	end else begin
		 $display("[OK] Transicao para WAIT_READ em %0d ciclos", cycles);
	end

    // Espera req
    cycles = 0;

    while (!req && cycles < 200) begin
        @(posedge clk);
        cycles = cycles + 1;
    end

    if (!req) begin
        error_count = error_count + 1;
        $display("[ERRO] req nao ativado para leitura");
    end
    else begin

        expect_signal(
            wEn,
            1'b0,
            "wEn desativado durante leitura"
        );

        sampled_addr_int = address;

        // Simula resposta da memoria
        data_valid  = 1'b0;
        modata_out  = 8'h5A;

        repeat (5) @(posedge clk);

        data_valid = 1'b1;

        @(posedge clk);

        ready = 1'b1;

        @(posedge clk);

        expect_signal(
            req,
            1'b0,
            "req desativado apos leitura"
        );

        expect_signal(
            modata,
            8'h5A,
            "Dado recebido da memoria"
        );

        // Displays
        expect_signal(
            hex1,
            nibble_to_7seg(4'hA),
            "HEX1 mostra nibble baixo do dado lido"
        );

        expect_signal(
            hex4,
            nibble_to_7seg(sampled_addr_int[3:0]),
            "HEX4 mostra addr[3:0]"
        );

        expect_signal(
            hex5,
            nibble_to_7seg(sampled_addr_int[7:4]),
            "HEX5 mostra addr[7:4]"
        );
    end

    repeat (4) @(posedge clk);

    // ======================================================
    // TESTE 2: ESCRITA
    // ======================================================

    $display("\n[TESTE] Fluxo de requisicao de escrita");

    sw = 10'b00_0010_1010;

    // Pressiona KEY[3]
    key[3] = 0;

    repeat (2) @(posedge clk);

    expect_signal(
        iface_state,
        3'b001,
        "Transicao para REQ_WRITE"
    );
	 
	 ready = 1'b0;

    @(posedge clk);

    // Solta botão
    key[3] = 1;

    wait_for(iface_state, 3'b011, 200, cycles);
	 
	 if (cycles == -1) begin
	 	  $display("[ERRO] Transicao para WAIT_WRITE NAO ocorreu");
	 end else begin
		  $display("[OK] Transicao para WAIT_WRITE em %0d ciclos", cycles);
	 end
	
    // Espera req
    cycles = 0;

    while (!req && cycles < 200) begin
        @(posedge clk);
        cycles = cycles + 1;
    end

    if (!req) begin
        error_count = error_count + 1;
        $display("[ERRO] req nao ativado para escrita");
    end
    else begin

        expect_signal(
            wEn,
            1'b1,
            "wEn ativado durante escrita"
        );

        expect_signal(
            modata,
            8'h0A,
            "Dado correto no barramento"
        );

        sampled_addr_w_int = address;

        // Controlador ocupado
        data_valid = 1'b0;

        repeat (3) @(posedge clk);

        ready = 1'b1;
		  data_valid = 1'b1;

        @(posedge clk);

		  wait_for(iface_state, 3'b000, 200, cycles);
	 
		  if (cycles == -1) begin
		 	  $display("[ERRO] Retorno para REQ_READ apos escrita NAO ocorreu");
		  end else begin
		 	  $display("[OK] Retornou para REQ_READ apos escrita em %0d ciclos", cycles);
		  end

        @(posedge clk);
		  
		   wait_for(iface_state, 3'b010, 200, cycles);
	 
		  if (cycles == -1) begin
		 	  $display("[ERRO] Transicao para WAIT_READ apos escrita NAO ocorreu");
		  end else begin
		 	  $display("[OK] Transitou para WAIT_READ apos escrita em %0d ciclos", cycles);
		  end

        // Simula leitura automatica
        ready       = 1'b0;
        modata_out  = 8'h0A;
        data_valid  = 1'b0;

        repeat (2) @(posedge clk);

        data_valid = 1'b1;

        @(posedge clk);

        ready = 1'b1;

        @(posedge clk);

        expect_signal(
            req,
            1'b0,
            "req desativado apos escrita/leitura"
        );

        // Displays
        expect_signal(
            hex1,
            nibble_to_7seg(4'hA),
            "HEX1 mostra dado escrito"
        );

        expect_signal(
            hex0,
            nibble_to_7seg(4'hA),
            "HEX0 mostra dado relido"
        );

        expect_signal(
            hex4,
            nibble_to_7seg(sampled_addr_w_int[3:0]),
            "HEX4 mostra addr[3:0]"
        );

        expect_signal(
            hex5,
            nibble_to_7seg(sampled_addr_w_int[7:4]),
            "HEX5 mostra addr[7:4]"
        );
    end

    // ======================================================
    // RESULTADO FINAL
    // ======================================================

    if (error_count == 0) begin
        $display("\n==== FIM DA SIMULACAO: TODOS OS TESTES PASSARAM ====");
    end
    else begin
        $display(
            "\n==== FIM DA SIMULACAO: %0d FALHAS ====",
            error_count
        );
    end

$finish;
end

endmodule