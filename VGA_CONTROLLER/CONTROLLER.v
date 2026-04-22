module CONTROLLER (
    input clk, 
    input [2:0] KEY,
    input [9:0] SW,
    output reg ppu_oam_write_en,
    output reg [3:0] ppu_oam_sel,
    output reg [9:0] ppu_oam_sx,
    output reg [8:0] ppu_oam_sy,
    output reg [5:0] ppu_oam_val,
    output debug_sprite_mode,
    output reset_n
);

    reg [9:0] oam_sx_reg;
	reg [24:0] oam_move_counter;
	reg init_write_pending;
	reg [2:0] init_write_counter;
    reg move_write_req;
    reg update_write_pending;
    reg [3:0] update_write_counter;
    reg [4:0] sprite_base_val;
    reg last_sw_0;
    reg last_sw_1;

    localparam [24:0] HALF_SEC_TICKS = 416_667;
	wire key_right_pressed = ~KEY[1];
	wire key_left_pressed = ~KEY[2];
	wire one_dir_pressed = key_right_pressed ^ key_left_pressed;


	assign debug_sprite_mode = SW[9];

    assign reset_n = KEY[0];

    always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			oam_sx_reg <= 10'd320;
			oam_move_counter <= 25'd0;
            move_write_req <= 1'b0;
            // Start with a full title-card write burst right after init writes.
            update_write_pending <= 1'b1;
            update_write_counter <= 4'd0;
            sprite_base_val <= ({3'b000, SW[1:0]} << 3) + 5'd1;
			init_write_pending <= 1'b1;
			init_write_counter <= 3'd0;
            last_sw_0 <= SW[0];
            last_sw_1 <= SW[1];

            ppu_oam_write_en <= 1'b0;
            ppu_oam_sel <= 4'd1;
            ppu_oam_sx <= 10'd320;
            ppu_oam_sy <= 9'd352;
            ppu_oam_val <= SW[1:0] + 33;
        end else begin
            // Default: keep sprite #1 data visible on output bus and write disabled.
            ppu_oam_write_en <= 1'b0;
            ppu_oam_sel <= 4'd1;
            ppu_oam_sx <= oam_sx_reg;
            ppu_oam_sy <= 9'd352;
            ppu_oam_val <= SW[1:0] + 33;

            // Detect SW changes and schedule a burst update across 9 cycles.
            if ((last_sw_0 != SW[0]) || (last_sw_1 != SW[1])) begin
                update_write_pending <= 1'b1;
                update_write_counter <= 4'd0;
                sprite_base_val <= ({3'b000, SW[1:0]} << 3) + 5'd1;
            end
            last_sw_0 <= SW[0];
            last_sw_1 <= SW[1];

            if (one_dir_pressed) begin
                if (oam_move_counter == (HALF_SEC_TICKS - 1'b1)) begin
                    oam_move_counter <= 25'd0;
                    if (key_right_pressed && (oam_sx_reg < 10'd607)) begin
                        oam_sx_reg <= oam_sx_reg + 10'd1;
                        move_write_req <= 1'b1;
                    end else if (key_left_pressed && (oam_sx_reg > 10'd0)) begin
                        oam_sx_reg <= oam_sx_reg - 10'd1;
                        move_write_req <= 1'b1;
                    end
                end else begin
                    oam_move_counter <= oam_move_counter + 25'd1;
                end
            end else begin
                oam_move_counter <= 25'd0;
            end

            // One OAM write per clock for deterministic timing.
            if (init_write_pending) begin
                ppu_oam_write_en <= 1'b1;
                ppu_oam_sel <= 4'd1;
                ppu_oam_sx <= oam_sx_reg;
                ppu_oam_sy <= 9'd352;
                ppu_oam_val <= SW[1:0] + 33;

                if (init_write_counter == 3'd7) begin
                    init_write_pending <= 1'b0;
                    init_write_counter <= 3'd0;
                end else begin
                    init_write_counter <= init_write_counter + 3'd1;
                end
            end else if (update_write_pending) begin
                ppu_oam_write_en <= 1'b1;
                if (update_write_counter == 4'd0) begin
                    // Keep character sprite (slot 1) in sync with SW change.
                    ppu_oam_sel <= 4'd1;
                    ppu_oam_sx <= oam_sx_reg;
                    ppu_oam_sy <= 9'd352;
                    ppu_oam_val <= SW[1:0] + 33;
                end else begin
                    ppu_oam_sel <= 4'd1 + update_write_counter;
                    ppu_oam_val <= {1'b0, sprite_base_val} + (update_write_counter - 4'd1);

                    case (update_write_counter)
                        4'd1: begin ppu_oam_sx <= 10'd256; ppu_oam_sy <= 9'd32; end
                        4'd2: begin ppu_oam_sx <= 10'd288; ppu_oam_sy <= 9'd32; end
                        4'd3: begin ppu_oam_sx <= 10'd320; ppu_oam_sy <= 9'd32; end
                        4'd4: begin ppu_oam_sx <= 10'd352; ppu_oam_sy <= 9'd32; end
                        4'd5: begin ppu_oam_sx <= 10'd256; ppu_oam_sy <= 9'd64; end
                        4'd6: begin ppu_oam_sx <= 10'd288; ppu_oam_sy <= 9'd64; end
                        4'd7: begin ppu_oam_sx <= 10'd320; ppu_oam_sy <= 9'd64; end
                        default: begin ppu_oam_sx <= 10'd352; ppu_oam_sy <= 9'd64; end
                    endcase
                end

                if (update_write_counter == 4'd8) begin
                    update_write_pending <= 1'b0;
                    update_write_counter <= 4'd0;
                end else begin
                    update_write_counter <= update_write_counter + 4'd1;
                end
            end else if (move_write_req) begin
                ppu_oam_write_en <= 1'b1;
                ppu_oam_sel <= 4'd1;
                ppu_oam_sx <= oam_sx_reg;
                ppu_oam_sy <= 9'd352;
                ppu_oam_val <= SW[1:0] + 33;
                move_write_req <= 1'b0;
            end
		end
	end

endmodule