module POS_BG_tb;
    reg [9:0] x_pos;
    reg [8:0] y_pos;

    wire [4:0] bg_x_pos;
    wire [3:0] bg_y_pos;

    POS_BG uut (
        .x_pos(x_pos),
        .y_pos(y_pos),
        .bg_x_pos(bg_x_pos),
        .bg_y_pos(bg_y_pos)
    );

    task check;
        input [9:0] x;
        input [8:0] y;
        begin
            x_pos = x;
            y_pos = y;
            #1;

            if (bg_x_pos !== (x >> 5))
                $display("[ERRO] em x: x=%d esperado=%d obtido=%d", x, (x>>5), bg_x_pos);
            else
                $display("[OK] x: x=%d -> %d", x, bg_x_pos);

            if (bg_y_pos !== (y >> 5))
                $display("[ERRO] em y: y=%d esperado=%d obtido=%d", y, (y>>5), bg_y_pos);
            else
                $display("[OK] y: y=%d -> %d", y, bg_y_pos);

            $display("-------------------------");
        end
    endtask

    initial begin
        // casos simples
        check(0, 0);
        check(31, 31);     
        check(32, 32);     
        check(63, 63);     
        check(64, 64);     

        // casos maiores
        check(100, 50);
        check(255, 128);
        check(511, 256);

        // casos de borda
        check(1023, 511);

        $display("Teste finalizado.");
        $stop;
    end

endmodule