//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2013-2019 MiSTer-X
//------------------------------------------------------------------------------
// FPGA Implimentation of "Green Beret" (Video Part)
//------------------------------------------------------------------------------

module VIDEO
    (
        input         VCLKx8,
        input         VCLKx4,
        input         VCLKx2,
        input         VCLK,

        input  [8:0]  HP,
        input  [8:0]  VP,

        input         PALD,
        input         CPUD,

        output        PCLK,
        output [11:0] POUT,

        input         CPUCL,
        input         CPUMX,
        input  [15:0] CPUAD,
        input         CPUWR,
        input  [7:0]  CPUWD,
        output        CPUDV,
        output [7:0]  CPURD,


        input         DLCL,
        input  [17:0] DLAD,
        input  [7:0]  DLDT,
        input         DLEN,

        input  [15:0] hs_address,
        input  [7:0]  hs_data_in,
        output [7:0]  hs_data_out,
        input         hs_write,
        input         hs_access
    );

    // Video RAMs
    wire        CS_CRAM = ( CPUAD[15:11] ==  5'b1100_0              ) & CPUMX;  // $C000-$C7FF
    wire        CS_VRAM = ( CPUAD[15:11] ==  5'b1100_1              ) & CPUMX;  // $C800-$CFFF
    wire        CS_MRAM = ( CPUAD[15:12] ==  4'b1101                ) & CPUMX;  // $D000-$DFFF
    wire        CS_ZRM0 = ( CPUAD[15: 5] == 11'b1110_0000_000       ) & CPUMX;  // $E000-$E01F
    wire        CS_ZRM1 = ( CPUAD[15: 5] == 11'b1110_0000_001       ) & CPUMX;  // $E020-$E03F
    wire        CS_SPRB = ( CPUAD[15: 0] == 16'b1110_0000_0100_0011 ) & CPUMX;  // $E043

    wire  [7:0] OD_CRAM, OD_VRAM;
    wire  [7:0] OD_MRAM;
    wire  [7:0] OD_ZRM0, OD_ZRM1;

    assign CPUDV = CS_CRAM | CS_VRAM | CS_MRAM | CS_ZRM0 | CS_ZRM1 ;

    assign CPURD = CS_CRAM ? OD_CRAM :
                   CS_VRAM ? OD_VRAM :
                   CS_MRAM ? OD_MRAM :
                   CS_ZRM0 ? OD_ZRM0 :
                   CS_ZRM1 ? OD_ZRM1 :
                   8'h0;

    wire [10:0]    BGVA;
    wire  [7:0]    BGCR, BGVR;

    reg         SPRB;
    wire  [7:0] SATA;
    wire  [7:0] SATD;
    wire [11:0] SAAD = {3'b000,SPRB,SATA};

    always @( posedge CPUCL )
        if ( CS_SPRB & CPUWR )
            SPRB <= ~CPUWD[3];

    wire  [4:0] ZRMA;
    wire  [7:0] ZRM0, ZRM1;
    wire [15:0] ZRMD = {ZRM1,ZRM0};

    // Hiscore mux
    wire        mram_clk = hs_access ? DLCL : CPUCL;
    wire [11:0] mram_addr = hs_access ? hs_address[11:0] : CPUAD[11:0];
    wire        mram_cs = hs_access ? 1'b1 : CS_MRAM;
    wire        mram_we = hs_access ? hs_write : CPUWR;
    wire [7:0]  mram_di = hs_access ? hs_data_in : CPUWD;
    wire [7:0]  mram_do;

    assign      OD_MRAM = hs_access ? 8'b0 : mram_do;
    assign      hs_data_out = hs_access ? mram_do : 8'b0;

    VRAM2048 cram( CPUCL, CPUAD[10:0], CS_CRAM, CPUWR, CPUWD, OD_CRAM, VCLKx4, BGVA, BGCR );
    VRAM2048 vram( CPUCL, CPUAD[10:0], CS_VRAM, CPUWR, CPUWD, OD_VRAM, VCLKx4, BGVA, BGVR );
    VRAM4096 mram( mram_clk, mram_addr, mram_cs, mram_we, mram_di, mram_do,~VCLKx8, SAAD, SATD );
    VRAM32   zrm0( CPUCL, CPUAD[ 4:0], CS_ZRM0, CPUWR, CPUWD, OD_ZRM0, VCLKx4, ZRMA, ZRM0 );
    VRAM32   zrm1( CPUCL, CPUAD[ 4:0], CS_ZRM1, CPUWR, CPUWD, OD_ZRM1, VCLKx4, ZRMA, ZRM1 );

    // BG Scanline Generator
    wire  [8:0] BGVP = VP+9'd16;
    wire  [8:0] BGHP = HP+9'd8+(ZRMD[8:0]);

    assign      ZRMA = BGVP[7:3];
    assign      BGVA = {BGVP[7:3],BGHP[8:3]};
    wire  [8:0] BGCH = {BGCR[6],BGVR};
    wire  [3:0] BGCL = BGCR[3:0];
    wire  [1:0] BGFL = BGCR[5:4];

    wire  [2:0] BGHH = BGHP[2:0]^{3{BGFL[0]}};
    wire  [2:0] BGVV = BGVP[2:0]^{3{BGFL[1]}};
    wire [13:0] BGCA = {BGCH,BGVV[2:0],BGHH[2:1]};
    wire  [0:7] BGCD;
    BGCHIP_ROM  bgchip( VCLKx2, BGCA, BGCD, DLCL,DLAD,DLDT,DLEN );

    wire  [7:0] BGCT = {BGCL,(BGHH[0] ? BGCD[4:7]:BGCD[0:3])};
    wire  [3:0] BGPT;
    BGCLUT_ROM  bgclut( ~VCLK, BGCT, BGPT, DLCL,DLAD,DLDT,DLEN );

    reg            BGHI;
    always @( negedge VCLK ) BGHI <= ~BGCR[7];

    // Sprite Scanline Generator
    wire [8:0] SPHP = HP+9'd9;
    wire [8:0] SPVP = VP+9'd18;
    wire [3:0] SPPT;
    SPRRENDER  spr( VCLKx8,VCLK, SPHP,SPVP,SATA,SATD, SPPT, DLCL,DLAD,DLDT,DLEN );

    // Color Mixer
    wire [4:0] COLMIX = (BGHI & (|BGPT)) ? {1'b1,BGPT} : (|SPPT) ? {1'b0,SPPT} : {1'b1,BGPT};

    // Palette
    wire [4:0] PALIN = PALD ? VP[6:2] : COLMIX;
    wire [7:0] PALET;
    PALET_ROM  palet( VCLK, PALIN, PALET, DLCL,DLAD,DLDT,DLEN );
    wire [7:0] PALOT = PALD ? ( (|VP[8:7]) ? 8'h0 : PALET ) : PALET;

    // Pixel Output
    assign PCLK = ~VCLK;
    assign POUT = {PALOT[7:6],2'b00,PALOT[5:3],1'b0,PALOT[2:0],1'b0};

endmodule


//----------------------------------
//  Sprite Render
//----------------------------------
module SPRRENDER
    (
        input            VCLKx8,
        input            VCLK,

        input      [8:0] SPHP,
        input      [8:0] SPVP,

        output     [7:0] SATA,
        input      [7:0] SATD,

        output reg [3:0] SPPT,


        input            DLCL,
        input     [17:0] DLAD,
        input      [7:0] DLDT,
        input            DLEN
    );

    reg  [5:0]  sano;
    reg  [1:0]  saof;
    reg  [7:0]  sat0, sat1, sat2, sat3;

    reg  [2:0]  phase;

    wire [8:0]  px    = {1'b0,sat2} - {sat1[7],8'h0};
    wire [7:0]  py    = (phase==1) ? SATD : sat3;
    wire        fx    = sat1[4];
    wire        fy    = sat1[5];
    wire [8:0]  code  = {sat1[6],sat0};
    wire [3:0]  color = sat1[3:0];

    wire [8:0]  ht    = {1'b0,py}-SPVP;
    wire        hy    = (py!=0) & (ht[8:4]==5'b11111);

    reg  [4:0]  xcnt;
    wire [3:0]  lx    = xcnt[3:0]^{4{ fx}};
    wire [3:0]  ly    =   ht[3:0]^{4{~fy}};

    wire [15:0] SPCA  = {code,ly[3],lx[3],ly[2:0],lx[2:1]};
    wire  [0:7] SPCD;
    SPCHIP_ROM    spchip( ~VCLKx8, SPCA, SPCD, DLCL,DLAD,DLDT,DLEN );

    wire [7:0]  pix   = {color,(lx[0] ? SPCD[4:7]:SPCD[0:3])};


`define SPRITES 8'h30

    always @( posedge VCLKx8 )
    begin
        if (SPHP==0)
        begin
            xcnt  <= 0;
            sano  <= 0;
            saof  <= 3;
            phase <= 1;
        end
        else
        case (phase)
            0: /* empty */ ;
            1:
            begin
                if (sano >= `SPRITES)
                    phase <= 0;
                else
                begin
                    if (hy)
                    begin
                        sat3  <= SATD;
                        saof  <= 2;
                        phase <= phase+3'd1;
                    end
                    else
                        sano <= sano+6'd1;
                end
            end
            2:
            begin
                sat2  <= SATD;
                saof  <= 1;
                phase <= phase+3'd1;
            end
            3:
            begin
                sat1  <= SATD;
                saof  <= 0;
                phase <= phase+3'd1;
            end
            4:
            begin
                sat0  <= SATD;
                saof  <= 3;
                sano  <= sano+6'd1;
                xcnt  <= 5'b1_0000;
                phase <= phase+3'd1;
            end
            5:
            begin
                xcnt  <= xcnt+5'd1;
                phase <= wre ? phase : 3'd1;
            end
            default: ;
        endcase
    end

    assign SATA = {sano,saof};

    wire       wre = xcnt[4];
    wire       sid = SPVP[0];
    wire [8:0] wpx = px+xcnt[3:0];

    // CLUT
    reg  [9:0] lbad;
    reg  [3:0] lbdt;
    reg        lbwe;
    always @(posedge VCLKx8)
    begin
        lbad <= {~sid,wpx};
        lbwe <= wre;
    end
    wire [3:0] opix;
    SPCLUT_ROM spclut(VCLKx8, pix, opix, DLCL,DLAD,DLDT,DLEN );
    always @(negedge VCLKx8) lbdt <= opix;

    // Line-Buffer
    reg  [9:0] radr0=0,radr1=1;
    wire [3:0] ispt;
    always @(negedge VCLK) radr0 <= {sid,SPHP};
    always @(posedge VCLK)
    begin
        if (radr0!=radr1)
            SPPT <= ispt;
        radr1 <= radr0;
    end
    LineBuf lbuf(VCLKx8,lbwe & (lbdt!=0),lbad,lbdt, VCLKx8,(radr0==radr1),radr0,ispt);

endmodule
