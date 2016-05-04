-- Designed by Toshio Iwata at DIGITALFILTER.COM 2013/03/19

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY VGA_CTRL IS
	PORT	(
		CLK	: IN std_logic;
		RST_N	: IN std_logic;
		CamHsync_EDGE	: IN std_logic;
		CamVsync_EDGE	: IN std_logic;
		VgaLineCount : out std_logic_vector(8 downto 0);
		VgaPixCount : out std_logic_vector(9 downto 0);
		VgaVisible : OUT std_logic;
		VgaVsync : OUT std_logic;
		VgaHsync : OUT std_logic;
		VgaHsync_edge : out std_logic;
    OddFrame : out std_logic );
	END VGA_CTRL;

ARCHITECTURE structure OF VGA_CTRL IS

	signal VgaLineCount_sig	: std_logic_vector(8 downto 0);
	signal VgaPixCount_sig	: std_logic_vector(9 downto 0);
	signal VgaPixCount_clr : std_logic;
	signal VgaLineCount_clr : std_logic;
	signal VgaPixCount_enb : std_logic;
	signal VgaLineCount_enb : std_logic;
	signal VgaVsync_sig : std_logic;
	signal VgaHsync_sig : std_logic;
  signal VgaFrameCount : std_logic;
	signal VgaVisible_V : std_logic;
	signal VgaVisible_H : std_logic;

BEGIN
-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
  if( RST_N = '0' ) then
    VgaPixCount_enb <= '0';
  elsif( CLK'event and CLK = '1' ) then
    VgaPixCount_enb <= not VgaPixCount_enb;
  end if; 
end process;

-------------------------------------------------------------- 
   VgaPixCount_clr <= '1' when (VgaPixCount_enb = '1' and VgaPixCount_sig = 783 ) 
                      or CamHsync_EDGE = '1' else '0'; -- 2012/06/25

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		VgaPixCount_sig <= (others => '0');
	elsif( CLK'event and CLK = '1' ) then
		if(VgaPixCount_clr = '1') then 
         VgaPixCount_sig <= (others => '0');
		elsif(VgaPixCount_enb = '1') then 
         VgaPixCount_sig <= VgaPixCount_sig+ 1;
      end if; 
	end if;  
end process;

  VgaPixCount <= VgaPixCount_sig;

-------------------------------------------------------------- 
   VgaLineCount_enb <= '1' when VgaPixCount_sig = 783 and VgaPixCount_enb = '1' else '0';
   VgaLineCount_clr <= '1' when VgaPixCount_clr = '1' and VgaLineCount_sig = 509 else '0'; -- 2012/06/30

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		VgaLineCount_sig <= (others => '0');
	elsif( CLK'event and CLK = '1' ) then
      if(VgaLineCount_clr = '1' or CamVsync_edge = '1') then 
         VgaLineCount_sig <= (others => '0');
      elsif(VgaLineCount_enb = '1') then 
         VgaLineCount_sig <= VgaLineCount_sig+ 1;
		end if; 
	end if;  
end process;

  VgaLineCount <= VgaLineCount_sig;
  
-------------------------------------------------------------- 
   VgaVisible_H <= '1' when VgaPixCount_sig >= 134 and VgaPixCount_sig < 776 else '0'; -- from 136 2012/09/28 
   VgaHsync_sig <= '1' when VgaPixCount_sig >= 96 else '0'; -- from 94 2012/09/28
   VgaHsync_edge <= '1' when VgaPixCount_sig = 96 else '0'; -- from 94 2012/09/28

-------------------------------------------------------------- 
   VgaVisible_V <= '1'when VgaLineCount_sig >= 1 and VgaLineCount_sig < 480 else '0'; -- from 515 2012/09/28
   VgaVsync_sig <= '0' when VgaLineCount_sig >= 484 and VgaLineCount_sig <= 485 else '1'; -- 2012/11/07

-------------------------------------------------------------- 
gen_VgaVisible_sig : process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		VgaVisible <= '0';
	elsif( CLK'event and CLK = '1' ) then
	   if( VgaPixCount_enb = '1' ) then
		   VgaVisible <= VgaVisible_V and VgaVisible_H; 
		end if;
	end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' or CamVsync_EDGE = '1') then
		VgaFrameCount <= '0';
	elsif( CLK'event and CLK = '1' ) then
	   if( VgaPixCount_enb = '1' and VgaLineCount_enb = '1' and VgaLineCount_sig = 1 ) then
		   VgaFrameCount <= not VgaFrameCount; 
		end if;
	end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		VgaHsync <= '0';
	elsif( CLK'event and CLK = '1' ) then
	   if( VgaPixCount_enb = '1' ) then
		   VgaHsync <= VgaHsync_sig; 
		end if;
	end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		VgaVsync <= '0';
	elsif( CLK'event and CLK = '1' ) then
	   if( VgaPixCount_enb = '1' ) then
		   VgaVsync <= VgaVsync_sig; 
		end if;
	end if;  
end process;

-------------------------------------------------------------- 
  OddFrame <= not VgaFrameCount;
   
END structure;
