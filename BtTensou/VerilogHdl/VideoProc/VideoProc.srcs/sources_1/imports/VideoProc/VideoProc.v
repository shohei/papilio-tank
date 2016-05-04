// CMOS Camera Controller Top Module
// Designed by Toshio Iwata at DIGITALFILTER.COM 2014/08/11

module VideoProc (
	CLK32M,
	RST_N,
	XCLK,
	BUZZER,
    VMOTOR_L,
    VMOTOR_R,
	SCL,
	SDA,
	CamHsync,
	CamVsync,
	PCLK,
	CARD_CMD, 
    CARD_CLK,
    CARD_DAT3,
    CARD_DAT0,
    RX,
    TX,
  CamData,
  SDRAM_DQMH,
  SDRAM_DQML,
  SDRAM_CS_N,
  SDRAM_WE_N,
  SDRAM_RAS_N,
  SDRAM_CAS_N,
  SDRAM_CKE,
  SDRAM_DQ,
  SDRAM_A,
  SDRAM_BA,
  SDRAM_CLK,
  	VgaVsync,
	VgaHsync,
	SW0,
	SW1,
   VR,
   VG,
   VB	
); 

input		CLK32M, RST_N;
output	XCLK;
inout SCL, SDA;
input	CamHsync;
input CamVsync;
input PCLK;
input [7:0]CamData;
output	VgaVsync;
output	VgaHsync;
input SW0;
input SW1;
output	[7:0] VR	;
output	[7:0] VG	;
output	[7:0] VB	;
output SDRAM_DQMH;
output SDRAM_DQML;
output SDRAM_CS_N;
output SDRAM_WE_N;
output SDRAM_RAS_N;
output SDRAM_CAS_N;
output SDRAM_CKE;
inout[15:0] SDRAM_DQ;
output[11:0] SDRAM_A;
output[1:0] SDRAM_BA;
output SDRAM_CLK;
output CARD_CMD;
output CARD_CLK;
output CARD_DAT3;
input CARD_DAT0;
output BUZZER;
output VMOTOR_L, VMOTOR_R;
input RX;
output TX;

wire CLK, CLK100M, RST;
wire SDRAM_DQENB_N;
wire [7:0] VgaDataR_sig, VgaDataG_sig, VgaDataB_sig;
wire [15:0] SDRAM_DQI, SDRAM_DQO;
wire [1:0] sda_o;
wire [1:0] scl_o;
wire [0:0] sda_i;
wire [0:0] scl_i;
wire [3:0] ViewMode;
wire DISPOFF;
wire   PIXSTB;
wire   PIXRD;
wire   PIXWR;
wire  [15:0] PIX2NIOS;
wire  [15:0] PIX2LOGIC;
wire LBRDY;
wire [25:0] GPO3_sig;
wire [20:0] GPI3_sig;
wire [2:0] GPO4_sig;
wire [0:0] GPI4_sig;
wire MDET_L, MDET_R;
wire [1:0] SW_sig;

  assign VR = DISPOFF == 0 ? VgaDataR_sig : 8'h00;
  assign VG = DISPOFF == 0 ? VgaDataG_sig : 8'h00;
  assign VB = DISPOFF == 0 ? VgaDataB_sig : 8'h00;

	VideoProcCore VideoProcCore_inst(
		.CLK(CLK),
		.CLK100M(CLK100M),
		.RST_N(RST_N),
		.PIXSTB(PIXSTB),
        .PIXWR(PIXWR),
        .PIXRD(PIXRD),
        .PIX2NIOS(PIX2NIOS),
        .PIX2LOGIC(PIX2LOGIC),
        .LBRDY(LBRDY),
        .XCLK(XCLK),
        .ViewMode(ViewMode),
	.CamHsync(CamHsync),
	.CamVsync(CamVsync),
	.PCLK(PCLK),
  .CamData(CamData),
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
  .SDRAM_BA(SDRAM_BA),
  .SDRAM_CLK(),
  .MDET_L(MDET_L),
  .MDET_R(MDET_R),
  .BUZZER(BUZZER),
	.VgaVsync(VgaVsync),
	.VgaHsync(VgaHsync),
	.SW0(SW0),
	.SW1(SW1),
   .VgaDataR(VgaDataR_sig),
   .VgaDataG(VgaDataG_sig),
   .VgaDataB(VgaDataB_sig)	
	);

	assign RST = !RST_N;
	assign SW_sig[1] = SW1;
	assign SW_sig[0] = SW0;
	
	assign SDA = (sda_o[1] == 1'b1) ? sda_o[0] : 1'bz;
	assign sda_i[0] = SDA;
	
  	assign SCL = (scl_o[1] == 1'b1) ? scl_o[0] : 1'bz;
	assign scl_i[0] = SCL;

	assign ViewMode = GPO3_sig[3:0];
    assign DISPOFF = GPO3_sig[4];
    assign PIXSTB = GPO3_sig[5];
    assign PIXRD = GPO3_sig[6];
    assign PIXWR = GPO3_sig[7];
    assign PIX2LOGIC = GPO3_sig[23:8];
    assign VMOTOR_L = GPO3_sig[24];
    assign VMOTOR_R = GPO3_sig[25];
    
    assign CARD_CMD = GPO4_sig[0];
    assign CARD_CLK = GPO4_sig[1];
    assign CARD_DAT3 = GPO4_sig[2];

    assign GPI3_sig = {MDET_R, MDET_L, PIX2NIOS, LBRDY, SW_sig};

    assign GPI4_sig[0] = CARD_DAT0;
  
	microblaze_mcs_v1_4_0 mcs_0 (
		.Clk(CLK),
		.Reset(RST),
		.UART_Rx(RX),
        .UART_Tx(TX),
		.GPO1(sda_o),
		.GPO2(scl_o),
		.GPO3(GPO3_sig),
		.GPO4(GPO4_sig),
		.GPI1(sda_i),
		.GPI2(scl_i),
		.GPI3(GPI3_sig),
		.GPI4(GPI4_sig),
		.GPI1_Interrupt(),
		.GPI2_Interrupt(),
		.GPI3_Interrupt(),
		.GPI4_Interrupt()
    );

	 clk_wiz_v3_6_0 your_instance_name (
		// Clock in ports
		.CLK_IN1(CLK32M),
		// Clock out ports
		.CLK_OUT1(CLK),
		.CLK_OUT2(CLK100M),
		.CLK_OUT3(SDRAM_CLK),
		// Status and control signals
		.RESET(1'b0),
		.LOCKED()
    );

  assign SDRAM_DQI = SDRAM_DQ;
  assign SDRAM_DQ = (SDRAM_DQENB_N == 0) ? SDRAM_DQO : 16'bz;
  
endmodule
