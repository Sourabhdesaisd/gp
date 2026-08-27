//machine exception program counter
//it stores the PC value of a instruction which is being interrupted of
//encountered an exception
//software can also access and write 
//


module mepc_csr
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
input [DATA_WIDTH-1:0] 		csr_write_data		,
input 			csr_write_en		,
input [CSR_ADDR_WIDTH-1:0] 		csr_write_addr		,
//input 			int_exp_valid		,
//input 			instr_misalign_valid 	,
//input [PC_WIDTH-1:0] 		pc			,
input [PC_WIDTH-1:0]		csr_mepc_in		,
input 			csr_mepc_write_valid	,
input           csr_clear_bit,
input           csr_set_bit,
output  [PC_WIDTH-1:0]		csr_mepc_o		,	
output reg [DATA_WIDTH-1:0] 	mepc_csr_o   	,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,          
input           debug_mode_valid_i      
   
);

localparam MEPC = 12'b0011_0100_0001;//341

//wire wr_addr_valid;
//	assign wr_addr_valid = ((csr_write_addr == MEPC) || (int_exp_valid | csr_mepc_write_valid )) ? 1'b1 : 1'b0;

/*always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst)
	begin
		mepc_csr_o <= {DATA_WIDTH{1'b0}};
	end
	else
	begin
	if(wr_addr_valid)
		begin
		if(csr_mepc_write_valid && (!instr_misalign_valid))
		begin
			mepc_csr_o <= {44'd0,csr_mepc_in};
		end
		else if(csr_write_en && (csr_write_addr == MEPC) )
		begin
			mepc_csr_o <= csr_write_data;
		end
	end

	end
end*/
	always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
				begin
					mepc_csr_o <= {DATA_WIDTH{1'b0}};
				end
                /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
                begin
                    mepc_csr_o <= {DATA_WIDTH{1'b0}};
                end*/
				else
				begin
                    if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MEPC) )
                    begin
                        mepc_csr_o <= {dbg_csr_write_data_i[31:2], 2'b00};
                    end
		            else if(csr_mepc_write_valid /*& (!instr_misalign_valid)*/)
						begin
							mepc_csr_o <= {csr_mepc_in[31:2], 2'b00};
						end
					else if(csr_write_en && (csr_write_addr == MEPC) )
						begin
							//mepc_csr_o <= {csr_write_data[31:2], 2'b00};
                          case({csr_clear_bit,csr_set_bit})
				            2'b00://complete write
				            begin
				            	mepc_csr_o <= {csr_write_data[31:2], 2'b00};
				            end
				            2'b01://clear specified bits
				            begin
				            	mepc_csr_o <= {(mepc_csr_o[31:2] | csr_write_data[31:2]), 2'b00};
				            end
				            2'b10://set specified bits
				            begin
				            	mepc_csr_o <= {(mepc_csr_o[31:2] & (~csr_write_data[31:2])), 2'b00};
				            end
                            default : begin
                                mepc_csr_o <= {mepc_csr_o[31:2], 2'b00};
                            end
                          endcase

						end
				end
		end
assign csr_mepc_o = mepc_csr_o;
endmodule

