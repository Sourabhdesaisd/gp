////////////////////////////////////////////////////////////////////
//machine level core implementation id
//this is fixed by the provider of architectural source code
//it is a read only csr
//zero value indicates that this csr is not implemented
//this register should be written MSB to LSB 
////////////////////////////////////////////////////////////////////
module mimpid_csr
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
output reg [DATA_WIDTH-1:0] mimp_id_o 
);

localparam MIMPID = 0 ;

always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst)
	begin
		mimp_id_o <= MIMPID;
	end
    else begin
		mimp_id_o <= MIMPID;
	end
end
endmodule

