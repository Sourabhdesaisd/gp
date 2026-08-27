module arbiter_mmu #(
   parameter VPN_WIDTH = 20
) (
    input logic clk,
    input logic  rst_n,
    input logic  instruction_hit ,
    input logic mem_hit ,
    input logic prefetch_hit ,

    input logic prefetch_en ,
    input logic mmu_en,

    input logic ptw_busy,

    input logic mem_vpn_req,
    input logic inst_vpn_req,

    input logic  [VPN_WIDTH-1:0] instruction_vpn ,
    input logic [VPN_WIDTH-1:0] mem_vpn ,
    input logic  [VPN_WIDTH-1:0] prefetch_vpn ,

    output logic vpn_req ,
    output logic [VPN_WIDTH-1:0] requested_vpn ,
    output logic is_mem_vpn

) ;


reg vpn_req_r;
reg [VPN_WIDTH-1:0] requested_vpn_r;
reg is_mem_vpn_r;


always@(posedge clk or negedge rst_n)  begin

   if(!rst_n) begin
       requested_vpn_r <= '0 ;
         vpn_req_r <= 1'd0 ;
         is_mem_vpn_r <= 1'd0 ;
         end

   else if(!ptw_busy & !instruction_hit & inst_vpn_req & mmu_en)
        begin
         requested_vpn_r <= instruction_vpn ;
         vpn_req_r <= 1'd1 ;
         is_mem_vpn_r <= 1'd0 ;
    end

    else if(!ptw_busy & !mem_hit & mem_vpn_req & mmu_en )
        begin
            requested_vpn_r <= mem_vpn ;
            vpn_req_r <= 1'd1 ;
            is_mem_vpn_r <= 1'd1 ;
      end

    else if(!ptw_busy & !prefetch_hit & prefetch_en & mmu_en)
            begin
            requested_vpn_r <= prefetch_vpn ;
            vpn_req_r <= 1'd1 ;
            is_mem_vpn_r <= 1'd0 ;
          end

    else
          begin
            requested_vpn_r <= {VPN_WIDTH{1'b0}} ;
            vpn_req_r <= 1'd0 ;
            is_mem_vpn_r <= 1'd0 ;
        end

end

assign requested_vpn = requested_vpn_r;
assign vpn_req = vpn_req_r;
assign is_mem_vpn = is_mem_vpn_r;


endmodule



