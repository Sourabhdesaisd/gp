//------------------------------------------------------------------------------
// Company  : KYROS SEMI PVT LTD
// Designer : Deekshith H P
// Date     : 06-07-2026
// Design   : BOOT_CONTROLLER
//------------------------------------------------------------------------------


module BOOT_CONTROLLER_P #(parameter logic [3:0]  BOOT_PULSE_COUNTER_P = 4'd10)

                        (

                        input boot_pulse_in                   ,
                        input gpio_11_in                        ,
                        input rc_clk_in                         ,
                        input pll_clk_mux_in                        ,
                        input pll_lock_done_in                  ,
                        input gpio_9_in                         ,
                     //   input debug_rst_in                      ,
                        output logic boot_en_out                ,
                        output logic jtag_pulse_out             ,
                        output logic pll_xtal_clk_sel_out       ,
                        output logic pulse_for_clk_rst_ctrl

                        );




logic boot_en_out_n;
logic jtag_pulse_out_n;
logic pll_xtal_clk_sel_out_n;
//logic pulse_for_clk_rst_ctrl_n;




typedef enum  logic [2:0] {
                             IDLE                           = 3'd0,
                             BOOT_EN_GEN                    = 3'd1,
                             JTAG_PULSE_RELEASE             = 3'd2,
                             BOOT_LOAD_DONE                 = 3'd3,
                             PULSE_RELEAS_CLK_RST_CTRL      = 3'd4

} state_t;

state_t state , next_state ;

logic [3:0]  boot_pulse_counter;
logic start_w;



always @(posedge rc_clk_in or negedge boot_pulse_in)
begin
    if (!boot_pulse_in)
    begin
        boot_pulse_counter <= 4'd0;
        start_w            <= 1'b0;
    end
    else
    begin
        if (boot_pulse_counter == BOOT_PULSE_COUNTER_P)
        begin
            start_w <= 1'b1;
        end
        else
        begin
            boot_pulse_counter <= boot_pulse_counter + 4'd1;
            start_w            <= 1'b0;
        end
    end
end



always@(posedge rc_clk_in or negedge boot_pulse_in)
begin
     if(!boot_pulse_in)
       begin
           state <= IDLE ;
       end
     else
       begin
           state <= next_state;
       end
 end

logic [7:0] jtag_pulse_cnt;
logic [7:0] clk_rst_ctrl_pulse;


always@(posedge rc_clk_in or negedge boot_pulse_in)
    begin
        if(!boot_pulse_in)
            begin
                jtag_pulse_cnt <= 8'd0;
            end
        else if (state == JTAG_PULSE_RELEASE)
            begin
                jtag_pulse_cnt <= jtag_pulse_cnt + 8'd1;
            end
    end


logic pulse_release_req;

always_ff @(posedge rc_clk_in or negedge boot_pulse_in)
begin
    if(!boot_pulse_in)
        pulse_release_req <= 1'b0;
    else
        pulse_release_req <= (state == PULSE_RELEAS_CLK_RST_CTRL);
end


logic req_sync1, req_sync2;

always_ff @(posedge pll_clk_mux_in)
begin
    req_sync1 <= pulse_release_req;
    req_sync2 <= req_sync1;

end

always_ff @(posedge pll_clk_mux_in)
begin
    if(req_sync2)
        clk_rst_ctrl_pulse <= clk_rst_ctrl_pulse + 8'd1;
    else
        clk_rst_ctrl_pulse <= 8'd0;
end



always_comb
    begin
        next_state  = state;
        boot_en_out_n           = 1'b0;
        jtag_pulse_out_n       = 1'b0;
        pll_xtal_clk_sel_out_n   = 1'b0;
        boot_en_out_n             = 1'b0;


       case(state)

            IDLE :
            begin
                if(start_w)
                    begin
                        next_state = BOOT_EN_GEN ;
                    end
                else
                    begin
                        next_state = IDLE;
                    end
            end

            BOOT_EN_GEN :
            begin
                if(!gpio_11_in)
                    begin
                        boot_en_out_n = 1'b1 ;
                        next_state = JTAG_PULSE_RELEASE ;
                    end
                else
                    begin
                        boot_en_out_n = 1'b0;
                        next_state  = BOOT_LOAD_DONE;
                    end
            end

            JTAG_PULSE_RELEASE :
            begin
                boot_en_out_n = 1'b1;

                if(gpio_11_in)
                    begin
                        next_state = BOOT_LOAD_DONE;
                        end
                else
                    begin
                    if(jtag_pulse_cnt == 8'd49)
                    begin
                        jtag_pulse_out_n = 1'b1;
                        next_state = JTAG_PULSE_RELEASE ;
                    end
                 else
                    begin
                        jtag_pulse_out_n = 1'b0;
                        next_state = JTAG_PULSE_RELEASE ;
                    end
                    end
            end



             BOOT_LOAD_DONE :
             begin
              //  jtag_pulse_out_n   = debug_rst_in;

                if(gpio_11_in && pll_lock_done_in)
                    begin
                        pll_xtal_clk_sel_out_n = 1'b0;
                        next_state           =  PULSE_RELEAS_CLK_RST_CTRL;
                    end
               else if( gpio_9_in && gpio_11_in)
                    begin
                        pll_xtal_clk_sel_out_n = 1'b1;
                        next_state           = PULSE_RELEAS_CLK_RST_CTRL;
                    end
            end


            PULSE_RELEAS_CLK_RST_CTRL :
            begin
               if( gpio_9_in && gpio_11_in)
                    begin
                        pll_xtal_clk_sel_out_n = 1'b1;
                    end
            end

            default : next_state = IDLE;
        endcase
   end




    always_ff @(posedge pll_clk_mux_in)
begin
     if(clk_rst_ctrl_pulse == 8'd49)
        pulse_for_clk_rst_ctrl <= 1'b1;
    else
        pulse_for_clk_rst_ctrl <= 1'b0;
end








always_ff @(posedge rc_clk_in or negedge boot_pulse_in)
begin
    if(!boot_pulse_in) begin
        boot_en_out            <= 1'b0;
        jtag_pulse_out         <= 1'b0;
        pll_xtal_clk_sel_out   <= 1'b0;
           end
    else begin
        boot_en_out            <= boot_en_out_n;
        jtag_pulse_out         <= jtag_pulse_out_n;
        pll_xtal_clk_sel_out   <= pll_xtal_clk_sel_out_n;
            end
end


endmodule

