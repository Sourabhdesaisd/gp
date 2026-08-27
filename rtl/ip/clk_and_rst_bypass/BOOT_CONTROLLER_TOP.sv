//------------------------------------------------------------------------------
// Company  : KYROS SEMI PVT LTD
// Designer : Deekshith H P
// Date     : 07-07-2026
// Design   : BOOT_CONTROLLER_TOP
//------------------------------------------------------------------------------


module BOOT_CONTROLLER_TOP(

                        input logic por_in                            ,
                        input logic gpio_11_in                        ,
                        input logic rc_clk_in                         ,
                        input logic pll_clk_mux_in                    ,
                        input logic pll_lock_done_in                  ,
                        input logic gpio_9_in                         ,
                        input logic hard_rst_n                          ,
                     //   input logic debug_rst_in                      ,
                        output logic boot_en_out                ,
                        output logic pll_xtal_clk_sel_out       ,
                        output logic pulse_for_clk_rst_ctrl     ,
                        output logic jtag_pulse_out             ,
                        output logic boot_pulse

                            );


logic boot_pulse_w ;
logic jtag_pulse_out_w;
logic pulse_for_clk_rst_ctrl_w;


BOOT_PULSE_GEN_P boot_pulse_gen (
                            .clk_in(rc_clk_in),
                            .por(por_in),
                            .hard_rst_n(hard_rst_n),
                            .jtag_pulse_in(jtag_pulse_out_w),
                            .boot_pulse_gen(boot_pulse_w),
                            .jtag_pulse_gen_out(jtag_pulse_out)

                          );


BOOT_CONTROLLER_P boot_controller_b(

                                    .boot_pulse_in(boot_pulse_w)  ,
                                    .gpio_11_in(gpio_11_in)  ,
                                    .rc_clk_in(rc_clk_in)   ,
                                    .pll_clk_mux_in(pll_clk_mux_in),
                                    .pll_lock_done_in(pll_lock_done_in) ,
                                    .gpio_9_in(gpio_9_in) ,
                                  //  .debug_rst_in(debug_rst_in),
                                    .boot_en_out(boot_en_out),
                                    .jtag_pulse_out(jtag_pulse_out_w) ,
                                    .pll_xtal_clk_sel_out(pll_xtal_clk_sel_out),
                                    .pulse_for_clk_rst_ctrl(pulse_for_clk_rst_ctrl_w)

                                );


PULSE_RST_GEN pulse_rst_unit(

                                     .pll_clk_mux_in(pll_clk_mux_in),
                                     .hard_rst_n(hard_rst_n),
                                     .pulse_for_clk_rst_ctrl_in(pulse_for_clk_rst_ctrl_w),
                                     .pulse_for_clk_rst_ctrl_out(pulse_for_clk_rst_ctrl)
                                   );



assign boot_pulse = boot_pulse_w ;

endmodule

