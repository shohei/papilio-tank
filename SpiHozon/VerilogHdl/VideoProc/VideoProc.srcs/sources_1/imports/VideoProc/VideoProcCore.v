module VideoProcCore (
	CLK,
	CLK100M,
	RST_N,
  PIXSTB,
  PIXWR,
  PIXRD,
  PIX2NIOS,
  PIX2LOGIC,
  LBRDY,
	XCLK,
	ViewMode,
	CamHsync,
	CamVsync,
	PCLK,
  CamData,
  SDRAM_DQENB_N,
  SDRAM_DQMH,
  SDRAM_DQML,
  SDRAM_CS_N,
  SDRAM_WE_N,
  SDRAM_RAS_N,
  SDRAM_CAS_N,
  SDRAM_CKE,
  SDRAM_DQI,
  SDRAM_DQO,
  SDRAM_A,
  SDRAM_BA,
  SDRAM_CLK,
  MDET_L,
  MDET_R,
  BUZZER,
 	VgaVsync,
	VgaHsync,
	SW0,
	SW1,
   VgaDataR,
   VgaDataG,
   VgaDataB	
); 

input		CLK, CLK100M, RST_N;
output	XCLK;
input	CamHsync;
input CamVsync;
input PCLK;
input [7:0]CamData;
output	VgaVsync;
output	VgaHsync;
input SW0;
input SW1;
output	[7:0] VgaDataR	;
output	[7:0] VgaDataG	;
output	[7:0] VgaDataB	;
output SDRAM_DQENB_N;
output SDRAM_DQMH;
output SDRAM_DQML;
output SDRAM_CS_N;
output SDRAM_WE_N;
output SDRAM_RAS_N;
output SDRAM_CAS_N;
output SDRAM_CKE;
input[15:0] SDRAM_DQI;
output[15:0] SDRAM_DQO;
output[11:0] SDRAM_A;
output[1:0] SDRAM_BA;
output SDRAM_CLK;
input[3:0] ViewMode;
output MDET_L;
output MDET_R;
input PIXSTB;
input PIXWR;
input PIXRD;
output [15:0] PIX2NIOS;
input [15:0] PIX2LOGIC;
output LBRDY;
output BUZZER;

wire CamHsync_EDGE, CamVsync_EDGE;
wire [9:0] LB_WR_ADDR;
wire [15:0] LB_WR_DATA;
wire LB_WR_N;
wire [8:0] VgaLineCount;
wire [9:0] VgaPixCount;
wire [15:0] buf_RGB;
wire [8:0] CamLineCount;
wire [15:0] CamPixCount4x;
wire VgaVisible, VgaVsync, VgaHsync, VgaHsync_EDGE, OddFrame;
wire [15:0] latch0, latch1, latch2, latch3;
wire winp0,winp1,winp2,winp3;
wire [7:0] vga_r, vga_g, vga_b;
wire  [15:0] vga_RGB_latch0;
wire  [15:0] vga_RGB_latch1;
wire  [15:0] vga_RGB_latch2;
wire  [15:0] vga_RGB_latch3;
wire [8:0] SdrwLineCount;
wire MDET_L, MDET_R;

assign VgaDataR = (VgaVisible == 1 ) ? vga_r : 8'h00;
assign VgaDataG = (VgaVisible == 1 ) ? vga_g : 8'h00;
assign VgaDataB = (VgaVisible == 1 ) ? vga_b : 8'h00;

assign XCLK = CamPixCount4x[0];
assign SDRAM_CLK = CLK100M;

	LINEIN_CTRL LINEIN_CTRL_inst(
	.CLK(CLK),
	.RST_N(RST_N),
	.LB_WR_ADDR(LB_WR_ADDR),
	.LB_WR_DATA(LB_WR_DATA),
	.LB_WR_N(LB_WR_N),
	.VgaLineCount(VgaLineCount),
	.VgaPixCount(VgaPixCount),
	.buf_RGB(buf_RGB)
);

	CAM_CTRL CAM_CTRL_inst(
	.CLK(CLK),
	.RST_N(RST_N),
	.PCLK(PCLK),
	.CamHsync(CamHsync),
	.CamVsync(CamVsync),
	.CamData(CamData),
	.LB_WR_ADDR(LB_WR_ADDR),
	.LB_WR_DATA(LB_WR_DATA),
	.LB_WR_N(LB_WR_N),
	.CamHsync_EDGE(CamHsync_EDGE),
	.CamVsync_EDGE(CamVsync_EDGE),
	.CamLineCount(CamLineCount),
	.CamPixCount4x(CamPixCount4x)
);

	VGA_CTRL VGA_CTRL_inst (
	.CLK(CLK),
	.RST_N(RST_N),
	.CamHsync_EDGE(CamHsync_EDGE),
	.CamVsync_EDGE(CamVsync_EDGE),
	.VgaLineCount(VgaLineCount),
	.VgaPixCount(VgaPixCount),
	.VgaVisible(VgaVisible),
	.VgaVsync(VgaVsync),
	.VgaHsync(VgaHsync),
	.VgaHsync_EDGE(VgaHsync_EDGE),
	.OddFrame(OddFrame)
); 

  SDRAM_CTRL SDRAM_CTRL_inst (
  .CLK(CLK),
  .CLK100M(CLK100M),
  .RST_N(RST_N),
  .PIXSTB(PIXSTB),
  .PIXWR(PIXWR),
  .LBRDY(LBRDY),
  .SdrwLineCount(SdrwLineCount),
  .ViewMode(ViewMode),
  .VgaHsync_EDGE(VgaHsync_EDGE),
  .CamVsync(CamVsync),
  .CamVsync_EDGE(CamVsync_EDGE),
  .CamLineCount(CamLineCount),
  .CamPixCount4x(CamPixCount4x),
  .VgaLineCount(VgaLineCount),
  .VgaPixCount(VgaPixCount),
  .buf_RGB(buf_RGB),
  .latch0(latch0),
  .latch1(latch1),
  .latch2(latch2),
  .latch3(latch3),
  .vga_RGB_dly0(vga_RGB_latch0),
  .vga_RGB_dly1(vga_RGB_latch1),
  .vga_RGB_dly2(vga_RGB_latch2),
  .vga_RGB_dly3(vga_RGB_latch3),
  .winp0(winp0),
  .winp1(winp1),
  .winp2(winp2),
  .winp3(winp3),
  .MDET_L(MDET_L),
  .MDET_R(MDET_R),
  .SDRAM_DQENB_N(SDRAM_DQENB_N),
  .SDRAM_DQMH(SDRAM_DQMH),
  .SDRAM_DQML(SDRAM_DQML),
  .SDRAM_CS_N(SDRAM_CS_N),
  .SDRAM_WE_N(SDRAM_WE_N),
  .SDRAM_RAS_N(SDRAM_RAS_N),
  .SDRAM_CAS_N(SDRAM_CAS_N),
  .SDRAM_CKE(SDRAM_CKE),
  .SDRAM_DQI(SDRAM_DQI),
  .SDRAM_DQO(SDRAM_DQO),
  .SDRAM_A(SDRAM_A),
  .SDRAM_BA(SDRAM_BA)
);

LINEOUT_CTRL LINEOUT_CTRL_inst(
  .CLK(CLK),
  .CLK100M(CLK100M),
  .RST_N(RST_N),
  .ViewMode(ViewMode),
  .PIXSTB(PIXSTB),
  .PIXWR(PIXWR),
  .PIXRD(PIXRD),
  .PIX2NIOS(PIX2NIOS),
  .PIX2LOGIC(PIX2LOGIC),
  .LBRDY(LBRDY),
  .SdrwLineCount(SdrwLineCount),
  .CamHsync_EDGE(CamHsync_EDGE),
  .latch0(latch0),
  .latch1(latch1),
  .latch2(latch2),
  .latch3(latch3),
  .CamLineCount(CamLineCount),
  .VgaLineCount(VgaLineCount),
  .VgaPixCount(VgaPixCount),
  .vga_RGB_latch0(vga_RGB_latch0),
  .vga_RGB_latch1(vga_RGB_latch1),
  .vga_RGB_latch2(vga_RGB_latch2),
  .vga_RGB_latch3(vga_RGB_latch3),
  .winp0(winp0),
  .winp1(winp1),
  .winp2(winp2),
  .winp3(winp3),
  .vga_r(vga_r),
  .vga_g(vga_g),
  .vga_b(vga_b)
);

assign BUZZER = 0;

endmodule
