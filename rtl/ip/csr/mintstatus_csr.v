module mintstatus_csr//addr = 0xFC0
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input 		csr_clk					,
input 		csr_rst					,
//input       wdt_reset_i ,
input 		interrupt_valid_i			,
//input       exception_valid_i       ,
input 		mret_valid_i				,
input [7:0] prv_int_lvl_pr_i ,
input [7:0] 	int_active_level_priority_i	,
output[DATA_WIDTH-1:0] 	int_active_level_priority_o	,
output reg [7:0] mintstatus_o       ,
input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,

//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
input           debug_mode_valid_i      

);

//wire [7:0] din;
//wire [7:0] dout;
//assign din = int_active_level_priority_i;

//reg [7:0] fifo [6:0];
//reg [2:0] ptr;
//reg [2:0] trap_entry_cnt;
//reg [2:0] trap_exit_cnt;

always@(posedge csr_clk or negedge csr_rst )
begin
	if(!csr_rst )
    begin
        mintstatus_o <= 8'd0 ;
    end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i )//|wdt_reset_i)
    begin
                mintstatus_o <= 8'd0 ;

    end*/

    else
    begin
        if(dbg_csr_write_en_i && debug_mode_valid_i && (dbg_csr_addr_i == 12'd0) )
        begin
                mintstatus_o <= dbg_csr_write_data_i[7:0];//here only we need first 8 bit 
        end
		/*else if (exception_valid_i)
        begin
        mintstatus_o <= 8'hff;
        end*/
        else if(interrupt_valid_i)
        begin
            mintstatus_o <= int_active_level_priority_i ;
        end
        else if(mret_valid_i)
        begin
            mintstatus_o <= prv_int_lvl_pr_i ;//from mcause
        end
    end
end
/*
always@(posedge csr_clk or negedge csr_rst)
begin
	if(!csr_rst)
	begin
		ptr <= 3'd0;
		trap_entry_cnt <= 3'd0;
		trap_exit_cnt <= 3'd0;
	end
	else
	begin
	        if((trap_entry_cnt == trap_exit_cnt) & (trap_entry_cnt != 0))
				begin
				trap_entry_cnt <= 0;
				trap_exit_cnt <= 0;
		     end 
			else if(interrupt_valid_i & (!exception_valid_i))
			begin
				ptr 	  <= ptr+3'd1;
				fifo[ptr] <= din;
				trap_entry_cnt <= trap_entry_cnt + 1 ;
			
			end
			else if(exception_valid_i)
			begin
			ptr <= ptr+3'd1;
			fifo[ptr] <= 8'hff;
			trap_entry_cnt <= trap_entry_cnt + 1 ;
			end
			else if(mret_valid_i)
			begin
				ptr	    <= ptr - 3'd1 ;
				//fifo[ptr-1] <= 8'd0;
				trap_exit_cnt <= trap_exit_cnt + 1;
	
			end
	end
end

//assign dout =(mret_valid_i) ? fifo[ptr] : 0;
assign dout = (trap_entry_cnt != trap_exit_cnt ) ? fifo[ptr-1] : 0 ; */

	assign int_active_level_priority_o = {{DATA_WIDTH-8{1'b0}},mintstatus_o};
endmodule

