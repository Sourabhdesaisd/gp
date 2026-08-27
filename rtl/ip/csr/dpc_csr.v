module dpc_csr
#(
parameter CSR_ADDR_WIDTH    = 12,
parameter DATA_WIDTH        = 32,
parameter PC_WIDTH          = 32
)

(
input 			            csr_clk			,
input 			            csr_rst			,
input [PC_WIDTH-1:0]		csr_dpc_in		,
input 			            csr_dpc_write_valid	,
input                       dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]  dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]      dbg_csr_write_data_i    ,
input                       debug_mode_valid_i      ,
//output reg [DATA_WIDTH-1:0] dpc_csr_o   	,
output  [PC_WIDTH-1:0]		csr_dpc_o			
 
);

localparam dpc = 12'h7B1;
reg [31:0] dpc_csr_o;
	always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
	    begin
			dpc_csr_o <= {DATA_WIDTH{1'b0}};
		end
        else if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == dpc) )
        begin
            dpc_csr_o <= {dbg_csr_write_data_i[31:2], 2'b00};
        end
	    else if(csr_dpc_write_valid)
		begin
			dpc_csr_o <= {csr_dpc_in[31:2], 2'b00};
		end
	end
    
assign csr_dpc_o = dpc_csr_o;
endmodule

