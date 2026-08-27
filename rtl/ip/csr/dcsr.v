//////////////debug module related CSRs////////////////////

module dcsr
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input           dcsr_clk_i              ,
input           dcsr_rst_i              ,
//input wdt_reset_i,
input [DATA_WIDTH-1:0]    dcsr_write_data_i       ,
input [CSR_ADDR_WIDTH-1:0]    dcsr_addr_i             ,
input           dcsr_write_en_i         ,
input           dcsr_set_en_i           ,
input           dcsr_clear_en_i         ,

input           ebreak_valid_i          ,
//input           trigger_valid_i         ,
input           haltreq_valid_i         ,
//input           single_step_valid_i     ,
input           reset_haltreq_valid_i   ,

//input           dbg_csr_write_en_i      ,
//input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
//input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
//input           debug_mode_valid_i      ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i        ,
output [DATA_WIDTH-1:0]   dcsr_o              
);

localparam DCSR_ADDR     = 12'h7b0  ;
localparam DEBUG_VER     = 4'd4     ;
localparam RSVD          = 10'd0    ;
localparam EBREAK_VS     = 1'b0     ;
localparam EBREAK_VU     = 1'b0     ;
localparam EBREAK_M      = 1'b1     ;
localparam EBREAK_U      = 1'b0     ;
localparam EBREAK_S      = 1'b0     ;
localparam STEP_IE       = 1'b0     ;
localparam STOP_CNT      = 1'b1     ;
localparam STOP_TIME     = 1'b1     ;
localparam CS_EBREAK     = 3'd1     ;
localparam CS_TRIG       = 3'd2     ;
localparam CS_HALTREQ    = 3'd3     ;
localparam CS_STEP       = 3'd4     ;
localparam CS_RST_HALTREQ= 3'd5     ;
localparam MPRVEN        = 1'b0     ;
localparam NMIP          = 1'b0     ;
localparam STEP          = 1'b0     ;
localparam PRV           = 2'd3     ;


reg [DATA_WIDTH-1:0] dcsr_r;

always@(posedge dcsr_clk_i or negedge dcsr_rst_i )
begin
    if(!dcsr_rst_i )   
    begin
    dcsr_r <= {DEBUG_VER,RSVD,EBREAK_VS,EBREAK_VU,EBREAK_M,1'b0,EBREAK_S,EBREAK_U,STEP_IE,STOP_CNT,STOP_TIME,3'd0,1'b0,MPRVEN,NMIP,STEP,PRV};
    end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin

    dcsr_r <= {DEBUG_VER,RSVD,EBREAK_VS,EBREAK_VU,EBREAK_M,1'b0,EBREAK_S,EBREAK_U,STEP_IE,STOP_CNT,STOP_TIME,3'd0,1'b0,MPRVEN,NMIP,STEP,PRV};
    end*/
    else
    begin
        if(dcsr_write_en_i && (dcsr_addr_i == 12'h7B0))
        begin
            if(dcsr_set_en_i)
            begin
                dcsr_r <= dcsr_r | dcsr_write_data_i ; 
            end
            else if (dcsr_clear_en_i)
            begin
                dcsr_r <= (dcsr_r & (~dcsr_write_data_i));
            end
            else
            begin
                dcsr_r  <= dcsr_write_data_i    ;
            end
        end

    end
end

reg [2:0] debug_cause;

always@(posedge dcsr_clk_i or negedge dcsr_rst_i )
begin
    if(!dcsr_rst_i )
    begin
        debug_cause <= 3'd0;
    end
    /*else if(dbg_ndm_reset_i | dbg_hart_reset_i)//| wdt_reset_i)
    begin
                debug_cause <= 3'd0;
    end*/
    else
    begin
        /*if(trigger_valid_i)
        begin
            debug_cause <= CS_TRIG;
        end
        else */if(ebreak_valid_i)
        begin
            debug_cause <= CS_EBREAK;

        end
        else if(reset_haltreq_valid_i)
        begin
            debug_cause <= CS_RST_HALTREQ;

        end
        else if(haltreq_valid_i)
        begin
            debug_cause <= CS_HALTREQ;

        end
        /*else if(single_step_valid_i)
        begin
            debug_cause <= CS_STEP;

        end*/

    end
end

assign dcsr_o = {dcsr_r[31:9],debug_cause,dcsr_r[5:0]};
endmodule

