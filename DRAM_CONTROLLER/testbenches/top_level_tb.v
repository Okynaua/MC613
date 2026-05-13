`timescale 1ns/1ps

module top_level_tb();

    // =====================================================
    // PARAMETERS
    // =====================================================

    parameter LABEL_W = 1024;

    parameter BIN = 0,
              HEX = 1,
              DEC = 2;

    // =====================================================
    // CLOCK
    // =====================================================

    reg CLOCK_50;

    initial CLOCK_50 = 0;
    always #10 CLOCK_50 = ~CLOCK_50; // 50 MHz

    // =====================================================
    // INPUTS
    // =====================================================

    reg [9:0] SW;
    reg [3:0] KEY;

    // =====================================================
    // OUTPUTS
    // =====================================================

    wire [6:0] HEX0;
    wire [6:0] HEX1;
    wire [6:0] HEX4;
    wire [6:0] HEX5;

    wire [9:0] LEDR;

    wire [12:0] DRAM_ADDR;
    wire [1:0]  DRAM_BA;
    wire        DRAM_CKE;

    wire [15:0] DRAM_DQ;

    wire DRAM_LDQM;
    wire DRAM_UDQM;

    wire DRAM_CAS_N;
    wire DRAM_CS_N;
    wire DRAM_WE_N;
    wire DRAM_RAS_N;

    wire DRAM_CLK;

    // =====================================================
    // SIMULATED MEMORY
    // =====================================================

    reg [15:0] dram_data;

    assign DRAM_DQ = (DRAM_WE_N) ? dram_data : 16'bz;

    // =====================================================
    // DUT
    // =====================================================

    top_level uut(
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .LEDR(LEDR),

        .DRAM_ADDR(DRAM_ADDR),
        .DRAM_BA(DRAM_BA),
        .DRAM_CKE(DRAM_CKE),
        .DRAM_DQ(DRAM_DQ),
        .DRAM_LDQM(DRAM_LDQM),
        .DRAM_UDQM(DRAM_UDQM),
        .DRAM_CAS_N(DRAM_CAS_N),
        .DRAM_CS_N(DRAM_CS_N),
        .DRAM_WE_N(DRAM_WE_N),
        .DRAM_RAS_N(DRAM_RAS_N),
        .DRAM_CLK(DRAM_CLK)
    );

    // =====================================================
    // HEX -> BIN
    // =====================================================

    wire [3:0] BIN0, BIN1, BIN4, BIN5;

    hex2bin getBin0(
        .HEX(HEX0),
        .BIN(BIN0)
    );

    hex2bin getBin1(
        .HEX(HEX1),
        .BIN(BIN1)
    );

    hex2bin getBin4(
        .HEX(HEX4),
        .BIN(BIN4)
    );

    hex2bin getBin5(
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

        $display("==== INICIO top_level_tb ====");

        error_count = 0;

        // Valores iniciais
        SW        = 10'b0;
        KEY       = 4'b1111;
        dram_data = 16'h00AB;

        // =====================================================
        // RESET TEST
        // =====================================================

        $display("\n==== TESTE RESET ====");

        KEY[0] = 0;

        #100;

        KEY[0] = 1;

        #100;

        expect_signal(LEDR[9:7], 3'b100,
                      "Interface entra em READY apos reset", BIN);

        expect_signal(DRAM_CKE, 1,
                      "DRAM_CKE permanece ativo", BIN);

        // =====================================================
        // READ TEST
        // =====================================================

        $display("\n==== TESTE LEITURA ====");

        SW[9:4] = 6'b101010;

        #200;

        expect_signal(BIN5, SW[9:6],
                      "HEX5 mostra parte alta do endereco", HEX);

        expect_signal(BIN4, {2'b00,SW[5],SW[4]},
                      "HEX4 mostra parte baixa do endereco", HEX);

        // Aguarda controlador terminar leitura
        wait(LEDR[9:7] == 3'b100);

        #50;

        expect_signal(BIN1, 4'hB,
                      "HEX1 mostra dado lido da memoria", HEX);

        // =====================================================
        // WRITE TEST
        // =====================================================

        $display("\n==== TESTE ESCRITA ====");

        SW[3:0] = 4'hD;

        // KEY[3] ativo em low
        KEY[3] = 0;

        #200;

        expect_signal(BIN0, 4'hD,
                      "HEX0 mostra dado escrito", HEX);

        expect_signal(DRAM_WE_N, 0,
                      "WRITE envia comando WRITE para DRAM", BIN);

        KEY[3] = 1;

        // =====================================================
        // DRAM SIGNALS TEST
        // =====================================================

        $display("\n==== TESTE SINAIS DRAM ====");

        expect_signal(DRAM_CS_N, 0,
                      "CS ativo", BIN);

        expect_signal(DRAM_LDQM, 0,
                      "LDQM desativado", BIN);

        expect_signal(DRAM_UDQM, 0,
                      "UDQM desativado", BIN);

        // =====================================================
        // FINAL REPORT
        // =====================================================

        #500;

        $display("\n==== RESULTADO FINAL ====");

        if (error_count == 0)
            $display("[SUCESSO] Todos os testes passaram.");
        else
            $display("[FALHA] Total de erros: %0d", error_count);

        $display("\n==== FIM top_level_tb ====");

        $stop;
    end

    // =====================================================
    // MONITOR
    // =====================================================

    initial begin
        $monitor(
            "Tempo=%0t | IF_state=%b | CTRL_state=%b | SW=%h | HEX=%h%h %h%h | DRAM_CMD={CS=%b RAS=%b CAS=%b WE=%b} | ADDR=%h | DATA=%h",
            $time,
            LEDR[9:7],
            LEDR[5:0],
            SW,
            BIN5,
            BIN4,
            BIN1,
            BIN0,
            DRAM_CS_N,
            DRAM_RAS_N,
            DRAM_CAS_N,
            DRAM_WE_N,
            DRAM_ADDR,
            DRAM_DQ
        );
    end

endmodule
