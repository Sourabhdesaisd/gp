module tlb_top #(
    parameter int L1_ENTRIES   = 16,
    parameter int L2_ENTRIES   = 32,
    parameter int VPN_WIDTH    = 20,
    parameter int PPN_WIDTH    = 20,
    parameter int ACCESS_WIDTH = 3,
    parameter int ASID_WIDTH   = 8
) (
    input  logic clk,
    input  logic rst_n,
    input  logic i_flush,

    input logic inst_vpn_req,


    input  logic [ASID_WIDTH-1:0] i_current_asid,
    input logic mem_read_en,
    input logic mem_write_en,

    // Instruction fetch interface
    input  logic [VPN_WIDTH-1:0]  i_vpn_in,
    output logic [PPN_WIDTH-1:0]  o_ppn_out,
    output logic inst_execute_permission_fault,
    output logic  o_hit,

    // prefetcher
    input logic [VPN_WIDTH-1:0]  prefetch_vpn_in,
    output logic prefetch_hit,

    // ptw to tlb
    input logic is_mem_vpn,


    // Load/Store (data) interface
    input  logic [VPN_WIDTH-1:0]  i_mem_vpn_in,
    output logic [PPN_WIDTH-1:0]  o_mem_ppn_out,
    output logic mem_read_permission_fault ,
    output logic mem_write_permission_fault ,
  //  output logic o_mem_dirty_out,
    output logic o_mem_hit,

    // PTW refill interface
    input  logic  i_ptw_write_en,
    input  logic [VPN_WIDTH-1:0]  i_ptw_write_vpn,
    input  logic [PPN_WIDTH-1:0]  i_ptw_write_ppn,
    input logic read_access_bit ,
    input logic write_access_bit ,
    input logic execute_access_bit ,
  //  input  logic i_ptw_write_dirty,
    input  logic i_ptw_write_valid,
    input  logic [ASID_WIDTH-1:0] i_ptw_write_asid


);

    //  L1 ITLB
    logic [PPN_WIDTH-1:0]    itlb_ppn;
    logic  itlb_hit;
    logic itlb_prefetch_hit ;
    logic l2tlb_prefetch_hit ;
    logic itlb_execute_access_bit ;


assign prefetch_hit = itlb_prefetch_hit | l2tlb_prefetch_hit ;


    itlb #(
        .TLB_ENTRIES (L1_ENTRIES),
        .VPN_WIDTH   (VPN_WIDTH),
        .PPN_WIDTH   (PPN_WIDTH),
        .ASID_WIDTH  (ASID_WIDTH)
    ) u_itlb (
        .clk           (clk),
        .rst_n           (rst_n),
        .i_flush       (i_flush),
        .i_inst_vpn_req(inst_vpn_req),
        .i_current_asid(i_current_asid),
        .i_vpn_in      (i_vpn_in),
        .o_ppn_out     (itlb_ppn),
        .o_execute_access_bit (itlb_execute_access_bit),
        .o_hit         (itlb_hit),

        .i_prefetch_vpn_in (prefetch_vpn_in),
        .o_prefetch_hit (itlb_prefetch_hit),

        .i_write_en    (i_ptw_write_en &  ~is_mem_vpn ),
        .i_write_vpn   (i_ptw_write_vpn),
        .i_write_ppn   (i_ptw_write_ppn),
        .execute_access_bit (execute_access_bit),
        .i_write_valid (i_ptw_write_valid),
        .i_write_asid  (i_ptw_write_asid)
    );

    //  L1 DTLB
    logic [PPN_WIDTH-1:0]    dtlb_ppn;
  //  logic                    dtlb_dirty;
    logic                    dtlb_hit;
    logic dtlb_read_access_bit ;
    logic dtlb_write_access_bit ;


    dtlb #(
        .TLB_ENTRIES (L1_ENTRIES),
        .VPN_WIDTH   (VPN_WIDTH),
        .PPN_WIDTH   (PPN_WIDTH),
        .ASID_WIDTH  (ASID_WIDTH)
    ) u_dtlb (
        .clk           (clk),
        .rst_n           (rst_n),
        .i_flush       (i_flush),
        .i_mem_vpn_req(mem_read_en || mem_write_en),
        .i_current_asid(i_current_asid),
        .i_vpn_in      (i_mem_vpn_in),
        .o_ppn_out     (dtlb_ppn),
        .o_read_access_bit     (dtlb_read_access_bit),
        .o_write_access_bit     (dtlb_write_access_bit),
    //    .o_dirty_out   (dtlb_dirty),
        .o_hit         (dtlb_hit),
        .i_write_en    (i_ptw_write_en &  is_mem_vpn ),
        .i_write_vpn   (i_ptw_write_vpn),
        .i_write_ppn   (i_ptw_write_ppn),
        .read_access_bit	(read_access_bit) ,
	    .write_access_bit 	(write_access_bit) ,
    //    .i_write_dirty (i_ptw_write_dirty),
        .i_write_valid (i_ptw_write_valid),
        .i_write_asid  (i_ptw_write_asid)
    );

    //  L2 Unified TLB
    logic [PPN_WIDTH-1:0]    l2_ppn;

    logic  l2_hit;

    logic [PPN_WIDTH-1:0]    l2_mem_ppn;

  //  logic  l2_mem_dirty;
    logic  l2_mem_hit;

    logic l2tlb_execute_access_bit ;
    logic l2tlb_read_access_bit ;
    logic l2tlb_write_access_bit ;


    l2tlb #(
        .TLB_ENTRIES (L2_ENTRIES),
        .VPN_WIDTH   (VPN_WIDTH),
        .PPN_WIDTH   (PPN_WIDTH),
        .ASID_WIDTH  (ASID_WIDTH)
    ) u_ltlb (
        .clk           (clk),
        .rst_n           (rst_n),
        .i_flush       (i_flush),
        .i_current_asid(i_current_asid),

        .is_mem_vpn	(is_mem_vpn) ,


        // IF port
        .i_vpn_in      (i_vpn_in),
        .o_ppn_out     (l2_ppn),
        .o_hit         (l2_hit),

        .i_prefetch_vpn_in	(prefetch_vpn_in) ,
    	.o_prefetch_hit		(l2tlb_prefetch_hit) ,
        // MEM port
        .i_mem_vpn_in      (i_mem_vpn_in),
        .o_mem_ppn_out     (l2_mem_ppn),
        .o_execute_access_bit	(l2tlb_execute_access_bit) ,
	    .o_read_access_bit 		(l2tlb_read_access_bit) ,
	    .o_write_access_bit		(l2tlb_write_access_bit) ,

     //   .o_mem_dirty_out   (l2_mem_dirty),
        .o_mem_hit         (l2_mem_hit),

        // Refill (same PTW)
        .i_write_en    (i_ptw_write_en),
        .i_write_vpn   (i_ptw_write_vpn),
        .i_write_ppn   (i_ptw_write_ppn),
        .execute_access_bit 	(execute_access_bit) ,
	    .read_access_bit	(read_access_bit) ,
	    .write_access_bit 	(write_access_bit) ,

   //     .i_write_dirty (i_ptw_write_dirty),
        .i_write_valid (i_ptw_write_valid),
        .i_write_asid  (i_ptw_write_asid)
    );

    // TLB control
    tlb_ctrl #(
        .PPN_WIDTH    (PPN_WIDTH)
    ) u_tlb_control (
        .itlb_hit      (itlb_hit),
        .itlb_ppn      (itlb_ppn),
        .mem_read_en    (mem_read_en),
        .mem_write_en  (mem_write_en),
        .itlb_execute_access_bit (itlb_execute_access_bit),
        .l2_hit        (l2_hit),
        .l2_ppn        (l2_ppn),
        .o_hit         (o_hit),
        .o_ppn_out     (o_ppn_out),

        .dtlb_hit      (dtlb_hit),
        .dtlb_ppn      (dtlb_ppn),
        .dtlb_read_access_bit	(dtlb_read_access_bit),
	    .dtlb_write_access_bit	(dtlb_write_access_bit),

   //     .dtlb_dirty    (dtlb_dirty),
        .l2_mem_hit    (l2_mem_hit),
        .l2_mem_ppn    (l2_mem_ppn),
        .l2tlb_execute_access_bit	(l2tlb_execute_access_bit) ,
        .l2tlb_read_access_bit	(l2tlb_read_access_bit) ,
        .l2tlb_write_access_bit	(l2tlb_write_access_bit) ,
     //   .l2_mem_dirty  (l2_mem_dirty),
        .o_mem_hit     (o_mem_hit),
        .o_mem_ppn_out (o_mem_ppn_out),
  //      .o_mem_dirty_out(o_mem_dirty_out),
        .inst_execute_permission_fault(inst_execute_permission_fault) ,
	    .mem_read_permission_fault(mem_read_permission_fault) ,
	    .mem_write_permission_fault(mem_write_permission_fault)

    );


endmodule
