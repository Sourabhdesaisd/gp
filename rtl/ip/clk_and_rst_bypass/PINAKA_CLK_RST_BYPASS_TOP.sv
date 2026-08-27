//------------------------------------------------------------------------------
// Company  : KYROS SEMI PVT LTD
// Designer : Deekshith H P
// Date     : 08-07-2026
// Design   : PINAKA_CLK_RST_BYPASS_TOP
//------------------------------------------------------------------------------


module PINAKA_CLK_RST_BYPASS_TOP(


                        input por_in                            ,
                        input gpio_11_in                        ,
                        input rc_clk_in                         ,
                        input pll_lock_done_in                  ,
                        input gpio_9_in                         ,
                        input debug_rst_in                      ,
                        input pll_clk_in                        ,
                        input xtal_clk_in                       ,
                        input mem_clk_in                        ,
                        input debug_clk_in                      ,
                        input hard_rst_n                          ,
                        output logic clk_for_jtag               ,
                        output logic boot_en_out                ,
                        output logic pulse_for_clk_rst_ctrl     ,
                        output logic mux_jtag_debug_pulse_out   ,
                        output logic clk_for_clk_rst_ctrl       ,
                        output logic clk_for_mem_out            ,
                        output logic pulse_for_top_toprst       ,
                        output logic boot_debug_start1          ,
                        output logic boot_debug_start2          ,
                        output logic boot_debug_start3          ,
                        output logic boot_debug_start4          ,
                        output logic boot_debug_start5          ,
                        output logic boot_debug_start6
//                        output logic boot_debug_start7

                                    );


logic boot_pulse_w;
logic pll_xtal_clk_sel_out_w;
logic pll_xtal_clk_w ;
logic boot_en_out_w ;
logic jtag_pulse_w;


BOOT_CONTROLLER_TOP  boot_controller(

                                         .por_in(por_in),
                                         .gpio_11_in(gpio_11_in),
                                         .rc_clk_in(rc_clk_in),
                                         .pll_clk_mux_in(pll_xtal_clk_w),
                                         .pll_lock_done_in(pll_lock_done_in),
                                         .gpio_9_in(gpio_9_in),
                                       //  .debug_rst_in(debug_rst_in),
                                        .hard_rst_n(hard_rst_n),
                                          .boot_en_out(boot_en_out_w),
                                         .pll_xtal_clk_sel_out(pll_xtal_clk_sel_out_w),
                                         .pulse_for_clk_rst_ctrl(pulse_for_clk_rst_ctrl),
                                         .jtag_pulse_out(jtag_pulse_w),
                                         .boot_pulse(boot_pulse_w)

                            );



clk_mux_2to1 debug_rc_clk_mux (
                                .clk_0_i(debug_clk_in),
                                .rst_ni(boot_pulse_w),
                                .clk_1_i(rc_clk_in),
                                .sel_i(boot_en_out_w),
                                .test_clk_i(1'b0),
                                .test_en_i(1'b0),
                                .clk_o(clk_for_jtag)
                            );



clk_mux_2to1 pll_xtal_clk_mux (
                                .clk_0_i(pll_clk_in),
                                .rst_ni(boot_pulse_w),
                                .clk_1_i(xtal_clk_in),
                                .sel_i(pll_xtal_clk_sel_out_w),
                              // .sel_i(boot_en_out_w),
                                .test_clk_i(1'b0),
                                .test_en_i(1'b0),
                                .clk_o(pll_xtal_clk_w)
                            );





clk_mux_2to1 mem_rc_clk_mux (
                                .clk_0_i(mem_clk_in),
                                .rst_ni(boot_pulse_w),
                                .clk_1_i(rc_clk_in),
                                .sel_i(boot_en_out_w),
                                .test_clk_i(1'b0),
                                .test_en_i(1'b0),
                                .clk_o(clk_for_mem_out)
                            );



assign mux_jtag_debug_pulse_out = boot_en_out_w ? jtag_pulse_w : debug_rst_in;

//assign mux_jtag_debug_pulse_out = boot_en_out_w ? jtag_pulse_w : debug_rst_in  ;



assign      clk_for_clk_rst_ctrl    = pll_xtal_clk_w;
assign      pulse_for_top_toprst    = boot_pulse_w  ;
assign      boot_en_out = boot_en_out_w ;


////////////////////debuging_pin/////////////////////////
assign boot_debug_start1 = boot_pulse_w ;
assign boot_debug_start2 = boot_en_out_w;
assign boot_debug_start3 = pll_lock_done_in;
assign boot_debug_start4 = pll_xtal_clk_sel_out_w;
assign boot_debug_start5 = clk_for_jtag;
assign boot_debug_start6 = pll_xtal_clk_w;
//assign boot_debug_start7 = clk_for_mem_out;






endmodule

