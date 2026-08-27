module ptw #(

    parameter int VPN_WIDTH      = 20,
    parameter int PPN_WIDTH      = 20,
    parameter int ACCESS_WIDTH   = 3, // [2] = W , [1] =R , [0] = X
    parameter int ASID_WIDTH     = 8,
    parameter int PTE_ADDR_WIDTH = 32,
    parameter int WAIT_MAX       = 16

)(

    input  logic clk,
    input  logic rst_n,

    // Request Interface (from arbitor)

    input  logic                    req_valid,
    input  logic [VPN_WIDTH-1:0]    req_vpn,
    input  logic                    is_mem_vpn,
    output logic                    reg_is_mem_vpn,

    // Memory Request Interface

    output logic                    mem_req_valid,
    output logic [PTE_ADDR_WIDTH-1:0] mem_req_addr,

    // Memory Response Interface

    input  logic                    mem_resp_valid,
    input  logic [PPN_WIDTH-1:0]    mem_resp_ppn,
    input  logic [ACCESS_WIDTH-1:0] mem_resp_access,
 //   input  logic                    mem_resp_dirty,
    input  logic                    mem_resp_validbit,

    // Context inputs

    input  logic [ASID_WIDTH-1:0]   i_current_asid,
    input  logic [VPN_WIDTH+1:0]    i_pt_base_ppn,


    // PTW -> TLB refill outputs

    output logic                    o_ptw_write_en,
    output logic [VPN_WIDTH-1:0]    o_ptw_write_vpn,
    output logic [PPN_WIDTH-1:0]    o_ptw_write_ppn,
    output logic [ACCESS_WIDTH-1:0] o_ptw_write_access,
 //   output logic                    o_ptw_write_dirty,
    output logic                    o_ptw_write_valid,
    output logic [ASID_WIDTH-1:0]   o_ptw_write_asid,


    // MMU status

    output logic                    o_mmu_busy,


    // Timeout control/status

    input  logic                    i_ptw_timeout_enable,
    output logic                    o_ptw_timeout,

// page faults

    output logic 		inst_page_fault,
    output logic 		mem_page_fault

);



    // FSM STATES

    typedef enum logic [2:0] {

        S_IDLE   = 3'd0,
        S_REQ    = 3'd1,
        S_WAIT   = 3'd2,
        S_REFILL = 3'd3,
        S_HIT   = 3'd4
    } state_t;

    state_t state, next_state;



    // INTERNAL REGISTERS

    logic [VPN_WIDTH-1:0]  lat_vpn;
    logic [ASID_WIDTH-1:0] lat_asid;
    logic [VPN_WIDTH+1:0] lat_base_ppn;

    int unsigned wait_cnt;
    logic timeout;

    // PTE ADDRESS FUNCTION

    function automatic [PTE_ADDR_WIDTH-1:0] mk_pte_addr(
        input logic [VPN_WIDTH+1:0] base_ppn,
        input logic [VPN_WIDTH-1:0] vpn

    );

        logic [PTE_ADDR_WIDTH-1:0] base_addr;
        logic [PTE_ADDR_WIDTH-1:0] vpn_off;


        begin
            base_addr = {base_ppn, 10'b0};
            vpn_off = {{(PTE_ADDR_WIDTH-VPN_WIDTH){1'b0}}, vpn } << 2;
            mk_pte_addr = base_addr + vpn_off;

        end

    endfunction


    // TIMEOUT LOGIC


    assign timeout =
        i_ptw_timeout_enable &&
        (wait_cnt >= (WAIT_MAX-1));


    //  STATE REGISTER

    always_ff @(posedge clk or negedge rst_n) begin

       if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end



    // NEXT STATE LOGIC


    always_comb begin
        next_state = state;

        case (state)

            S_IDLE: begin
                if (req_valid)
                    next_state = S_REQ;
            end


            S_REQ: begin
                next_state = S_WAIT;
            end


            S_WAIT: begin
                if (mem_resp_valid )
                    next_state = S_REFILL;

                else if (timeout)

                    next_state = S_IDLE;
            end


            S_REFILL: begin
    			if(o_ptw_write_valid)
		    		next_state = S_HIT;
	    		else
			    	next_state = S_IDLE;

            end


            S_HIT : begin

                next_state = S_IDLE;

             end



            default: begin

                next_state = S_IDLE;

            end

        endcase



    end



    //  OUTPUT LOGIC



    always_comb begin

        // defaults

        mem_req_valid   = 1'b0;
        mem_req_addr    = '0;
        o_ptw_write_en  = 1'b0;
        o_ptw_timeout   = 1'b0;
        o_mmu_busy      = 1'b0;
	inst_page_fault = 1'b0;
	mem_page_fault = 1'b0;


        case (state)

            S_REQ: begin

                o_mmu_busy   = 1'b1;
                mem_req_valid = 1'b1;
                mem_req_addr = mk_pte_addr(lat_base_ppn, lat_vpn);

            end



            S_WAIT: begin

                o_mmu_busy = 1'b1;
                if (timeout)
                    o_ptw_timeout = 1'b1;

            end


            S_REFILL: begin

                o_mmu_busy     = 1'b1;
	        	if(o_ptw_write_valid)

               		 o_ptw_write_en = 1'b1;

	        	else begin

		             if(reg_is_mem_vpn)
			            mem_page_fault = 1'b1;
		              else
			            inst_page_fault = 1'b1;
		        end

            end



            S_HIT :  o_mmu_busy = 1'b1;

            default: begin
                o_mmu_busy = 1'b0;
            end

        endcase

    end



    //  Datapath registers



    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin



            lat_vpn        <= '0;
            lat_asid       <= '0;
            lat_base_ppn   <= '0;
            reg_is_mem_vpn <= '0;
            wait_cnt       <= 0;
            o_ptw_write_vpn     <= '0;
            o_ptw_write_ppn     <= '0;
            o_ptw_write_access  <= '0;
        //    o_ptw_write_dirty   <= 1'b0;
            o_ptw_write_valid   <= 1'b0;
            o_ptw_write_asid    <= '0;


        end else begin

            case (state)


                S_IDLE: begin

                    wait_cnt <= 0;

                    if (req_valid) begin

                        lat_vpn        <= req_vpn;
                        lat_asid       <= i_current_asid;
                        lat_base_ppn   <= i_pt_base_ppn;
                        reg_is_mem_vpn <= is_mem_vpn;

                    end

                end





                S_WAIT: begin


                o_ptw_write_vpn    <= lat_vpn;
                o_ptw_write_ppn    <= mem_resp_ppn;
                o_ptw_write_access <= mem_resp_access;
            //    o_ptw_write_dirty  <= mem_resp_dirty;
                o_ptw_write_valid  <= mem_resp_validbit;
                o_ptw_write_asid   <= lat_asid;

                if (mem_resp_valid)
                    wait_cnt <= 0;
                else
                    wait_cnt <= wait_cnt + 1;

            end

            default: begin
                wait_cnt <= wait_cnt;
            end

        endcase
    end
end
endmodule
