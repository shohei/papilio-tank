-- Designed by Toshio Iwata at DIGITALFILTER.COM 2014/06/01

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SDRAM_CTRL IS
PORT(
CLK: IN std_logic;
CLK100M: IN std_logic;
RST_N: IN std_logic;
  PIXSTB : in std_logic;
  PIXWR : in std_logic;
  LBRDY : in std_logic;
	SdrwLineCount : in std_logic_vector(8 downto 0);
		ViewMode : in std_logic_vector(3 downto 0);
VgaHsync_edge : in std_logic;
CamVsync : in std_logic;
CamVsync_edge : in std_logic;
		CamLineCount : in std_logic_vector(8 downto 0);
		CamPixCount4x : in std_logic_vector(15 downto 0);
		VgaLineCount : in std_logic_vector(8 downto 0);
		VgaPixCount : in std_logic_vector(9 downto 0);
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
  SDRAM_DQMH: out std_logic;
  SDRAM_DQML: out std_logic;
  SDRAM_CS_N: out std_logic;
  SDRAM_WE_N: out std_logic;
  SDRAM_RAS_N: out std_logic;
  SDRAM_CAS_N: out std_logic;
  SDRAM_CKE: out std_logic;
  SDRAM_DQI : in std_logic_vector(15 downto 0);
  SDRAM_DQO : out std_logic_vector(15 downto 0);
  SDRAM_A : out std_logic_vector(11 downto 0);
  SDRAM_BA : out std_logic_vector(1 downto 0)
 );
END SDRAM_CTRL;

ARCHITECTURE structure OF SDRAM_CTRL IS

 signal buf_RGB_dly1 : std_logic_vector(15 downto 0);
 signal buf_RGB_dly2 : std_logic_vector(15 downto 0);
 signal buf_RGB_dly3 : std_logic_vector(15 downto 0);
 signal sdram_data0, sdram_data1, sdram_data2, sdram_data3 : std_logic_vector(15 downto 0);
 signal buf_RGB_win : std_logic;
 signal MemState : std_logic_vector(4 downto 0);
 signal Initial : std_logic_vector(4 downto 0) := "00000";
 signal MRS : std_logic_vector(4 downto 0) := "00010";
 signal BstWr : std_logic_vector(4 downto 0) := "00100";
 signal BstRd : std_logic_vector(4 downto 0) := "00101";
 signal PreChAll : std_logic_vector(4 downto 0) := "00001";
 signal doingPreChAll : std_logic_vector(4 downto 0) := "10001";
 signal doingMRS : std_logic_vector(4 downto 0) := "10010";
 signal cmdcount : std_logic_vector(3 downto 0);
 signal count100m : std_logic_vector(4 downto 0);
 signal sdram_data : std_logic_vector(15 downto 0);
 signal csn, wrn, rasn, casn : std_logic;
 signal dqm, dqenbn : std_logic;
 signal cmdFound : std_logic;
 signal baddr, baddr_norm : std_logic_vector(1 downto 0);
 signal coladdr : std_logic_vector(11 downto 0);
 signal rowaddr : std_logic_vector(11 downto 0);
 signal pwrupcount : std_logic_vector(15 downto 0);
 signal pwrupready : std_logic;
 signal oddLine2x : std_logic;
 signal FrameCount, frame2write, frame2read, frame, frame2read_norm, frame2read_m7, frame2read_diff : std_logic_vector(2 downto 0);
 signal SDRAM_DQENB_N_sig: std_logic;
 signal SDRAM_DQMH_sig: std_logic;
 signal SDRAM_DQML_sig: std_logic;
 signal SDRAM_CS_N_sig: std_logic;
 signal SDRAM_WE_N_sig: std_logic;
 signal SDRAM_RAS_N_sig: std_logic;
 signal SDRAM_CAS_N_sig: std_logic;
 signal SDRAM_CKE_sig: std_logic;
 signal SDRAM_DQO_sig : std_logic_vector(15 downto 0);
 signal SDRAM_A_sig : std_logic_vector(11 downto 0);
 signal SDRAM_BA_sig : std_logic_vector(1 downto 0);
 signal line2write, line2read, linerw : std_logic_vector(8 downto 0);
 signal rasn_norm, rasn_diff : std_logic;
 signal casn_norm, casn_diff : std_logic;
 signal rowaddr_norm : std_logic_vector(11 downto 0);
 signal coladdr_norm : std_logic_vector(11 downto 0);
 signal dec14, dec15, dec16, dec17, dec18 : std_logic;
signal latchp0	: std_logic_vector(15 downto 0);
signal latchp1	: std_logic_vector(15 downto 0);
signal latchp2	: std_logic_vector(15 downto 0);
signal latchp3	: std_logic_vector(15 downto 0);
signal latchd0	: std_logic_vector(15 downto 0);
signal latchd1	: std_logic_vector(15 downto 0);
signal latchd2	: std_logic_vector(15 downto 0);
signal latchd3	: std_logic_vector(15 downto 0);
signal rasn_norm_sig: std_logic;
signal casn_norm_sig: std_logic;
signal rowaddr_norm_sig: std_logic_vector(11 downto 0);
signal coladdr_norm_sig: std_logic_vector(11 downto 0);
signal baddr_norm_sig: std_logic_vector(1 downto 0);
signal count100m_clr, buf_RGB_win_dly1, buf_RGB_win_dly2 : std_logic;
signal cmdready : std_logic;
signal diffR0	: std_logic_vector(5 downto 0);
signal diffR1	: std_logic_vector(5 downto 0);
signal diffR2	: std_logic_vector(5 downto 0);
signal diffR3	: std_logic_vector(5 downto 0);
signal absR0	: std_logic_vector(4 downto 0);
signal absR1	: std_logic_vector(4 downto 0);
signal absR2	: std_logic_vector(4 downto 0);
signal absR3	: std_logic_vector(4 downto 0);
signal diffG0	: std_logic_vector(6 downto 0);
signal diffG1	: std_logic_vector(6 downto 0);
signal diffG2	: std_logic_vector(6 downto 0);
signal diffG3	: std_logic_vector(6 downto 0);
signal absG0	: std_logic_vector(5 downto 0);
signal absG1	: std_logic_vector(5 downto 0);
signal absG2	: std_logic_vector(5 downto 0);
signal absG3	: std_logic_vector(5 downto 0);
signal diffB0	: std_logic_vector(5 downto 0);
signal diffB1	: std_logic_vector(5 downto 0);
signal diffB2	: std_logic_vector(5 downto 0);
signal diffB3	: std_logic_vector(5 downto 0);
signal absB0	: std_logic_vector(4 downto 0);
signal absB1	: std_logic_vector(4 downto 0);
signal absB2	: std_logic_vector(4 downto 0);
signal absB3	: std_logic_vector(4 downto 0);
signal abs0	: std_logic_vector(15 downto 0);
signal abs1	: std_logic_vector(15 downto 0);
signal abs2	: std_logic_vector(15 downto 0);
signal abs3	: std_logic_vector(15 downto 0);
signal rasn_diff_sig: std_logic;
signal casn_diff_sig: std_logic;
 signal abs_y, abs_r, abs_g, abs_b : std_logic_vector(11 downto 0);
 signal abs_y_sft : std_logic_vector(11 downto 0);
 signal acc_y_L, acc_y_latch_L, add_y_L : std_logic_vector(11 downto 0);
 signal v_abs_y_sft_L, v_acc_y_L, v_add_y_L, v_acc_y_latch_L : std_logic_vector(11 downto 0);
 signal acc_y_R, acc_y_latch_R, add_y_R : std_logic_vector(11 downto 0);
 signal v_abs_y_sft_R, v_acc_y_R, v_add_y_R, v_acc_y_latch_R : std_logic_vector(11 downto 0);
signal sdram_data_sdrd : std_logic_vector(15 downto 0);

BEGIN
-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    MemState <= Initial;
  elsif( CLK'event and CLK = '1' ) then
    if(MemState = Initial and pwrupready = '1') then -- go to precharge
      MemState <= PreChAll;
    elsif(MemState = PreChAll) then
      MemState <= doingPreChAll;
    elsif(MemState = doingPreChAll and cmdready = '1') then -- wait 300ns and go to MRS
      MemState <= MRS;
    elsif(MemState = MRS) then
      MemState <= doingMRS;
    elsif(MemState = doingMRS and cmdready = '1') then -- wait 300ns and go to burst write
      MemState <= BstWr;
    elsif(MemState = BstWr and VgaHsync_edge = '1' and oddLine2x = '1') then -- go to burst read
      MemState <= BstRd;
    elsif(MemState = BstRd and VgaHsync_edge = '1' and oddLine2x = '0') then -- go to burst write
      MemState <= BstWr;
    end if;
  end if;
end process;

-------------------------------------------------------------------
  cmdFound <= '1' when MemState = PreChall or MemState = MRS else '0';

-------------------------------------------------------------------
process( RST_N, CLK, cmdFound )
begin
  if( RST_N = '0' or cmdFound = '1' ) then
    cmdcount <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(cmdcount /= 15) then
      cmdcount <= cmdcount + 1; 
    end if;
  end if;
end process;

  cmdready <= '1' when cmdcount = 15 else '0'; -- 20ns * 15 = 300ns
  
-------------------------------------------------------------------
  buf_RGB_win <= '1' when CamPixCount4x(2 downto 0) = "000" else '0'; 

-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    buf_RGB_dly3 <= (others => '0');
    buf_RGB_dly2 <= (others => '0');
    buf_RGB_dly1 <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(CamPixCount4x(0) = '0') then
      buf_RGB_dly3 <= buf_RGB_dly2;
      buf_RGB_dly2 <= buf_RGB_dly1;
      buf_RGB_dly1 <= buf_RGB;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    sdram_data3 <= (others => '0');
    sdram_data2 <= (others => '0');
    sdram_data1 <= (others => '0');
    sdram_data0 <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(buf_RGB_win = '1') then
      sdram_data3 <= buf_RGB_dly3;
      sdram_data2 <= buf_RGB_dly2;
      sdram_data1 <= buf_RGB_dly1;
      sdram_data0 <= buf_RGB;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    buf_RGB_win_dly2 <= '0';
    buf_RGB_win_dly1 <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    buf_RGB_win_dly2 <= buf_RGB_win_dly1;
    buf_RGB_win_dly1 <= buf_RGB_win;
  end if;
end process;

  count100m_clr <= '1' when buf_RGB_win_dly1 = '1' and buf_RGB_win_dly2 = '0' else '0';

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    count100m <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(count100m_clr = '1') then
      count100m <= (others => '0');
    else
      count100m <= count100m + 1;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    pwrupcount <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(pwrupcount /= 10000) then -- 20ns * 10000 = 200us
      pwrupcount <= pwrupcount + 1;
    end if;
  end if;
end process;

  pwrupready <= '1' when pwrupcount = 10000 else '0';

-------------------------------------------------------------------
  oddLine2x <= '0' when CamPixCount4x < 1567 else '1';

-------------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0') then
    FrameCount <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(CamVsync_edge = '1') then 
      if(ViewMode = "0000" or ViewMode = "0010" or ViewMode = "0011" or ViewMode = "0100") then 
                                                -- normal, repeat, differential, motion detect
        FrameCount <= FrameCount + 1;
      end if;
    end if;
  end if;
end process;

  frame2write <= FrameCount-1 when ViewMode = "0110" else FrameCount;
  
  frame2read_norm <= FrameCount-1; 
                
  frame2read_m7 <= FrameCount+1;

  frame2read_diff <= frame2read_m7 when count100m >= 8 and count100m <= 15 and MemState = BstRd 
                else frame2read_norm;

  frame2read <= frame2read_diff when ViewMode = "0011" or ViewMode = "0100"
           else frame2read_norm;

  frame <= frame2write when MemState = BstWr else frame2read;
  
-------------------------------------------------------------------
  line2write <= SdrwLineCount(7 downto 0) & '0' when ViewMode = "0110"
             else CamLineCount(8 downto 0);
  
-------------------------------------------------------------------
  line2read <= SdrwLineCount(7 downto 0) & '0' when ViewMode = "0101"
             else VgaLineCount;

-------------------------------------------------------------------
  linerw <= line2write when MemState = BstWr else 
            line2read;
                  
-------------------------------------------------------------------
  rasn_norm_sig <= '0' when dec16 = '1' else '1'; 
  rasn_diff_sig <= '0' when (dec16 = '1' and MemState = BstWr)
               or ((dec16 = '1' or count100m = 8) and MemState = BstRd) else '1'; 
  
  casn_norm_sig <= '0' when count100m = 2 else '1';
  casn_diff_sig <= '0' when (count100m = 2 and MemState = BstWr)
               or ((count100m = 2 or count100m = 10) and MemState = BstRd) else '1'; 
  
  rowaddr_norm_sig <= frame(0) & linerw & VgaPixCount(9 downto 8);

  coladdr_norm_sig <= "0100" & VgaPixCount(7 downto 2) & "00";
  
  baddr_norm_sig <= frame(2 downto 1);

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    rasn_norm <= '0';
    rasn_diff <= '0';
    casn_norm <= '0';
    casn_diff <= '0';
    rowaddr_norm <= (others => '0');
    coladdr_norm <= (others => '0');
    baddr_norm <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    rasn_norm <= rasn_norm_sig;
    rasn_diff <= rasn_diff_sig;
    casn_norm <= casn_norm_sig;
    casn_diff <= casn_diff_sig;
    rowaddr_norm <= rowaddr_norm_sig; 
    coladdr_norm <= coladdr_norm_sig;
    baddr_norm <= baddr_norm_sig;
  end if;
end process;

-------------------------------------------------------------------
  sdram_data <= sdram_data3 when count100m = 3 else 
                sdram_data2 when count100m = 4 else
                sdram_data1 when count100m = 5 else
                sdram_data0 when count100m = 6 else (others => '0');
                
-------------------------------------------------------------------
  csn <= '0';
  wrn <= '0' when MemState = BstWr and oddLine2x = '0' and count100m = 3 and 
                 (ViewMode = "0000" or ViewMode = "0011" or ViewMode = "0100" 
                 or (ViewMode = "0110" and PIXWR = '0' and LBRDY = '0')) else '1';
                                                       
  rasn <= rasn_diff when ViewMode = "0011" or ViewMode = "0100" else rasn_norm;
                         
  casn <= casn_diff when ViewMode = "0011" or ViewMode = "0100" else casn_norm; 

  dqm <= '0';
  baddr <= baddr_norm;
  
  dqenbn <= '0' when MemState = BstWr and oddLine2x = '0' and count100m >= 3 and count100m <= 6 and
                 (ViewMode = "0000" or ViewMode = "0011" or ViewMode = "0100" 
                 or (ViewMode = "0110" and PIXWR = '0' and LBRDY = '0')) else '1';

  rowaddr <= rowaddr_norm;
                        
  coladdr <= coladdr_norm;
  
-------------------------------------------------------------------
  SDRAM_BA_sig <= "00" when MemState = MRS else baddr;  
  SDRAM_A_sig <= "010000000000" when MemState = PreChAll or MemState = doingPreChAll else
             "000000100010" when MemState = MRS else 
--             "000000000000" when MemState = doingMRS else 
             "000000100010" when MemState = doingMRS else -- same as MRS 2014/04/15
             rowaddr when count100m = 1 or count100m = 9 else 
             coladdr when count100m = 3 or count100m = 11 else (others => '0');
  
  SDRAM_DQO_sig <= sdram_data_sdrd when ViewMode = "0110" else sdram_data;  

  SDRAM_DQMH_sig <= '0';
  SDRAM_DQML_sig <= '0';
  
  SDRAM_CS_N_sig <= '0' when MemState = PreChAll or MemState = doingPreChAll else 
                '0' when MemState = MRS else
                '0' when MemState = doingMRS else csn;
                
  SDRAM_WE_N_sig <= '0' when MemState = PreChAll else
                '1' when MemState = doingPreChAll else
                '0' when MemState = MRS else
--                '1' when MemState = doingMRS else wrn;
                '0' when MemState = doingMRS else wrn; -- same as MRS 2014/04/15
                
  SDRAM_RAS_N_sig <= '0' when MemState = PreChAll or MemState = doingPreChAll else
                 '0' when MemState = MRS else
--                 '1' when MemState = doingMRS else rasn;
                 '0' when MemState = doingMRS else rasn; -- same as MRS 2014/04/15
                 
  SDRAM_CAS_N_sig <= '1' when MemState = PreChAll else
                 '0' when MemState = doingPreChAll else
                 '0' when MemState = MRS else
--                 '1' when MemState = doingMRS else  casn;
                 '0' when MemState = doingMRS else  casn; -- same as MRS 2014/04/15
  
  SDRAM_CKE_sig <= '1';

  SDRAM_DQENB_N_sig <= dqenbn;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0') then
    SDRAM_BA <= (others => '0');
    SDRAM_A <= (others => '0');
    SDRAM_DQO <= (others => '0'); 
    SDRAM_DQMH <= '0';
    SDRAM_DQML <= '0';
    SDRAM_CS_N <= '0';
    SDRAM_WE_N <= '0';
    SDRAM_RAS_N <= '0';
    SDRAM_CAS_N <= '0';
    SDRAM_CKE <= '0';
    SDRAM_DQENB_N <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    SDRAM_BA <= SDRAM_BA_sig;
    SDRAM_A <= SDRAM_A_sig;
    SDRAM_DQO <= SDRAM_DQO_sig;  
    SDRAM_DQMH <= SDRAM_DQMH_sig;
    SDRAM_DQML <= SDRAM_DQML_sig;
    SDRAM_CS_N <= SDRAM_CS_N_sig;
    SDRAM_WE_N <= SDRAM_WE_N_sig;
    SDRAM_RAS_N <= SDRAM_RAS_N_sig;
    SDRAM_CAS_N <= SDRAM_CAS_N_sig;
    SDRAM_CKE <= SDRAM_CKE_sig;
    SDRAM_DQENB_N <= SDRAM_DQENB_N_sig;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchp0 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(count100m = 6) then 
      latchp0 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchp1 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(count100m = 7) then 
      latchp1 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchp2 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(count100m = 8) then 
      latchp2 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchp3 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(count100m = 9) then 
      latchp3 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    winp0 <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    if((count100m = 6 or count100m = 7) and oddLine2x = '1') then 
      winp0 <= '1';
    else 
      winp0 <= '0';
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    winp1 <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    if((count100m = 8 or count100m = 9) and oddLine2x = '1') then 
      winp1 <= '1';
    else 
      winp1 <= '0';
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    winp2 <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    if((count100m = 10 or count100m = 11) and oddLine2x = '1') then 
      winp2 <= '1';
    else 
      winp2 <= '0';
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    winp3 <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    if((count100m = 12 or count100m = 13) and oddLine2x = '1') then 
      winp3 <= '1';
    else 
      winp3 <= '0';
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchd0 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(dec14 = '1') then 
      latchd0 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchd1 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(dec15 = '1') then 
      latchd1 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchd2 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(dec16 = '1') then 
      latchd2 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    latchd3 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(dec17 = '1') then 
      latchd3 <= SDRAM_DQI;
    end if;
  end if;
end process;

-------------------------------------------------------------------
  dec14 <= '1' when count100m = 14 else '0';
  
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    dec18 <= '0';
    dec17 <= '0';
    dec16 <= '0';
    dec15 <= '0';
  elsif( CLK100M'event and CLK100M = '1' ) then
    dec18 <= dec17;
    dec17 <= dec16;
    dec16 <= dec15;
    dec15 <= dec14;
  end if;
end process;

-- modified 2012/08/28
-------------------------------------------------------------------
  diffR0 <= ('0' & latchd0(15 downto 11)) - ('0' & latchp0(15 downto 11));
  diffR1 <= ('0' & latchd1(15 downto 11)) - ('0' & latchp1(15 downto 11));
  diffR2 <= ('0' & latchd2(15 downto 11)) - ('0' & latchp2(15 downto 11));
  diffR3 <= ('0' & latchd3(15 downto 11)) - ('0' & latchp3(15 downto 11));

-------------------------------------------------------------------
  absR0 <= not diffR0(4) & not diffR0(3) & not diffR0(2) & not diffR0(1) & not diffR0(0) when diffR0(5) = '1' else diffR0(4 downto 0);
  absR1 <= not diffR1(4) & not diffR1(3) & not diffR1(2) & not diffR1(1) & not diffR1(0) when diffR1(5) = '1' else diffR1(4 downto 0);
  absR2 <= not diffR2(4) & not diffR2(3) & not diffR2(2) & not diffR2(1) & not diffR2(0) when diffR2(5) = '1' else diffR2(4 downto 0);
  absR3 <= not diffR3(4) & not diffR3(3) & not diffR3(2) & not diffR3(1) & not diffR3(0) when diffR3(5) = '1' else diffR3(4 downto 0);
  
-------------------------------------------------------------------
  diffG0 <= ('0' & latchd0(10 downto 5)) - ('0' & latchp0(10 downto 5));
  diffG1 <= ('0' & latchd1(10 downto 5)) - ('0' & latchp1(10 downto 5));
  diffG2 <= ('0' & latchd2(10 downto 5)) - ('0' & latchp2(10 downto 5));
  diffG3 <= ('0' & latchd3(10 downto 5)) - ('0' & latchp3(10 downto 5));

-------------------------------------------------------------------
  absG0 <= not diffG0(5) & not diffG0(4) & not diffG0(3) & not diffG0(2) & not diffG0(1) & not diffG0(0) when diffG0(6) = '1' else diffG0(5 downto 0);
  absG1 <= not diffG1(5) & not diffG1(4) & not diffG1(3) & not diffG1(2) & not diffG1(1) & not diffG1(0) when diffG1(6) = '1' else diffG1(5 downto 0);
  absG2 <= not diffG2(5) & not diffG2(4) & not diffG2(3) & not diffG2(2) & not diffG2(1) & not diffG2(0) when diffG2(6) = '1' else diffG2(5 downto 0);
  absG3 <= not diffG3(5) & not diffG3(4) & not diffG3(3) & not diffG3(2) & not diffG3(1) & not diffG3(0) when diffG3(6) = '1' else diffG3(5 downto 0);
  
-------------------------------------------------------------------
  diffB0 <= ('0' & latchd0(4 downto 0)) - ('0' & latchp0(4 downto 0));
  diffB1 <= ('0' & latchd1(4 downto 0)) - ('0' & latchp1(4 downto 0));
  diffB2 <= ('0' & latchd2(4 downto 0)) - ('0' & latchp2(4 downto 0));
  diffB3 <= ('0' & latchd3(4 downto 0)) - ('0' & latchp3(4 downto 0));

-------------------------------------------------------------------
  absB0 <= not diffB0(4) & not diffB0(3) & not diffB0(2) & not diffB0(1) & not diffB0(0) when diffB0(5) = '1' else diffB0(4 downto 0);
  absB1 <= not diffB1(4) & not diffB1(3) & not diffB1(2) & not diffB1(1) & not diffB1(0) when diffB1(5) = '1' else diffB1(4 downto 0);
  absB2 <= not diffB2(4) & not diffB2(3) & not diffB2(2) & not diffB2(1) & not diffB2(0) when diffB2(5) = '1' else diffB2(4 downto 0);
  absB3 <= not diffB3(4) & not diffB3(3) & not diffB3(2) & not diffB3(1) & not diffB3(0) when diffB3(5) = '1' else diffB3(4 downto 0);
  
-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    abs3 <= (others => '0');
    abs2 <= (others => '0');
    abs1 <= (others => '0');
    abs0 <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(dec18 = '1') then 
      abs3 <= absR3 & absG3 & absB3;
      abs2 <= absR2 & absG2 & absB2;
      abs1 <= absR1 & absG1 & absB1;
      abs0 <= absR0 & absG0 & absB0;
    end if;
  end if;
end process;

-------------------------------------------------------------------
  latch0 <= abs0 when ViewMode = "0011" else latchp0;
  latch1 <= abs1 when ViewMode = "0011" else latchp1;
  latch2 <= abs2 when ViewMode = "0011" else latchp2;
  latch3 <= abs3 when ViewMode = "0011" else latchp3;
                     -- differential mode

-----------------------------------------------------------------
  abs_r <= "000000" & absR3 & '0'; -- 6bit + 5bit + 1bit
  abs_g <= "000000" & absG3; -- 6bit + 6bit
  abs_b <= "000000" & absB3 & '0'; -- 6bit + 5bit + 1bit
  abs_y <= (abs_r(8 downto 0) & "000") + (abs_g(7 downto 0) & "0000") + abs_b + abs_b + abs_b;
  
-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    abs_y_sft <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(dec18 = '1') then 
      abs_y_sft <= "00000" & abs_y(11 downto 5);
    end if;
  end if;
end process;

---------------------------------------------------------------------
-- Detects the motion of left side of the VGA
---------------------------------------------------------------------
  add_y_L <= abs_y_sft + acc_y_L;

----------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0') then
    acc_y_L <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(VgaPixCount < 120) then -- clears till 120 (left)
      acc_y_L <= (others => '0');
    elsif(dec18 = '1' and acc_y_L(11) = '0') then
      acc_y_L <= add_y_L;
    end if;
  end if;
end process;

----------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0') then
    acc_y_latch_L <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(VgaLineCount < 33) then
      acc_y_latch_L <= (others => '0'); 
    elsif(VgaPixCount = 400) then -- latches at 400 (left)
      acc_y_latch_L <= acc_y_L; -- from add to acc 2014/04/15
    end if;
  end if;
end process;

-----------------------------------------------------------------
  v_abs_y_sft_L <= "00000000" & acc_y_latch_L(11 downto 8);
  v_add_y_L <= v_abs_y_sft_L + v_acc_y_L;
  
----------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0') then
    v_acc_y_L <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(VgaLineCount < 33) then
      v_acc_y_L <= (others => '0');
    elsif(VgaLineCount < 500 and VgaPixCount = 780 and v_acc_y_L(11) = '0') then
      v_acc_y_L <= v_add_y_L;
    end if;
  end if;
end process;

-----------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    v_acc_y_latch_L <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(VgaLineCount = 495 and VgaPixCount = 780) then 
      v_acc_y_latch_L <= v_acc_y_L; -- remove MDET_edge_L 2014/04/15
    end if;
  end if;
end process;

-----------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    MDET_L <= '0';
  elsif( CLK'event and CLK = '1' ) then
    if(v_acc_y_latch_L >= 256) then -- modified how to generate mdet_l 2014/04/15
      MDET_L <= '1'; 
    else 
      MDET_L <= '0'; 
    end if;
  end if;
end process;

---------------------------------------------------------------------
-- Detects the motion of right side of the VGA
---------------------------------------------------------------------
  add_y_R <= abs_y_sft + acc_y_R;

----------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0') then
    acc_y_R <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(VgaPixCount < 380) then -- clears till 380 (right)
      acc_y_R <= (others => '0');
    elsif(dec18 = '1' and acc_y_R(11) = '0') then
      acc_y_R <= add_y_R;
    end if;
  end if;
end process;

----------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0') then
    acc_y_latch_R <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(VgaLineCount < 33) then
      acc_y_latch_R <= (others => '0'); 
    elsif(VgaPixCount = 780) then -- latches at 780(right)
      acc_y_latch_R <= acc_y_R; -- from add to acc 2014/04/15
    end if;
  end if;
end process;

-----------------------------------------------------------------
  v_abs_y_sft_R <= "00000000" & acc_y_latch_R(11 downto 8);
  v_add_y_R <= v_abs_y_sft_R + v_acc_y_R;
  
----------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0') then
    v_acc_y_R <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(VgaLineCount < 33) then
      v_acc_y_R <= (others => '0');
    elsif(VgaLineCount < 500 and VgaPixCount = 780 and v_acc_y_R(11) = '0') then
      v_acc_y_R <= v_add_y_R;
    end if;
  end if;
end process;

-----------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    v_acc_y_latch_R <= (others => '0');
  elsif( CLK'event and CLK = '1' ) then
    if(VgaLineCount = 495 and VgaPixCount = 780) then 
      v_acc_y_latch_R <= v_acc_y_R; -- remove MDET_edge_R 2014/04/15
    end if;
  end if;
end process;

-----------------------------------------------------------------
process( RST_N, CLK )
begin
  if( RST_N = '0' ) then
    MDET_R <= '0';
  elsif( CLK'event and CLK = '1' ) then
    if(v_acc_y_latch_R >= 256) then -- modified how to generate mdet_r 2014/04/15
      MDET_R <= '1'; 
    else 
      MDET_R <= '0'; 
    end if;
  end if;
end process;

-------------------------------------------------------------------
process( RST_N, CLK100M )
begin
  if( RST_N = '0' ) then
    sdram_data_sdrd <= (others => '0');
  elsif( CLK100M'event and CLK100M = '1' ) then
    if(count100m = 2) then
      sdram_data_sdrd <= vga_RGB_dly0;
	  elsif(count100m = 3) then
	    sdram_data_sdrd <= vga_RGB_dly1;
	  elsif(count100m = 4) then
	    sdram_data_sdrd <= vga_RGB_dly2;
	  else
	    sdram_data_sdrd <= vga_RGB_dly3;
	  end if;
  end if;
end process;
                
END structure;
