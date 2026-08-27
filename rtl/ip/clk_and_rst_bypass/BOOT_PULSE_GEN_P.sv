//------------------------------------------------------------------------------
// Company  : KYROS SEMI PVT LTD
// Designer : Deekshith H P
// Date     : 26-06-2026
// Design   : RST_GEN
//------------------------------------------------------------------------------

module BOOT_PULSE_GEN_P #( parameter logic [7:0] BOOT_PULSE_COUNTER = 8'd50)
    (
    input  logic clk_in,
    input  logic por,
    input  logic jtag_pulse_in,
    input  logic hard_rst_n,
    output logic boot_pulse_gen,
    output logic jtag_pulse_gen_out
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


    always_ff@(posedge clk_in or negedge hard_rst_n)
    begin
        if(!hard_rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_ff@(posedge clk_in)
    begin
            if(state != ASSERT)
                assert_cnt <= 8'd0;
                else
                    assert_cnt <= assert_cnt + 8'd1;

    end



    always_comb begin

            next_state = state;

            case(state)
                        IDLE : begin
                                    if(por )
                                        begin
                                        next_state = ASSERT;
                                        end

                                 end

                      ASSERT :

                                    if(assert_cnt == BOOT_PULSE_COUNTER )

                                    next_state = NORMAL;


                        NORMAL :

                                    next_state = NORMAL;


                        default :
                                    next_state = IDLE;

           endcase
           
end


always@(posedge clk_in)
begin


    if (state == IDLE)
    begin
        boot_pulse_gen_w             <= 1'b0;
        jtag_pulse_gen_out         <= 1'b0;
       end
    else
    begin
        if(state == ASSERT)
            begin
            boot_pulse_gen_w             <= 1'b0;
             jtag_pulse_gen_out         <= 1'b0;
             end
            else
        begin

        if (state == NORMAL)
            boot_pulse_gen_w <= 1'b1;

        if (state == NORMAL && jtag_pulse_in)
            jtag_pulse_gen_out <= 1'b1;

    end
end
end

assign boot_pulse_gen = boot_pulse_gen_w;

endmodule
