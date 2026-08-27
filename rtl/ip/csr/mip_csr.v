//////////////////////////////////////////
//machine interrupt pending csr
////////////////////////////////////////////


module mip_csr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input 			csr_clk		,
input 			csr_rst		,
//input wdt_reset_i,
input [DATA_WIDTH-1:0] 		csr_write_data	,
input 	     		csr_write_enable,
input [CSR_ADDR_WIDTH-1:0] 		csr_write_addr	,
input 			csr_set_bit	,
input 			csr_clear_bit	,
output  [DATA_WIDTH-1:0] 	mip_o 	,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input           debug_mode_valid_i      

);

localparam MIP_DEFAULT = 32'h0000_03FF;
localparam MTVEC = 12'b0011_0100_0100;//344
wire wr_addr_valid;
assign wr_addr_valid = (csr_write_addr == MTVEC) ? 1'b1 : 1'b0;
reg [DATA_WIDTH-1:0] mip_r;

assign mip_o = {{DATA_WIDTH-12{1'b0}},mip_r[11],3'd0,mip_r[7],3'd0,mip_r[3],3'd0};

always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst )
	begin
		mip_r <= MIP_DEFAULT;
	end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        	mip_r <= {DATA_WIDTH{1'b0}};
    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MTVEC) )
        begin
                mip_r <= dbg_csr_write_data_i;
        end
		else if(csr_write_enable && wr_addr_valid)
		begin
			case({csr_clear_bit,csr_set_bit})
				2'b00://complete write
				begin
					mip_r <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					mip_r <= (mip_r | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					mip_r <= (mip_r & (~csr_write_data));
				end
                default: begin
                    mip_r <= mip_r;
                end
			endcase
		end

	end
end
endmodule

