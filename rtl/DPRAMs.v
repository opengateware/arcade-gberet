//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2013-2019 MiSTer-X
//------------------------------------------------------------------------------
// FPGA Implimentation of "Green Beret" (Dual-Port RAM for VIDEO)
//------------------------------------------------------------------------------

module VRAM4096
    (
        input            cl,
        input     [11:0] ad,
        input            en,
        input            wr,
        input      [7:0] id,
        output reg [7:0] od,

        input            clv,
        input     [11:0] adv,
        output reg [7:0] odv
    );

    reg [7:0] core [0:4095];

    always @( posedge cl ) begin
        if (en) begin
            if (wr)
                core[ad] <= id;
            else
                od <= core[ad];
        end
    end

    always @( posedge clv ) begin
        odv <= core[adv];
    end

endmodule

module VRAM2048
    (
        input            cl,
        input     [10:0] ad,
        input            en,
        input            wr,
        input      [7:0] id,
        output reg [7:0] od,

        input            clv,
        input     [10:0] adv,
        output reg [7:0] odv
    );

    reg [7:0] core [0:2047];

    always @( posedge cl ) begin
        if (en) begin
            if (wr)
                core[ad] <= id;
            else
                od <= core[ad];
        end
    end

    always @( posedge clv ) begin
        odv <= core[adv];
    end

endmodule

module VRAM32
    (
        input            cl,
        input      [4:0] ad,
        input            en,
        input            wr,
        input      [7:0] id,
        output reg [7:0] od,

        input            clv,
        input      [4:0] adv,
        output reg [7:0] odv
    );

    reg [7:0] core [0:31];

    always @( posedge cl ) begin
        if (en) begin
            if (wr)
                core[ad] <= id;
            else
                od <= core[ad];
        end
    end

    always @( posedge clv ) begin
        odv <= core[adv];
    end

endmodule

module LineBuf
    (
        input        WCL,
        input        WEN,
        input  [9:0] WAD,
        input  [3:0] WDT,

        input        RCL,
        input        RWE,
        input  [9:0] RAD,
        output [3:0] RDT
    );

    wire [3:0] dum;

    DPRAM1024_4 ramcore
                (
                    WAD, RAD,
                    WCL, RCL,
                    WDT, 4'h0,
                    WEN, RWE,
                    dum, RDT
                );

endmodule
