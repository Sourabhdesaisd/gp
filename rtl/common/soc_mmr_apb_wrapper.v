module soc_mmr_apb_wrapper
(
    input               pclk,
    input               presetn,

    // APB Slave Interface
    input       [15:0]   paddr,
    input               psel,
    input               penable,
    input               pwrite,
    input      [31:0]   pwdata,

    output reg [31:0]   prdata,
    output reg          pready,
    output reg          pslverr,

    // MMR Interface
    output reg             soc_mmr_write_en_i,
    output reg    [15:0]   soc_mmr_write_addr_i,
    output reg    [31:0]   soc_mmr_write_data_i,
    output reg             soc_mmr_read_en_i,
    output reg [15:0]      soc_mmr_read_addr_i,
    
    input               soc_read_rsp_i,
    input      [31:0]   soc_mmr_read_data_o
);

localparam MMR_LAST_ADDR        = 16'h9110;
localparam MMR_START_ADDR       = 16'h9000;
//////////////////////////////////////////////////////////////
// APB -> MMR
//////////////////////////////////////////////////////////////

wire addr_valid;
wire write_en_w, read_en_w;

assign addr_valid = ((paddr >= MMR_START_ADDR) && (paddr <= MMR_LAST_ADDR));

assign write_en_w = psel & penable &  pwrite & addr_valid;

assign read_en_w  = psel & penable & ~pwrite & addr_valid;

//assign soc_mmr_write_en_i   = psel & penable & pwrite;

//assign soc_mmr_write_addr_i = paddr;

//assign soc_mmr_write_data_i = pwdata;

//assign soc_mmr_read_en_i    = psel & penable & (~pwrite);

//assign soc_mmr_read_addr_i  = paddr;

always @(posedge pclk or negedge presetn)
begin
    if(!presetn) begin
        soc_mmr_write_en_i      <= 1'b0  ; 
        soc_mmr_write_addr_i    <= 16'd0 ;
        soc_mmr_write_data_i    <= 32'd0 ;
        soc_mmr_read_en_i       <= 1'b0  ;
        soc_mmr_read_addr_i     <= 16'd0 ;
        prdata                  <= 32'h0 ;
        
    end
    else begin 
        soc_mmr_write_addr_i    <= paddr        ;
        soc_mmr_write_data_i    <= pwdata       ;
        soc_mmr_read_addr_i     <= paddr        ;
        if (write_en_w)
            soc_mmr_write_en_i      <= 1'b1     ;
        else
            soc_mmr_write_en_i      <= 1'b0     ;

        if(read_en_w)
            soc_mmr_read_en_i       <= 1'b1     ;
        else
            soc_mmr_read_en_i       <= 1'b0     ;
    end

end


//////////////////////////////////////////////////////////////
// MMR -> APB
//////////////////////////////////////////////////////////////
reg rsp_sync1_r, rsp_sync2_r, rsp_sync3_r ;
always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        rsp_sync1_r <= 1'b0;
        rsp_sync2_r <= 1'b0;
        rsp_sync3_r <= 1'b0;
    end
    else begin
        rsp_sync1_r <= soc_read_rsp_i;
        rsp_sync2_r <= rsp_sync1_r;
        rsp_sync3_r <= rsp_sync2_r;
    end
end

wire read_data_valid_w = rsp_sync2_r ^ rsp_sync3_r;

always @(posedge pclk or negedge presetn)
begin
    if(!presetn) begin
        prdata <= 32'h0;
        
        end
    else if(read_data_valid_w) begin
        prdata <= soc_mmr_read_data_o;
        
        end
end

always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        pready  <= 1'b0; 
    else if (read_data_valid_w & psel & penable)
        pready  <= 1'b1;
    else if (write_en_w)
        pready  <= 1'b1;        
end

//////////////////////////////////////////////////////////////
// APB Response
//////////////////////////////////////////////////////////////

//assign pready  = 1'b1;

//reg pslverr_r;

always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        pslverr <= 1'b0;
    else if (psel && penable)
        pslverr <= ~addr_valid;
    else
        pslverr <= 1'b0;
end

//assign pslverr = pslverr_r;

endmodule
