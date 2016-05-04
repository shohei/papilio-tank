module LINEIN_CTRL (
	CLK,
	RST_N,
	LB_WR_ADDR,
	LB_WR_DATA,
	LB_WR_N,
	VgaLineCount,
	VgaPixCount,
	buf_RGB
); 

input		CLK, RST_N;
input	[9:0] LB_WR_ADDR;
input	[15:0] LB_WR_DATA;
input LB_WR_N;
input [8:0] VgaLineCount;
input [9:0] VgaPixCount;
output [15:0] buf_RGB;

wire ODDLINE;
reg oddline_dly1, oddline_dly2;
reg [9:0] LB_RD_ADDR;
wire [15:0] LB_RD_DATA_A;
wire [15:0] LB_RD_DATA_B;
wire LB_WR_N_B;
wire LB_WR_N_A;
wire LB_CS_N;
reg [15:0] buf_RGB;

SRAM SRAM_A (
  .CLK(CLK),
  .CS_N(LB_CS_N),
  .WR_N(LB_WR_N_A),
  .WRADDR(LB_WR_ADDR),
  .RDADDR(LB_RD_ADDR),
  .WRDATA(LB_WR_DATA),
  .RDDATA(LB_RD_DATA_A)
); 

SRAM SRAM_B (
  .CLK(CLK),
  .CS_N(LB_CS_N),
  .WR_N(LB_WR_N_B),
  .WRADDR(LB_WR_ADDR),
  .RDADDR(LB_RD_ADDR),
  .WRDATA(LB_WR_DATA),
  .RDDATA(LB_RD_DATA_B)
); 

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     oddline_dly2 <= 0;
     oddline_dly1 <= 0;
	end else begin
     oddline_dly2 <= oddline_dly1;
     oddline_dly1 <= ODDLINE;
	end
end

assign ODDLINE = VgaLineCount[1];

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     buf_RGB <= 0;
	end else begin
    if(oddline_dly2 == 0) begin
      buf_RGB <= LB_RD_DATA_B;
    end else begin 
      buf_RGB <= LB_RD_DATA_A;
    end    
	end
end

///////////////////////////////////////////////////////
always @(posedge CLK or negedge RST_N)
begin
	if (RST_N == 1'b0) begin
     LB_RD_ADDR <= 0;
	end else begin
     LB_RD_ADDR <= VgaPixCount[9:0] + 20;
	end
end

assign LB_WR_N_A = (oddline_dly2 == 0) ? LB_WR_N : 1; 
assign LB_WR_N_B = (oddline_dly2 == 1) ? LB_WR_N : 1; 
assign LB_CS_N = 0;

endmodule