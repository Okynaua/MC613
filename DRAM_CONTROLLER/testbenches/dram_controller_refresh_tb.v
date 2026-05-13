module dram_controller_refresh_tb;

	reg clk;                  
	reg rst;
	reg [25:0] adress; 
	reg req;
   reg wEn; 
	wire ready;
	
	dram_controller dut (
		.clk(clk),
		.rst(rst),
		.adress(adress),
		.req(req),
		.wEn(wEn),
		.ready(ready)
	);
	
// Geração de Clock (Período de 10ns -> Frequência de 100MHz)
    always #5 clk = ~clk;

    initial begin
        // 1. Inicialização dos sinais
        clk = 0;
        rst = 1;
        adress = 26'd0;
        req = 0;
        wEn = 0;

        // Monitoramento no console: imprime sempre que um desses sinais mudar
        $monitor("Tempo: %0t | Estado: %b | Next State: %b | Counter Refresh: %0d | CS: %b | RAS: %b | CAS: %b | WE: %b", 
                 $time, dut.current_state, dut.next_state, dut.counter_refresh, dut.CS, dut.RAS, dut.CAS, dut.WE);

        // 2. Liberação do reset após 20ns
        #20 rst = 0;
        #20; // Espera a máquina estabilizar no ready_state

        // 3. Forçando a condição de refresh
        // Como 'counter_refresh' não tem lógica de incremento no seu código atual,
        // usamos o comando 'force' do Verilog para simular a chegada no valor 1000.
        $display("--> INICIANDO CICLO DE REFRESH");
        force dut.counter_refresh = 1000;

        // Espera 1 ciclo de clock para a FSM perceber a mudança
        #10;
        
        // Removemos a força e zeramos para não ficar preso num loop de refresh infinito
        release dut.counter_refresh;
        force dut.counter_refresh = 0; 

        // 4. Aguardar as transições de estado
        // A máquina deve passar por: refresh -> refresh_precharge -> wait_t -> 
        // refresh_auto1 -> wait_t -> refresh_auto2 -> wait_t -> ready_state.
        // Vamos dar tempo suficiente (ex: 500ns) para o contador interno gerar os overflows.
        #5000;

        $display("--> TESTE CONCLUIDO");
        $finish;
    end

endmodule
