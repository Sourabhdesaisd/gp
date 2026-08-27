//`timescale 1ns/1ps
module top_core_trace #(
    parameter ADDR_WIDTH = 8,
              DATA_WIDTH = 32,
              FIFO_DATA_WIDTH = 82,
              FIFO_DEPTH = 16
   )(
    input               it_clk,
    input               it_rst_n,

    input               core_clk_i,
    input               core_rst_ni,

    // Trace Encoder Inputs
    input   [3:0]       it_itype,
    input   [19:0]      it_iaddr,
    input   [7:0]       it_cause,
    input   [19:0]      it_tval,
    input   [2:0]       it_priv,
    input   [2:0]       it_context,
//    input               it_trace_enable,
    input               it_ienable_in,
    input               it_itype_valid,
    input               it_first_instrn_valid_in,
    input   [19:0]      it_delta_addr,      //from hart
    input               it_del_adr_valid,

    // Flush Interface
    input               afvalid_i,
    output              afready_o,

    // ATB Interface
    input               atready_i,
    output  [15:0]      atdata_o,
    output              atvalid_o,
//    output  [6:0]       atid_o,
//    output  [2:0]       atbytes_o,

  // APB Interface
  input  logic                     pclk_i,
  input  logic                     presetn_i,
  input  logic [ADDR_WIDTH-1:0]    paddr_i,
  input  logic                     psel_i,
  input  logic                     penable_i,
  input  logic                     pwrite_i,
  input  logic                     pwdata_i,
  output logic [DATA_WIDTH-1:0]    prdata_o,
  output logic                     pready_o,
  output logic                     pslverr_o
  );

   /*AUTOLOGIC*/
    logic apb2ndff_sync_w;
    logic apb2ndff_sync_d;
    logic apb2ndff_sync1_d;
    logic ndff2core_trace_sync_q;
    logic ndff2async_fifo_sync_q;

    logic [FIFO_DATA_WIDTH-1:0] async_fifo_write_data;
    logic [FIFO_DATA_WIDTH-1:0] async_fifo_read_data;

    logic rd_transfer_flag;
    logic fifo_rd_en;
    logic fifo_write_en;

    logic full;

    logic   [3:0]       async_fifo2core_trace_itype;
    logic   [19:0]      async_fifo2core_trace_iaddr;
    logic   [7:0]       async_fifo2core_trace_cause;
    logic   [19:0]      async_fifo2core_trace_tval;
    logic   [2:0]       async_fifo2core_trace_priv;
    logic   [2:0]       async_fifo2core_trace_context;
//    logic               async_fifo2core_trace_trace_enable,
    logic               async_fifo2core_trace_ienable_in;
    logic               async_fifo2core_trace_ityp_valid;
    logic               async_fifo2core_trac1STinst_vald;
    logic   [19:0]      async_fifo2core_trace_delta_addr;      //from hart
    logic               async_fifo2core_trac_DelAdr_vald;
    


    always_ff@(posedge core_clk_i or negedge core_rst_ni) begin
        if(!core_rst_ni) begin
            apb2ndff_sync1_d <= 1'b0;
            ndff2async_fifo_sync_q <= 1'b0;
        end else begin
            apb2ndff_sync1_d <= apb2ndff_sync_w;
            ndff2async_fifo_sync_q <= apb2ndff_sync1_d;
        end
   end

   assign async_fifo_write_data = {it_del_adr_valid,it_delta_addr,it_first_instrn_valid_in, it_itype_valid,
                                    it_ienable_in, it_context, it_priv, it_tval, it_cause, it_iaddr, it_itype};

   always_ff@(posedge core_clk_i or negedge core_rst_ni) begin
    if(!core_rst_ni) begin
        fifo_write_en <= 1'b0;
    end else if(!full && ndff2async_fifo_sync_q) begin
        fifo_write_en <= 1'b1;
    end
  end

   always_ff@(posedge it_clk or negedge it_rst_n) begin
    if(!it_rst_n) begin
        fifo_rd_en <= 1'b0;
    end else if(!rd_transfer_flag && ndff2core_trace_sync_q) begin
        fifo_rd_en <= 1'b1;
    end
  end



 async_fifo_trace  #(
    .WRITE_WIDTH  (FIFO_DATA_WIDTH),
    .READ_WIDTH   (FIFO_DATA_WIDTH),
    .FIFO_DEPTH   (FIFO_DEPTH),
    .PTR_WIDTH   ($clog2(FIFO_DEPTH))
)i_asyncfifo_core_trace(
                    .w_clk(core_clk_i),
                    .r_clk(it_clk),
                    .aresetn(core_rst_ni),       // active-low async reset
                    .presetn(core_rst_ni),
                    .wr_en(fifo_write_en),
                    .rd_en(fifo_rd_en),
                    
                    .write_data(async_fifo_write_data),
                    .read_data(async_fifo_read_data),
                    
                    
                    .  full(full),
//                    .  emty()
                    .rd_transfer_flag(rd_transfer_flag)
);

    always_ff@(posedge it_clk or negedge it_rst_n) begin
        if(!it_rst_n) begin

            async_fifo2core_trace_itype             <= 4'b0;
            async_fifo2core_trace_iaddr             <= 20'b0;
            async_fifo2core_trace_cause             <= 8'b0;
            async_fifo2core_trace_tval              <= 20'b0;
            async_fifo2core_trace_priv              <= 3'b0;
            async_fifo2core_trace_context           <= 3'b0;    
//            async_fifo2core_trace_trace_enable      <= 'b0;
            async_fifo2core_trace_ienable_in        <= 1'b0;
            async_fifo2core_trace_ityp_valid       <= 1'b0;
            async_fifo2core_trac1STinst_vald      <= 1'b0;    
            async_fifo2core_trace_delta_addr        <= 20'b0;        
            async_fifo2core_trac_DelAdr_vald     <= 1'b0;
        end else if(rd_transfer_flag && ndff2core_trace_sync_q) begin
            async_fifo2core_trace_itype             <= async_fifo_read_data[3:0];
            async_fifo2core_trace_iaddr             <= async_fifo_read_data[23:4];
            async_fifo2core_trace_cause             <= async_fifo_read_data[31:24];
            async_fifo2core_trace_tval              <= async_fifo_read_data[51:32];
            async_fifo2core_trace_priv              <= async_fifo_read_data[54:52];
            async_fifo2core_trace_context           <= async_fifo_read_data[57:55];    
//            async_fifo2core_trace_trace_enable      <= 'b0;
            async_fifo2core_trace_ienable_in        <= async_fifo_read_data[58];
            async_fifo2core_trace_ityp_valid       <= async_fifo_read_data[59];
            async_fifo2core_trac1STinst_vald   <= async_fifo_read_data[60];    
            async_fifo2core_trace_delta_addr        <= async_fifo_read_data[80:61];        
            async_fifo2core_trac_DelAdr_vald     <= async_fifo_read_data[81];
        end
     end



   top_trace i_itrace_top (/*AUTOINST*/
			   // Outputs
			   .afready_o		(afready_o),
			   .atdata_o		(atdata_o),
			   .atvalid_o		(atvalid_o),
//			   .atid_o		(atid_o),
//			   .atbytes_o		(atbytes_o),
			   // Inputs
			   .it_clk		(it_clk),
			   .it_rst_n		(it_rst_n),
			   .it_itype		(async_fifo2core_trace_itype),
			   .it_iaddr		(async_fifo2core_trace_iaddr),
			   .it_cause		(async_fifo2core_trace_cause),
			   .it_tval		(async_fifo2core_trace_tval),
			   .it_priv		(async_fifo2core_trace_priv),
			   .it_context		(async_fifo2core_trace_context),
			   .it_trace_enable	(ndff2core_trace_sync_q),
			   .it_ienable_in	(async_fifo2core_trace_ienable_in),
			   .it_itype_valid	(async_fifo2core_trace_ityp_valid),
			   .it_first_instrn_valid_in(async_fifo2core_trac1STinst_vald),
			   .it_delta_addr	(async_fifo2core_trace_delta_addr),
			   .it_del_adr_valid	(async_fifo2core_trac_DelAdr_vald),
			   .afvalid_i		(afvalid_i),
			   .atready_i		(atready_i));


    always_ff@(posedge it_clk or negedge it_rst_n) begin
        if(!it_rst_n) begin
            apb2ndff_sync_d <= 1'b0;
            ndff2core_trace_sync_q <= 1'b0;
        end else begin
            apb2ndff_sync_d <= apb2ndff_sync_w;
            ndff2core_trace_sync_q <= apb2ndff_sync_d;
        end
   end

   apb_slave_reg_core_trace i_apb_reg_core_trace (
					      // Outputs
					      .prdata_o		(prdata_o),
					      .pready_o		(pready_o),
					      .pslverr_o	(pslverr_o),
					      .core_trace_ctrl_reg_o(apb2ndff_sync_w),
					      // Inputs
					      .pclk_i		(pclk_i),
					      .presetn_i	(presetn_i),
					      .paddr_i		(paddr_i),
					      .psel_i		(psel_i),
					      .penable_i	(penable_i),
					      .pwrite_i		(pwrite_i),
					      .pwdata_i		(pwdata_i));



endmodule

