////////////////////////////////////////////////////////////////
//indicates the machine architecture id
//zero indicates this csr is not implemented
//for open cores architecture id is fixed by RISCV org
//for commercial cores arch id is defined by respective vendors
////////////////////////////////////////////////////////////////
module marchid_csr
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
output reg [DATA_WIDTH-1:0] march_id_o 
);

localparam ARCHID = 0 ;

always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst)
	begin
		march_id_o <= ARCHID;
	end
    else begin
		march_id_o <= ARCHID;
	end

end
endmodule

