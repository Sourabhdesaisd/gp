/////////////////////////////////////////////
//machine interrupt enable csr
/////////////////////////////////////////////

module mie_csr
#(
parameter CSR_ADDR_WIDTH    = 12,
parameter DATA_WIDTH        = 32,
parameter INSTRUCTION_WIDTH = 32,
parameter PC_WIDTH          = 32
)

(
input 			csr_clk		,
input 			csr_rst		,
input [DATA_WIDTH-1:0] 		csr_write_data	,
input 	     		csr_write_enable,
input [CSR_ADDR_WIDTH-1:0] 		csr_write_addr	,
input 			csr_set_bit	,
input 			csr_clear_bit	,
output [DATA_WIDTH-1:0] 	mie_o 	,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,         
input           debug_mode_valid_i      
);

localparam MIE_DEFAULT = 32'h03FF_0000;
localparam MIE = 12'b0011_0000_0100;//304
wire wr_addr_valid;
	assign wr_addr_valid = (csr_write_addr == MIE) ? 1'b1 : 1'b0;

reg [DATA_WIDTH-1:0] mie_r;

assign mie_o = {mie_r[31:26],10'b1111111111,4'd0,1'b1,11'd0};
always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
	begin
		mie_r <= MIE_DEFAULT;
	end
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MIE) )
        begin
                mie_r <= dbg_csr_write_data_i;
        end
		else if(csr_write_enable && wr_addr_valid)
		begin
			case({csr_clear_bit,csr_set_bit})

				2'b00://complete write
				begin
					mie_r <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					mie_r <= (mie_r | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					mie_r <= (mie_r & (~csr_write_data));
				end
                default : begin
                    mie_r <= mie_r;
                end
endcase
		end

	end
end
endmodule

