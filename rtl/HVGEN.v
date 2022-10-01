//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2013-2019 MiSTer-X
//------------------------------------------------------------------------------
// FPGA Implimentation of "Green Beret" (Video Timing Part)
//------------------------------------------------------------------------------
module HVGEN
    (
        input              iPCLK,
        output      [8:0]  HPOS,
        output      [8:0]  VPOS,
        input       [11:0] iRGB,

        output reg  [11:0] oRGB,
        output reg         HBLK = 0,
        output reg         VBLK = 0,
        output reg         HSYN = 1,
        output reg         VSYN = 1,
        output reg         oBLKN,

        input signed [4:0] HOFFS,
        input signed [3:0] VOFFS
    );

    // 396x256. V-sync: 60.(60)Hz, H-Sync 15.(51)KHz, Pixel Clock: 6.144MHz

    localparam [8:0] width = 396;

    reg [8:0] hcnt = 0;
    reg [7:0] vcnt = 0;

    assign HPOS = hcnt-9'd24;
    assign VPOS = vcnt;

    wire [8:0] HS_B = 320 + HOFFS;
    wire [8:0] HS_E =  31 + HS_B;

    wire [8:0] VS_B = 226 + VOFFS;
    wire [8:0] VS_E =   5 + VS_B;


    always @(posedge iPCLK) begin
        if (hcnt < width-1)
            hcnt <= hcnt+9'd1;
        else begin
            vcnt <= vcnt+9'd1;
            hcnt <= 0;
        end
        HBLK  <= (hcnt < 25) | (hcnt >= 265);
        HSYN  <= (hcnt >= HS_B) & (hcnt < HS_E);
        VBLK  <= (vcnt >= 224) & (vcnt < 256);
        VSYN  <= (vcnt >= VS_B) & (vcnt < VS_E);
        oRGB  <= (HBLK|VBLK) ? 12'h0 : iRGB;
        oBLKN <= ~(HBLK|VBLK);
    end

endmodule
