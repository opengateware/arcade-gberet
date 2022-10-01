//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2013-2019 MiSTer-X
//------------------------------------------------------------------------------
// FPGA Implimentation of "Green Beret" (Sound Part)
//------------------------------------------------------------------------------

module SOUND
    (
        input         dacclk,
        input         reset,

        output  [7:0] SNDOUT,

        input         CPUCL,
        input         CPUMX,
        input  [15:0] CPUAD,
        input         CPUWR,
        input  [7:0]  CPUWD,
        input         pause
    );

    wire CS_SNDLC = ( CPUAD[15:8] == 8'hF2 ) & CPUMX & CPUWR;
    wire CS_SNDWR = ( CPUAD[15:8] == 8'hF4 ) & CPUMX;

    reg [7:0] SNDLATCH;
    always @( posedge CPUCL or posedge reset )
    begin
        if (reset)
            SNDLATCH <= 0;
        else
        begin
            if ( CS_SNDLC )
                SNDLATCH <= CPUWD;
        end
    end

    wire sndclk;
    sndclkgen scgen( dacclk, sndclk );


    wire [3:0] sndmask = pause ? 4'b0000 : 4'b1111;
    SN76496 sgn( sndclk, CPUCL, reset, CS_SNDWR, CPUWR, SNDLATCH, sndmask, SNDOUT );

endmodule

/**
 * Clock Generator
 * in: 50000000Hz -> out: 1600000Hz
 */
module sndclkgen( input in, output reg out );
    reg [6:0] count;
    always @( posedge in )
    begin
        if (count > 7'd117)
        begin
            count <= count - 7'd117;
            out <= ~out;
        end
        else
            count <= count + 7'd8;
    end
endmodule
