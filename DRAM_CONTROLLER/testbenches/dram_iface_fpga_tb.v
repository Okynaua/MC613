module DRAM_CONTROLLER_TOP (
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,
    input  wire [9:0]  SW,

    output wire [9:0]  LEDR,

    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5
);

    // =========================
    // Reset (KEY[0] ativo-baixo)
    // =========================
    wire reset_n = KEY[0];

    // =========================
    // Sinais do dram_iface
    // =========================
    wire [25:0] address;
    wire req;
    wire wEn;
    wire ready;
    wire ready_led;

    // Barramento bidirecional
    wire [7:0] data;

    // =========================
    // Controlador DRAM (stub ou real)
    // =========================
    // Aqui você conecta seu controlador de DRAM real.
    // Por enquanto, exemplo simples (loopback / sempre pronto)

    reg [7:0] data_reg;
    reg ready_reg;

    assign ready = ready_reg;

    // Simulação simples de memória
    assign data = (wEn && req) ? data_reg : 8'bz;

    always @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            ready_reg <= 1'b1;
            data_reg <= 8'h00;
        end else begin
            if (req) begin
                ready_reg <= 1'b0;

                if (wEn) begin
                    // WRITE
                    data_reg <= data;
                end

            end else begin
                ready_reg <= 1'b1;
            end
        end
    end

    // =========================
    // Instância do dram_iface
    // =========================
    dram_iface iface_inst (
        .clk(CLOCK_50),
        .reset(~reset_n), // seu TB usa reset ativo alto
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
        .ready_led(ready_led)
    );

    // =========================
    // LEDs para debug
    // =========================
    assign LEDR[0] = ready;
    assign LEDR[1] = req;
    assign LEDR[2] = wEn;
    assign LEDR[3] = ready_led;
    assign LEDR[9:4] = address[5:0];

endmodule