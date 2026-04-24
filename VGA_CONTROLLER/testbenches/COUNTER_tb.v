module COUNTER_tb;
    // parametros do modulo
    parameter COUNTER_SIZE = 10;
    parameter COUNTER_COMPARE_V = 15;

    // sinais do modulo
    reg clk;
    reg rst;
    wire overflow;
    wire [9:0] counter_value;

    COUNTER #(
        .COUNTER_SIZE(10),
        .COUNTER_COMPARE_V(15)
    ) uut (
        .clk(clk),
        .rst(rst),
        .overflow(overflow),
        .counter_value(counter_value)
    );

    always #5 clk = ~clk;

    initial begin
        $display("Tempo | rst | counter | overflow");
        $monitor("%4t  |  %b  |   %d    |    %b",
                  $time, rst, counter_value, overflow);
    end

    initial begin
        clk = 0;
        rst = 1;

        // reset ativado por alguns ciclos
        #12;
        rst = 0;

        // comeca a contagem
        repeat (20) @(posedge clk);

        // testando overflow
        repeat (COUNTER_COMPARE_V + 2) @(posedge clk);

        // reset durante contagem
        rst = 1;
        @(posedge clk);
        rst = 0;

        // contando apos o reset durante a contagem
        repeat (10) @(posedge clk);

        $display("Teste finalizado.");
        $stop;
    end

endmodule