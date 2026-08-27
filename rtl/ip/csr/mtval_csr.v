///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//when a trap is taken into M-Mode, this csr will be set to zero or written
//with exception specific value
//breakpoint is triggered, or an instruction-fetch, load, or store address-misaligned, access, or page-fault exception occurs, mtval is written with the faulting virtual address.
//On an illegal instruction trap, mtval may be written with the first XLEN or ILEN bits of the faulting instruction as described below.
//For other traps, mtval is set to zero
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module mtval_csr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input 			csr_clk			,
input 			csr_rst			,
//input wdt_reset_i,
input [DATA_WIDTH-1:0]		csr_write_data		,
input 			csr_write_en		,
input [CSR_ADDR_WIDTH-1:0]		csr_write_addr		,
input           csr_set_bit,
input		    csr_clear_bit,

//input 			ld_sd_misalign_valid	,
//input [DATA_WIDTH-1:0] 		ld_sd_misalign_addr	,
//input 			instr_misalign_valid	,
//input [DATA_WIDTH-1:0] 		instr_misalign_addr	,
//input 			illegal_instr_valid	,
//input [INSTRUCTION_WIDTH-1:0] 		illegal_instruction 	,	
//input			trap_valid		,//exceptions
output reg [DATA_WIDTH-1:0] 	mtval_o   ,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input  [31:0]      mtval_i                      ,
input              mtval_write_valid            , 
input           debug_mode_valid_i      


);

localparam MTVAL = 12'b0011_0100_0011;//343

wire wr_addr_valid;
assign wr_addr_valid = ((csr_write_addr == MTVAL) && csr_write_en) ? 1'b1 : 1'b0;

always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
	begin
		mtval_o <= {DATA_WIDTH{1'b0}};
	end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        mtval_o <= {DATA_WIDTH{1'b0}};
    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MTVAL) )
        begin
                mtval_o <= dbg_csr_write_data_i;
        end
		/*else if(trap_valid)
		begin
		if(ld_sd_misalign_valid)
		begin
			mtval_o <= ld_sd_misalign_addr;
		end
		else if(instr_misalign_valid)
		begin
			mtval_o <= instr_misalign_addr;
		end
		else if(illegal_instr_valid)
		begin
			mtval_o <= illegal_instruction;//pc
		end
		else
		begin
			mtval_o <= {DATA_WIDTH{1'b0}};
		end
		end*/
        else if(mtval_write_valid)
		begin
			mtval_o <= mtval_i;
		end
		else if(wr_addr_valid)
		begin
			//mtval_o <= csr_write_data;
          	case({csr_clear_bit,csr_set_bit})

				2'b00://complete write
				begin
					mtval_o <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					mtval_o <= (mtval_o | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					mtval_o <= (mtval_o & (~csr_write_data));
				end
                default : begin
                    mtval_o <= mtval_o;
                end
			endcase

		end

	end
end

endmodule

