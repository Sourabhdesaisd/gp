module dpc
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input           dpc_clk_i             ,
input           dpc_rst_i             ,
//input wdt_reset_i,
input           dpc_write_en_i        ,
input           dpc_set_en_i          ,
input           dpc_clear_en_i        ,
input [CSR_ADDR_WIDTH-1:0]    dpc_addr_i            ,
input [DATA_WIDTH-1:0]    dpc_write_data_i      ,
input           ebreak_valid_i        ,
input           trigger_valid_i       ,
input           single_step_valid_i   ,
input           haltreq_valid_i       ,
input [PC_WIDTH-1:0]    pc_i                  ,
output [INSTRUCTION_WIDTH-1:0]   dpc_o         ,
//input           dbg_csr_write_en_i      ,
//input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
//input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           debug_mode_valid_i      ,
input           dbg_ndm_reset_i         ,
input           dbg_hart_reset_i    ,
input                   branch_valid_i  ,
input [PC_WIDTH-1:0]    branch_pc_i    ,
input stall_valid_i

);

localparam DPC_ADDR = 12'h7B1;
reg [DATA_WIDTH-1:0] dpc_r;
wire [PC_WIDTH-1:0] pc_r;
wire [PC_WIDTH-1:0] ebreak_pc;
wire [PC_WIDTH-1:0] stall_pc;

assign ebreak_pc = pc_i + {{PC_WIDTH-4{1'b0}},4'b0100} ;
assign pc_r = pc_i + {{PC_WIDTH-4{1'b0}},4'b0100} ;//{{PC_WIDTH-4{1'b0}},4'b0100}
assign stall_pc = pc_i + {{PC_WIDTH-4{1'b0}},4'b1000} ;//{{PC_WIDTH-4{1'b0}},4'b0100}
//assign pc_r = pc_i;
/////////////
reg dbg_hart_reset_r;
wire neg_dbg_hart_rst;
wire pos_dbg_hart_req;
reg haltreq_valid_r;
wire neg_dbg_hart_req;
reg branch_valid_r;
reg stall_valid_r;
reg [PC_WIDTH-1:0] branch_pc_r;

wire branch_valid_w;
wire stall_valid_w;
wire [PC_WIDTH-1:0] branch_pc_w;

assign branch_pc_w = branch_pc_r;
assign stall_valid_w = stall_valid_r;
assign branch_valid_w = branch_valid_r;

always@(posedge dpc_clk_i or negedge dpc_rst_i)
   begin
       if(!dpc_rst_i)
         begin
             dbg_hart_reset_r <=1'b0 ;
             haltreq_valid_r    <= 1'b0;
            branch_valid_r      <=  1'b0;
            branch_pc_r         <= {PC_WIDTH{1'b0}};
            stall_valid_r       <= 1'b0;
         end
       else
       begin
           dbg_hart_reset_r <= dbg_hart_reset_i ;
           haltreq_valid_r <= haltreq_valid_i;
           branch_valid_r   <=  branch_valid_i;
           branch_pc_r      <=  branch_pc_i ;
           stall_valid_r <= stall_valid_i   ;
       end
   end

assign neg_dbg_hart_rst = (~dbg_hart_reset_i) && (dbg_hart_reset_r ^ dbg_hart_reset_i) ;
assign pos_dbg_hart_req = (haltreq_valid_i ^ haltreq_valid_r );
assign neg_dbg_hart_req = (~haltreq_valid_i) && (haltreq_valid_r ^ haltreq_valid_i) ;
////////////
always@(posedge dpc_clk_i or negedge dpc_rst_i )
begin
    if(!dpc_rst_i )
    begin
        dpc_r <= {DATA_WIDTH{1'b0}};
    end
    else if(dbg_ndm_reset_i | dbg_hart_reset_i /*| wdt_reset_i*/)//we dont need this wdt reset
    begin
                dpc_r <= {DATA_WIDTH{1'b0}};
    end
    else if(neg_dbg_hart_rst)
    begin
        dpc_r <=  pc_i;
    end
    else
    begin
        if(ebreak_valid_i)
        begin
            dpc_r <= {ebreak_pc};
        end
        else if(trigger_valid_i)
        begin
            dpc_r <= {pc_r};
        end
        else if(single_step_valid_i)
        begin
            dpc_r <= {pc_r};
        end
        else if(pos_dbg_hart_req && branch_valid_i)
        begin
            dpc_r <= branch_pc_i;
        end
        else if(pos_dbg_hart_req && stall_valid_i)
        begin
            dpc_r <= stall_pc;
        end

        else if(pos_dbg_hart_req && stall_valid_w)
        begin
            dpc_r <= stall_pc;
        end
        else if(pos_dbg_hart_req && branch_valid_w)
        begin
            dpc_r <= branch_pc_w;
        end
        else if(pos_dbg_hart_req && (!neg_dbg_hart_req))
        begin
            dpc_r <= {pc_r};
        end
        else if(dpc_write_en_i && (dpc_addr_i == DPC_ADDR) & (!dpc_set_en_i) & (!dpc_clear_en_i))
        begin
            dpc_r <= dpc_write_data_i ;
        end
        //else if(debug_mode_valid_i)
        //begin
          //  dpc_r <= pc_i;
        //end
        

    end
end

assign dpc_o = dpc_r;

endmodule

