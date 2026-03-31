module espera_1s_tb;

reg clk;
reg reset;
wire pulse_out;

// Instancia o DUT
espera_1s uut (
    .clk(clk),
    .reset(reset),
    .pulse_out(pulse_out)
);

// Clock 50 MHz → 20 ns
always #10 clk = ~clk;

// Monitoramento
initial begin
    $monitor("t=%0t | reset=%b contador=%d pronto=%b pulse=%b",
              $time, reset, uut.contador, uut.pronto, pulse_out);
end

initial begin
    clk = 0;
    reset = 1;

    $display("=== Teste inicia ===");

    // Reset inicial
    #30;
    reset = 0;

    #200;

    $display("\n=== Aplicando reset apos pulso ===");

    reset = 1;
    #20;
    reset = 0;

    // Verifica se reiniciou corretamente
    // força de novo perto do fim
    uut.contador = 26'd49_900_995;
    // espera o pulso de 1 segundo
    @(posedge pulse_out);

    $display("\n=== Pulso detectado ===");

    $finish;
end

endmodule