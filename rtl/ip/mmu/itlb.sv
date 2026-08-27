	module itlb #(
	    parameter int TLB_ENTRIES  = 16,
	    parameter int VPN_WIDTH    = 20,
	    parameter int PPN_WIDTH    = 20,
	    parameter int ASID_WIDTH   = 8
	) (
	    input  logic clk,
	    input  logic rst_n,
	    input  logic i_flush,

        input logic i_inst_vpn_req,

	    // ASID info
	    input logic [ASID_WIDTH-1:0]i_current_asid,
        input logic execute_access_bit,

	    // Lookup interface
	    input  logic [VPN_WIDTH-1:0]i_vpn_in,
	    output logic [PPN_WIDTH-1:0]o_ppn_out,
        output logic  o_execute_access_bit ,
	    output logic o_hit,

        // prefetch
        input  logic [VPN_WIDTH-1:0] i_prefetch_vpn_in ,
        output logic o_prefetch_hit,


	    // PTW refill interface
	    input logic i_write_en,
	    input logic [VPN_WIDTH-1:0]i_write_vpn,
	    input logic [PPN_WIDTH-1:0]i_write_ppn,
	    input logic i_write_valid,
	    input logic [ASID_WIDTH-1:0] i_write_asid
	);

	    // Storage arrays
	    logic [VPN_WIDTH-1:0]vpn_array[0:TLB_ENTRIES-1];
	    logic [PPN_WIDTH-1:0] ppn_array[0:TLB_ENTRIES-1];
        logic execute_access_bit_array [0:TLB_ENTRIES-1];
	    logic valid_array [0:TLB_ENTRIES-1];
	    logic [ASID_WIDTH-1:0]asid_array[0:TLB_ENTRIES-1];

	    // Lookup wiring
	    logic lookup_hit;
	    logic [$clog2(TLB_ENTRIES)-1:0]lookup_hit_index;

	    lookup #(
	        .VPN_WIDTH  (VPN_WIDTH),
	        .TLB_ENTRIES(TLB_ENTRIES),
	        .ASID_WIDTH (ASID_WIDTH)
	    ) u_tlb_lookup (
	        .i_vpn_to_find(i_vpn_in),
	        .i_current_asid(i_current_asid),
	        .i_tlb_vpn_array(vpn_array),
	        .i_tlb_asid_array(asid_array),
	        .i_tlb_valid_array(valid_array),
	        .o_hit(lookup_hit),
	        .o_hit_index(lookup_hit_index)
	    );

	    assign o_hit = lookup_hit;
	    assign o_ppn_out = lookup_hit ? ppn_array[lookup_hit_index] : '0;
	    assign  o_execute_access_bit = lookup_hit ? execute_access_bit_array [lookup_hit_index] : '0;


        // prefetcher lookup
         logic lookup_prefetcher_hit;
         logic  [$clog2(TLB_ENTRIES)-1:0]lookup_prefetch_hit_index;

	    lookup #(
	        .VPN_WIDTH  (VPN_WIDTH),
	        .TLB_ENTRIES(TLB_ENTRIES),
	        .ASID_WIDTH (ASID_WIDTH)
	    ) u_tlb_prefetch_lookup (
	        .i_vpn_to_find(i_prefetch_vpn_in),
	        .i_current_asid(i_current_asid),
	        .i_tlb_vpn_array(vpn_array),
	        .i_tlb_asid_array(asid_array),
	        .i_tlb_valid_array(valid_array),
	        .o_hit(lookup_prefetcher_hit),
	        .o_hit_index(lookup_prefetch_hit_index)
	    );

	    assign o_prefetch_hit = lookup_prefetcher_hit;


	    // Replacement info
        localparam int IDX_W = $clog2(TLB_ENTRIES);

        logic [IDX_W-1:0] plru_replace_index;
        logic [IDX_W-1:0] replace_index;
        logic replace_update;
        logic found_invalid;


	    replace_1_port_itlb #(
	        .TLB_ENTRIES(TLB_ENTRIES)
	    ) u_tlb_replace (
	        .clk(clk),
	        .rst_n(rst_n),
	        .i_hit(lookup_hit && i_inst_vpn_req),
	        .i_hit_index(lookup_hit_index),
            .i_prefetch_hit(1'b0),
            .i_prefetch_hit_index (lookup_prefetch_hit_index),
	        .i_update(replace_update),
            .i_update_index(replace_index),
	        .o_replace_index(plru_replace_index)
	    );

  always_comb begin
    replace_index = plru_replace_index;
    found_invalid = 1'b0;

    for (int i = 0; i < TLB_ENTRIES; i++) begin
        if (!valid_array[i] && !found_invalid) begin
            replace_index = IDX_W'(i);
            found_invalid = 1'b1;
        end
    end
end


	    // State updates
	    always_ff @(posedge clk or negedge rst_n) begin
	        if (!rst_n) begin
	            for (int i = 0; i < TLB_ENTRIES; i++) begin
	                valid_array[i] <= 1'b0;
	                vpn_array[i]   <= '0;
	                ppn_array[i]   <= '0;
	                execute_access_bit_array[i]<= '0;
	                asid_array[i]  <= '0;
	            end
	        end else if (i_flush) begin
	            for (int i = 0; i < TLB_ENTRIES; i++) begin
	                valid_array[i] <= 1'b0;
	            end
	        end else if (i_write_en) begin
	            vpn_array[replace_index] <= i_write_vpn;
	            ppn_array [replace_index] <= i_write_ppn;
	            execute_access_bit_array[replace_index] <= execute_access_bit;
	            valid_array[replace_index] <= i_write_valid;
	            asid_array [replace_index] <= i_write_asid;
	        end
	    end

	    assign replace_update = i_write_en;

endmodule
