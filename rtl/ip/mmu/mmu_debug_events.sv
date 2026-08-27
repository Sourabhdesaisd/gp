module mmu_debug_events #(
    parameter int VPN_WIDTH = 20,
    parameter int PPN_WIDTH = 20
)(

//    input  logic mmu_enable,

    input  logic inst_vpn_req,
  //  input  logic mem_read_en,
  //  input  logic mem_write_en,

    // PTW / PTE Memory Interface
    input  logic        pte_req_valid,
    input  logic [31:0] pte_req_addr,

    input  logic        mem_resp_valid,
    input  logic [PPN_WIDTH-1:0] mem_resp_ppn,
    input  logic        mem_resp_validbit,

    input  logic ptw_timeout_event,

    input  logic inst_page_fault,
    input  logic mem_page_fault,

    input  logic inst_execute_permission_fault,
    input  logic mem_read_permission_fault,
    input  logic mem_write_permission_fault,

    input  logic prefetch_hit,

    input  logic [VPN_WIDTH-1:0] i_if_vpn,
    input  logic [VPN_WIDTH-1:0] i_mem_vpn,

    // Debug Event Bus
 //   output logic        mmu_debug_valid,
    output logic [7:0]  mmu_debug_event,
    output logic [31:0] mmu_debug_data

);


  

  logic mem_permission_fault_event;
logic inst_permission_fault_event;
logic page_fault_event;
logic ptw_timeout_debug_event;
logic pte_invalid_event;
logic pte_valid_event;
logic tlb_miss_event;
logic prefetch_hit_event; 

   
// Memory Permission Fault 

assign mem_permission_fault_event =
       mem_read_permission_fault |
       mem_write_permission_fault;

// Instruction Permission Fault
assign inst_permission_fault_event =
       inst_execute_permission_fault;

// Page Fault
assign page_fault_event =
       inst_page_fault |
       mem_page_fault;

// PTW Timeout
assign ptw_timeout_debug_event =
       ptw_timeout_event;

// Invalid PTE
assign pte_invalid_event =
       mem_resp_valid && !mem_resp_validbit;

// Valid PTE Response
assign pte_valid_event =
       mem_resp_valid && mem_resp_validbit;

// TLB Miss (derived from PTW request)
assign tlb_miss_event =
       pte_req_valid;

// Prefetch Hit
assign prefetch_hit_event =
       prefetch_hit;
     

 

always_comb begin

  //  mmu_debug_valid = 1'b0;
    mmu_debug_event = 8'b0000_0000;
    mmu_debug_data  = 32'h0000_0000;



    if (mem_permission_fault_event) begin

     //   mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b1000_0000;
        mmu_debug_data  = {12'b0, i_mem_vpn};

    end

    else if (inst_permission_fault_event) begin

    //    mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0100_0000;
        mmu_debug_data  = {12'b0, i_if_vpn};

    end

    else if (page_fault_event) begin

    //    mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0010_0000;

        if (inst_page_fault)
            mmu_debug_data = {12'b0, i_if_vpn};
        else
            mmu_debug_data = {12'b0, i_mem_vpn};

    end

    else if (ptw_timeout_debug_event) begin

    //    mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0001_0000;
        mmu_debug_data  = pte_req_addr;

    end

    else if (pte_invalid_event) begin

    //    mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0000_1000;
        mmu_debug_data  = pte_req_addr;

    end

    else if (pte_valid_event) begin

   //     mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0000_0100;
        mmu_debug_data  = {12'b0, mem_resp_ppn};

    end

    else if (tlb_miss_event) begin

   //     mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0000_0010;

        if (inst_vpn_req)
            mmu_debug_data = {12'b0, i_if_vpn};
        else
            mmu_debug_data = {12'b0, i_mem_vpn};

    end

    else if (prefetch_hit_event) begin

  //      mmu_debug_valid = 1'b1;
        mmu_debug_event = 8'b0000_0001;
        mmu_debug_data  = {12'b0, i_if_vpn};

    end

end


endmodule
