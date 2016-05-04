// Designed by Toshio Iwata at DIGITALFILTER.COM 2014/06/01

module LINEOUT_CTRL(
  CLK,
  CLK100M,
  RST_N,
  ViewMode,
  PIXSTB,
  PIXWR,
  PIXRD,
  PIX2NIOS,
  PIX2LOGIC,
  LBRDY,
  SdrwLineCount,
  CamHsync_EDGE,
  latch0,
  latch1,
  latch2,
  latch3,
  CamLineCount,
  VgaLineCount,
  VgaPixCount,
  vga_RGB_latch0,
  vga_RGB_latch1,
  vga_RGB_latch2,
  vga_RGB_latch3,
  winp0,
  winp1,
  winp2,
  winp3,
  vga_r,
  vga_g,
  vga_b
);

input CLK;
input CLK100M;
input RST_N;
input[3:0] ViewMode;
input PIXSTB;
input PIXWR;
input PIXRD;
output[15:0] PIX2NIOS;
input[15:0] PIX2LOGIC;
output LBRDY;
output[8:0] SdrwLineCount;
input CamHsync_EDGE;
input[15:0] latch0;
input[15:0] latch1;
input[15:0] latch2;
input[15:0] latch3;
input[8:0] CamLineCount;
input[8:0] VgaLineCount;
input[9:0] VgaPixCount;
output[15:0] vga_RGB_latch0;
output[15:0] vga_RGB_latch1;
output[15:0] vga_RGB_latch2;
output[15:0] vga_RGB_latch3;
input winp0;
input winp1;
input winp2;
input winp3;
output[7:0] vga_r;
output[7:0] vga_g;
output[7:0] vga_b;

wire   CLK;
wire   CLK100M;
wire   RST_N;
wire  [3:0] ViewMode;
wire   PIXSTB;
wire   PIXWR;
wire   PIXRD;
wire  [15:0] PIX2NIOS;
wire  [15:0] PIX2LOGIC;
wire   LBRDY;
wire  [8:0] SdrwLineCount;
wire   CamHsync_EDGE;
wire  [15:0] latch0;
wire  [15:0] latch1;
wire  [15:0] latch2;
wire  [15:0] latch3;
wire  [8:0] CamLineCount;
wire  [8:0] VgaLineCount;
wire  [9:0] VgaPixCount;
reg   [15:0] vga_RGB_latch0;
reg   [15:0] vga_RGB_latch1;
reg   [15:0] vga_RGB_latch2;
reg   [15:0] vga_RGB_latch3;
wire   winp0;
wire   winp1;
wire   winp2;
wire   winp3;
wire  [7:0] vga_r;
wire  [7:0] vga_g;
wire  [7:0] vga_b;


reg  [9:0] OB_WR_ADDR;
reg  [9:0] OB_RD_ADDR;
reg  [15:0] OB_WR_DATA;
wire [15:0] OB_RD_DATA_A;
wire [15:0] OB_RD_DATA_B;
reg   OB_WR_N_A;
reg   OB_WR_N_B;
wire [9:0] OB_WR_ADDR_sig;
wire [9:0] OB_RD_ADDR_sig;
wire [15:0] OB_WR_DATA_sig;
wire  OB_WR_N_A_sig;
wire  OB_WR_N_B_sig;
wire  OB_CS_N;
wire  ODDLINE;
reg   oddline_dly1;
reg   oddline_dly2;
wire [1:0] ls2b;
reg  [15:0] vga_RGB;
reg  [9:0] LB_ADDR;
wire  PIXRD_EDGE;
reg   PIXRD_dly1;
reg   PIXRD_dly2;
wire  PIXWR_EDGE;
reg   PIXWR_dly1;
reg   PIXWR_dly2;
wire  PIXSTB_EDGE;
reg   PIXSTB_dly1;
reg   PIXSTB_dly2;
reg  [2:0] WaitLine;
reg  [9:0] pixstb_count;
reg  [9:0] pixstb_count_plus;
wire  LBRDY_sig;
reg  [3:0] ViewMode_dly1;
reg  [3:0] ViewMode_dly2;
wire  ViewMode5_EDGE;
wire  ViewMode6_EDGE;
reg  [8:0] SdrwLineCount_sig;

//-----------------------------------------------------------------
SRAM OutBuf_A(
  .CLK(CLK),
  .CS_N(OB_CS_N),
  .WR_N(OB_WR_N_A),
  .WRADDR(OB_WR_ADDR),
  .RDADDR(OB_RD_ADDR),
  .WRDATA(OB_WR_DATA),
  .RDDATA(OB_RD_DATA_A));

//-----------------------------------------------------------------
SRAM OutBuf_B(
  .CLK(CLK),
  .CS_N(OB_CS_N),
  .WR_N(OB_WR_N_B),
  .WRADDR(OB_WR_ADDR),
  .RDADDR(OB_RD_ADDR),
  .WRDATA(OB_WR_DATA),
  .RDDATA(OB_RD_DATA_B));

//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    oddline_dly2 <= 1'b0;
    oddline_dly1 <= 1'b0;
  end
  else  begin
    oddline_dly2 <= oddline_dly1;
    oddline_dly1 <= ODDLINE;
  end
end

assign ODDLINE = VgaLineCount[1] ;
//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    vga_RGB <= {16{1'b0}};
  end
  else  begin
    if ((oddline_dly2 == 1'b1)  )  begin
      vga_RGB <= OB_RD_DATA_A;
    end
    else  begin
      vga_RGB <= OB_RD_DATA_B;
    end
  end
end

//----------------------------------------------------------------- -- switch y and uv 2012/08/28
assign OB_WR_N_A_sig = ((ViewMode == 4'b0110 && PIXWR == 1'b1)   || (ViewMode != 4'b0110 && oddline_dly2 == 1'b0 && (winp0 == 1'b1 || winp1 == 1'b1 || winp2 == 1'b1 || winp3 == 1'b1)   && PIXRD == 1'b0 && LBRDY_sig == 1'b0)  )? 1'b0 : 1'b1;
assign OB_WR_N_B_sig = ((ViewMode == 4'b0110 && PIXWR == 1'b1)   || (ViewMode != 4'b0110 && oddline_dly2 == 1'b1 && (winp0 == 1'b1 || winp1 == 1'b1 || winp2 == 1'b1 || winp3 == 1'b1)   && PIXRD == 1'b0 && LBRDY_sig == 1'b0)  )? 1'b0 : 1'b1;
assign OB_WR_DATA_sig = (ViewMode == 4'b0110)? PIX2LOGIC[15:0]  : (winp0 == 1'b1)? latch0[15:0]  : (winp1 == 1'b1)? latch1[15:0]  : (winp2 == 1'b1)? latch2[15:0]  : latch3[15:0] ;
//-----------------------------------------------------------------
assign ls2b = (winp0 == 1'b1)? 2'b00 : (winp1 == 1'b1)? 2'b01 : (winp2 == 1'b1)? 2'b10 : 2'b11;
//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    LB_ADDR <= {10{1'b0}};
  end
  else  begin
    LB_ADDR <= VgaPixCount[9:0]  + 20;
  end
end

//------------------------------------------------------------ 
assign OB_WR_ADDR_sig = (ViewMode == 4'b0110)? pixstb_count_plus : {LB_ADDR[9:2] ,ls2b};
assign OB_RD_ADDR_sig = (PIXRD == 1'b1 && ViewMode == 4'b0101)? pixstb_count_plus : LB_ADDR;
assign OB_CS_N = 1'b0;
assign vga_r = {vga_RGB[15:11] ,3'b000};
assign vga_g = {vga_RGB[10:5] ,2'b00};
assign vga_b = {vga_RGB[4:0] ,3'b000};
//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    OB_RD_ADDR <= {10{1'b0}};
    OB_WR_ADDR <= {10{1'b0}};
    OB_WR_DATA <= {16{1'b0}};
    OB_WR_N_A <= 1'b0;
    OB_WR_N_B <= 1'b0;
  end
  else  begin
    OB_RD_ADDR <= OB_RD_ADDR_sig;
    OB_WR_ADDR <= OB_WR_ADDR_sig;
    OB_WR_DATA <= OB_WR_DATA_sig;
    OB_WR_N_A <= OB_WR_N_A_sig;
    OB_WR_N_B <= OB_WR_N_B_sig;
  end
end

//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    vga_RGB_latch0 <= {16{1'b0}};
  end
  else  begin
    if ((OB_RD_ADDR[1:0]  == 0)  )  begin
      vga_RGB_latch0 <= vga_RGB;
    end
  end
end

//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    vga_RGB_latch1 <= {16{1'b0}};
  end
  else  begin
    if ((OB_RD_ADDR[1:0]  == 1)  )  begin
      vga_RGB_latch1 <= vga_RGB;
    end
  end
end

//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    vga_RGB_latch2 <= {16{1'b0}};
  end
  else  begin
    if ((OB_RD_ADDR[1:0]  == 2)  )  begin
      vga_RGB_latch2 <= vga_RGB;
    end
  end
end

//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    vga_RGB_latch3 <= {16{1'b0}};
  end
  else  begin
    if ((OB_RD_ADDR[1:0]  == 3)  )  begin
      vga_RGB_latch3 <= vga_RGB;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    PIXRD_dly2 <= 1'b0;
    PIXRD_dly1 <= 1'b0;
  end
  else  begin
    PIXRD_dly2 <= PIXRD_dly1;
    PIXRD_dly1 <= PIXRD;
  end
end

assign PIXRD_EDGE = (PIXRD_dly1 == 1'b0 && PIXRD_dly2 == 1'b1)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    PIXWR_dly2 <= 1'b0;
    PIXWR_dly1 <= 1'b0;
  end
  else  begin
    PIXWR_dly2 <= PIXWR_dly1;
    PIXWR_dly1 <= PIXWR;
  end
end

assign PIXWR_EDGE = (PIXWR_dly1 == 1'b0 && PIXWR_dly2 == 1'b1)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    PIXSTB_dly2 <= 1'b0;
    PIXSTB_dly1 <= 1'b0;
  end
  else  begin
    PIXSTB_dly2 <= PIXSTB_dly1;
    PIXSTB_dly1 <= PIXSTB;
  end
end

assign PIXSTB_EDGE = (PIXSTB_dly1 == 1'b1 && PIXSTB_dly2 == 1'b0)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    WaitLine <= {3{1'b0}};
  end
  else  begin
    if ((PIXWR_EDGE == 1'b1 || PIXRD_EDGE == 1'b1)  )  begin
      WaitLine <= {3{1'b0}};
    end
    else if ((CamHsync_EDGE == 1'b1)  )  begin
      if ((WaitLine != 3)  )  begin
        // 2012/11/15
        WaitLine <= WaitLine + 1;
      end
    end
  end
end

assign LBRDY_sig = (!(WaitLine == 1 || WaitLine == 2)   && (ViewMode == 4'b0101 || ViewMode == 4'b0110)  )? 1'b1 : 1'b0;
// 2012/11/15
assign LBRDY = LBRDY_sig;
//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    pixstb_count <= {10{1'b0}};
  end
  else  begin
    if(PIXRD_EDGE == 1'b1 || PIXWR_EDGE == 1'b1) begin 
      pixstb_count <= {10{1'b0}};
    end
    else if(PIXSTB_EDGE == 1'b1) begin
      pixstb_count <= pixstb_count + 1;
    end
  end
end

  assign PIXSTBCO = pixstb_count;
  
//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    pixstb_count_plus <= {10{1'b0}};
  end
  else  begin
    pixstb_count_plus <= pixstb_count + 96;
  end
end

//------------------------------------------------------------ 
assign PIX2NIOS = vga_RGB;
//assign PIX2NIOS = {6'h00, OB_RD_ADDR_sig};

//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    ViewMode_dly2 <= {4{1'b0}};
    ViewMode_dly1 <= {4{1'b0}};
  end
  else  begin
    ViewMode_dly2 <= ViewMode_dly1;
    ViewMode_dly1 <= ViewMode;
  end
end

//------------------------------------------------------------ 
assign ViewMode5_EDGE = (ViewMode_dly1 == 4'b0101 && ViewMode_dly2 != 4'b0101)? 1'b1 : 1'b0;
assign ViewMode6_EDGE = (ViewMode_dly1 == 4'b0110 && ViewMode_dly2 != 4'b0110)? 1'b1 : 1'b0;
//------------------------------------------------------------ 
always@(posedge CLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    SdrwLineCount_sig <= {9{1'b0}};
  end
  else  begin
    if (ViewMode5_EDGE == 1'b1 || ViewMode6_EDGE == 1'b1) begin
      SdrwLineCount_sig <= {9{1'b0}};
    end
    else if ((PIXRD_EDGE == 1'b1 && ViewMode == 4'b0101) || (PIXWR_EDGE == 1'b1 && ViewMode == 4'b0110)) begin
        SdrwLineCount_sig <= SdrwLineCount_sig + 1;
    end
  end
end

assign SdrwLineCount = SdrwLineCount_sig;

endmodule
