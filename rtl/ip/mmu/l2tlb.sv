module l2tlb #(
    parameter int TLB_ENTRIES  = 32,
    parameter int VPN_WIDTH    = 20,
    parameter int PPN_WIDTH    = 20,
    parameter int ACCESS_WIDTH = 3,
    parameter int ASID_WIDTH   = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic i_flush,
    input logic is_mem_vpn,

    input  logic [ASID_WIDTH-1:0]   i_current_asid,
    input  logic [VPN_WIDTH-1:0]    i_vpn_in,
    output logic [PPN_WIDTH-1:0]    o_ppn_out,
    output logic o_execute_access_bit,
    output logic                    o_hit,

    input  logic [VPN_WIDTH-1:0] i_prefetch_vpn_in ,
    output logic  o_prefetch_hit ,

    input  logic [VPN_WIDTH-1:0]    i_mem_vpn_in,
    output logic [PPN_WIDTH-1:0]    o_mem_ppn_out,
  //  output logic                    o_mem_dirty_out,
    output logic o_read_access_bit,
    output logic o_write_access_bit,
    output logic                    o_mem_hit,

    input  logic                    i_write_en,
    input  logic [VPN_WIDTH-1:0]    i_write_vpn,
    input  logic [PPN_WIDTH-1:0]    i_write_ppn,
  //  input  logic                    i_write_dirty,
    input  logic                    i_write_valid,
    input  logic [ASID_WIDTH-1:0]   i_write_asid,
    input logic execute_access_bit,
    input logic read_access_bit,
    input logic write_access_bit 
);
    localparam int unsigned ENTRIES_W = $clog2(TLB_ENTRIES);

    // Current state arrays
    logic [VPN_WIDTH-1:0]    vpn_array    [0:TLB_ENTRIES-1];
    logic [PPN_WIDTH-1:0]    ppn_array    [0:TLB_ENTRIES-1];
//    logic                    dirty_array  [0:TLB_ENTRIES-1];
    logic                    valid_array  [0:TLB_ENTRIES-1];
    logic [ASID_WIDTH-1:0]   asid_array   [0:TLB_ENTRIES-1];
    logic                      mem_array  [0:TLB_ENTRIES-1];
    logic execute_access_bit_array [0:TLB_ENTRIES-1];
    logic read_access_bit_array [0:TLB_ENTRIES-1];
    logic write_access_bit_array [0:TLB_ENTRIES-1];


    // Next state arrays
    logic [VPN_WIDTH-1:0]    vpn_nxt      [0:TLB_ENTRIES-1];
    logic [PPN_WIDTH-1:0]    ppn_nxt      [0:TLB_ENTRIES-1];
 //   logic [ACCESS_WIDTH-1:0] access_nxt   [0:TLB_ENTRIES-1];
 //   logic                    dirty_nxt    [0:TLB_ENTRIES-1];
    logic                    valid_nxt    [0:TLB_ENTRIES-1];
    logic [ASID_WIDTH-1:0]   asid_nxt     [0:TLB_ENTRIES-1];
    logic                      mem_nxt    [0:TLB_ENTRIES-1];
    logic execute_access_bit_array_nxt [0:TLB_ENTRIES-1];
    logic read_access_bit_array_nxt [0:TLB_ENTRIES-1];
    logic write_access_bit_array_nxt [0:TLB_ENTRIES-1];


    
    // IF lookup
    
    logic                          if_lookup_hit;
    logic [ENTRIES_W-1:0]          if_lookup_hit_index;
    logic [TLB_ENTRIES-1:0] 	 hit_vector_inst;
    logic [TLB_ENTRIES-1:0] 	 hit_vector_prefetch;
    


// prefetch hit vector generation 

        always_comb begin
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            hit_vector_prefetch[i] = valid_array[i]   && 
                            (mem_array[i] == 1'b0) &&
                            (vpn_array[i]  == i_prefetch_vpn_in) && 
                            (asid_array[i] == i_current_asid);
                            end
                     end
    
    // hit detection
    assign    o_prefetch_hit = (hit_vector_prefetch != {TLB_ENTRIES{1'b0}});





// IF hit vector generation
        always_comb begin
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            hit_vector_inst[i] = valid_array[i]   && 
                            (mem_array[i] == 1'b0) &&
                            (vpn_array[i]  == i_vpn_in) && 
                            (asid_array[i] == i_current_asid);
                            end
                     end
    
    // hit detection
    assign    if_lookup_hit = (hit_vector_inst != {TLB_ENTRIES{1'b0}});
    
    // hit index selection
        always_comb begin
          if_lookup_hit_index =  {ENTRIES_W{1'b0}};
          for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            if (hit_vector_inst[TLB_ENTRIES-1-i])
                if_lookup_hit_index = ENTRIES_W'(TLB_ENTRIES-1-i);
        end
    end



    assign o_hit        = if_lookup_hit;
    assign o_ppn_out    = if_lookup_hit ? ppn_array   [if_lookup_hit_index] : '0;
    assign o_execute_access_bit = if_lookup_hit ? execute_access_bit_array[if_lookup_hit_index] : '0;



    // MEM lookup
    
    logic                          mem_lookup_hit;
    logic [ENTRIES_W-1:0]          mem_lookup_hit_index;
    logic [TLB_ENTRIES-1:0] 	 hit_vector_mem;
    

       always_comb begin
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            hit_vector_mem[i] = valid_array[i]   && 
                            (mem_array[i] == 1'b1 ) &&
                            (vpn_array[i]  ==  i_mem_vpn_in) && 
                            (asid_array[i] == i_current_asid);

                            end
                      end
    
    // hit detection
       assign    mem_lookup_hit = (hit_vector_mem != {TLB_ENTRIES{1'b0}});
    
    // hit index selection
        always_comb begin
           mem_lookup_hit_index =  {ENTRIES_W{1'b0}};
           for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            if (hit_vector_mem[TLB_ENTRIES-1-i])
                mem_lookup_hit_index = ENTRIES_W'(TLB_ENTRIES-1-i);
        end
    end

    

    assign o_mem_hit        = mem_lookup_hit;
    assign o_mem_ppn_out    = mem_lookup_hit ? ppn_array   [mem_lookup_hit_index] : '0;
    assign o_read_access_bit = mem_lookup_hit ? read_access_bit_array[mem_lookup_hit_index] : '0;
    assign o_write_access_bit = mem_lookup_hit ? write_access_bit_array[mem_lookup_hit_index] : '0;    
 //   assign o_mem_dirty_out  = mem_lookup_hit ? dirty_array [mem_lookup_hit_index] : 1'b0;


    // Replacement
    logic [ENTRIES_W-1:0] replace_index;

    replace_2_port #(
        .TLB_ENTRIES(TLB_ENTRIES)
    ) u_l2_replace (
        .clk             (clk),
        .rst_n             (rst_n),
        .i_update        (i_write_en),
        .o_replace_index (replace_index)
    );

    
    // Pre-compute enables
    logic [TLB_ENTRIES-1:0] entry_flush_en;
    logic [TLB_ENTRIES-1:0] entry_write_en;

    always_comb begin
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            entry_flush_en[i] = i_flush;
            entry_write_en[i] = i_write_en & (ENTRIES_W'(i) == replace_index);
        end
    end

    // Next state logic 
    always_comb begin
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            // Default: hold current state
            vpn_nxt   [i] = vpn_array   [i];
            ppn_nxt   [i] = ppn_array   [i];
        //    dirty_nxt [i] = dirty_array [i];
            valid_nxt [i] = valid_array [i];
            asid_nxt  [i] = asid_array  [i];
            mem_nxt  [i] = mem_array [i];
            execute_access_bit_array_nxt[i] = execute_access_bit_array[i];
            read_access_bit_array_nxt [i] = read_access_bit_array[i];
            write_access_bit_array_nxt [i] = write_access_bit_array[i];
            


            // Flush: clear valid
            if (entry_flush_en[i])
                valid_nxt[i] = 1'b0;

            // Write: update all fields
            if (entry_write_en[i]) begin
                vpn_nxt   [i] = i_write_vpn;
                ppn_nxt   [i] = i_write_ppn;
           //     dirty_nxt [i] = i_write_dirty;
                valid_nxt [i] = i_write_valid;
                asid_nxt  [i] = i_write_asid;
                mem_nxt [i] = is_mem_vpn;
                execute_access_bit_array_nxt[i] = execute_access_bit;
                read_access_bit_array_nxt [i] = read_access_bit;
                write_access_bit_array_nxt [i] = write_access_bit;


            end
        end
    end

    // Sequential  
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
                valid_array [i] <= 1'b0;
                vpn_array   [i] <= '0;
                ppn_array   [i] <= '0;
         //       dirty_array [i] <= 1'b0;
                asid_array  [i] <= '0;
                mem_array  [i] <= '0;
                execute_access_bit_array [i] <= 1'b0;
                read_access_bit_array [i] <= 1'b0;
                write_access_bit_array [i] <= 1'b0;
            end
        end else begin
            for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
                vpn_array   [i] <= vpn_nxt   [i];
                ppn_array   [i] <= ppn_nxt   [i];
          //      dirty_array [i] <= dirty_nxt [i];
                valid_array [i] <= valid_nxt [i];
                asid_array  [i] <= asid_nxt  [i];
                mem_array   [i] <= mem_nxt   [i];
                execute_access_bit_array[i] <= execute_access_bit_array_nxt[i];
                read_access_bit_array [i] <= read_access_bit_array_nxt[i];
                write_access_bit_array [i] <= write_access_bit_array_nxt[i];

            end
        end
    end

endmodule
