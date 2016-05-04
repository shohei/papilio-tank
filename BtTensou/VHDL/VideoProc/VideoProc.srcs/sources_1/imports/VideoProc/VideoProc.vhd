-- CMOS Camera Controller Top Module
-- Designed by Toshio Iwata at DIGITALFILTER.COM 2014/08/11

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VideoProc is
	PORT	(
	CLK32M	: IN std_logic;
	SW0 : in std_logic;
	SW1 : in std_logic;
	BUZZER : out std_logic;
	VMOTOR_L : out std_logic;
	VMOTOR_R : out std_logic;
	LED0 : out std_logic;
	RST_N	: IN std_logic;
	XCLK : out std_logic;
  CARD_CMD : out std_logic;
  CARD_CLK : out std_logic;
  CARD_DAT0 : in std_logic;
  CARD_DAT3 : out std_logic;
  RX : in STD_LOGIC; 
  TX : out STD_LOGIC; 
	CamHsync	: IN std_logic;
	CamVsync	: IN std_logic;
	PCLK	: IN std_logic;
  CamData	: in std_logic_vector(7 downto 0);
  SDRAM_DQMH	: out std_logic;
  SDRAM_DQML	: out std_logic;
  SDRAM_CS_N	: out std_logic;
  SDRAM_WE_N	: out std_logic;
  SDRAM_RAS_N	: out std_logic;
  SDRAM_CAS_N	: out std_logic;
  SDRAM_CKE	: out std_logic;
  SDRAM_DQ : inout std_logic_vector(15 downto 0);
  SDRAM_A : out std_logic_vector(11 downto 0);
  SDRAM_BA : out std_logic_vector(1 downto 0);
  SDRAM_CLK : out std_logic;
	VgaVsync : OUT std_logic;
	VgaHsync : OUT std_logic;
	SCL : inout std_logic;
	SDA : inout std_logic;
   VgaDataR	: OUT std_logic_vector(7 downto 0);
   VgaDataG	: OUT std_logic_vector(7 downto 0);
   VgaDataB	: OUT std_logic_vector(7 downto 0) );
end VideoProc ;

architecture structure of VideoProc is

component VideoProcCore
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
end component;

		  -- The following code must appear in the VHDL architecture header:
------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component clk_wiz_v3_6_0
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  CLK_OUT3          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

component microblaze_mcs_v1_4_0 
port (
  Clk : in std_logic;
  Reset : in std_logic;
  UART_Rx : in STD_LOGIC; 
  UART_Tx : out STD_LOGIC; 
  GPO1 : out std_logic_vector(1 downto 0);
  GPO2 : out std_logic_vector(1 downto 0);
  GPO3 : out std_logic_vector(25 downto 0);
  GPO4 : out std_logic_vector(2 downto 0);
  GPI1 : in std_logic_vector(0 downto 0);
  GPI2 : in std_logic_vector(0 downto 0);
  GPI3 : in std_logic_vector(20 downto 0);
  GPI4 : in std_logic_vector(0 downto 0);
  GPI1_interrupt : out std_logic;
  GPI2_interrupt : out std_logic;
  GPI3_interrupt : out std_logic;
  GPI4_interrupt : out std_logic );
end component;

-- COMP_TAG_END ------ End COMPONENT Declaration ------------

signal CLK, RST : std_logic;
signal sda_o : std_logic_vector(1 downto 0);
signal scl_o : std_logic_vector(1 downto 0);
signal sda_i : std_logic_vector(0 downto 0);
signal scl_i : std_logic_vector(0 downto 0);
signal sw_sig : std_logic_vector(1 downto 0);
signal led_sig : std_logic_vector(0 downto 0);
 signal CLK100M	: std_logic;
 signal SDRAM_DQENB_N : std_logic;
signal   SDRAM_DQI, SDRAM_DQO : std_logic_vector(15 downto 0);
signal  VgaDataR_sig, VgaDataG_sig, VgaDataB_sig : std_logic_vector(7 downto 0);

signal PERIOD : std_logic_vector(23 downto 0);
signal DECODE : std_logic_vector(23 downto 0);
signal ViewMode : std_logic_vector(3 downto 0);
signal DISPOFF : std_logic;
signal   PIXSTB : std_logic;
signal   PIXRD : std_logic;
signal   PIXWR : std_logic;
signal   PIX2NIOS : std_logic_vector(15 downto 0);
signal   PIX2LOGIC : std_logic_vector(15 downto 0);
signal LBRDY : std_logic;
signal GPO3_sig : std_logic_vector(25 downto 0);
signal GPI3_sig : std_logic_vector(20 downto 0);
signal GPO4_sig : std_logic_vector(2 downto 0);
signal GPI4_sig : std_logic_vector(0 downto 0);
signal MDET_L, MDET_R : std_logic;

begin

  VgaDataR <= VgaDataR_sig when DISPOFF = '0' else "00000000";
  VgaDataG <= VgaDataG_sig when DISPOFF = '0' else "00000000";
  VgaDataB <= VgaDataB_sig when DISPOFF = '0' else "00000000";

  LED0 <= led_sig(0);
  sw_sig <= SW1 & SW0;

  RST <= not RST_N;

  SDA <= sda_o(0) when sda_o(1) = '1' else 'Z';
  sda_i(0) <= SDA;
  
  SCL <= scl_o(0) when scl_o(1) = '1' else 'Z';
  scl_i(0) <= SCL;
  
  ViewMode <= GPO3_sig(3 downto 0);
  DISPOFF <= GPO3_sig(4);
  PIXSTB <= GPO3_sig(5);
  PIXRD <= GPO3_sig(6);
  PIXWR <= GPO3_sig(7);
  PIX2LOGIC <= GPO3_sig(23 downto 8);
  VMOTOR_L <= GPO3_sig(24);
  VMOTOR_R <= GPO3_sig(25);
  
  GPI3_sig <= MDET_R & MDET_L & PIX2NIOS & LBRDY & sw_sig;
  
  CARD_CMD <= GPO4_sig(0);
  CARD_CLK <= GPO4_sig(1);
  CARD_DAT3 <= GPO4_sig(2);
  
  GPI4_sig(0) <= CARD_DAT0;
  
mcs_0 : microblaze_mcs_v1_4_0 port map (
    Clk 	=> CLK,
    Reset	=> RST,
    UART_Rx => RX, 
    UART_Tx => TX, 
    GPO1 	=> sda_o,
    GPO2 	=> scl_o,
    GPO3 	=> GPO3_sig,
    GPO4 	=> GPO4_sig,
    GPI1 	=> sda_i,
    GPI2 	=> scl_i,
    GPI3 	=> GPI3_sig,
    GPI4 	=> GPI4_sig,
    GPI1_interrupt	=> open,
    GPI2_interrupt	=> open,
    GPI3_interrupt	=> open,
    GPI4_interrupt	=> open );

VideoProcCore_1 : VideoProcCore port map (
		CLK	=> CLK,
		CLK100M	=> CLK100M,
		RST_N	=> RST_N,
		XCLK	=> XCLK,
	CamHsync	=> CamHsync,
	CamVsync	=> CamVsync,
	PCLK	=> PCLK,
  CamData	=> CamData,
  ViewMode	=> ViewMode,
		MDET_L => MDET_L,
	   MDET_R => MDET_R,
	BUZZER => BUZZER,
  PIXSTB => PIXSTB,
  PIXRD => PIXRD,
  PIXWR => PIXWR,
  PIX2NIOS => PIX2NIOS,
  PIX2LOGIC => PIX2LOGIC,
  LBRDY => LBRDY,
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
  SDRAM_BA => SDRAM_BA,
  SDRAM_CLK	=> open,
      VgaVsync => VgaVsync,
      VgaHsync => VgaHsync,
      VgaDataR => VgaDataR_sig, 
		VgaDataG => VgaDataG_sig, 
		VgaDataB => VgaDataB_sig );

-------------------------------------------------------------- 
  SDRAM_DQI <= SDRAM_DQ;
  SDRAM_DQ <= SDRAM_DQO when SDRAM_DQENB_N = '0' else (others => 'Z');

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : clk_wiz_v3_6_0
  port map
   (-- Clock in ports
    CLK_IN1 => CLK32M,
    -- Clock out ports
    CLK_OUT1 => CLK,
    CLK_OUT2 => CLK100M,
    CLK_OUT3 => SDRAM_CLK,
    -- Status and control signals
    RESET  => '0',
    LOCKED => open);
-- INST_TAG_END ------ End INSTANTIATION Template ------------

end structure ;
