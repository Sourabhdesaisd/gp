module mmu_core #(
    parameter int VPN_WIDTH    = 20,
    parameter int PPN_WIDTH    = 20,
    parameter int ACCESS_WIDTH = 3,
    parameter int ASID_WIDTH   = 9,
    parameter int L1_ENTRIES   = 16,
    parameter int L2_ENTRIES   = 32
)(
    input  logic clk,
    input  logic rst_n,
    input logic mem_read_en,
    input logic mem_write_en,
    input logic inst_vpn_req,  // new


    // CPU Fetch Interface
    input  logic [VPN_WIDTH-1:0]    i_if_vpn,
    output logic [PPN_WIDTH-1:0]    o_if_ppn,
   output logic  inst_execute_permission_fault,
    output logic  o_if_hit,

    // CPU Memory Interface
    input  logic [VPN_WIDTH-1:0]    i_mem_vpn,
    output logic [PPN_WIDTH-1:0]    o_mem_ppn,
    output logic mem_read_permission_fault,
    output logic mem_write_permission_fault,
   // output logic  o_mem_dirty,
    output logic  o_mem_hit,

    output logic o_mmu_busy, // new

    // PTW --  PTE  Memory  Interface
    output logic   pte_req_valid,
    output logic [31:0]  pte_req_addr,

    input  logic  mem_resp_valid,
    input  logic [PPN_WIDTH-1:0]   mem_resp_ppn,
    input  logic [ACCESS_WIDTH-1:0] mem_resp_access,  //new combined
 //   input  logic   mem_resp_dirty,
    input  logic   mem_resp_validbit,

    output logic  inst_page_fault, // new
    output logic  mem_page_fault, // new

    // CSR Interface
   input logic mmu_enable,
   input  logic prefetch_enable, //new
   input  logic tlb_flush,
   input logic [ASID_WIDTH-1:0] current_asid,
   input  logic [PPN_WIDTH+1:0]  pt_base_ppn,
   input logic ptw_timeout_enable, //new
   output logic ptw_timeout_event,  // new


// outputs for trace unit

 //   output logic mmu_debug_valid,
   output logic  [7:0] mmu_debug_event,
   output logic [31:0] mmu_debug_data
);



    logic prefetch_en_ff1, prefetch_en_ff2;
    logic timeout_en_ff1,  timeout_en_ff2;

    // PTW  TLB refill signals
    logic ptw_write_en;
    logic [VPN_WIDTH-1:0]    ptw_write_vpn;
    logic [PPN_WIDTH-1:0]    ptw_write_ppn;
    logic [ACCESS_WIDTH-1:0] ptw_write_access;
//    logic                    ptw_write_dirty;
    logic                    ptw_write_valid;
    logic [ASID_WIDTH-1:0]   ptw_write_asid;

    // prefetch
    logic prefetch_hit;
    logic [VPN_WIDTH-1:0]  prefetch_vpn;

    // arb to ptw
    logic arb_req_valid;
    logic [VPN_WIDTH-1:0] arb_req_vpn;
    logic is_mem_vpn;

    logic reg_is_mem_vpn;

    logic mem_vpn_req;

    assign mem_vpn_req = mem_read_en | mem_write_en ;


    logic [VPN_WIDTH-1:0] o_inst_ppn;
    logic [VPN_WIDTH-1:0] o_memory_ppn;

    logic o_inst_hit;
    logic o_memory_hit;

    assign o_if_ppn = mmu_enable ? o_inst_ppn : i_if_vpn;
    assign o_mem_ppn = mmu_enable ? o_memory_ppn : i_mem_vpn;

    assign o_if_hit = mmu_enable? o_inst_hit : inst_vpn_req;
    assign o_mem_hit = mmu_enable? o_memory_hit : mem_vpn_req ;


   always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prefetch_en_ff1 <= 1'b0;
        prefetch_en_ff2 <= 1'b0;
        timeout_en_ff1  <= 1'b0;
        timeout_en_ff2  <= 1'b0;
    end
    else begin
        prefetch_en_ff1 <= prefetch_enable;
        prefetch_en_ff2 <= prefetch_en_ff1;

        timeout_en_ff1  <= ptw_timeout_enable;
        timeout_en_ff2  <= timeout_en_ff1;
    end
end

    // CSR Block
 /*   mmu_csr #(
        .ASID_WIDTH (ASID_WIDTH),
        .PPN_WIDTH  (PPN_WIDTH)
    ) u_csr (
        .clk                  (clk),
        .rst_n                  (rst_n),
        .i_csr_we             (i_csr_we),
        .i_csr_re             (i_csr_re),
        .i_csr_addr           (i_csr_addr),
        .i_csr_wdata          (i_csr_wdata),
        .o_csr_rdata          (o_csr_rdata),
        .o_mmu_enable         (mmu_enable),
        .o_prefetch_enable    (prefetch_enable),
        .o_tlb_flush          (tlb_flush),
        .o_current_asid       (current_asid),
        .o_pt_base_ppn        (pt_base_ppn),
        .o_ptw_timeout_enable (ptw_timeout_enable),
        .i_ptw_timeout_event  (ptw_timeout_event)
    );  */

    // TLB TOP
    tlb_top #(
        .L1_ENTRIES   (L1_ENTRIES),
        .L2_ENTRIES   (L2_ENTRIES),
        .VPN_WIDTH    (VPN_WIDTH),
        .PPN_WIDTH    (PPN_WIDTH),
        .ACCESS_WIDTH (ACCESS_WIDTH),
        .ASID_WIDTH   (ASID_WIDTH)
    ) u_tlb (
        .clk                 (clk),
        .rst_n                 (rst_n),
        .i_flush             (tlb_flush),
        .i_current_asid      (current_asid),
        .inst_vpn_req(inst_vpn_req),
        .mem_read_en        (mem_read_en),
        .mem_write_en        (mem_write_en),

        .i_vpn_in            (i_if_vpn),
        .o_ppn_out           (o_inst_ppn),
        .write_access_bit 	(ptw_write_access[0]) ,
	    .read_access_bit	(ptw_write_access[1]) ,
	    .execute_access_bit	(ptw_write_access[2]) ,

        .o_hit               (o_inst_hit),

        .prefetch_vpn_in    (prefetch_vpn),
        .prefetch_hit       ( prefetch_hit),

        .is_mem_vpn          (reg_is_mem_vpn),

        .i_mem_vpn_in        (i_mem_vpn),
        .o_mem_ppn_out       (o_memory_ppn),
      //  .o_mem_dirty_out     (o_mem_dirty),
        .o_mem_hit           (o_memory_hit),

        .i_ptw_write_en      (ptw_write_en),
        .i_ptw_write_vpn     (ptw_write_vpn),
        .i_ptw_write_ppn     (ptw_write_ppn),
   //     .i_ptw_write_dirty  (ptw_write_dirty),
        .i_ptw_write_valid  (ptw_write_valid),
        .i_ptw_write_asid   (ptw_write_asid),
        .inst_execute_permission_fault(inst_execute_permission_fault) ,
	    .mem_read_permission_fault(mem_read_permission_fault) ,
	    .mem_write_permission_fault(mem_write_permission_fault)



    );


    // Prefetcher
    prefetcher #(
        .VPN_WIDTH  (VPN_WIDTH)
    ) u_prefetcher (
        .i_tlb_vpn       (i_if_vpn),
        .o_pref_req_vpn  (prefetch_vpn)
    );


    // PTW Arbiter
    arbiter_mmu #(
        .VPN_WIDTH  (VPN_WIDTH)
    ) u_arbiter (
    .clk(clk),
    .rst_n(rst_n),
    .instruction_hit (o_if_hit),
    .mem_hit        (o_mem_hit),
    .prefetch_hit   (prefetch_hit),
    .prefetch_en    (prefetch_en_ff2),
    .mmu_en         (mmu_enable),
    .ptw_busy(o_mmu_busy),
    .mem_vpn_req    (mem_vpn_req),
    .inst_vpn_req   (inst_vpn_req),

    .instruction_vpn    (i_if_vpn),
    .mem_vpn        (i_mem_vpn),
    .prefetch_vpn   (prefetch_vpn),

    .vpn_req    (arb_req_valid),
    .requested_vpn  (arb_req_vpn),
    .is_mem_vpn     (is_mem_vpn)

    );

    // Page Table Walker
    ptw #(
        .VPN_WIDTH     (VPN_WIDTH),
        .PPN_WIDTH     (PPN_WIDTH),
        .ACCESS_WIDTH (ACCESS_WIDTH),
        .ASID_WIDTH   (ASID_WIDTH)
    ) u_ptw (
        .clk                   (clk),
        .rst_n                   (rst_n),

        .req_valid             (arb_req_valid),
        .req_vpn               (arb_req_vpn),
        .is_mem_vpn            (is_mem_vpn),
        .reg_is_mem_vpn         (reg_is_mem_vpn),

        .mem_req_valid         (pte_req_valid),
        .mem_req_addr          (pte_req_addr),

        .mem_resp_valid        (mem_resp_valid),
        .mem_resp_ppn          (mem_resp_ppn),
        .mem_resp_access       (mem_resp_access),
     //   .mem_resp_dirty        (mem_resp_dirty),
        .mem_resp_validbit     (mem_resp_validbit),

        .i_current_asid        (current_asid),
        .i_pt_base_ppn         (pt_base_ppn),

        .o_ptw_write_en        (ptw_write_en),
        .o_ptw_write_vpn       (ptw_write_vpn),
        .o_ptw_write_ppn       (ptw_write_ppn),
        .o_ptw_write_access   (ptw_write_access),
    //    .o_ptw_write_dirty    (ptw_write_dirty),
        .o_ptw_write_valid    (ptw_write_valid),
        .o_ptw_write_asid     (ptw_write_asid),

        .o_mmu_busy         (o_mmu_busy),
        .i_ptw_timeout_enable (timeout_en_ff2),
        .o_ptw_timeout        (ptw_timeout_event),
        .inst_page_fault  (inst_page_fault),
        .mem_page_fault (mem_page_fault)
    );


    /// debug events points

   mmu_debug_events  u_mmu_debug_events (

    // MMU Control
 //   .mmu_enable                    (mmu_enable),

    // Translation Request
    .inst_vpn_req                  (inst_vpn_req),
 //   .mem_read_en                   (mem_read_en),
//    .mem_write_en                  (mem_write_en),

    .pte_req_valid  (pte_req_valid),
    .pte_req_addr   (pte_req_addr),

    .mem_resp_valid (mem_resp_valid),
    .mem_resp_ppn   (mem_resp_ppn),
    .mem_resp_validbit  (mem_resp_validbit),


    .ptw_timeout_event             (ptw_timeout_event),


    // Page Faults
    .inst_page_fault               (inst_page_fault),
    .mem_page_fault                (mem_page_fault),

    // Permission Faults
    .inst_execute_permission_fault (inst_execute_permission_fault),
    .mem_read_permission_fault     (mem_read_permission_fault),
    .mem_write_permission_fault    (mem_write_permission_fault),

    // context values
    .prefetch_hit  (prefetch_hit),
    .i_if_vpn   (i_if_vpn),
    .i_mem_vpn (i_mem_vpn),

    // Debug Event Output
 //   .mmu_debug_valid(mmu_debug_valid),
    .mmu_debug_event(mmu_debug_event),
    .mmu_debug_data(mmu_debug_data)

);




endmodule
