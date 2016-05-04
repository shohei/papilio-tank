module VGA_CTRL (
	CLK,
	RST_N,
	CamHsync_EDGE,
	CamVsync_EDGE,
	VgaLineCount,
	VgaPixCount,
	VgaVisible,
	VgaVsync,
	VgaHsync,
	VgaHsync_EDGE,
	OddFrame
); 

input		CLK, RST_N;
input CamHsync_EDGE, CamVsync_EDGE;
output	[8:0] VgaLineCount;
output	[9:0] VgaPixCount;
output	VgaVisible, VgaVsync,	VgaHsync, VgaHsync_EDGE, OddFrame;

reg VgaPixCount_enb;
reg [9:0] VgaPixCount_sig;
reg [8:0] VgaLineCount_sig;
reg VgaVisible_sig;
reg VgaFrameCount;
wire VgaHsync_sig, VgaVsync_sig;
reg VgaHsync_tmp, VgaVsync_tmp;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		VgaPixCount_enb  <= 0;
	end else begin
		VgaPixCount_enb <= !VgaPixCount_enb;
	end
end

///////////////////////////////////////////////////////
assign VgaPixCount_clr = (VgaPixCount_enb == 1'b1 && VgaPixCount_sig == 783)
                      || CamHsync_EDGE == 1'b1 ? 1 : 0; 

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		VgaPixCount_sig <= 0;
	end else begin
		if(VgaPixCount_clr == 1'b1) begin
			VgaPixCount_sig <= 0;
		end else if( VgaPixCount_enb == 1'b1 ) begin
			VgaPixCount_sig <= VgaPixCount_sig + 1;
		end
	end
end

assign VgaPixCount = VgaPixCount_sig;

assign VgaLineCount_enb = (VgaPixCount_sig == 783 && VgaPixCount_enb == 1'b1) ? 1 : 0;
assign VgaLineCount_clr = (VgaPixCount_clr == 1'b1 && VgaLineCount_sig == 509) ? 1 : 0;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		VgaLineCount_sig  <= 0;
	end else begin
		if(VgaLineCount_clr == 1'b1 || CamVsync_EDGE == 1'b1) begin
			VgaLineCount_sig  <= 0;
		end else if(VgaLineCount_enb == 1'b1) begin 
			VgaLineCount_sig  <= VgaLineCount_sig  + 1;
		end
	end
end

assign VgaLineCount = VgaLineCount_sig;

assign VgaVisible_H = (VgaPixCount_sig >= 134 && VgaPixCount_sig < 776) ? 1 : 0;  
assign VgaHsync_sig = (VgaPixCount_sig >= 96) ? 1 : 0; 
assign VgaHsync_EDGE = (VgaPixCount_sig == 96) ? 1 : 0;

assign VgaVisible_V = (VgaLineCount_sig >= 1 && VgaLineCount_sig < 480) ? 1 : 0;
assign VgaVsync_sig = (VgaLineCount_sig >= 484 && VgaLineCount_sig <= 485) ? 0 : 1;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		VgaVisible_sig <= 0;
	end else begin
		if(VgaPixCount_enb == 1'b1) begin
			VgaVisible_sig <= VgaVisible_V & VgaVisible_H;
		end
	end
end

assign VgaVisible = VgaVisible_sig;

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N or posedge CamVsync_EDGE )
begin
	if (RST_N == 1'b0 || CamVsync_EDGE == 1'b1) begin
		VgaFrameCount <= 0;
	end else begin
		if(VgaPixCount_enb == 1'b1 && VgaLineCount_enb == 1'b1 && VgaLineCount_sig == 1) begin
			VgaFrameCount <= !VgaFrameCount;
		end
	end
end

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		VgaHsync_tmp <= 0;
	end else begin
		if(VgaPixCount_enb == 1'b1) begin
			VgaHsync_tmp <= VgaHsync_sig;
		end
	end
end

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
		VgaVsync_tmp <= 0;
	end else begin
		if(VgaPixCount_enb == 1'b1) begin
			VgaVsync_tmp <= VgaVsync_sig;
		end
	end
end

assign VgaHsync = VgaHsync_tmp;
assign VgaVsync = VgaVsync_tmp;
assign OddFrame = !VgaFrameCount;

endmodule