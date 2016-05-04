-- Designed by Toshio Iwata at DIGITALFILTER.COM 2013/03/19

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VideoProcCore is
	PORT	(
	CLK	: IN std_logic;
	CLK100M	: IN std_logic;
	RST_N	: IN std_logic;
	XCLK : out std_logic;
	CamHsync	: IN std_logic;
	CamVsync	: IN std_logic;
	PCLK	: IN std_logic;
  CamData	: in std_logic_vector(7 downto 0);
		ViewMode : in std_logic_vector(3 downto 0);
	MDET_L : out std_logic;
	MDET_R : out std_logic;
	BUZZER : out std_logic;
  PIXSTB : in std_logic;
  PIXRD : in std_logic;
  PIXWR : in std_logic;
  PIX2NIOS : out std_logic_vector(15 downto 0);
  PIX2LOGIC : in std_logic_vector(15 downto 0);
  LBRDY : out std_logic;
	SDRAM_DQENB_N : out std_logic;
  SDRAM_DQMH	: out std_logic;
  SDRAM_DQML	: out std_logic;
  SDRAM_CS_N	: out std_logic;
  SDRAM_WE_N	: out std_logic;
  SDRAM_RAS_N	: out std_logic;
  SDRAM_CAS_N	: out std_logic;
  SDRAM_CKE	: out std_logic;
  SDRAM_DQI : in std_logic_vector(15 downto 0);
  SDRAM_DQO : out std_logic_vector(15 downto 0);
  SDRAM_A : out std_logic_vector(11 downto 0);
  SDRAM_BA : out std_logic_vector(1 downto 0);
  SDRAM_CLK : out std_logic;
	VgaVsync : OUT std_logic;
	VgaHsync : OUT std_logic;
   VgaDataR	: OUT std_logic_vector(7 downto 0);
   VgaDataG	: OUT std_logic_vector(7 downto 0);
   VgaDataB	: OUT std_logic_vector(7 downto 0) );
end VideoProcCore ;

architecture structure of VideoProcCore is

component CAM_CTRL
	PORT	(
		CLK	: IN std_logic;
		RST_N	: IN std_logic;
		PCLK	: IN std_logic;
		CamHsync	: IN std_logic;
		CamVsync	: IN std_logic;
		CamData	: IN std_logic_vector(7 downto 0);
		LB_WR_ADDR	: out std_logic_vector(9 downto 0);
		LB_WR_DATA	: out std_logic_vector(15 downto 0);
		LB_WR_N	: out std_logic;
		CamHsync_EDGE	: out std_logic;
		CamVsync_EDGE	: out std_logic;
		CamLineCount : out std_logic_vector(8 downto 0);
    CamPixCount4x : out std_logic_vector(15 downto 0) ); 
end component;

component VGA_CTRL
	PORT	(
		CLK	: IN std_logic;
		RST_N	: IN std_logic;
		CamHsync_EDGE	: IN std_logic;
		CamVsync_EDGE	: IN std_logic;
		VgaPixCount : out std_logic_vector(9 downto 0);
		VgaLineCount	: out std_logic_vector(8 downto 0);
		VgaVisible : OUT std_logic;
		VgaVsync : OUT std_logic;
		VgaHsync : OUT std_logic;
		VgaHsync_edge : out std_logic );
end component;

component LineIn_CTRL
	Port (
		CLK	: IN std_logic;
		RST_N	: IN std_logic;
		LB_WR_ADDR	: IN std_logic_vector(9 downto 0);
		LB_WR_DATA	: IN std_logic_vector(15 downto 0);
		LB_WR_N	: IN std_logic;
		VgaLineCount : in std_logic_vector(8 downto 0);
		VgaPixCount : in std_logic_vector(9 downto 0);
  buf_RGB : out std_logic_vector(15 downto 0)
);
end component;

component LineOut_CTRL
	Port (
		CLK	: IN std_logic;
		CLK100M	: IN std_logic;
		RST_N	: IN std_logic;
		ViewMode : in std_logic_vector(3 downto 0);
  PIXSTB : in std_logic;
  PIXWR : in std_logic;
  PIXRD : in std_logic;
  PIX2NIOS : out std_logic_vector(15 downto 0);
  PIX2LOGIC : in std_logic_vector(15 downto 0);
LBRDY : out std_logic;
	SdrwLineCount : out std_logic_vector(8 downto 0);
CamHsync_edge : in std_logic;
		latch0	: IN std_logic_vector(15 downto 0);
		latch1	: IN std_logic_vector(15 downto 0);
		latch2	: IN std_logic_vector(15 downto 0);
		latch3	: IN std_logic_vector(15 downto 0);
		CamLineCount : in std_logic_vector(8 downto 0);
		VgaLineCount	: in std_logic_vector(8 downto 0);
		VgaPixCount : IN std_logic_vector(9 downto 0);
  vga_RGB_dly0 : out std_logic_vector(15 downto 0);
  vga_RGB_dly1 : out std_logic_vector(15 downto 0);
  vga_RGB_dly2 : out std_logic_vector(15 downto 0);
  vga_RGB_dly3 : out std_logic_vector(15 downto 0);
		winp0: in std_logic;
		winp1: in std_logic;
		winp2: in std_logic;
		winp3: in std_logic;
  vga_r : out std_logic_vector(7 downto 0);
  vga_g : out std_logic_vector(7 downto 0);
  vga_b : out std_logic_vector(7 downto 0)
);
end component;

component SDRAM_CTRL
	Port (
		CLK	: IN std_logic;
		CLK100M	: IN std_logic;
		RST_N	: IN std_logic;
  PIXSTB : in std_logic;
  PIXWR : in std_logic;
  LBRDY : in std_logic;
	SdrwLineCount : in std_logic_vector(8 downto 0);
		ViewMode : in std_logic_vector(3 downto 0);
		VgaHsync_edge : in std_logic;
		CamVsync_edge : in std_logic;
		CamVsync : in std_logic;
		CamLineCount: in std_logic_vector(8 downto 0);
		CamPixCount4x : in std_logic_vector(15 downto 0);
		VgaPixCount : in std_logic_vector(9 downto 0);
		VgaLineCount	: in std_logic_vector(8 downto 0);
  buf_RGB : in std_logic_vector(15 downto 0);
		latch0	: out std_logic_vector(15 downto 0);
		latch1	: out std_logic_vector(15 downto 0);
		latch2	: out std_logic_vector(15 downto 0);
		latch3	: out std_logic_vector(15 downto 0);
  vga_RGB_dly0 : in std_logic_vector(15 downto 0);
  vga_RGB_dly1 : in std_logic_vector(15 downto 0);
  vga_RGB_dly2 : in std_logic_vector(15 downto 0);
  vga_RGB_dly3 : in std_logic_vector(15 downto 0);
		winp0: out std_logic;
		winp1: out std_logic;
		winp2: out std_logic;
		winp3: out std_logic;
	MDET_L : out std_logic;
	MDET_R : out std_logic;
  SDRAM_DQENB_N: out std_logic;
  SDRAM_DQMH	: out std_logic;
  SDRAM_DQML	: out std_logic;
  SDRAM_CS_N	: out std_logic;
  SDRAM_WE_N	: out std_logic;
  SDRAM_RAS_N	: out std_logic;
  SDRAM_CAS_N	: out std_logic;
  SDRAM_CKE	: out std_logic;
  SDRAM_DQI : in std_logic_vector(15 downto 0);
  SDRAM_DQO : out std_logic_vector(15 downto 0);
  SDRAM_A : out std_logic_vector(11 downto 0);
  SDRAM_BA : out std_logic_vector(1 downto 0) );
end component;
        
signal rgb_sig : std_logic_vector(23 downto 0);
signal VgaHsync_sig : std_logic;
signal ODDLINE_sig : std_logic;
signal 	LB_WR_ADDR	: std_logic_vector(9 downto 0);
signal 	LB_WR_DATA	: std_logic_vector(15 downto 0);
signal 	LB_WR_N	: std_logic;
signal CamHsync_EDGE, CamVsync_EDGE : std_logic;
signal VgaVisible : std_logic;
 signal pclk_sig : std_logic;
 signal buf_RGB : std_logic_vector(15 downto 0);
signal VgaHsync_edge : std_logic;
signal CamPixCount4x : std_logic_vector(15 downto 0);
signal CamLineCount : std_logic_vector(8 downto 0);
signal latch0, latch1, latch2, latch3 : std_logic_vector(15 downto 0);
signal winp0,winp1,winp2,winp3 : std_logic;
 signal vga_r, vga_g, vga_b : std_logic_vector(7 downto 0);
signal  vga_RGB_dly0 : std_logic_vector(15 downto 0);
signal  vga_RGB_dly1 : std_logic_vector(15 downto 0);
signal  vga_RGB_dly2 : std_logic_vector(15 downto 0);
signal  vga_RGB_dly3 : std_logic_vector(15 downto 0);
signal VgaPixCount : std_logic_vector(9 downto 0);
signal VgaLineCount	: std_logic_vector(8 downto 0);
signal LBRDY_sig : std_logic;
signal SdrwLineCount : std_logic_vector(8 downto 0);
signal  counter0 : std_logic_vector(23 downto 0);
signal  counter0_clr, counter0_dec : std_logic;

begin

  VgaHsync <= VgaHsync_sig;

  VgaDataR <= vga_r when VgaVisible = '1' else "00000000";
  VgaDataG <= vga_g when VgaVisible = '1' else "00000000";
  VgaDataB <= vga_b when VgaVisible = '1' else "00000000";

  pclk_sig <= PCLK;
  
CAM_CTRL_1 : CAM_CTRL port map (
		CLK	=> CLK,
		RST_N	=> RST_N,
		PCLK	=> PCLK_sig,
		CamHsync	=> CamHsync,
		CamVsync	=> CamVsync,
		CamData	=> CamData,
		LB_WR_ADDR	=> LB_WR_ADDR,
		LB_WR_DATA	=> LB_WR_DATA,
		LB_WR_N	=> LB_WR_N,
		CamHsync_EDGE => CamHsync_EDGE,
		CamVsync_EDGE => CamVsync_EDGE,
		CamLineCount => CamLineCount,
    CamPixCount4x => CamPixCount4x ); 

    XCLK <= CamPixCount4x(0);
    
VGA_CTRL_1 : VGA_CTRL port map (
		CLK	=> CLK,
		RST_N	=> RST_N,
		CamHsync_EDGE	=> CamHsync_EDGE, 
		CamVsync_EDGE	=> CamVsync_EDGE, 
		VgaLineCount	=> VgaLineCount, 
		VgaPixCount	=> VgaPixCount, 
		VgaVisible => VgaVisible,
		VgaVsync => VgaVsync,
		VgaHsync => VgaHsync_sig,
		VgaHsync_edge => VgaHsync_edge );

LineIn_CTRL_1 : LineIn_CTRL port map (
   CLK		=> CLK,
		RST_N	=> RST_N,
		LB_WR_ADDR	=> LB_WR_ADDR,
		LB_WR_DATA	=> LB_WR_DATA,
		LB_WR_N	=> LB_WR_N,
		VgaLineCount => VgaLineCount,
		VgaPixCount	=> VgaPixCount, 
  buf_RGB => buf_RGB
 );

LineOut_CTRL_1 : LineOut_CTRL port map (
   CLK		=> CLK,
   CLK100M		=> CLK100M,
		RST_N	=> RST_N,
		ViewMode => ViewMode,
  PIXSTB => PIXSTB,
  PIXWR => PIXWR,
  PIXRD => PIXRD,
  PIX2NIOS => PIX2NIOS,
  PIX2LOGIC => PIX2LOGIC,
LBRDY => LBRDY_sig,
	SdrwLineCount =>	SdrwLineCount ,
		CamHsync_edge => CamHsync_edge,
		latch0	=> latch0,
		latch1	=> latch1,
		latch2	=> latch2,
		latch3	=> latch3,
		CamLineCount => CamLineCount,
		VgaLineCount	=> VgaLineCount, 
		VgaPixCount	=> VgaPixCount,
  vga_RGB_dly0 => vga_RGB_dly0,
  vga_RGB_dly1 => vga_RGB_dly1,
  vga_RGB_dly2 => vga_RGB_dly2,
  vga_RGB_dly3 => vga_RGB_dly3,
		winp0	=> winp0,
		winp1	=> winp1,
		winp2	=> winp2,
		winp3	=> winp3,
  vga_r => vga_r, 
  vga_g => vga_g,
  vga_b => vga_b
 );
 
 LBRDY <= LBRDY_sig;

SDRAM_CTRL_1 : SDRAM_CTRL port map (
   CLK		=> CLK,
   CLK100M		=> CLK100M,
		RST_N	=> RST_N,
		PIXSTB => PIXSTB,
  PIXWR => PIXWR,
  LBRDY => LBRDY_sig,
	SdrwLineCount =>	SdrwLineCount ,
		ViewMode => ViewMode,
		VgaHsync_edge => VgaHsync_edge,
		CamVsync_edge => CamVsync_edge,
		CamVsync => CamVsync,
		CamLineCount => CamLineCount,
    CamPixCount4x => CamPixCount4x,
		VgaPixCount => VgaPixCount,
		VgaLineCount	=> VgaLineCount, 
  buf_RGB => buf_RGB, 
		latch0	=> latch0,
		latch1	=> latch1,
		latch2	=> latch2,
		latch3	=> latch3,
  vga_RGB_dly0 => vga_RGB_dly0,
  vga_RGB_dly1 => vga_RGB_dly1,
  vga_RGB_dly2 => vga_RGB_dly2,
  vga_RGB_dly3 => vga_RGB_dly3,
		winp0	=> winp0,
		winp1	=> winp1,
		winp2	=> winp2,
		winp3	=> winp3,
	MDET_L => MDET_L,
	MDET_R => MDET_R,
  SDRAM_DQENB_N => SDRAM_DQENB_N,
  SDRAM_DQMH	=> SDRAM_DQMH,
  SDRAM_DQML	=> SDRAM_DQML,
  SDRAM_CS_N	=> SDRAM_CS_N,
  SDRAM_WE_N	=> SDRAM_WE_N,
  SDRAM_RAS_N	=> SDRAM_RAS_N,
  SDRAM_CAS_N	=> SDRAM_CAS_N,
  SDRAM_CKE	=> SDRAM_CKE,
  SDRAM_DQI => SDRAM_DQI,
  SDRAM_DQO => SDRAM_DQO,
  SDRAM_A => SDRAM_A,
  SDRAM_BA => SDRAM_BA
 );

  SDRAM_CLK <= CLK100M;
  BUZZER <= '0';
  
end structure ;

