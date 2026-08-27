//////////////////////////////////////////////////////////////////////////////////
//mcause register
//Stores info regarding interrupt and exception
//exclusive excpetion/interrupt code and interrupt bits for each interrupt and
//exception

//machine exception program counter
//it stores the PC value of a instruction which is being interrupted of
//encountered an exception
//software can also access and write 
///////////////////////////////////////////////////////////////////////////////////

module mcause_csr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input csr_clk		,
input csr_rst		,
//input wdt_reset_i,
input [DATA_WIDTH-1:0] csr_write_data	,
input csr_write_en	,
input [CSR_ADDR_WIDTH-1:0] csr_write_addr	,
//input interrupt_valid	,
input csr_set_bit,
input csr_clear_bit,
//input exception_valid	,
//input [DATA_WIDTH-1:0] exception_code,
input [DATA_WIDTH-1:0] interrupt_code,
//input exception_id_write_valid_i,
input interrupt_id_write_valid_i,
output [DATA_WIDTH-1:0] mcause_o  ,
input [7:0] mintstatus_i,
output [7:0]prv_int_lvl_pr_o,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,          
input           debug_mode_valid_i      

);
//reg [7:0] prev_int_lvl_pr_r;
reg [DATA_WIDTH-1:0] mcause_r;
reg [7:0] mintstatus_r;
localparam MCAUSE = 12'b0011_0100_0010;//342
wire [7:0] mintstatus_w ;

wire wr_addr_valid;
assign wr_addr_valid = ((csr_write_addr == MCAUSE) && csr_write_en) ? 1'b1 : 1'b0;
assign prv_int_lvl_pr_o = mcause_r[23:16]; 
//assign mcause_o = mcause_r;
assign mcause_o = {mcause_r[DATA_WIDTH-1],1'b1,2'b11,mcause_r[27],3'd0,mcause_r[23:16],4'd0,mcause_r[CSR_ADDR_WIDTH-1:0]};
//reg interrupt_valid_r;
/*always@(posedge csr_clk or negedge csr_rst)
begin
     if(!csr_rst)
    begin
       prev_int_lvl_pr_r  <= 8'd0;
    end
    else if(interrupt_valid | exception_valid)
    begin
        prev_int_lvl_pr_r <= mintstatus_i ;
    end

end*/
always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
    begin
        //interrupt_valid_r <= 1'b0;
        mintstatus_r <= 8'd0 ;
    end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        //interrupt_valid_r <= 1'b0;
        mintstatus_r <= 8'd0 ;

    end*/
    else
    begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MCAUSE) )
        begin
                mintstatus_r <= dbg_csr_write_data_i[7:0];


        end
		else
        begin
        //interrupt_valid_r <= interrupt_valid ;
        mintstatus_r <= mintstatus_i ;
        end
    end
end

assign mintstatus_w = mintstatus_r;

always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
	begin
		mcause_r <= {DATA_WIDTH{1'b0}};
	end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
        		mcause_r <= {DATA_WIDTH{1'b0}};

    end*/
	else
	begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == MCAUSE) )
        begin
                mcause_r <= dbg_csr_write_data_i;
        end
		/*else if(exception_id_write_valid_i)
		begin
			//mcause_r <= {1'b0,exception_code[62:0]};//{40'd0,mintststus_r,4'd0,exception_code[CSR_ADDR_WIDTH-1:0]}
            mcause_r <=   {{DATA_WIDTH-24{1'b0}},mintstatus_i,4'd0,exception_code[CSR_ADDR_WIDTH-1:0]};
		end*/
		else if(interrupt_id_write_valid_i)
		begin
		//	mcause_r <= {1'b1,interrupt_code[62:0]};
            mcause_r <=   {1'b1,{DATA_WIDTH-25{1'b0}},mintstatus_w,4'd0,interrupt_code[CSR_ADDR_WIDTH-1:0]};
            
          //  mcause_o <= {1'b1,63'd10};
		end
		else if(wr_addr_valid)
		begin
				case({csr_clear_bit,csr_set_bit})

				2'b00://complete write
				begin
					mcause_r <= csr_write_data;
				end
				2'b01://clear specified bits
				begin
					mcause_r <= (mcause_r | csr_write_data) ;
				end
				2'b10://set specified bits
				begin
					mcause_r <= (mcause_r & (~csr_write_data));
				end
                default : begin
                    mcause_r <= mcause_r;
                end
			endcase

		end
	end
end

endmodule

