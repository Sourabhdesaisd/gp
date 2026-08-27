	module dtlb #(
	    parameter int TLB_ENTRIES  = 16,
	    parameter int VPN_WIDTH    = 20,
	    parameter int PPN_WIDTH    = 20,
	  //  parameter int ACCESS_WIDTH = 3,
	    parameter int ASID_WIDTH   = 8
	) (
	    input  logic clk,
	    input  logic rst_n,
	    input  logic i_flush,

        input logic i_mem_vpn_req,

	    // ASID
	    input  logic [ASID_WIDTH-1:0] i_current_asid,
        input logic read_access_bit,
        input logic write_access_bit,

	    // Lookup (mem side)
	    input  logic [VPN_WIDTH-1:0] i_vpn_in,
	    output logic [PPN_WIDTH-1:0] o_ppn_out,
	    output logic  o_read_access_bit ,
        output logic  o_write_access_bit,
	//    output logic o_dirty_out,
	    output logic o_hit,

	    // PTW refill
	    input  logic  i_write_en,
	    input  logic [VPN_WIDTH-1:0]  i_write_vpn,
	    input  logic [PPN_WIDTH-1:0]  i_write_ppn,
	 //   input  logic [ACCESS_WIDTH-1:0] i_write_access,
//	    input  logic  i_write_dirty,
	    input  logic  i_write_valid,
	    input  logic [ASID_WIDTH-1:0] i_write_asid
	);

	    logic [VPN_WIDTH-1:0]vpn_array[0:TLB_ENTRIES-1];
	    logic [PPN_WIDTH-1:0] ppn_array[0:TLB_ENTRIES-1];
	    logic read_access_bit_array [0:TLB_ENTRIES-1];
        logic write_access_bit_array [0:TLB_ENTRIES-1];
	//    logic  dirty_array [0:TLB_ENTRIES-1];
	    logic  valid_array [0:TLB_ENTRIES-1];
	    logic [ASID_WIDTH-1:0]asid_array[0:TLB_ENTRIES-1];

	    logic lookup_hit;
	    logic [$clog2(TLB_ENTRIES)-1:0] lookup_hit_index;

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
	    assign o_ppn_out = lookup_hit ? ppn_array[lookup_hit_index]    : '0;
	    assign o_read_access_bit = lookup_hit ? read_access_bit_array[lookup_hit_index] : '0;
	    assign o_write_access_bit = lookup_hit ? write_access_bit_array[lookup_hit_index] : '0;
  //     assign o_dirty_out  = lookup_hit ? dirty_array[lookup_hit_index]  : 1'b0;

	    localparam int IDX_W = $clog2(TLB_ENTRIES);

        logic [IDX_W-1:0] plru_replace_index;
        logic [IDX_W-1:0] replace_index;
        logic replace_update;
        logic found_invalid;

	    replace_1_port_dtlb #(
	        .TLB_ENTRIES(TLB_ENTRIES)
	    ) u_tlb_replace (
	        .clk (clk),
	        .rst_n (rst_n),
	        .i_hit (lookup_hit && i_mem_vpn_req),
	        .i_hit_index(lookup_hit_index),
	        .i_update(replace_update),
            .i_update_index (replace_index),
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

	    always_ff @(posedge clk or negedge rst_n) begin
	        if (!rst_n) begin
	            for (int i = 0; i < TLB_ENTRIES; i++) begin
	                valid_array[i]  <= 1'b0;
	                vpn_array[i]    <= '0;
	                ppn_array[i]    <= '0;
	                write_access_bit_array[i] <= '0;
                    read_access_bit_array[i] <= '0;
	           //     dirty_array[i]  <= 1'b0;
	                asid_array[i]   <= '0;
	            end
	        end else if (i_flush) begin
			// flush has priority over write
	            for (int i = 0; i < TLB_ENTRIES; i++) begin
	                valid_array[i] <= 1'b0;
	            end
	        end else if (i_write_en) begin
	            vpn_array[replace_index] <= i_write_vpn;
	            ppn_array[replace_index] <= i_write_ppn;
	            read_access_bit_array[replace_index] <= read_access_bit;
	            write_access_bit_array[replace_index] <= write_access_bit;
	          //  dirty_array [replace_index] <= i_write_dirty;
	            valid_array[replace_index] <= i_write_valid;
	            asid_array[replace_index] <= i_write_asid;
	        end
	    end

	    assign replace_update = i_write_en;

endmodule
