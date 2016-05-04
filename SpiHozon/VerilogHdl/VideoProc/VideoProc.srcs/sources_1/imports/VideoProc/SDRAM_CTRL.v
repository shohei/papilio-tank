// Designed by Toshio Iwata at DIGITALFILTER.COM 2014/06/01

module SDRAM_CTRL(
  CLK,
  CLK100M,
  RST_N,
  PIXSTB,
  PIXWR,
  LBRDY,
  SdrwLineCount,
  ViewMode,
  VgaHsync_EDGE,
  CamVsync,
  CamVsync_EDGE,
  CamLineCount,
  CamPixCount4x,
  VgaLineCount,
  VgaPixCount,
  buf_RGB,
  latch0,
  latch1,
  latch2,
  latch3,
  vga_RGB_dly0,
  vga_RGB_dly1,
  vga_RGB_dly2,
  vga_RGB_dly3,
  winp0,
  winp1,
  winp2,
  winp3,
  MDET_L,
  MDET_R,
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
  SDRAM_BA
);

input CLK;
input CLK100M;
input RST_N;
input PIXSTB;
input PIXWR;
input LBRDY;
input[8:0] SdrwLineCount;
input[3:0] ViewMode;
input VgaHsync_EDGE;
input CamVsync;
input CamVsync_EDGE;
input[8:0] CamLineCount;
input[15:0] CamPixCount4x;
input[8:0] VgaLineCount;
input[9:0] VgaPixCount;
input[15:0] buf_RGB;
output[15:0] latch0;
output[15:0] latch1;
output[15:0] latch2;
output[15:0] latch3;
input[15:0] vga_RGB_dly0;
input[15:0] vga_RGB_dly1;
input[15:0] vga_RGB_dly2;
input[15:0] vga_RGB_dly3;
output winp0;
output winp1;
output winp2;
output winp3;
output MDET_L;
output MDET_R;
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

wire   CLK;
wire   CLK100M;
wire   RST_N;
wire   PIXSTB;
wire   PIXWR;
wire   LBRDY;
wire  [8:0] SdrwLineCount;
wire  [3:0] ViewMode;
wire   VgaHsync_EDGE;
wire   CamVsync;
wire   CamVsync_EDGE;
wire  [8:0] CamLineCount;
wire  [15:0] CamPixCount4x;
wire  [8:0] VgaLineCount;
wire  [9:0] VgaPixCount;
wire  [15:0] buf_RGB;
wire  [15:0] latch0;
wire  [15:0] latch1;
wire  [15:0] latch2;
wire  [15:0] latch3;
wire  [15:0] vga_RGB_dly0;
wire  [15:0] vga_RGB_dly1;
wire  [15:0] vga_RGB_dly2;
wire  [15:0] vga_RGB_dly3;
reg    winp0;
reg    winp1;
reg    winp2;
reg    winp3;
reg    MDET_L;
reg    MDET_R;
reg    SDRAM_DQENB_N;
reg    SDRAM_DQMH;
reg    SDRAM_DQML;
reg    SDRAM_CS_N;
reg    SDRAM_WE_N;
reg    SDRAM_RAS_N;
reg    SDRAM_CAS_N;
reg    SDRAM_CKE;
wire  [15:0] SDRAM_DQI;
reg   [15:0] SDRAM_DQO;
reg   [11:0] SDRAM_A;
reg   [1:0] SDRAM_BA;


reg  [15:0] buf_RGB_dly1;
reg  [15:0] buf_RGB_dly2;
reg  [15:0] buf_RGB_dly3;
reg  [15:0] sdram_data0;
reg  [15:0] sdram_data1;
reg  [15:0] sdram_data2;
reg  [15:0] sdram_data3;
wire  buf_RGB_win;
reg  [4:0] MemState;
wire [4:0] Initial;
wire [4:0] MRS;
wire [4:0] BstWr;
wire [4:0] BstRd;
wire [4:0] PreChAll;
wire [4:0] doingPreChAll;
wire [4:0] doingMRS;
reg  [3:0] cmdcount;
reg  [4:0] count100m;
wire [15:0] sdram_data;
wire  csn;
wire  wrn;
wire  rasn;
wire  casn;
wire  dqm;
wire  dqenbn;
wire  cmdFound;
wire [1:0] baddr;
reg  [1:0] baddr_norm;
wire [11:0] coladdr;
wire [11:0] rowaddr;
reg  [15:0] pwrupcount;
wire  pwrupready;
wire  oddLine2x;
reg  [2:0] FrameCount;
wire [2:0] frame2write;
wire [2:0] frame2read;
wire [2:0] frame;
wire [2:0] frame2read_norm;
wire [2:0] frame2read_m7;
wire [2:0] frame2read_diff;
wire  SDRAM_DQENB_N_sig;
wire  SDRAM_DQMH_sig;
wire  SDRAM_DQML_sig;
wire  SDRAM_CS_N_sig;
wire  SDRAM_WE_N_sig;
wire  SDRAM_RAS_N_sig;
wire  SDRAM_CAS_N_sig;
wire  SDRAM_CKE_sig;
wire [15:0] SDRAM_DQO_sig;
wire [11:0] SDRAM_A_sig;
wire [1:0] SDRAM_BA_sig;
wire [8:0] line2write;
wire [8:0] line2read;
wire [8:0] linerw;
reg   rasn_norm;
reg   rasn_diff;
reg   casn_norm;
reg   casn_diff;
reg  [11:0] rowaddr_norm;
reg  [11:0] coladdr_norm;
wire  dec14;
reg   dec15;
reg   dec16;
reg   dec17;
reg   dec18;
reg  [15:0] latchp0;
reg  [15:0] latchp1;
reg  [15:0] latchp2;
reg  [15:0] latchp3;
reg  [15:0] latchd0;
reg  [15:0] latchd1;
reg  [15:0] latchd2;
reg  [15:0] latchd3;
wire  rasn_norm_sig;
wire  casn_norm_sig;
wire [11:0] rowaddr_norm_sig;
wire [11:0] coladdr_norm_sig;
wire [1:0] baddr_norm_sig;
wire  count100m_clr;
reg   buf_RGB_win_dly1;
reg   buf_RGB_win_dly2;
wire  cmdready;
wire [5:0] diffR0;
wire [5:0] diffR1;
wire [5:0] diffR2;
wire [5:0] diffR3;
wire [4:0] absR0;
wire [4:0] absR1;
wire [4:0] absR2;
wire [4:0] absR3;
wire [6:0] diffG0;
wire [6:0] diffG1;
wire [6:0] diffG2;
wire [6:0] diffG3;
wire [5:0] absG0;
wire [5:0] absG1;
wire [5:0] absG2;
wire [5:0] absG3;
wire [5:0] diffB0;
wire [5:0] diffB1;
wire [5:0] diffB2;
wire [5:0] diffB3;
wire [4:0] absB0;
wire [4:0] absB1;
wire [4:0] absB2;
wire [4:0] absB3;
reg  [15:0] abs0;
reg  [15:0] abs1;
reg  [15:0] abs2;
reg  [15:0] abs3;
wire  rasn_diff_sig;
wire  casn_diff_sig;
wire [11:0] abs_y;
wire [11:0] abs_r;
wire [11:0] abs_g;
wire [11:0] abs_b;
reg  [11:0] abs_y_sft;
reg  [11:0] acc_y_L;
reg  [11:0] acc_y_latch_L;
wire [11:0] add_y_L;
wire [11:0] v_abs_y_sft_L;
reg  [11:0] v_acc_y_L;
wire [11:0] v_add_y_L;
reg  [11:0] v_acc_y_latch_L;
reg  [11:0] acc_y_R;
reg  [11:0] acc_y_latch_R;
wire [11:0] add_y_R;
wire [11:0] v_abs_y_sft_R;
reg  [11:0] v_acc_y_R;
wire [11:0] v_add_y_R;
reg  [11:0] v_acc_y_latch_R;
reg  [15:0] sdram_data_sdrd;

assign Initial = 5'b00000;
assign MRS = 5'b00010;
assign BstWr = 5'b00100;
assign BstRd = 5'b00101;
assign PreChAll = 5'b00001;
assign doingPreChAll = 5'b10001;
assign doingMRS = 5'b10010;

//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    MemState <= Initial;
  end
  else  begin
    if ((MemState == Initial && pwrupready == 1'b1)  )  begin
      // go to precharge
      MemState <= PreChAll;
    end
    else if ((MemState == PreChAll)  )  begin
      MemState <= doingPreChAll;
    end
    else if ((MemState == doingPreChAll && cmdready == 1'b1)  )  begin
      // wait 300ns and go to MRS
      MemState <= MRS;
    end
    else if ((MemState == MRS)  )  begin
      MemState <= doingMRS;
    end
    else if ((MemState == doingMRS && cmdready == 1'b1)  )  begin
      // wait 300ns and go to burst write
      MemState <= BstWr;
    end
    else if ((MemState == BstWr && VgaHsync_EDGE == 1'b1 && oddLine2x == 1'b1)  )  begin
      // go to burst read
      MemState <= BstRd;
    end
    else if ((MemState == BstRd && VgaHsync_EDGE == 1'b1 && oddLine2x == 1'b0)  )  begin
      // go to burst write
      MemState <= BstWr;
    end
  end
end

//-----------------------------------------------------------------
assign cmdFound = (MemState == PreChAll || MemState == MRS)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N or posedge cmdFound)  begin
  if ((RST_N == 1'b0 || cmdFound == 1'b1)  )  begin
    cmdcount <= {4{1'b0}};
  end
  else  begin
    if ((cmdcount != 15)  )  begin
      cmdcount <= cmdcount + 1;
    end
  end
end

assign cmdready = (cmdcount == 15)? 1'b1 : 1'b0;
// 20ns * 15 = 300ns
//-----------------------------------------------------------------
assign buf_RGB_win = (CamPixCount4x[2:0]  == 3'b000)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    buf_RGB_dly3 <= {16{1'b0}};
    buf_RGB_dly2 <= {16{1'b0}};
    buf_RGB_dly1 <= {16{1'b0}};
  end
  else  begin
    if ((CamPixCount4x[0]  == 1'b0)  )  begin
      buf_RGB_dly3 <= buf_RGB_dly2;
      buf_RGB_dly2 <= buf_RGB_dly1;
      buf_RGB_dly1 <= buf_RGB;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    sdram_data3 <= {16{1'b0}};
    sdram_data2 <= {16{1'b0}};
    sdram_data1 <= {16{1'b0}};
    sdram_data0 <= {16{1'b0}};
  end
  else  begin
    if ((buf_RGB_win == 1'b1)  )  begin
      sdram_data3 <= buf_RGB_dly3;
      sdram_data2 <= buf_RGB_dly2;
      sdram_data1 <= buf_RGB_dly1;
      sdram_data0 <= buf_RGB;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    buf_RGB_win_dly2 <= 1'b0;
    buf_RGB_win_dly1 <= 1'b0;
  end
  else  begin
    buf_RGB_win_dly2 <= buf_RGB_win_dly1;
    buf_RGB_win_dly1 <= buf_RGB_win;
  end
end

assign count100m_clr = (buf_RGB_win_dly1 == 1'b1 && buf_RGB_win_dly2 == 1'b0)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    count100m <= {5{1'b0}};
  end
  else  begin
    if ((count100m_clr == 1'b1)  )  begin
      count100m <= {5{1'b0}};
    end
    else  begin
      count100m <= count100m + 1;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    pwrupcount <= {16{1'b0}};
  end
  else  begin
    if ((pwrupcount != 10000)  )  begin
      // 20ns * 10000 = 200us
      pwrupcount <= pwrupcount + 1;
    end
  end
end

assign pwrupready = (pwrupcount == 10000)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
assign oddLine2x = (CamPixCount4x < 1567)? 1'b0 : 1'b1;
//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    FrameCount <= {3{1'b0}};
  end
  else  begin
    if ((CamVsync_EDGE == 1'b1)  )  begin
      if ((ViewMode == 4'b0000 || ViewMode == 4'b0010 || ViewMode == 4'b0011 || ViewMode == 4'b0100)  )  begin
        // normal, repeat, differential, motion detect
        FrameCount <= FrameCount + 1;
      end
    end
  end
end

assign frame2write = (ViewMode == 4'b0110)? FrameCount - 1 : FrameCount;
assign frame2read_norm = FrameCount - 1;
assign frame2read_m7 = FrameCount + 1;
assign frame2read_diff = (count100m >= 8 && count100m <= 15 && MemState == BstRd)? frame2read_m7 : frame2read_norm;
assign frame2read = (ViewMode == 4'b0011 || ViewMode == 4'b0100)? frame2read_diff : frame2read_norm;
assign frame = (MemState == BstWr)? frame2write : frame2read;
//-----------------------------------------------------------------
assign line2write = (ViewMode == 4'b0110)? {SdrwLineCount[7:0] ,1'b0} : CamLineCount[8:0] ;
//-----------------------------------------------------------------
assign line2read = (ViewMode == 4'b0101)? {SdrwLineCount[7:0] ,1'b0} : VgaLineCount;
//-----------------------------------------------------------------
assign linerw = (MemState == BstWr)? line2write : line2read;
//-----------------------------------------------------------------
assign rasn_norm_sig = (dec16 == 1'b1)? 1'b0 : 1'b1;
assign rasn_diff_sig = ((dec16 == 1'b1 && MemState == BstWr)   || ((dec16 == 1'b1 || count100m == 8)   && MemState == BstRd)  )? 1'b0 : 1'b1;
assign casn_norm_sig = (count100m == 2)? 1'b0 : 1'b1;
assign casn_diff_sig = ((count100m == 2 && MemState == BstWr)   || ((count100m == 2 || count100m == 10)   && MemState == BstRd)  )? 1'b0 : 1'b1;
assign rowaddr_norm_sig = {frame[0] ,linerw,VgaPixCount[9:8] };
assign coladdr_norm_sig = {4'b0100,VgaPixCount[7:2] ,2'b00};
assign baddr_norm_sig = frame[2:1] ;
//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    rasn_norm <= 1'b0;
    rasn_diff <= 1'b0;
    casn_norm <= 1'b0;
    casn_diff <= 1'b0;
    rowaddr_norm <= {12{1'b0}};
    coladdr_norm <= {12{1'b0}};
    baddr_norm <= {2{1'b0}};
  end
  else  begin
    rasn_norm <= rasn_norm_sig;
    rasn_diff <= rasn_diff_sig;
    casn_norm <= casn_norm_sig;
    casn_diff <= casn_diff_sig;
    rowaddr_norm <= rowaddr_norm_sig;
    coladdr_norm <= coladdr_norm_sig;
    baddr_norm <= baddr_norm_sig;
  end
end

//-----------------------------------------------------------------
assign sdram_data = (count100m == 3)? sdram_data3 : (count100m == 4)? sdram_data2 : (count100m == 5)? sdram_data1 : (count100m == 6)? sdram_data0 : {16{1'b0}};
//-----------------------------------------------------------------
assign csn = 1'b0;
assign wrn = (MemState == BstWr && oddLine2x == 1'b0 && count100m == 3 && (ViewMode == 4'b0000 || ViewMode == 4'b0011 || ViewMode == 4'b0100 || (ViewMode == 4'b0110 && PIXWR == 1'b0 && LBRDY == 1'b0)  )  )? 1'b0 : 1'b1;
assign rasn = (ViewMode == 4'b0011 || ViewMode == 4'b0100)? rasn_diff : rasn_norm;
assign casn = (ViewMode == 4'b0011 || ViewMode == 4'b0100)? casn_diff : casn_norm;
assign dqm = 1'b0;
assign baddr = baddr_norm;
assign dqenbn = (MemState == BstWr && oddLine2x == 1'b0 && count100m >= 3 && count100m <= 6 && (ViewMode == 4'b0000 || ViewMode == 4'b0011 || ViewMode == 4'b0100 || (ViewMode == 4'b0110 && PIXWR == 1'b0 && LBRDY == 1'b0)  )  )? 1'b0 : 1'b1;
assign rowaddr = rowaddr_norm;
assign coladdr = coladdr_norm;
//-----------------------------------------------------------------
assign SDRAM_BA_sig = (MemState == MRS)? 2'b00 : baddr;
assign SDRAM_A_sig = (MemState == PreChAll || MemState == doingPreChAll)? 12'b010000000000 : (MemState == MRS)? 12'b000000100010 : (MemState == doingMRS)? 12'b000000100010 : (count100m == 1 || count100m == 9)? rowaddr : (count100m == 3 || count100m == 11)? coladdr : {12{1'b0}};
assign SDRAM_DQO_sig = (ViewMode == 4'b0110)? sdram_data_sdrd : sdram_data;
assign SDRAM_DQMH_sig = 1'b0;
assign SDRAM_DQML_sig = 1'b0;
assign SDRAM_CS_N_sig = (MemState == PreChAll || MemState == doingPreChAll)? 1'b0 : (MemState == MRS)? 1'b0 : (MemState == doingMRS)? 1'b0 : csn;
assign SDRAM_WE_N_sig = (MemState == PreChAll)? 1'b0 : (MemState == doingPreChAll)? 1'b1 : (MemState == MRS)? 1'b0 : (MemState == doingMRS)? 1'b0 : wrn;
// same as MRS 2014/04/15
assign SDRAM_RAS_N_sig = (MemState == PreChAll || MemState == doingPreChAll)? 1'b0 : (MemState == MRS)? 1'b0 : (MemState == doingMRS)? 1'b0 : rasn;
// same as MRS 2014/04/15
assign SDRAM_CAS_N_sig = (MemState == PreChAll)? 1'b1 : (MemState == doingPreChAll)? 1'b0 : (MemState == MRS)? 1'b0 : (MemState == doingMRS)? 1'b0 : casn;
// same as MRS 2014/04/15
assign SDRAM_CKE_sig = 1'b1;
assign SDRAM_DQENB_N_sig = dqenbn;
//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    SDRAM_BA <= {2{1'b0}};
    SDRAM_A <= {12{1'b0}};
    SDRAM_DQO <= {16{1'b0}};
    SDRAM_DQMH <= 1'b0;
    SDRAM_DQML <= 1'b0;
    SDRAM_CS_N <= 1'b0;
    SDRAM_WE_N <= 1'b0;
    SDRAM_RAS_N <= 1'b0;
    SDRAM_CAS_N <= 1'b0;
    SDRAM_CKE <= 1'b0;
    SDRAM_DQENB_N <= 1'b0;
  end
  else  begin
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
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchp0 <= {16{1'b0}};
  end
  else  begin
    if ((count100m == 6)  )  begin
      latchp0 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchp1 <= {16{1'b0}};
  end
  else  begin
    if ((count100m == 7)  )  begin
      latchp1 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchp2 <= {16{1'b0}};
  end
  else  begin
    if ((count100m == 8)  )  begin
      latchp2 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchp3 <= {16{1'b0}};
  end
  else  begin
    if ((count100m == 9)  )  begin
      latchp3 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    winp0 <= 1'b0;
  end
  else  begin
    if (((count100m == 6 || count100m == 7)   && oddLine2x == 1'b1)  )  begin
      winp0 <= 1'b1;
    end
    else  begin
      winp0 <= 1'b0;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    winp1 <= 1'b0;
  end
  else  begin
    if (((count100m == 8 || count100m == 9)   && oddLine2x == 1'b1)  )  begin
      winp1 <= 1'b1;
    end
    else  begin
      winp1 <= 1'b0;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    winp2 <= 1'b0;
  end
  else  begin
    if (((count100m == 10 || count100m == 11)   && oddLine2x == 1'b1)  )  begin
      winp2 <= 1'b1;
    end
    else  begin
      winp2 <= 1'b0;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    winp3 <= 1'b0;
  end
  else  begin
    if (((count100m == 12 || count100m == 13)   && oddLine2x == 1'b1)  )  begin
      winp3 <= 1'b1;
    end
    else  begin
      winp3 <= 1'b0;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchd0 <= {16{1'b0}};
  end
  else  begin
    if ((dec14 == 1'b1)  )  begin
      latchd0 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchd1 <= {16{1'b0}};
  end
  else  begin
    if ((dec15 == 1'b1)  )  begin
      latchd1 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchd2 <= {16{1'b0}};
  end
  else  begin
    if ((dec16 == 1'b1)  )  begin
      latchd2 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    latchd3 <= {16{1'b0}};
  end
  else  begin
    if ((dec17 == 1'b1)  )  begin
      latchd3 <= SDRAM_DQI;
    end
  end
end

//-----------------------------------------------------------------
assign dec14 = (count100m == 14)? 1'b1 : 1'b0;
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    dec18 <= 1'b0;
    dec17 <= 1'b0;
    dec16 <= 1'b0;
    dec15 <= 1'b0;
  end
  else  begin
    dec18 <= dec17;
    dec17 <= dec16;
    dec16 <= dec15;
    dec15 <= dec14;
  end
end

// modified 2012/08/28
//-----------------------------------------------------------------
assign diffR0 = ({1'b0,latchd0[15:11] }) - ({1'b0,latchp0[15:11] });
assign diffR1 = ({1'b0,latchd1[15:11] }) - ({1'b0,latchp1[15:11] });
assign diffR2 = ({1'b0,latchd2[15:11] }) - ({1'b0,latchp2[15:11] });
assign diffR3 = ({1'b0,latchd3[15:11] }) - ({1'b0,latchp3[15:11] });
//-----------------------------------------------------------------
assign absR0 = (diffR0[5]  == 1'b1)? { ~diffR0[4] , ~diffR0[3] , ~diffR0[2] , ~diffR0[1] , ~diffR0[0] } : diffR0[4:0] ;
assign absR1 = (diffR1[5]  == 1'b1)? { ~diffR1[4] , ~diffR1[3] , ~diffR1[2] , ~diffR1[1] , ~diffR1[0] } : diffR1[4:0] ;
assign absR2 = (diffR2[5]  == 1'b1)? { ~diffR2[4] , ~diffR2[3] , ~diffR2[2] , ~diffR2[1] , ~diffR2[0] } : diffR2[4:0] ;
assign absR3 = (diffR3[5]  == 1'b1)? { ~diffR3[4] , ~diffR3[3] , ~diffR3[2] , ~diffR3[1] , ~diffR3[0] } : diffR3[4:0] ;
//-----------------------------------------------------------------
assign diffG0 = ({1'b0,latchd0[10:5] }) - ({1'b0,latchp0[10:5] });
assign diffG1 = ({1'b0,latchd1[10:5] }) - ({1'b0,latchp1[10:5] });
assign diffG2 = ({1'b0,latchd2[10:5] }) - ({1'b0,latchp2[10:5] });
assign diffG3 = ({1'b0,latchd3[10:5] }) - ({1'b0,latchp3[10:5] });
//-----------------------------------------------------------------
assign absG0 = (diffG0[6]  == 1'b1)? { ~diffG0[5] , ~diffG0[4] , ~diffG0[3] , ~diffG0[2] , ~diffG0[1] , ~diffG0[0] } : diffG0[5:0] ;
assign absG1 = (diffG1[6]  == 1'b1)? { ~diffG1[5] , ~diffG1[4] , ~diffG1[3] , ~diffG1[2] , ~diffG1[1] , ~diffG1[0] } : diffG1[5:0] ;
assign absG2 = (diffG2[6]  == 1'b1)? { ~diffG2[5] , ~diffG2[4] , ~diffG2[3] , ~diffG2[2] , ~diffG2[1] , ~diffG2[0] } : diffG2[5:0] ;
assign absG3 = (diffG3[6]  == 1'b1)? { ~diffG3[5] , ~diffG3[4] , ~diffG3[3] , ~diffG3[2] , ~diffG3[1] , ~diffG3[0] } : diffG3[5:0] ;
//-----------------------------------------------------------------
assign diffB0 = ({1'b0,latchd0[4:0] }) - ({1'b0,latchp0[4:0] });
assign diffB1 = ({1'b0,latchd1[4:0] }) - ({1'b0,latchp1[4:0] });
assign diffB2 = ({1'b0,latchd2[4:0] }) - ({1'b0,latchp2[4:0] });
assign diffB3 = ({1'b0,latchd3[4:0] }) - ({1'b0,latchp3[4:0] });
//-----------------------------------------------------------------
assign absB0 = (diffB0[5]  == 1'b1)? { ~diffB0[4] , ~diffB0[3] , ~diffB0[2] , ~diffB0[1] , ~diffB0[0] } : diffB0[4:0] ;
assign absB1 = (diffB1[5]  == 1'b1)? { ~diffB1[4] , ~diffB1[3] , ~diffB1[2] , ~diffB1[1] , ~diffB1[0] } : diffB1[4:0] ;
assign absB2 = (diffB2[5]  == 1'b1)? { ~diffB2[4] , ~diffB2[3] , ~diffB2[2] , ~diffB2[1] , ~diffB2[0] } : diffB2[4:0] ;
assign absB3 = (diffB3[5]  == 1'b1)? { ~diffB3[4] , ~diffB3[3] , ~diffB3[2] , ~diffB3[1] , ~diffB3[0] } : diffB3[4:0] ;
//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    abs3 <= {16{1'b0}};
    abs2 <= {16{1'b0}};
    abs1 <= {16{1'b0}};
    abs0 <= {16{1'b0}};
  end
  else  begin
    if ((dec18 == 1'b1)  )  begin
      abs3 <= {absR3,absG3,absB3};
      abs2 <= {absR2,absG2,absB2};
      abs1 <= {absR1,absG1,absB1};
      abs0 <= {absR0,absG0,absB0};
    end
  end
end

//-----------------------------------------------------------------
assign latch0 = (ViewMode == 4'b0011)? abs0 : latchp0;
assign latch1 = (ViewMode == 4'b0011)? abs1 : latchp1;
assign latch2 = (ViewMode == 4'b0011)? abs2 : latchp2;
assign latch3 = (ViewMode == 4'b0011)? abs3 : latchp3;
// differential mode
//---------------------------------------------------------------
assign abs_r = {6'b000000,absR3,1'b0};
// 6bit + 5bit + 1bit
assign abs_g = {6'b000000,absG3};
// 6bit + 6bit
assign abs_b = {6'b000000,absB3,1'b0};
// 6bit + 5bit + 1bit
assign abs_y = ({abs_r[8:0] ,3'b000}) + ({abs_g[7:0] ,4'b0000}) + abs_b + abs_b + abs_b;
//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    abs_y_sft <= {12{1'b0}};
  end
  else  begin
    if ((dec18 == 1'b1)  )  begin
      abs_y_sft <= {5'b00000,abs_y[11:5] };
    end
  end
end

//-------------------------------------------------------------------
// Detects the motion of left side of the VGA
//-------------------------------------------------------------------
assign add_y_L = abs_y_sft + acc_y_L;
//--------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    acc_y_L <= {12{1'b0}};
  end
  else  begin
    if ((VgaPixCount < 120)  )  begin
      // clears till 120 (left)
      acc_y_L <= {12{1'b0}};
    end
    else if ((dec18 == 1'b1 && acc_y_L[11]  == 1'b0)  )  begin
      acc_y_L <= add_y_L;
    end
  end
end

//--------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    acc_y_latch_L <= {12{1'b0}};
  end
  else  begin
    if ((VgaLineCount < 33)  )  begin
      acc_y_latch_L <= {12{1'b0}};
    end
    else if ((VgaPixCount == 400)  )  begin
      // latches at 400 (left)
      acc_y_latch_L <= acc_y_L;
      // from add to acc 2014/04/15
    end
  end
end

//---------------------------------------------------------------
assign v_abs_y_sft_L = {8'b00000000,acc_y_latch_L[11:8] };
assign v_add_y_L = v_abs_y_sft_L + v_acc_y_L;
//--------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    v_acc_y_L <= {12{1'b0}};
  end
  else  begin
    if ((VgaLineCount < 33)  )  begin
      v_acc_y_L <= {12{1'b0}};
    end
    else if ((VgaLineCount < 500 && VgaPixCount == 780 && v_acc_y_L[11]  == 1'b0)  )  begin
      v_acc_y_L <= v_add_y_L;
    end
  end
end

//---------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    v_acc_y_latch_L <= {12{1'b0}};
  end
  else  begin
    if ((VgaLineCount == 495 && VgaPixCount == 780)  )  begin
      v_acc_y_latch_L <= v_acc_y_L;
      // remove MDET_EDGE_L 2014/04/15
    end
  end
end

//---------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    MDET_L <= 1'b0;
  end
  else  begin
    if ((v_acc_y_latch_L >= 256)  )  begin
      // modified how to generate mdet_l 2014/04/15
      MDET_L <= 1'b1;
    end
    else  begin
      MDET_L <= 1'b0;
    end
  end
end

//-------------------------------------------------------------------
// Detects the motion of right side of the VGA
//-------------------------------------------------------------------
assign add_y_R = abs_y_sft + acc_y_R;
//--------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    acc_y_R <= {12{1'b0}};
  end
  else  begin
    if ((VgaPixCount < 380)  )  begin
      // clears till 380 (right)
      acc_y_R <= {12{1'b0}};
    end
    else if ((dec18 == 1'b1 && acc_y_R[11]  == 1'b0)  )  begin
      acc_y_R <= add_y_R;
    end
  end
end

//--------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    acc_y_latch_R <= {12{1'b0}};
  end
  else  begin
    if ((VgaLineCount < 33)  )  begin
      acc_y_latch_R <= {12{1'b0}};
    end
    else if ((VgaPixCount == 780)  )  begin
      // latches at 780(right)
      acc_y_latch_R <= acc_y_R;
      // from add to acc 2014/04/15
    end
  end
end

//---------------------------------------------------------------
assign v_abs_y_sft_R = {8'b00000000,acc_y_latch_R[11:8] };
assign v_add_y_R = v_abs_y_sft_R + v_acc_y_R;
//--------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    v_acc_y_R <= {12{1'b0}};
  end
  else  begin
    if ((VgaLineCount < 33)  )  begin
      v_acc_y_R <= {12{1'b0}};
    end
    else if ((VgaLineCount < 500 && VgaPixCount == 780 && v_acc_y_R[11]  == 1'b0)  )  begin
      v_acc_y_R <= v_add_y_R;
    end
  end
end

//---------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    v_acc_y_latch_R <= {12{1'b0}};
  end
  else  begin
    if ((VgaLineCount == 495 && VgaPixCount == 780)  )  begin
      v_acc_y_latch_R <= v_acc_y_R;
      // remove MDET_EDGE_R 2014/04/15
    end
  end
end

//---------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    MDET_R <= 1'b0;
  end
  else  begin
    if ((v_acc_y_latch_R >= 256)  )  begin
      // modified how to generate mdet_r 2014/04/15
      MDET_R <= 1'b1;
    end
    else  begin
      MDET_R <= 1'b0;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK100M or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    sdram_data_sdrd <= {16{1'b0}};
  end
  else  begin
    if ((count100m == 2)  )  begin
      sdram_data_sdrd <= vga_RGB_dly0;
    end
    else if ((count100m == 3)  )  begin
      sdram_data_sdrd <= vga_RGB_dly1;
    end
    else if ((count100m == 4)  )  begin
      sdram_data_sdrd <= vga_RGB_dly2;
    end
    else  begin
      sdram_data_sdrd <= vga_RGB_dly3;
    end
  end
end


endmodule
