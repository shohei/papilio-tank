module CAM_CTRL (
	CLK,
	RST_N,
	PCLK,
	CamHsync,
	CamVsync,
	CamData,
	LB_WR_ADDR,
	LB_WR_DATA,
	LB_WR_N,
	CamHsync_EDGE,
	CamVsync_EDGE,
	CamLineCount,
	CamPixCount4x
); 

input		CLK, RST_N;
output	[8:0] CamLineCount;
output	[15:0] CamPixCount4x;
output	[9:0] LB_WR_ADDR;
output	[15:0] LB_WR_DATA;
output LB_WR_N;
input CamHsync, CamVsync;
input [7:0] CamData;
input PCLK;
output CamHsync_EDGE, CamVsync_EDGE;

reg [15:0] CamPixCount4x_sig;
reg [10:0] PclkPixCount;
reg CamHsync_dly1, CamHsync_dly2;
wire CamHsync_edge_sig; 
reg CamVsync_dly1, CamVsync_dly2;
wire CamVsync_edge_sig; 
wire Rg_dec, gB_dec;
reg Rg_dec_dly1, Rg_dec_dly2;
reg [7:0] Rg_latch, gB_latch;
reg [9:0] PclkPixCount_dly1, PclkPixCount_dly2;
reg [8:0] CamLineCount_sig;


///////////////////////////////////////////////////////
always @(posedge PCLK or negedge RST_N or posedge CamHsync_edge_sig)
begin
	if (RST_N == 1'b0 || CamHsync_edge_sig == 1'b1) begin
		PclkPixCount <= 0;
	end else begin
	  PclkPixCount <= PclkPixCount + 1;
	end
end

///////////////////////////////////////////////////////
assign Rg_dec = !PclkPixCount[0];
assign gB_dec = PclkPixCount[0];

///////////////////////////////////////////////////////
always @(posedge PCLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     Rg_latch <= 0;
	end else begin
	   if(Rg_dec == 1'b1) begin
       Rg_latch <= CamData;
     end
	end
end

///////////////////////////////////////////////////////
always @(posedge PCLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     gB_latch <= 0;
	end else begin
	   if(gB_dec == 1'b1) begin
       gB_latch <= CamData;
     end
	end
end

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     CamPixCount4x_sig <= 0;
	end else begin
	   if(CamPixCount4x_sig == 3135 || CamHsync_edge_sig == 1'b1) begin
       CamPixCount4x_sig <= 0;
     end else begin
       CamPixCount4x_sig <= CamPixCount4x_sig + 1;
     end
	end
end

assign CamPixCount4x = CamPixCount4x_sig;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     Rg_dec_dly2 <= 0;
     Rg_dec_dly1 <= 0;
	end else begin
     Rg_dec_dly2 <= Rg_dec_dly1;
     Rg_dec_dly1 <= Rg_dec;
	end
end

///////////////////////////////////////////////////////
always @(posedge PCLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     PclkPixCount_dly2 <= 0;
     PclkPixCount_dly1 <= 0;
	end else begin
     PclkPixCount_dly2 <= PclkPixCount_dly1;
     PclkPixCount_dly1 <= PclkPixCount[10:1];
	end
end

///////////////////////////////////////////////////////
assign LB_WR_N = (Rg_dec_dly1 == 1'b1 && Rg_dec_dly2 == 1'b0) ? 1'b0 : 1'b1;
assign LB_WR_DATA = {Rg_latch, gB_latch};
assign LB_WR_ADDR = PclkPixCount_dly2;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     CamHsync_dly2 <= 0;
     CamHsync_dly1 <= 0;
	end else begin
     CamHsync_dly2 <= CamHsync_dly1;
     CamHsync_dly1 <= CamHsync;
	end
end

///////////////////////////////////////////////////////
assign  CamHsync_edge_sig = (CamHsync_dly1 == 1'b0 && CamHsync_dly2 == 1'b1) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     CamVsync_dly2 <= 0;
     CamVsync_dly1 <= 0;
	end else begin
     CamVsync_dly2 <= CamVsync_dly1;
     CamVsync_dly1 <= CamVsync;
	end
end

///////////////////////////////////////////////////////
assign CamVsync_edge_sig = (CamVsync_dly1 == 1'b0 && CamVsync_dly2 == 1'b1) ? 1'b1 : 1'b0;
assign CamVsync_EDGE = CamVsync_edge_sig;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     CamLineCount_sig <= 0;
	end else begin
	   if(CamVsync_edge_sig == 1'b1) begin
       CamLineCount_sig <= 0;
     end else if( CamHsync_edge_sig == 1'b1) begin
       CamLineCount_sig <= CamLineCount_sig + 1;
     end
	end
end

///////////////////////////////////////////////////////
assign CamLineCount = CamLineCount_sig;
assign CamHsync_EDGE = CamHsync_edge_sig;

endmodule