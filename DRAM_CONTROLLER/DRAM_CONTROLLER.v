module DRAM_CONTROLLER (
    // Clock e Periféricos da Placa
    input  wire        CLOCK_50,   // Clock de 50MHz da placa
    input  wire [3:0]  KEY,        // KEY[0]=Reset, KEY[3]=Write Request
    input  wire [9:0]  SW,         // Endereço e Dados
    output wire [6:0]  HEX0,       // Dado de escrita
    output wire [6:0]  HEX1,       // Dado lido
    output wire [6:0]  HEX4,       // Endereço (Parte)
    output wire [6:0]  HEX5,       // Endereço (Parte)
    output wire [9:0]  LEDR,       // Debug (Opcional)

    // Interface com o Chip SDRAM (Pinos Físicos)
    output wire [12:0] DRAM_ADDR,  // Endereço da memória (A0-A12)
    output wire [1:0]  DRAM_BA,    // Bank Address (BA0-BA1)
    output wire        DRAM_CAS_N, // Column Address Strobe
    output wire        DRAM_CKE,   // Clock Enable
    output wire        DRAM_CLK,   // Clock da Memória
    output wire        DRAM_CS_N,  // Chip Select
    inout  wire [15:0] DRAM_DQ,    // Barramento de Dados (16 bits)
    output wire        DRAM_LDQM,  // Low-byte Data Mask
    output wire        DRAM_RAS_N, // Row Address Strobe
    output wire        DRAM_UDQM,  // Upper-byte Data Mask
    output wire        DRAM_WE_N   // Write Enable
);

    // --- Sinais Internos de Interconexão ---
    wire [25:0] internal_address;
    wire [7:0]  internal_data;     // Barramento compartilhado (8 bits)
    wire        req_signal;
    wire        wEn_signal;
    wire        ready_signal;
    wire        data_valid_signal;

    // --- Tratamento de Clock ---
    // O datasheet especifica 143MHz. Idealmente, usa-se um PLL.
    // Para este exemplo, usaremos o CLOCK_50, mas em um projeto real 
    // deve-se instanciar o componente ALTPLL.
    assign DRAM_CLK = CLOCK_50; 

    // --- Instanciação do Módulo de Interface (User-side) ---
    dram_iface iface_inst (
        .clk(CLOCK_50),
        .ready(ready_signal),
        .data_valid(data_valid_signal),
        .reset(KEY[0]),            // dram_iface espera reset ativo em baixo (KEY[0])
        .write_req(KEY[3]),        // dram_iface espera write_req ativo em baixo (KEY[3])
        .SW(SW),
        .data(internal_data),      // Conectado ao barramento compartilhado
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .address(internal_address),
        .req(req_signal),
        .wEn(wEn_signal),
        .current_state(LEDR[2:0])  // Visualização de estado nos LEDs
    );

    // --- Instanciação do Controlador DRAM (Hardware-side) ---
    // Nota: O nome do módulo no arquivo é 'dram_controler' (com um 'l')
    dram_controller controller_inst (
        .clk(CLOCK_50),
        .reset(~KEY[0]),           // dram_controler usa reset síncrono ativo em alto
        .address(internal_address),
        .data(dram_bus), // Ajuste para a porta de 9 bits [8:0] do código fornecido
        .req(req_signal),
        .wEn(wEn_signal),
        .data_valid(data_valid_signal),
        .ready(ready_signal),
        .current_state(LEDR[8:3]), // Visualização de estado nos LEDs
        
        // Pinos da Memória
        .cs(DRAM_CS_N),
        .ras(DRAM_RAS_N),
        .cas(DRAM_CAS_N),
        .we(DRAM_WE_N),
        .ba(DRAM_BA),
        .a(DRAM_ADDR),
        .dqm({DRAM_UDQM, DRAM_LDQM}),
        .cke(DRAM_CKE)
    );

    // --- Conexão do Barramento de Dados Físico ---
    // A memória é de 16 bits, mas o projeto utiliza apenas 8 bits.
    // Conectamos os 8 bits inferiores e deixamos os superiores em alta impedância.
    assign DRAM_DQ[7:0]  = internal_data; 
    assign DRAM_DQ[15:8] = 8'bz;

endmodule