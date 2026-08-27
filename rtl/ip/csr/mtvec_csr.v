///////////////////////////////////////////////////
//mtvec csr - holds trap vector configuration
//read write register 
///////////////////////////////////////////////////

module mtvec_csr
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
output [DATA_WIDTH-1:0] 	mtvec_o 	,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input           debug_mode_valid_i      
);

localparam INT_BASE_ADDR = 32'h0000_C000;
localparam INT_MODE = 2'b01;
localparam MTVEC = 12'b0011_0000_0101;//305
wire wr_addr_valid;
assign wr_addr_valid = (csr_write_addr == MTVEC) ? 1'b1 : 1'b0;

wire [1:0] mode;
assign mode = INT_MODE;



reg [DATA_WIDTH-1:0] mtvec_r ;

assign mtvec_o = {mtvec_r[DATA_WIDTH-1:2],mode};

always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
	begin
		mtvec_r <= INT_BASE_ADDR;//{{DATA_WIDTH-16{1'b0}},16'd32768};//32768 16'h8000
	end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
       		mtvec_r <= {{DATA_WIDTH-16{1'b0}},16'd32768};
    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MTVEC) )
        begin
                mtvec_r <= dbg_csr_write_data_i;
        end
		else if(csr_write_enable && wr_addr_valid)
		begin
			case({csr_clear_bit,csr_set_bit})
			    2'b00://complete write
				begin
					mtvec_r <= {csr_write_data[DATA_WIDTH-1:0]};
				end
				2'b01://set
				begin
					mtvec_r <= (mtvec_r | csr_write_data) ;
				end
				2'b10://clear
				begin
					mtvec_r <= (mtvec_r & (~csr_write_data));
				end
                default : begin
                    mtvec_r <= mtvec_r;
                end
            endcase
		end

	end
end
endmodule

