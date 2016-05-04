-- Designed by Toshio Iwata at DIGITALFILTER.COM 2013/03/19

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LINEIN_CTRL IS
	PORT	(
		CLK	: IN std_logic;
		RST_N	: IN std_logic;
		LB_WR_ADDR	: IN std_logic_vector(9 downto 0);
		LB_WR_DATA	: IN std_logic_vector(15 downto 0);
		LB_WR_N	: IN std_logic;
		VgaLineCount : in std_logic_vector(8 downto 0);
		VgaPixCount : in std_logic_vector(9 downto 0);
  buf_RGB : out std_logic_vector(15 downto 0)
 );
END LINEIN_CTRL;

ARCHITECTURE structure OF LINEIN_CTRL IS

component SRAM
   Port (
          CLK : In std_logic;
          CS_N : In std_logic;
          WR_N : In std_logic;
          WRADDR : In std_logic_vector(9 downto 0);
          RDADDR : In std_logic_vector(9 downto 0);
          WRDATA : In std_logic_vector(15 downto 0);
          RDDATA : Out std_logic_vector(15 downto 0) );
end component;

 signal LB_RD_ADDR : std_logic_vector(9 downto 0);
 signal LB_RD_DATA_A : std_logic_vector(15 downto 0);
 signal LB_RD_DATA_B : std_logic_vector(15 downto 0);
 signal LB_WR_N_B : std_logic;
 signal LB_WR_N_A : std_logic;
 signal LB_CS_N : std_logic;
 signal ODDLINE, oddline_dly1, oddline_dly2 : std_logic;

BEGIN

-------------------------------------------------------------------
LineBuf_A : SRAM port map (
   CLK		=> CLK,
   CS_N 	=> LB_CS_N,
   WR_N	=> LB_WR_N_A, 
   WRADDR	=> LB_WR_ADDR, 
   RDADDR	=> LB_RD_ADDR, 
   WRDATA	=> LB_WR_DATA, 
   RDDATA	=> LB_RD_DATA_A );

-------------------------------------------------------------------
LineBuf_B : SRAM port map (
   CLK		=> CLK,
   CS_N 	=> LB_CS_N,
   WR_N	=> LB_WR_N_B, 
   WRADDR	=> LB_WR_ADDR, 
   RDADDR	=> LB_RD_ADDR, 
   WRDATA	=> LB_WR_DATA, 
   RDDATA	=> LB_RD_DATA_B );

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     oddline_dly2 <= '0';
     oddline_dly1 <= '0';
   elsif( CLK'event and CLK = '1' ) then
     oddline_dly2 <= oddline_dly1;
     oddline_dly1 <= ODDLINE;
   end if;  
end process;

  ODDLINE <= VgaLineCount(1);

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     buf_RGB <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(oddline_dly2 = '0') then
       buf_RGB <= LB_RD_DATA_B;
     else
       buf_RGB <= LB_RD_DATA_A;
     end if;
   end if;  
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		LB_RD_ADDR <= (others => '0');
	elsif( CLK'event and CLK = '1' ) then
		LB_RD_ADDR <= VgaPixCount(9 downto 0) + 21;
	end if;  
end process;

-------------------------------------------------------------------
  LB_WR_N_A <= LB_WR_N when oddline_dly2 = '0' else '1'; 
  LB_WR_N_B <= LB_WR_N when oddline_dly2 = '1' else '1';   
  LB_CS_N <= '0';

END structure;
