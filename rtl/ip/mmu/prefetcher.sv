module prefetcher #(
    parameter int VPN_WIDTH  = 20
) (

    input  logic [VPN_WIDTH-1:0] i_tlb_vpn,      // VPN that hit
    // To PTW (prefetch request)
    output logic [VPN_WIDTH-1:0] o_pref_req_vpn
);


   assign o_pref_req_vpn  = i_tlb_vpn + {{VPN_WIDTH-1{1'b0}},1'b1} ;
endmodule
