/////////////////////////////////////////////////////
//mstatus csr
//read write register
//global interrupt enable bits - MIE, SIE, UIE
////////////////////////////////////////////////////


module mstatus_csr
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
input			mie_set		,//interrupt occurs
input 			mie_clear	,//end of interrupt
output  [DATA_WIDTH-1:0] 		mstatus_o 	,
output			mstatus_mie_o		,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input           debug_mode_valid_i      

);
localparam MSTATUS = 12'b0011_0000_0000;
wire wr_addr_valid;
assign wr_addr_valid = (csr_write_addr == MSTATUS) ? 1'b1 : 1'b0;
reg [DATA_WIDTH-1:0] mstatus_r;

assign mstatus_o = {{DATA_WIDTH-13{1'b0}},2'b11,3'd0,mstatus_r[7],3'd0,mstatus_r[3],3'd0};
always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
	begin
		mstatus_r <= {DATA_WIDTH{1'b0}};
	end
   /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        		mstatus_r <= {DATA_WIDTH{1'b0}};

    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MSTATUS) )
        begin
                mstatus_r <= dbg_csr_write_data_i;
        end
		else if(csr_write_enable && wr_addr_valid)
		begin
			case({csr_clear_bit,csr_set_bit})
				2'b00://complete write
				begin
					mstatus_r <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					mstatus_r <= (mstatus_r | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					mstatus_r <= (mstatus_r & (~csr_write_data));
				end
                default : begin
                    mstatus_r <= mstatus_r;
                end
			endcase
		end
		else if(mie_set)
			begin
	//	mstatus_r[7] <= mstatus_r[3];
                mstatus_r[3] <= 1'b1;
			end
		else if(mie_clear)
			begin
			//	mstatus_r[3] <= mstatus_r[7];
              mstatus_r[3] <= 1'b0;
			end

	end
end
assign mstatus_mie_o = mstatus_r[3];
endmodule

