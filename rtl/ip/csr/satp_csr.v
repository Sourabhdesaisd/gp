////////////////////////////////////////////////////////////////
//                                                            //
//    Supervisor Address Translation and Protection (satp)    //
//                                                            //
////////////////////////////////////////////////////////////////

module satp_csr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input 			csr_clk		,
input 			csr_rst		,
//input       wdt_reset_i,
input [DATA_WIDTH-1:0] 		csr_write_data	,
input 	     		csr_write_enable,
input [CSR_ADDR_WIDTH-1:0] 		csr_write_addr	,
input 			csr_set_bit	,
input 			csr_clear_bit	,
output  [DATA_WIDTH-1:0] 	satp_o 	,
output        	satp_mode_o 	,
output  [8:0] 	satp_asid_o 	,
output  [21:0] 	satp_ppn_o 	,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input           debug_mode_valid_i      

);
localparam SATP = 12'b0001_1000_0000;//180
wire wr_addr_valid;

assign wr_addr_valid = (csr_write_addr == SATP) ? 1'b1 : 1'b0;

reg [DATA_WIDTH-1:0] satp_r;

assign satp_o = satp_r;
assign satp_mode_o = satp_r[31];
assign satp_asid_o = satp_r[30:22];
assign satp_ppn_o = satp_r[21:0];

always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst )
	begin
		satp_r <= {DATA_WIDTH{1'b0}};
	end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        	satp_r <= {DATA_WIDTH{1'b0}};
    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == SATP) )
        begin
                satp_r <= dbg_csr_write_data_i;
        end
		else if(csr_write_enable && wr_addr_valid)
		begin
			case({csr_clear_bit,csr_set_bit})
				2'b00://complete write
				begin
					satp_r <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					satp_r <= (satp_r | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					satp_r <= (satp_r & (~csr_write_data));
				end
                default : begin
                    satp_r <= satp_r;
                end
			endcase
		end

	end
end
endmodule

