-- Designed by Toshio Iwata at DIGITALFILTER.COM 2014/06/01

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LINEOUT_CTRL IS
	PORT	(
		CLK	: IN std_logic;
		CLK100M	: IN std_logic;
		RST_N	: IN std_logic;
		ViewMode : in std_logic_vector(3 downto 0);
		PIXSTB: in std_logic;
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
END LINEOUT_CTRL;

ARCHITECTURE structure OF LINEOUT_CTRL IS

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

 signal OB_WR_ADDR : std_logic_vector(9 downto 0);
 signal OB_RD_ADDR : std_logic_vector(9 downto 0);
 signal OB_WR_DATA : std_logic_vector(15 downto 0);
 signal OB_RD_DATA_A : std_logic_vector(15 downto 0);
 signal OB_RD_DATA_B : std_logic_vector(15 downto 0);
 signal OB_WR_N_A : std_logic;
 signal OB_WR_N_B : std_logic;
 signal OB_WR_ADDR_sig : std_logic_vector(9 downto 0);
 signal OB_RD_ADDR_sig : std_logic_vector(9 downto 0);
 signal OB_WR_DATA_sig : std_logic_vector(15 downto 0);
 signal OB_WR_N_A_sig : std_logic;
 signal OB_WR_N_B_sig : std_logic;
 signal OB_CS_N : std_logic;
signal ODDLINE, oddline_dly1, oddline_dly2 : std_logic;
 signal ls2b : std_logic_vector(1 downto 0);
signal  vga_RGB : std_logic_vector(15 downto 0);
 signal LB_ADDR : std_logic_vector(9 downto 0);
signal PIXRD_edge, PIXRD_dly1, PIXRD_dly2 : std_logic;
signal PIXWR_edge, PIXWR_dly1, PIXWR_dly2 : std_logic;
signal PIXSTB_edge, PIXSTB_dly1, PIXSTB_dly2 : std_logic;
signal WaitLine : std_logic_vector(2 downto 0);
signal  pixstb_count : std_logic_vector(9 downto 0);
signal  pixstb_count_plus : std_logic_vector(9 downto 0);
signal LBRDY_sig : std_logic;
	signal ViewMode_dly1, ViewMode_dly2 : std_logic_vector(3 downto 0);
  signal ViewMode5_edge : std_logic;
  signal ViewMode6_edge : std_logic;
	signal SdrwLineCount_sig : std_logic_vector(8 downto 0);

BEGIN

-------------------------------------------------------------------
OutBuf_A : SRAM port map (
   CLK		=> CLK,
   CS_N 	=> OB_CS_N,
   WR_N	=> OB_WR_N_A, 
   WRADDR	=> OB_WR_ADDR, 
   RDADDR	=> OB_RD_ADDR, 
   WRDATA	=> OB_WR_DATA, 
   RDDATA	=> OB_RD_DATA_A );

-------------------------------------------------------------------
OutBuf_B : SRAM port map (
   CLK		=> CLK,
   CS_N 	=> OB_CS_N,
   WR_N	=> OB_WR_N_B, 
   WRADDR	=> OB_WR_ADDR, 
   RDADDR	=> OB_RD_ADDR, 
   WRDATA	=> OB_WR_DATA, 
   RDDATA	=> OB_RD_DATA_B );

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
     vga_RGB <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(oddline_dly2 = '1' ) then
       vga_RGB <= OB_RD_DATA_A;
     else 
       vga_RGB <= OB_RD_DATA_B;
     end if;  
  end if;
end process;

------------------------------------------------------------------- 
  OB_WR_N_A_sig <= '0' when (ViewMode = "0110" and PIXWR = '1') or 
                     (ViewMode /= "0110" and oddline_dly2 = '0' and 
                     (winp0 = '1' or winp1 = '1' or winp2 = '1' or winp3 = '1') 
                     and PIXRD = '0' and LBRDY_sig = '0') else '1';
                       
  OB_WR_N_B_sig <= '0' when (ViewMode = "0110" and PIXWR = '1') or 
                     (ViewMode /= "0110" and oddline_dly2 = '1' and 
                     (winp0 = '1' or winp1 = '1' or winp2 = '1' or winp3 = '1') 
                     and PIXRD = '0' and LBRDY_sig = '0') else '1';
  
  OB_WR_DATA_sig <= PIX2LOGIC(15 downto 0) when ViewMode = "0110" else
                   latch0(15 downto 0) when winp0 = '1' else
                   latch1(15 downto 0) when winp1 = '1' else
                   latch2(15 downto 0) when winp2 = '1' else latch3(15 downto 0);
  
-------------------------------------------------------------------
  ls2b <= "00" when winp0 = '1' else
          "01" when winp1 = '1' else
          "10" when winp2 = '1' else
          "11";

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
	if( RST_N = '0' ) then
		LB_ADDR <= (others => '0');
	elsif( CLK'event and CLK = '1' ) then
		LB_ADDR <= VgaPixCount(9 downto 0) + 20;
	end if;  
end process;
          
-------------------------------------------------------------- 
  OB_WR_ADDR_sig <= pixstb_count_plus when ViewMode = "0110" else LB_ADDR(9 downto 2) & ls2b;
  OB_RD_ADDR_sig <= pixstb_count_plus when PIXRD = '1' and ViewMode = "0101" else LB_ADDR;
  OB_CS_N <= '0';

  vga_r <= vga_RGB(15 downto 11) & "000";
  vga_g <= vga_RGB(10 downto 5) & "00";
  vga_b <= vga_RGB(4 downto 0) & "000";
  
-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     OB_RD_ADDR <= (others => '0');
     OB_WR_ADDR <= (others => '0');
     OB_WR_DATA <= (others => '0');
     OB_WR_N_A <= '0';
     OB_WR_N_B <= '0';
   elsif( CLK'event and CLK = '1' ) then
     OB_RD_ADDR <= OB_RD_ADDR_sig;
     OB_WR_ADDR <= OB_WR_ADDR_sig;
     OB_WR_DATA <= OB_WR_DATA_sig;
     OB_WR_N_A <= OB_WR_N_A_sig;
     OB_WR_N_B <= OB_WR_N_B_sig;
  end if;
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     vga_RGB_dly0 <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(OB_RD_ADDR(1 downto 0) = 0 ) then
       vga_RGB_dly0 <= vga_RGB;
     end if;  
  end if;
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     vga_RGB_dly1 <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(OB_RD_ADDR(1 downto 0) = 1 ) then
       vga_RGB_dly1 <= vga_RGB;
     end if;  
  end if;
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     vga_RGB_dly2 <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(OB_RD_ADDR(1 downto 0) = 2 ) then
       vga_RGB_dly2 <= vga_RGB;
     end if;  
  end if;
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     vga_RGB_dly3 <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if(OB_RD_ADDR(1 downto 0) = 3 ) then
       vga_RGB_dly3 <= vga_RGB;
     end if;  
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0') then
      PIXRD_dly2 <= '0';
      PIXRD_dly1 <= '0';
  elsif( CLK'event and CLK = '1' ) then
    PIXRD_dly2 <= PIXRD_dly1;
    PIXRD_dly1 <= PIXRD;
  end if;
end process;

  PIXRD_edge <= '1' when PIXRD_dly1 = '0' and PIXRD_dly2 = '1' else '0';
  
  -------------------------------------------------------------------
  process( RST_N, CLK )
  begin
    if( RST_N = '0') then
        PIXWR_dly2 <= '0';
        PIXWR_dly1 <= '0';
    elsif( CLK'event and CLK = '1' ) then
      PIXWR_dly2 <= PIXWR_dly1;
      PIXWR_dly1 <= PIXWR;
    end if;
  end process;
  
    PIXWR_edge <= '1' when PIXWR_dly1 = '0' and PIXWR_dly2 = '1' else '0';
 
-------------------------------------------------------------------
    process( RST_N, CLK )
    begin
      if( RST_N = '0') then
          PIXSTB_dly2 <= '0';
          PIXSTB_dly1 <= '0';
      elsif( CLK'event and CLK = '1' ) then
        PIXSTB_dly2 <= PIXSTB_dly1;
        PIXSTB_dly1 <= PIXSTB;
      end if;
    end process;
    
      PIXSTB_edge <= '1' when PIXSTB_dly1 = '1' and PIXSTB_dly2 = '0' else '0';
      
-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    WaitLine <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(PIXWR_edge = '1' or PIXRD_edge = '1') then
      WaitLine <= (others => '0');
    elsif(CamHsync_edge = '1') then
      if(WaitLine /= 3) then -- 2012/11/15
        WaitLine <= WaitLine + 1;
      end if;
    end if;
  end if;
end process;

  LBRDY_sig <= '1' when not(WaitLine = 1 or WaitLine = 2) and (ViewMode = "0101" or ViewMode = "0110") else '0'; -- 2012/11/15
  LBRDY <= LBRDY_sig;
  
-------------------------------------------------------------- 
process( CLK, RST_N )  
begin 
   if( RST_N = '0' ) then
     pixstb_count <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     if( PIXRD_edge = '1' or PIXWR_edge = '1' ) then
       pixstb_count <= (others => '0');
     elsif( PIXSTB_edge = '1' ) then 
       pixstb_count <= pixstb_count + 1;
    end if;
  end if;
end process;

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     pixstb_count_plus <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     pixstb_count_plus <= pixstb_count + 96;
  end if;
end process;

-------------------------------------------------------------- 
  PIX2NIOS <= vga_RGB; 

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
   if( RST_N = '0' ) then
     ViewMode_dly2 <= (others => '0');
     ViewMode_dly1 <= (others => '0');
   elsif( CLK'event and CLK = '1' ) then
     ViewMode_dly2 <= ViewMode_dly1;
     ViewMode_dly1 <= ViewMode;
   end if;  
end process;
   
-------------------------------------------------------------- 
  ViewMode5_edge <= '1' when ViewMode_dly1 = "0101" and ViewMode_dly2 /= "0101" else '0';
  ViewMode6_edge <= '1' when ViewMode_dly1 = "0110" and ViewMode_dly2 /= "0110" else '0';

-------------------------------------------------------------- 
process( RST_N, CLK )  
begin 
  if( RST_N = '0' ) then
    SdrwLineCount_sig <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if( ViewMode5_edge = '1' or ViewMode6_edge = '1' ) then
      SdrwLineCount_sig <= (others => '0');
    elsif((PIXRD_edge = '1' and ViewMode = "0101")
       or (PIXWR_edge = '1' and ViewMode = "0110")) then
      SdrwLineCount_sig <= SdrwLineCount_sig + 1;
    end if;
  end if;  
end process;

  SdrwLineCount <= SdrwLineCount_sig;

END structure;
