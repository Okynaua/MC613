module CONTROLLER (
    input clk, 
    input [3:0] KEY,
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
    reg [8:0] oam_sy_reg;
    reg signed [7:0] oam_vy_reg;
    reg [1:0] jump_count;
    reg key_jump_prev;
    reg jump_request;
    reg [1:0] key_right_sync;
    reg [1:0] key_left_sync;
    reg [1:0] key_jump_sync;
    reg [24:0] h_move_counter;
    reg [24:0] v_move_counter;
	reg init_write_pending;
	reg [2:0] init_write_counter;
    reg move_write_req;
    reg update_write_pending;
    reg [3:0] update_write_counter;
    reg [4:0] sprite_base_val;
    reg last_sw_0;
    reg last_sw_1;
    integer sy_next_calc;

    localparam [24:0] H_MOVE_TICKS = 208_333;
    localparam [24:0] V_PHYS_TICKS = 416_667;
    localparam [8:0] FLOOR_Y = 9'd352;
    localparam signed [7:0] JUMP_VELOCITY = -8'sd12;
    localparam signed [7:0] GRAVITY_STEP = 8'sd1;
    localparam signed [7:0] MAX_FALL_VELOCITY = 8'sd12;
	wire key_right_pressed = ~key_right_sync[1];
	wire key_left_pressed = ~key_left_sync[1];
    wire key_jump_pressed = ~key_jump_sync[1];
	wire one_dir_pressed = key_right_pressed ^ key_left_pressed;


	assign debug_sprite_mode = SW[9];

    assign reset_n = KEY[0];

    always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			oam_sx_reg <= 10'd320;
            oam_sy_reg <= FLOOR_Y;
            oam_vy_reg <= 8'sd0;
            jump_count <= 2'd0;
            key_jump_prev <= 1'b0;
            jump_request <= 1'b0;
            key_right_sync <= 2'b11;
            key_left_sync <= 2'b11;
            key_jump_sync <= 2'b11;
			h_move_counter <= 25'd0;
			v_move_counter <= 25'd0;
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
            ppu_oam_sy <= FLOOR_Y;
            ppu_oam_val <= SW[1:0] + 33;
        end else begin
            // Default: keep sprite #1 data visible on output bus and write disabled.
            ppu_oam_write_en <= 1'b0;
            ppu_oam_sel <= 4'd1;
            ppu_oam_sx <= oam_sx_reg;
            ppu_oam_sy <= oam_sy_reg;
            ppu_oam_val <= SW[1:0] + 33;

            // Synchronize active-low keys to this clock domain.
            key_right_sync <= {key_right_sync[0], KEY[1]};
            key_left_sync <= {key_left_sync[0], KEY[2]};
            key_jump_sync <= {key_jump_sync[0], KEY[3]};

            // Latch jump edge so short key presses are not lost between physics ticks.
            if (key_jump_pressed && !key_jump_prev)
                jump_request <= 1'b1;
            key_jump_prev <= key_jump_pressed;

            // Detect SW changes and schedule a burst update across 9 cycles.
            if ((last_sw_0 != SW[0]) || (last_sw_1 != SW[1])) begin
                update_write_pending <= 1'b1;
                update_write_counter <= 4'd0;
                sprite_base_val <= ({3'b000, SW[1:0]} << 3) + 5'd1;
            end
            last_sw_0 <= SW[0];
            last_sw_1 <= SW[1];

            if (h_move_counter == (H_MOVE_TICKS - 1'b1)) begin
                h_move_counter <= 25'd0;
                if (one_dir_pressed) begin
                    if (key_right_pressed && (oam_sx_reg < 10'd607)) begin
                        oam_sx_reg <= oam_sx_reg + 10'd1;
                        move_write_req <= 1'b1;
                    end else if (key_left_pressed && (oam_sx_reg > 10'd0)) begin
                        oam_sx_reg <= oam_sx_reg - 10'd1;
                        move_write_req <= 1'b1;
                    end
                end
            end else begin
                h_move_counter <= h_move_counter + 25'd1;
            end

            if (v_move_counter == (V_PHYS_TICKS - 1'b1)) begin
                v_move_counter <= 25'd0;
                sy_next_calc = oam_sy_reg;

                if (jump_request) begin
                    if (jump_count < 2) begin
                        oam_vy_reg <= JUMP_VELOCITY;
                        jump_count <= jump_count + 2'd1;
                        sy_next_calc = $signed({1'b0, oam_sy_reg}) + JUMP_VELOCITY;
                    end
                    jump_request <= 1'b0;
                end else begin
                    if ((oam_sy_reg < FLOOR_Y) || (oam_vy_reg != 8'sd0)) begin
                        sy_next_calc = $signed({1'b0, oam_sy_reg}) + $signed(oam_vy_reg);
                        if (oam_vy_reg < MAX_FALL_VELOCITY)
                            oam_vy_reg <= oam_vy_reg + GRAVITY_STEP;
                    end
                end

                if (sy_next_calc >= FLOOR_Y) begin
                    if ((oam_sy_reg != FLOOR_Y) || (oam_vy_reg != 8'sd0))
                        move_write_req <= 1'b1;
                    oam_sy_reg <= FLOOR_Y;
                    oam_vy_reg <= 8'sd0;
                    jump_count <= 2'd0;
                end else if (sy_next_calc < 0) begin
                    if (oam_sy_reg != 9'd0)
                        move_write_req <= 1'b1;
                    oam_sy_reg <= 9'd0;
                end else if (sy_next_calc != oam_sy_reg) begin
                    oam_sy_reg <= sy_next_calc[8:0];
                    move_write_req <= 1'b1;
                end
            end else begin
                v_move_counter <= v_move_counter + 25'd1;
            end

            // One OAM write per clock for deterministic timing.
            if (init_write_pending) begin
                ppu_oam_write_en <= 1'b1;
                ppu_oam_sel <= 4'd1;
                ppu_oam_sx <= oam_sx_reg;
                ppu_oam_sy <= oam_sy_reg;
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
                    ppu_oam_sy <= oam_sy_reg;
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
                ppu_oam_sy <= oam_sy_reg;
                ppu_oam_val <= SW[1:0] + 33;
                move_write_req <= 1'b0;
            end
		end
	end

endmodule