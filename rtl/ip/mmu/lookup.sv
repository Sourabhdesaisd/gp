module lookup #(
    parameter int VPN_WIDTH   = 20,
    parameter int TLB_ENTRIES = 16,
    parameter int ASID_WIDTH  = 8
)(
    input  logic [VPN_WIDTH-1:0]              i_vpn_to_find,            // VPN from the cpu (pc address from [12:31)
    input  logic [ASID_WIDTH-1:0]             i_current_asid,           // context change (tag)

    input  logic [VPN_WIDTH-1:0]              i_tlb_vpn_array  [0:TLB_ENTRIES-1],
    input  logic [ASID_WIDTH-1:0]             i_tlb_asid_array [0:TLB_ENTRIES-1],
    input  logic                              i_tlb_valid_array[0:TLB_ENTRIES-1],

    output logic                              o_hit,  // hit in the array 
    output logic [$clog2(TLB_ENTRIES)-1:0]   o_hit_index // index of the arrray that hit 
);

    localparam int unsigned ENTRIES_W = $clog2(TLB_ENTRIES);  //  width for index

    logic [TLB_ENTRIES-1:0] hit_vector; // match vector 

     // Parallel comparison across all entries
    always_comb begin
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            hit_vector[i] = i_tlb_valid_array[i]   &&
                            (i_tlb_vpn_array[i]  == i_vpn_to_find) && 
                            (i_tlb_asid_array[i] == i_current_asid);
        end
    end

    // Hit detection: any bit set in hit_vector
    always_comb begin
        o_hit = (hit_vector != '0);
    end

    // Priority encoder: selects highest index match If multiple hits, last matching entry wins
    always_comb begin
        o_hit_index = '0;
        for (int unsigned i = 0; i < TLB_ENTRIES; i++) begin
            if (hit_vector[TLB_ENTRIES-1-i])
                o_hit_index = ENTRIES_W'(TLB_ENTRIES-1-i);
        end
    end

endmodule
