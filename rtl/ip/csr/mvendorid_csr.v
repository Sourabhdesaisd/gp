///////////////////////////////////////////////////////////////////////
//machine vendor id csr
//32 bit read onlt register
//value zero indicates that this CSR is not implemented or the core is
//non-commercial 
///////////////////////////////////////////////////////////////////////

module mvendorid_csr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input csr_clk,
input csr_rst,
//input wdt_reset_i,
output reg [DATA_WIDTH-1:0] mvendor_id_o 
);

localparam VID = 0 ;

always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst)
	begin
		mvendor_id_o <= VID;
	end
end
endmodule

