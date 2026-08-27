
../rtl/rt/ip/axi2apb_bridge/axi_typedef_pkg.sv   


../rtl/rt/common/axi_master_wrapper/axi_wrapper_top.v
../rtl/rt/common/axi_master_wrapper/axi_rw_engine.v


../rtl/rt/common/axi_slave_with_data_memory/axi_4lite_slave.v  
../rtl/rt/common/axi_slave_with_data_memory/axi_datamem_wrapper.v  
../rtl/rt/common/mem/data_memory.v


../rtl/rt/common/axi_slave_with_instruction_memory/axi_instmem_wrapper.v
../rtl/rt/common/mem/instruction_memory.v 


../rtl/rt/common/soc_mmr_apb_wrapper.v


../rtl/rt/ip/mmu/arbiter_mmu.sv              
../rtl/rt/ip/mmu/l2tlb.sv                
../rtl/rt/ip/mmu/prefetcher.sv           
../rtl/rt/ip/mmu/replace_1_port_itlb.sv  
../rtl/rt/ip/mmu/tlb_ctrl.sv 
../rtl/rt/ip/mmu/dtlb.sv                 
../rtl/rt/ip/mmu/lookup.sv               
../rtl/rt/ip/mmu/ptw.sv                  
../rtl/rt/ip/mmu/replace_2_port.sv       
../rtl/rt/ip/mmu/tlb_top.sv 
../rtl/rt/ip/mmu/itlb.sv                             
../rtl/rt/ip/mmu/replace_1_port_dtlb.sv
../rtl/rt/ip/mmu/mmu_debug_events.sv
../rtl/rt/ip/mmu/mmu_core.sv 


../rtl/rt/ip/basic_isa/rv32i_core.v 
../rtl/rt/ip/basic_isa/pc_reg.v
../rtl/rt/ip/basic_isa/if_stage_simple_btb.v
../rtl/rt/ip/basic_isa/dynamic_branch_predictor.v
../rtl/rt/ip/basic_isa/btb_file.v
../rtl/rt/ip/basic_isa/btb_read.v
../rtl/rt/ip/basic_isa/btb_write.v
../rtl/rt/ip/basic_isa/btb.v
../rtl/rt/ip/basic_isa/register_file.v
../rtl/rt/ip/basic_isa/control_unit.v
../rtl/rt/ip/basic_isa/top_decode.v
../rtl/rt/ip/basic_isa/decode_unit.v
../rtl/rt/ip/basic_isa/arithmetic_unit32.v
../rtl/rt/ip/basic_isa/logical_unit32.v
../rtl/rt/ip/basic_isa/shift_unit32.v
../rtl/rt/ip/basic_isa/compare_unit32.v
../rtl/rt/ip/basic_isa/branch_jump_unit.v
../rtl/rt/ip/basic_isa/alu_top32.v
../rtl/rt/ip/basic_isa/forwarding_unit.v
../rtl/rt/ip/basic_isa/execute_stage.v
../rtl/rt/ip/basic_isa/ex_mem_pipe.v
../rtl/rt/ip/basic_isa/load_datapath.v
../rtl/rt/ip/basic_isa/store_datapath.v
../rtl/rt/ip/basic_isa/data_mem_top.v
../rtl/rt/ip/basic_isa/mem_stage.v
../rtl/rt/ip/basic_isa/mem_wb_pipe.v
../rtl/rt/ip/basic_isa/wb_stage.v
../rtl/rt/ip/basic_isa/if_id_pipe.v
../rtl/rt/ip/basic_isa/id_ex_pipe.v
../rtl/rt/ip/basic_isa/hazard_unit.v
../rtl/rt/ip/basic_isa/halt_fsm.v
../rtl/rt/ip/basic_isa/int_ctrl_logic.v
../rtl/rt/ip/basic_isa/trace_core.v


../rtl/rt/ip/multi_byte_i2c/i2c_master.sv
../rtl/rt/ip/multi_byte_i2c/i2c_register.sv
../rtl/rt/ip/multi_byte_i2c/i2c_wrapper.sv


../rtl/rt/ip/SPI/spi_master.sv
../rtl/rt/ip/SPI/spi_regs.sv
../rtl/rt/ip/SPI/spi_wrapper.sv


../rtl/rt/ip/UART/baud_gen.sv       
../rtl/rt/ip/UART/ndff_sync1.sv     
../rtl/rt/ip/UART/regs.sv           
../rtl/rt/ip/UART/rx_top.sv         
../rtl/rt/ip/UART/tx_async_fifo.sv  
../rtl/rt/ip/UART/demux.sv          
../rtl/rt/ip/UART/ndff_sync.sv      
../rtl/rt/ip/UART/rx_async_fifo.sv  
../rtl/rt/ip/UART/thr.sv            
../rtl/rt/ip/UART/tx_top.sv         
../rtl/rt/ip/UART/mux.sv            
../rtl/rt/ip/UART/rbr.sv            
../rtl/rt/ip/UART/rx_fsm.sv         
../rtl/rt/ip/UART/tsr_controler.sv  
../rtl/rt/ip/UART/uart_top.sv


../rtl/rt/ip/axi2apb_bridge/apb_master.sv        
../rtl/rt/ip/axi2apb_bridge/async_fifo_read.sv   
../rtl/rt/ip/axi2apb_bridge/axi_slave.sv         
../rtl/rt/ip/axi2apb_bridge/bridge_ndff_sync.sv         
../rtl/rt/ip/axi2apb_bridge/arbiter.sv           
../rtl/rt/ip/axi2apb_bridge/async_fifo_write.sv  
../rtl/rt/ip/axi2apb_bridge/top_bridge.sv


../rtl/rt/ip/csr/soc_csr_top.v
../rtl/rt/ip/csr/soc_csr_read_mux.v      
../rtl/rt/ip/csr/soc_csr_reg_file.v
../rtl/rt/ip/csr/satp_csr.v
../rtl/rt/ip/csr/mintstatus_csr.v
../rtl/rt/ip/csr/misa_csr.v
../rtl/rt/ip/csr/mtvec_csr.v
../rtl/rt/ip/csr/mepc_csr.v
../rtl/rt/ip/csr/mie_csr.v
../rtl/rt/ip/csr/mtval_csr.v
../rtl/rt/ip/csr/mcause_csr.v
../rtl/rt/ip/csr/mscratch_csr.v
../rtl/rt/ip/csr/mstatus_csr.v
../rtl/rt/ip/csr/marchid_csr.v
../rtl/rt/ip/csr/mhartid_csr.v
../rtl/rt/ip/csr/mimpid_csr.v
../rtl/rt/ip/csr/mvendorid_csr.v
../rtl/rt/ip/csr/dcsr.v
../rtl/rt/ip/csr/dpc_csr.v


../rtl/rt/ip/debug_module/DM_ace.v               
../rtl/rt/ip/debug_module/dmi_transaction_fsm.v  
../rtl/rt/ip/debug_module/DTM_cdc.v              
../rtl/rt/ip/debug_module/jtag_tap_controller.v   
../rtl/rt/ip/debug_module/dmi_address_decoder.v  
../rtl/rt/ip/debug_module/dm_program_buffer.v    
../rtl/rt/ip/debug_module/dtmcs_register.v             
../rtl/rt/ip/debug_module/jtag_tdo_mux.v         
../rtl/rt/ip/debug_module/dmi_data_register.v    
../rtl/rt/ip/debug_module/DM_reg.v               
../rtl/rt/ip/debug_module/sba_address_decoder.v     
../rtl/rt/ip/debug_module/dmi_request.v                
../rtl/rt/ip/debug_module/jtag_idcode_dr.v       
../rtl/rt/ip/debug_module/dmi_response_buffer.v  
../rtl/rt/ip/debug_module/DTM_bypass.v           
../rtl/rt/ip/debug_module/jtag_ir.v              
../rtl/rt/ip/debug_module/sba_control_fsm.v
../rtl/rt/ip/debug_module/trace_debug.v
../rtl/rt/ip/debug_module/debug_module.v


../rtl/rt/ip/clk_rst_cntrlr/apb_reg_clk_rst_ctrl.sv  
../rtl/rt/ip/clk_rst_cntrlr/clk_mux_2to1.sv                 
../rtl/rt/ip/clk_rst_cntrlr/system_clk_rst_gen.sv    
../rtl/rt/ip/clk_rst_cntrlr/clk_int_div.sv           
../rtl/rt/ip/clk_rst_cntrlr/rstgen_bypass.sv         
../rtl/rt/ip/clk_rst_cntrlr/sync.sv                  
../rtl/rt/ip/clk_rst_cntrlr/tc_clk_gating.sv  
../rtl/rt/ip/clk_rst_cntrlr/tc_clk_or2.sv  
../rtl/rt/ip/clk_rst_cntrlr/tc_clk_xor2.sv
../rtl/rt/ip/clk_rst_cntrlr/clk_mux_2to1_test.sv  
../rtl/rt/ip/clk_rst_cntrlr/system_rst_gen.sv      
../rtl/rt/ip/clk_rst_cntrlr/tc_clk_mux2.sv
../rtl/rt/ip/clk_rst_cntrlr/top_clk_rst_ctrl.sv 


../rtl/rt/ip/clk_and_rst_bypass/BOOT_CONTROLLER.sv     
../rtl/rt/ip/clk_and_rst_bypass/BOOT_PULSE_GEN_P.sv          
../rtl/rt/ip/clk_and_rst_bypass/BOOT_CONTROLLER_TOP.sv    
../rtl/rt/ip/clk_and_rst_bypass/PULSE_RST_GEN.sv
../rtl/rt/ip/clk_and_rst_bypass/PINAKA_CLK_RST_BYPASS_TOP.sv  


../rtl/rt/common/wd_timer/watchdog_sync.sv
../rtl/rt/common/wd_timer/watchdog_timer.sv


../rtl/rt/common/gpio_regfile/gpio_regfile.sv        
../rtl/rt/common/gpio_regfile/pinmux_gpio_ss.sv
../rtl/rt/common/gpio_regfile/gpio_top_regfile.sv


../rtl/rt/common/top_register/top_async_fifo.sv
../rtl/rt/common/top_register/top_cdc_ndff.sv
../rtl/rt/common/top_register/top_cdc_pulse_sync.sv
../rtl/rt/common/top_register/top_register.sv
../rtl/rt/common/top_register/top_register_cdc.sv

         
../rtl/rt/common/analog_register.sv

../rtl/rt/common/analog_preboot.sv




../rtl/rt/ip/int_ctrl/soc_ic_top.v             
../rtl/rt/ip/int_ctrl/soc_int_rec.v            
../rtl/rt/ip/int_ctrl/soc_mmr_ctrl.v           
../rtl/rt/ip/int_ctrl/soc_mmr_reg_file.v       
../rtl/rt/ip/int_ctrl/soc_priority_resolve.v 
../rtl/rt/ip/int_ctrl/soc_interrupt_control.v  
../rtl/rt/ip/int_ctrl/soc_irg.v                
../rtl/rt/ip/int_ctrl/soc_mmr_op_mux.v         
../rtl/rt/ip/int_ctrl/soc_mmr_top.v


../rtl/rt/common/pte_memory_wrapper/pte_controller.v  
../rtl/rt/common/mem/pte_memory.v
../rtl/rt/common/pte_memory_wrapper/pte_wrapper.v


../rtl/rt/ip/trace_ip/async_fifo.sv
../rtl/rt/ip/trace_ip/event_compare.sv    
../rtl/rt/ip/trace_ip/read_pointer.sv  
../rtl/rt/ip/trace_ip/trace_system_top.sv
../rtl/rt/ip/trace_ip/write_pointer.sv    
../rtl/rt/ip/trace_ip/capture_controller.sv 
../rtl/rt/ip/trace_ip/event_mux.sv   
../rtl/rt/ip/trace_ip/trace_cdc.sv
../rtl/rt/ip/trace_ip/trace_top.sv    
../rtl/rt/ip/trace_ip/circular_buffer.sv  
../rtl/rt/ip/trace_ip/gpio_output.sv  
../rtl/rt/ip/trace_ip/trace_register.sv  
../rtl/rt/ip/trace_ip/trace_wrapper.sv


../rtl/rt/ip/TRACE_UNIT/async_fifo_trace.sv   
../rtl/rt/ip/TRACE_UNIT/apb_slave_reg_core_trace.sv  
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat2.v              
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat3_sf1.v  
../rtl/rt/ip/TRACE_UNIT/atb_transmitter.sv                 
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat3_enableblock.v  
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat3_sf2.v  
../rtl/rt/ip/TRACE_UNIT/top_trace.sv
../rtl/rt/ip/TRACE_UNIT/branch_map.v                 
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat3_mux.v          
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat3_sf3.v  
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat1.v       
../rtl/rt/ip/TRACE_UNIT/inst_trace_enformat3_sf0.v          
../rtl/rt/ip/TRACE_UNIT/inst_trace_enmodule.v
../rtl/rt/ip/TRACE_UNIT/top_core_trace.sv


../rtl/rt/common/apb_slave_psel_wrapper.v


../rtl/rt/top/pinaka.sv
     
