module PPU_TILE(
    input [3:0] bg_value,
    input [9:0] x_pos,
    input [8:0] y_pos,
    output reg [4:0] bg_color_idx
);

reg [4:0] t0 [0:1023];
reg [4:0] t1 [0:1023];
reg [4:0] t2 [0:1023];
reg [4:0] t3 [0:1023];
reg [4:0] t4 [0:1023];
reg [4:0] t5 [0:1023];
reg [4:0] t6 [0:1023];
reg [4:0] t7 [0:1023];
reg [4:0] t8 [0:1023];
reg [4:0] t9 [0:1023];
reg [4:0] tA [0:1023];
reg [4:0] tB [0:1023];
reg [4:0] tC [0:1023];
reg [4:0] tD [0:1023];
reg [4:0] tE [0:1023];
reg [4:0] tF [0:1023];


initial begin
    $readmemh("tiles/tile0.hex", t0);
    $readmemh("tiles/tile1.hex", t1);
    $readmemh("tiles/tile2.hex", t2);
    $readmemh("tiles/tile3.hex", t3);
    $readmemh("tiles/tile4.hex", t4);
    $readmemh("tiles/tile5.hex", t5);
    $readmemh("tiles/tile6.hex", t6);
    $readmemh("tiles/tile7.hex", t7);
    $readmemh("tiles/tile8.hex", t8);
    $readmemh("tiles/tile9.hex", t9);
    $readmemh("tiles/tileA.hex", tA);
    $readmemh("tiles/tileB.hex", tB);
    $readmemh("tiles/tileC.hex", tC);
    $readmemh("tiles/tileD.hex", tD);
    $readmemh("tiles/tileE.hex", tE);
    $readmemh("tiles/tileF.hex", tF);
end

// {Y_resto, X_resto} cria o índice: (Y % 32) * 32 + (X % 32)
wire [9:0] internal_addr = {pos_y[4:0], pos_x[4:0]};

//assign result
always @(*) begin
    case (bg_value)
        4'h0: bg_color_idx = t0[internal_addr];
        4'h1: bg_color_idx = t1[internal_addr];
        4'h2: bg_color_idx = t2[internal_addr];
        4'h3: bg_color_idx = t3[internal_addr];
        4'h4: bg_color_idx = t4[internal_addr];
        4'h5: bg_color_idx = t5[internal_addr];
        4'h6: bg_color_idx = t6[internal_addr];
        4'h7: bg_color_idx = t7[internal_addr];
        4'h8: bg_color_idx = t8[internal_addr];
        4'h9: bg_color_idx = t9[internal_addr];
        4'hA: bg_color_idx = tA[internal_addr];
        4'hB: bg_color_idx = tB[internal_addr];
        4'hC: bg_color_idx = tC[internal_addr];
        4'hD: bg_color_idx = tD[internal_addr];
        4'hE: bg_color_idx = tE[internal_addr];
        4'hF: bg_color_idx = tF[internal_addr];
        default: bg_color_idx = 5'b00000;
    endcase
end

endmodule