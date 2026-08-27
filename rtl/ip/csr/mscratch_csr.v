//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//mscratch csr
//read write register
//it is used to hold a pointer to a machine-mode hart-local context space and swapped with a user register upon entry to an M-mode trap handler.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module mscratch_csr
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
output reg [DATA_WIDTH-1:0] 	mscratch_o 	,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input           debug_mode_valid_i      

);
localparam MSCRATCH = 12'b0011_0100_0000;//340
wire wr_addr_valid;


assign wr_addr_valid = (csr_write_addr == MSCRATCH) ? 1'b1 : 1'b0;

always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )	
    begin
		mscratch_o <= {DATA_WIDTH{1'b0}};
	end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        		mscratch_o <= {DATA_WIDTH{1'b0}};

    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MSCRATCH) )
        begin
                mscratch_o <= dbg_csr_write_data_i;
        end
		else if(csr_write_enable && wr_addr_valid)
		begin
			case({csr_clear_bit,csr_set_bit})
				2'b00://complete write
				begin
					mscratch_o <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					mscratch_o <= (mscratch_o | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					mscratch_o <= (mscratch_o & (~csr_write_data));
				end
                default : begin
                    mscratch_o <= mscratch_o;
                end
endcase
		end

	end
end
endmodule

