//------------------------------------------------------------------------------
// Company  : KYROS SEMI PVT LTD
// Designer : Deekshith H P
// Date     : 30-07-2026
// Design   : PULSE_RST_GEN
//------------------------------------------------------------------------------


module PULSE_RST_GEN(

    input logic pll_clk_mux_in,
    input logic  hard_rst_n,    
    input  logic pulse_for_clk_rst_ctrl_in,
    output logic pulse_for_clk_rst_ctrl_out
     );

logic[7:0] assert_cnt;

logic boot_pulse_gen_w ;

typedef enum logic[1:0]
    {
            IDLE = 2'b00,
            ASSERT = 2'b01,
            NORMAL = 2'b10
    } state_i;

    state_i state , next_state;


    always_ff@(posedge pll_clk_mux_in )
    begin
        state <= next_state;
    end

    always_ff@(posedge pll_clk_mux_in)
    begin
            if(state != ASSERT)
                assert_cnt <= 8'd0;
                else
                    assert_cnt <= assert_cnt + 8'd1;

    end

    always_comb begin

            next_state = state;

            case(state)
                        IDLE :
                                    if(pulse_for_clk_rst_ctrl_in)
                                        begin
                                        next_state = ASSERT;
                                        end

                        ASSERT :
                                    if(assert_cnt ==8'd7)
                                    next_state = NORMAL;

                        NORMAL : //begin
                                   // if(pulse_for_clk_rst_ctrl_in)
                                     //   next_state = ASSERT;
                                       // else
                                    next_state = NORMAL;
                                  ///  end
                        default :
                                    next_state = IDLE;
           endcase
           end


/*always@(posedge pll_clk_mux_in)
begin

    if (state == IDLE)
    begin
        boot_pulse_gen_w    <= 1'b0;
        end
           else
             begin
                 if (state == NORMAL)
            boot_pulse_gen_w <= 1'b1;

            end

end*/

always@(posedge pll_clk_mux_in or negedge hard_rst_n )
    begin
        if(!hard_rst_n)
            boot_pulse_gen_w <= 1'b0;
        else begin
         if((state == IDLE))
            boot_pulse_gen_w <= 1'b0;
            else begin
            if(state == ASSERT)
                boot_pulse_gen_w <= 1'b0;

            if(state == NORMAL && pulse_for_clk_rst_ctrl_in)
                boot_pulse_gen_w <= 1'b1;
                end
        end
end

assign pulse_for_clk_rst_ctrl_out = boot_pulse_gen_w ;

endmodule

