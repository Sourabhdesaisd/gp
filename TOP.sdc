set_units -time 1000.0ps
set_units -capacitance 1000.0fF

create_clock -name TCK -period 500 -waveform {0 250} [get_ports TCK ]
create_clock -name pll_clk -period 2.5 -waveform {0 1.25} [get_ports pll_clk ]
create_clock -name xtal_clk -period 40 -waveform {0 20} [get_ports xtal_clk ]
create_clock -name rc_clk -period 20000 -waveform {0 10000} [get_ports rc_clk ]

create_generated_clock -name core_clk -source [get_ports pll_clk] -divide_by 1  [get_pins clk_rst_ctrl_top_instance/clk_soc_o]

create_generated_clock -name debug_clk -source [get_pins clk_rst_ctrl_top_instance/clk_soc_o] -divide_by 2 [get_pins clk_rst_bypass_top_instance/clk_for_jtag]

create_generated_clock -name pclk  -source [get_pins -hier *clk_rst_ctrl_top_instance/clk_soc_o] -divide_by 2 [get_pins -hier *clk_rst_ctrl_top_instance/clk_per_o]

create_generated_clock -name memory_clk -source [get_pins clk_rst_ctrl_top_instance/clk_soc_o] -divide_by 1 [get_pins clk_rst_bypass_top_instance/clk_for_mem_out]

create_generated_clock -name ctrl_bypass_debug_clk -source [get_pins clk_rst_ctrl_top_instance/clk_soc_o] -divide_by 2 [get_pins clk_rst_ctrl_top_instance/clk_for_debug_o]

create_generated_clock -name bclk -source [get_pins -hier *clk_rst_ctrl_top_instance/clk_per_o] -divide_by 27 [get_pins -hier *uart_wrapper_instance/dut/bclk_reg/Q]

create_generated_clock -name rx_baud_clk -source [get_pins uart_wrapper_instance/dut/bclk_reg/Q] -divide_by 1 [get_pins uart_wrapper_instance/dut/rx_baud_clk_reg/Q]

###reate_generated_clock  -name MCLK -source [get_ports pll_clk_in] -divide_by 1 [get_ports mem_clk_in]
##create_generated_clock  -name DCLK -source [get_ports pll_clk_in] -divide_by 2 [get_ports debug_clk_in]


set_clock_uncertainty -setup 0.5 [get_clocks  TCK]
set_clock_uncertainty -hold  0.25 [get_clocks TCK]

set_clock_uncertainty -setup 0.5 [get_clocks pll_clk]
set_clock_uncertainty -hold  0.25 [get_clocks pll_clk]

set_clock_uncertainty -setup 0.5 [get_clocks  xtal_clk]
set_clock_uncertainty -hold  0.25 [get_clocks xtal_clk]

set_clock_uncertainty -setup 0.5 [get_clocks  rc_clk]
set_clock_uncertainty -hold  0.25 [get_clocks rc_clk]



##set_case_analysis 0 [get_ports pll_clk_in]
##set_clock_groups -physically_exclusive -group [get_clocks PCLK] -group [get_clocks XCLK]
##set_case_analysis 0 [get_ports pll_clk]

set_clock_groups -logically_exclusive -group [get_clocks pll_clk]  -group [get_clocks xtal_clk] 
##set_clock_groups -asynchronous -group [get_clocks TCK] -group [get_clocks pll_clk] -group [get_clocks rc_clk]  -group [get_clocks xtal_clk] 
set_input_delay -clock pll_clk 0.5  -max [remove_from_collection [all_inputs] [get_ports {pll_clk rc_clk xtal_clk TCK }]]
set_input_delay -clock pll_clk 0.25 -min  [remove_from_collection [all_inputs] [get_ports {pll_clk rc_clk xtal_clk TCK }]]

set_output_delay -clock pll_clk 0.5 -max  [all_outputs]
set_output_delay -clock pll_clk 0.25 -min  [all_outputs]


set_driving_cell -lib_cell BUFFD6 [remove_from_collection [all_inputs] [get_ports {pll_clk rc_clk xtal_clk TCK }]]

set_load -max 0.01 [all_outputs]

