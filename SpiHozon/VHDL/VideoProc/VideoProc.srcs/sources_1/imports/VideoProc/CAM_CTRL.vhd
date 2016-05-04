-- Designed by Toshio Iwata at DIGITALFILTER.COM 2013/03/19

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY CAM_CTRL IS
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
		CamHsync_EDGE: out std_logic;
		CamVsync_EDGE: out std_logic;
		CamLineCount : out std_logic_vector(8 downto 0);
    CamPixCount4x : out std_logic_vector(15 downto 0) ); 
END CAM_CTRL;

ARCHITECTURE structure OF CAM_CTRL IS

  signal CamPixCount4x_sig : std_logic_vector(15 downto 0); 
	signal PclkPixCount : std_logic_vector(10 downto 0);
	signal Rg_dec, gB_dec : std_logic;
	signal Rg_dec_dly1, Rg_dec_dly2 : std_logic;
	signal CamHsync_dly1, CamHsync_dly2 : std_logic;
	signal CamHsync_edge_sig : std_logic;
	signal Rg_latch, gB_latch : std_logic_vector(7 downto 0);
	signal CamVsync_dly1, CamVsync_dly2 : std_logic;
  signal CamVsync_edge_sig : std_logic;
	signal CamLineCount_sig : std_logic_vector(8 downto 0);
	signal PclkPixCount_dly1, PclkPixCount_dly2 : std_logic_vector(9 downto 0);

BEGIN
-------------------------------------------------------------- 
process( RST_N, PCLK, CamHsync_edge_sig )  
begin 
  if( RST_N = '0' or CamHsync_edge_sig = '1' ) then
    PclkPixCount <= (others => '0');
  elsif( PCLK'event and PCLK = '1' ) then
    PclkPixCount <= PclkPixCount + 1;
  end if;  
end process;

-------------------------------------------------------------- 
  Rg_dec <= not PclkPixCount(0);
  gB_dec <= PclkPixCount(0);
  
-------------------------------------------------------------- 
process( RST_N, PCLK )  
begin 
   if( RST_N = '0' ) then
     Rg_latch <= (others => '0');
   elsif( PCLK'event and PCLK = '1' ) then
    if(Rg_dec = '1') then
      Rg_latch <= CamData;
    end if;
   end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, PCLK )  
begin 
   if( RST_N = '0' ) then
     gB_latch <= (others => '0');
   elsif( PCLK'event and PCLK = '1' ) then
    if(gB_dec = '1') then
      gB_latch <= CamData;
    end if;
   end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     CamPixCount4x_sig <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(CamPixCount4x_sig = 3135 or CamHsync_edge_sig = '1') then
       CamPixCount4x_sig <= (others => '0');
     else
       CamPixCount4x_sig <= CamPixCount4x_sig + 1;
     end if;
   end if;  
end process;

  CamPixCount4x <= CamPixCount4x_sig;
  
-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     Rg_dec_dly2 <= '0';
     Rg_dec_dly1 <= '0';
   elsif( CLK'event and CLK = '1' ) then
     Rg_dec_dly2 <= Rg_dec_dly1;
     Rg_dec_dly1 <= Rg_dec;
   end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, PCLK )  
begin 
   if( RST_N = '0' ) then
     PclkPixCount_dly2 <= (others => '0');
     PclkPixCount_dly1 <= (others => '0');
   elsif( PCLK'event and PCLK = '1' ) then
     PclkPixCount_dly2 <= PclkPixCount_dly1;
     PclkPixCount_dly1 <= PclkPixCount(10 downto 1);
   end if;  
end process;

-------------------------------------------------------------- 
  LB_WR_N <= '0' when Rg_dec_dly1 = '1' and Rg_dec_dly2 = '0' else '1';
  
  LB_WR_DATA <= Rg_latch & gB_latch;
  
  LB_WR_ADDR <= PclkPixCount_dly2;
	
-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     CamHsync_dly2 <= '0';
     CamHsync_dly1 <= '0';
   elsif( CLK'event and CLK = '1' ) then
     CamHsync_dly2 <= CamHsync_dly1;
     CamHsync_dly1 <= CamHsync;
   end if;  
end process;

-------------------------------------------------------------- 
  CamHsync_edge_sig <= '1' when CamHsync_dly1 = '0' and CamHsync_dly2 = '1' else '0';
  
-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     CamVsync_dly2 <= '0';
     CamVsync_dly1 <= '0';
   elsif( CLK'event and CLK = '1' ) then
     CamVsync_dly2 <= CamVsync_dly1;
     CamVsync_dly1 <= CamVsync;
   end if;  
end process;

-------------------------------------------------------------- 
  CamVsync_edge_sig <= '1' when CamVsync_dly1 = '0' and CamVsync_dly2 = '1' else '0';
  CamVsync_EDGE <= CamVsync_edge_sig;
  
-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
  if( RST_N = '0' ) then
    CamLineCount_sig <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(CamVsync_edge_sig = '1') then
      CamLineCount_sig <= (others => '0');
    elsif(CamHsync_edge_sig = '1') then
      CamLineCount_sig <= CamLineCount_sig + 1;
    end if;
  end if;  
end process;

-------------------------------------------------------------- 
  CamLineCount <= CamLineCount_sig;
  CamHsync_EDGE <= CamHsync_edge_sig;
  
END structure;
