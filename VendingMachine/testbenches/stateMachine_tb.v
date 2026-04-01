module stateMachine_tb;

reg clk_test;
reg advance_test;
reg cancel_test;
wire subtraction_carry_test;
wire subtraction_zero_test;
wire accumulator_zero_test;

wire product_enable_test;
wire product_reset_test;
wire pulse_acc_enable_test;
wire acc_reset_test;
wire change_led_test;
wire paid_led_test;

reg [7:0] model_credit;
reg [7:0] model_price;
reg [7:0] model_next_coin;
integer error_count;

localparam integer LABEL_W = 8*96;

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
    .paid_led(paid_led_test)
);

// Clock 50 MHz
initial begin
    clk_test = 0;
    forever #10 clk_test = ~clk_test;
end

// Modelo simplificado do ambiente externo
assign subtraction_zero_test = (model_price != 0) && (model_credit == model_price);
assign subtraction_carry_test = (model_price != 0) && (model_credit > model_price);
assign accumulator_zero_test = (model_credit == 0);

always @(posedge clk_test) begin
    if (acc_reset_test) begin
        model_credit <= 8'd0;
        model_price <= 8'd0;
    end else if (pulse_acc_enable_test) begin
        model_credit <= model_credit + model_next_coin;
    end
end

// Monitor
initial begin
    $monitor("t=%0t | clk=%b | state=%b | adv=%b | cancel=%b | subC=%b | subZ=%b | accZ=%b | credit=%0d | price=%0d | prod_en=%b | prod_rst=%b | acc_en=%b | acc_rst=%b | change=%b | paid=%b | nxt_st=%b",
        $time, clk_test, uut.currentState, uut.pulse_advance, uut.pulse_cancel,
        subtraction_carry_test, subtraction_zero_test, accumulator_zero_test,
        model_credit, model_price,
        product_enable_test, product_reset_test,
        pulse_acc_enable_test, acc_reset_test,
        change_led_test, paid_led_test, uut.nextState);
end

task expect_state;
    input [1:0] expected;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (uut.currentState !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | estado esperado=%b obtido=%b (t=%0t)", label, expected, uut.currentState, $time);
    end else begin
        $display("[OK] %0s | estado=%b", label, uut.currentState);
    end
end
endtask

task expect_signal;
    input observed;
    input expected;
    input [LABEL_W-1:0] label;
begin
    #1;
    if (observed !== expected) begin
        error_count = error_count + 1;
        $display("[ERRO] %0s | esperado=%b obtido=%b (t=%0t)", label, expected, observed, $time);
    end else begin
        $display("[OK] %0s | valor=%b", label, observed);
    end
end
endtask

task press_advance;
begin
    @(negedge clk_test);
    advance_test = 1'b0;
    @(negedge clk_test);
    advance_test = 1'b1;
end
endtask

task press_cancel;
begin
    @(negedge clk_test);
    cancel_test = 1'b0;
    @(negedge clk_test);
    cancel_test = 1'b1;
end
endtask

task set_product_price;
    input [7:0] cents;
begin
    model_price = cents;
    $display("[TB] Produto selecionado: %0d", cents);
end
endtask

task insert_coin;
    input [7:0] cents;
begin
    model_next_coin = cents;
    press_advance();
    @(posedge clk_test);
    model_next_coin = 8'd0;
    $display("[TB] Moeda inserida: %0d | credito=%0d", cents, model_credit);
end
endtask

task pulse_timeout;
begin
    force uut.secondElapsed = 1'b1;
    @(posedge clk_test);
    release uut.secondElapsed;
    @(posedge clk_test);
end
endtask

initial begin
    $display("==== INICIO DA SIMULACAO ====");

    // Inicialização
    advance_test = 1;
    cancel_test = 1;
    model_credit = 8'd0;
    model_price = 8'd0;
    model_next_coin = 8'd0;
    error_count = 0;

    repeat (2) @(posedge clk_test);
    expect_state(2'b00, "estado inicial em selection");
    expect_signal(product_enable_test, 1'b1, "product_enable em selection");

    // Teste 1: fluxo normal (pagamento exato)
    $display("\n[TESTE 1] Fluxo normal com pagamento exato");
    set_product_price(8'd150);
    press_advance();
    expect_state(2'b01, "selection -> insertion");
    expect_signal(product_enable_test, 1'b0, "product_enable desliga em insertion");

    insert_coin(8'd100);
    expect_state(2'b01, "permanece em insertion apos 1a moeda");
    expect_signal(paid_led_test, 1'b0, "paid_led apagado antes de quitar");

    insert_coin(8'd50);
    expect_state(2'b10, "insertion -> sold com subtraction_zero");
    expect_signal(paid_led_test, 1'b1, "paid_led aceso em sold");
    expect_signal(change_led_test, 1'b0, "sem troco no pagamento exato");

    pulse_timeout();
    expect_state(2'b00, "sold -> selection apos timeout");
    expect_signal(acc_reset_test, 1'b0, "acc_reset pulso concluido apos retorno");

    // Teste 2: pagamento com troco
    $display("\n[TESTE 2] Pagamento com troco");
    set_product_price(8'd130);
    press_advance();
    expect_state(2'b01, "selection -> insertion (ciclo 2)");

    insert_coin(8'd100);
    insert_coin(8'd100);
    expect_state(2'b10, "insertion -> sold com subtraction_carry");
    expect_signal(change_led_test, 1'b1, "change_led aceso com troco");
    expect_signal(paid_led_test, 1'b1, "paid_led aceso com troco");

    pulse_timeout();
    expect_state(2'b00, "sold -> selection (ciclo 2)");

    // Teste 3: cancelamento com saldo
    $display("\n[TESTE 3] Cancelamento com saldo");
    set_product_price(8'd120);
    press_advance();
    expect_state(2'b01, "selection -> insertion (ciclo 3)");

    insert_coin(8'd50);
    press_cancel();
    expect_state(2'b11, "insertion -> canceled apos cancel");
    expect_signal(change_led_test, 1'b1, "change_led ligado em canceled com saldo");

    pulse_timeout();
    expect_state(2'b00, "canceled -> selection apos timeout");

    // Teste 4: cancelamento sem saldo (retorno imediato)
    $display("\n[TESTE 4] Cancelamento sem saldo");
    set_product_price(8'd90);
    press_advance();
    expect_state(2'b01, "selection -> insertion (ciclo 4)");

    press_cancel();
    expect_state(2'b11, "insertion -> canceled sem saldo");
    expect_signal(acc_reset_test, 1'b1, "acc_reset ativo no cancelamento sem saldo");
    expect_signal(product_reset_test, 1'b1, "product_reset ativo no cancelamento sem saldo");

    @(posedge clk_test);
    expect_state(2'b00, "canceled retorna imediato quando accumulator_zero=1");

    @(posedge clk_test);

    // Resultado final
    if (error_count == 0) begin
        $display("\n==== FIM DA SIMULACAO: TODOS OS TESTES PASSARAM ====");
    end else begin
        $display("\n==== FIM DA SIMULACAO: %0d FALHAS ====", error_count);
    end

    $finish;
end

endmodule