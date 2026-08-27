module pte_wrapper #(

     parameter PTE_INDEX_WIDTH = 6
 )(
     input clk,
     input rst_n,

  // debug interface
  
    input dbg_valid,
    input [31:0] dbg_addr,


    input dbg_write_en,
    input [31:0] dbg_wdata,
    output  [1:0] dbg_write_resp,
    output  dbg_write_valid,


    input dbg_read_en,
    output  [31:0] dbg_rdata,
    output  [1:0] dbg_read_resp,
    output  dbg_read_valid,

    /// MMU/PTW interface

    input ptw_req_valid,
    input [31:0] ptw_req_addr,

    output  [23:0] ptw_rdata,
    output  ptw_resp_valid

);


   wire [PTE_INDEX_WIDTH -1:0] pte_index;
   wire  pte_write_en;
   wire [31:0] pte_wdata;
   wire [31:0]  pte_rdata;

   pte_controller #(
    .PTE_INDEX_WIDTH(PTE_INDEX_WIDTH)
) u_pte_controller (

    .clk(clk),
    .rst_n(rst_n),

   
    .dbg_valid(dbg_valid),
    .dbg_addr(dbg_addr),
    
    .dbg_write_en(dbg_write_en),    
    .dbg_wdata(dbg_wdata),
    .dbg_write_resp(dbg_write_resp),
    .dbg_write_valid(dbg_write_valid),

    .dbg_read_en(dbg_read_en),
    .dbg_rdata(dbg_rdata),
    .dbg_read_resp(dbg_read_resp),
    .dbg_read_valid(dbg_read_valid),

    .ptw_req_valid(ptw_req_valid),
    .ptw_req_addr(ptw_req_addr),

    .ptw_rdata(ptw_rdata),
    .ptw_resp_valid(ptw_resp_valid),

    .pte_index(pte_index),
    .pte_write_en(pte_write_en),
    .pte_wdata(pte_wdata),
    .pte_rdata(pte_rdata)

);

pte_memory #(
    .PTE_INDEX_WIDTH(PTE_INDEX_WIDTH)
) u_pte_memory (

    .clk(clk),
    .write_en(pte_write_en),

    .index(pte_index),

    .data_in(pte_wdata),
    .data_out(pte_rdata)

);

endmodule
    


    




