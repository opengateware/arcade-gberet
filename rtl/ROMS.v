//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2013-2019 MiSTer-X
//------------------------------------------------------------------------------
// FPGA Implimentation of "Green Beret" (ROMS part)
//------------------------------------------------------------------------------

module DLROM #(
        parameter AW,
        parameter DW
    ) (
        input                 CL0,
        input      [(AW-1):0] AD0,
        output reg [(DW-1):0] DO0,

        input                 CL1,
        input      [(AW-1):0] AD1,
        input      [(DW-1):0] DI1,
        input                 WE1
    );

    reg [(DW-1):0] core[0:((2**AW)-1)];

    always @(posedge CL0)
        DO0 <= core[AD0];
    always @(posedge CL1)
        if (WE1)
            core[AD1] <= DI1;

endmodule

module MAIN_ROM
    (
        input        CL,
        input        MX,
        input [15:0] AD,
        input  [2:0] BK,
        output       DV,
        output [7:0] DT,

        input        DLCL,
        input [17:0] DLAD,
        input  [7:0] DLDT,
        input        DLEN
    );

    wire [14:0] AD1 = (AD[15:11] == 5'b11111) ? {1'b1,BK,AD[10:0]} : {1'b0,AD[13:0]};

    wire  [7:0] DT0, DT1;
    DLROM #(15,8) r0(CL,AD[14:0],DT0, DLCL,DLAD,DLDT,DLEN & (DLAD[17:15]==3'b00_0));
    DLROM #(15,8) r1(CL, AD1,DT1, DLCL,DLAD,DLDT,DLEN & (DLAD[17:15]==3'b00_1));

    assign DV = ((AD[15:11] == 5'b11111)|(AD[15:14] != 2'b11)) & MX;
    assign DT = AD[15] ? DT1 : DT0;

endmodule

module SPCHIP_ROM
    (
        input        CL,
        input [15:0] AD,
        output [7:0] DT,

        input        DLCL,
        input [17:0] DLAD,
        input  [7:0] DLDT,
        input        DLEN
    );
    DLROM #(16,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:16]==2'b01));
endmodule

module BGCHIP_ROM
    (
        input        CL,
        input [13:0] AD,
        output [7:0] DT,

        input        DLCL,
        input [17:0] DLAD,
        input  [7:0] DLDT,
        input        DLEN
    );
    DLROM #(14,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:14]==4'b10_00));
endmodule

module SPCLUT_ROM
    (
        input        CL,
        input  [7:0] AD,
        output [7:0] DT,

        input        DLCL,
        input [17:0] DLAD,
        input  [7:0] DLDT,
        input        DLEN
    );
    DLROM #(8,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:8]==10'b10_0100_0000));
endmodule

module BGCLUT_ROM
    (
        input        CL,
        input  [7:0] AD,
        output [7:0] DT,

        input        DLCL,
        input [17:0] DLAD,
        input  [7:0] DLDT,
        input        DLEN
    );
    DLROM #(8,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:8]==10'b10_0100_0001));
endmodule

module PALET_ROM
    (
        input        CL,
        input  [4:0] AD,
        output [7:0] DT,

        input        DLCL,
        input [17:0] DLAD,
        input  [7:0] DLDT,
        input        DLEN
    );
    DLROM #(5,8) r(CL,AD,DT, DLCL,DLAD,DLDT,DLEN & (DLAD[17:5]==13'b10_0100_0010_000));
endmodule
