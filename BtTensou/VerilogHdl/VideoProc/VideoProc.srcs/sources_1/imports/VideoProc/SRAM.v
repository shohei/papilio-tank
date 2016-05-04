module SRAM (
	CLK,
  CS_N,
  WR_N,
  WRADDR,
  RDADDR,
  WRDATA,
  RDDATA
); 

input	CLK;
input CS_N, WR_N;
input [9:0] WRADDR;
input [9:0] RDADDR;
input [15:0] WRDATA;
output [15:0] RDDATA;

reg [15:0] RAMDATA [0:1024];
reg [15:0] RDDATA_sig;

///////////////////////////////////////////////////////
// sram write
always @(posedge CLK)
begin
	if(CS_N == 0 && WR_N == 0) begin
  		RAMDATA[WRADDR] <= WRDATA;
	end
end

///////////////////////////////////////////////////////
// sram read
always @(posedge CLK)
begin
  if(CS_N == 0 && WR_N == 1) begin
    	RDDATA_sig <= RAMDATA[RDADDR];
  end
end

assign RDDATA = RDDATA_sig;

endmodule