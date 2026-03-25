module stateMachine_tb;

reg clk_test;
reg advance_test;
reg cancel_test;
reg subtraction_carry_test;
reg subtraction_zero_test;
reg accumulator_zero_test;
reg currentState_test;

wire product_enable_test;
wire product_reset_test;
wire pulse_acc_enable_test;
wire acc_reset_test;
wire change_led_test;
wire paid_led_test;

// Instanciação do módulo
stateMachine uut (
    .clk(clk_test),
    .advance(advance_test),
    .cancel(cancel_test),
    .subtraction_carry(subtraction_carry_test),
    .subtraction_zero(subtraction_zero_test),
    .accumulator_zero(accumulator_zero_test),
    .product_enable(product_enable_test),
    .product_reset(product_reset_test),
    .pulse_acc_enable(pulse_acc_enable_test),
    .acc_reset(acc_reset_test),
    .change_led(change_led_test),
    .paid_led(paid_led_test),
	 .currentStateOut(currentState_test)
);

// Clock 50 MHz
initial begin
    clk_test = 0;
    forever #10 clk_test = ~clk_test;
end

// Monitor
initial begin
    $monitor("t=%0t | adv=%b | cancel=%b | subC=%b | subZ=%b | accZ=%b | prod_en=%b | prod_rst=%b | acc_en=%b | acc_rst=%b | change=%b | paid=%b",
        $time, advance_test, cancel_test,
        subtraction_carry_test, subtraction_zero_test, accumulator_zero_test,
        product_enable_test, product_reset_test,
        pulse_acc_enable_test, acc_reset_test,
        change_led_test, paid_led_test);
end

initial begin
    $display("==== INICIO DA SIMULACAO ====");

    // Inicialização
    advance_test = 0;
    cancel_test = 0;
    subtraction_carry_test = 0;
    subtraction_zero_test = 0;
    accumulator_zero_test = 1;

    // =========================
    // 1. Estado inicial: selection
    // =========================
    #20;
    $display("\n[TESTE] Indo para insertion (pressiona advance)");
    advance_test = 1;
    #20;
    advance_test = 0;

    // =========================
    // 2. Inserção de dinheiro
    // =========================
    #20;
    $display("\n[TESTE] Inserindo valor (pulso advance)");
    advance_test = 1;
    #20;
    advance_test = 0;

    // =========================
    // 3. Pagamento completo (subtraction_zero)
    // =========================
    #20;
    $display("\n[TESTE] Pagamento completo");
    subtraction_zero_test = 1;
    #20;
    subtraction_zero_test = 0;

    // Espera "tempo" do timer (simulado grosseiramente)
    #100;

    // =========================
    // 4. Novo ciclo → insertion
    // =========================
    $display("\n[TESTE] Novo ciclo - indo para insertion");
    advance_test = 1;
    #20;
    advance_test = 0;

    // =========================
    // 5. Pagamento com troco (subtraction_carry)
    // =========================
    #20;
    $display("\n[TESTE] Pagamento com troco");
    subtraction_carry_test = 1;
    #20;
    subtraction_carry_test = 0;

    #100;

    // =========================
    // 6. Cancelamento com dinheiro
    // =========================
    $display("\n[TESTE] Cancelamento com saldo");
    advance_test = 1; // vai pra insertion
    #20;
    advance_test = 0;

    #20;
    accumulator_zero_test = 0; // tem dinheiro
    cancel_test = 1;
    #20;
    cancel_test = 0;

    #100;

    // =========================
    // 7. Cancelamento sem dinheiro
    // =========================
    $display("\n[TESTE] Cancelamento sem saldo");
    advance_test = 1;
    #20;
    advance_test = 0;

    #20;
    accumulator_zero_test = 1; // sem dinheiro
    cancel_test = 1;
    #20;
    cancel_test = 0;

    #40;

    $display("\n==== FIM DA SIMULACAO ====");
    $finish;
end

endmodule