///////////////////////////////////////////////////////
//indicates the id of the hardware thread running
//hart id must be unique
//atleast one hart must have id zero
//////////////////////////////////////////////////////////

module mhartid_csr
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
output reg [DATA_WIDTH-1:0] mhart_id_o 
);

localparam HARTID = 0 ;

always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst)
	begin
		mhart_id_o <= HARTID;
	end
    else
	begin
		mhart_id_o <= HARTID;
	end
end
endmodule

