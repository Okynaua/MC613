module PPU_OAM_tb;

    reg pixel_clk;
    reg ppu_oam_write_en;
    reg [3:0] ppu_oam_sel;
    reg [9:0] ppu_oam_sx;
    reg [8:0] ppu_oam_sy;
    reg [5:0] ppu_oam_val;
    reg [9:0] x_pos;
    reg [8:0] y_pos;

    wire [5:0] sprite_idx;
    wire [9:0] sprite_x_pos;
    wire [8:0] sprite_y_pos;

    PPU_OAM uut (
        .pixel_clk(pixel_clk),
        .ppu_oam_write_en(ppu_oam_write_en),
        .ppu_oam_sel(ppu_oam_sel),
        .ppu_oam_sx(ppu_oam_sx),
        .ppu_oam_sy(ppu_oam_sy),
        .ppu_oam_val(ppu_oam_val),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .sprite_idx(sprite_idx),
        .sprite_x_pos(sprite_x_pos),
        .sprite_y_pos(sprite_y_pos)
    );

    always #5 pixel_clk = ~pixel_clk;

    // tarefas a serem testadas

    task write_sprite;      // Escrevendo sprite
        input [3:0] sel;
        input [9:0] sx;
        input [8:0] sy;
        input [5:0] val;
        begin
            @(posedge pixel_clk);
            ppu_oam_write_en = 1;
            ppu_oam_sel = sel;
            ppu_oam_sx = sx;
            ppu_oam_sy = sy;
            ppu_oam_val = val;

            @(posedge pixel_clk);
            ppu_oam_write_en = 0;
        end
    endtask

    task check_pixel;       // Checando um pixel especifico
        input [9:0] x;
        input [8:0] y;
        input [5:0] expected_idx;
        begin
            x_pos = x;
            y_pos = y;
            #1;

            if (sprite_idx !== expected_idx) begin
                $display("ERRO: Pixel (%d,%d) -> esperado=%d obtido=%d",
                          x, y, expected_idx, sprite_idx);
                $fatal;
            end else begin
                $display("OK: Pixel (%d,%d) -> sprite=%d",
                          x, y, sprite_idx);
            end
        end
    endtask

    initial begin
        pixel_clk = 0;
        ppu_oam_write_en = 0;
        x_pos = 0;
        y_pos = 0;

        #10;

        $display("\nTESTE 1: Pixel sem sprite");
        check_pixel(10, 10, 0);

        $display("\nTESTE 2: Adicionar sprite");
        write_sprite(0, 50, 50, 5);

        $display("\nTESTE 3: Pixel com sprite");
        check_pixel(55, 55, 5);

        $display("\nTESTE 4: Pixel fora do sprite");
        check_pixel(10, 10, 0);

        $display("\nTESTE 5: Mudar posicao do sprite");
        write_sprite(0, 100, 100, 5);

        // antiga posição não deve mais ter sprite
        check_pixel(55, 55, 0);

        // nova posição deve ter sprite
        check_pixel(105, 105, 5);

        $display("\nTESTE 6: Remover sprite");
        write_sprite(0, 0, 0, 0);

        check_pixel(105, 105, 0);   // Verificando se ainda há sprite na posição

        $display("\nTODOS OS TESTES PASSARAM");
        $stop;
    end

endmodule