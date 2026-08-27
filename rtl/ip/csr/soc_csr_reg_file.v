//CSR Register file
//top module where individual csr registers are instantiated
//

module soc_csr_reg_file
#(
parameter CSR_ADDR_WIDTH    = 0,
parameter DATA_WIDTH        = 0,
parameter INSTRUCTION_WIDTH = 0,
parameter PC_WIDTH          = 0
)

(
input 		                    csr_clk			            ,
input 		                    csr_rst			            ,
input                           dpc_valid_i                 ,
input        [31:0]             dpc_i                       ,
//input                           wdt_reset_i                 ,
input 		                    csr_write_en		        ,
input  [CSR_ADDR_WIDTH-1:0] 	csr_addr		            ,
input  [DATA_WIDTH-1:0]  	    csr_write_data		        ,
input 		                    csr_set_bit		            ,
input                           mret_valid_i                ,
input 		                    csr_clear_bit		        ,
input 		                    interrupt_valid 	        ,
input  [DATA_WIDTH-1:0]	        interrupt_code		        ,
//input 		                    exception_valid 	        ,
//input  [DATA_WIDTH-1:0]	        exception_code		        ,
//input 		                    ld_sd_misalign_valid        ,
//input [DATA_WIDTH-1:0] 	        ld_sd_misalign_addr	        ,
//input 		                    instr_misalign_valid        ,
//input 			                trap_valid_i		        ,
//input 			                stall_valid_i		        ,
//input 			                branch_valid_i		        ,
//input [DATA_WIDTH-1:0] 	        instr_misalign_addr	        ,
input 		                    mie_set			            ,//interrupt occurs
input 		                    mie_clear		            ,//end of interrupt
input 	[PC_WIDTH-1:0]	        csr_mepc_in			        ,
input 		                    csr_mepc_write_valid        ,
output  [PC_WIDTH-1:0]	        csr_mepc_o			        ,
//input 		                    invalid_instr_valid	        ,
//input  [INSTRUCTION_WIDTH-1:0]  invalid_instruction	        ,
input [7:0]   	                interrupt_lvl_pr_i	        ,//from zic
output [DATA_WIDTH-1:0] 	    int_active_level_priority_o,
//input 		                    exception_id_write_valid_i  ,
input		                    interrupt_id_write_valid_i  ,
//input  [PC_WIDTH-1:0]           pc			,
output [DATA_WIDTH-1:0] 	    mvendorid_o		,	
output [DATA_WIDTH-1:0] 	    marchid_o  		,     
output [DATA_WIDTH-1:0] 	    mimpid_o   		,     
output [DATA_WIDTH-1:0] 	    mhartid_o  		,     
output [DATA_WIDTH-1:0] 	    mstatus_o  		,     
output		                    mstatus_mie_o		,
output [DATA_WIDTH-1:0] 	    misa_o	   		,     
//output [DATA_WIDTH-1:0] 	    medeleg_o  		,     
//output [DATA_WIDTH-1:0] 	    mideleg_o  		,     
output [DATA_WIDTH-1:0] 	    mie_o 	   		,     
output [DATA_WIDTH-1:0] 	    mtvec_o	   		,	
//output [DATA_WIDTH-1:0] 	    mcounter_o 		,     
output [DATA_WIDTH-1:0] 	    mscratch_o 		,	
output [DATA_WIDTH-1:0] 	    mepc_o 	   		,
output [DATA_WIDTH-1:0] 	    mcause_o   		,	
output [DATA_WIDTH-1:0] 	    mtval_o    		,	
//output [DATA_WIDTH-1:0] 	    mip_o 			,
output [DATA_WIDTH-1:0] 	    satp_o 			,
output                   	    satp_mode_o 			,
output [8:0]             	    satp_asid_o 			,
output [21:0]            	    satp_ppn_o 			,

//output [DATA_WIDTH-1:0]         mcounter_inhibit_o 	,		
//output [DATA_WIDTH-1:0]         mcycle_o			,
//output [DATA_WIDTH-1:0]         minstret_o		,
//output [DATA_WIDTH-1:0]         zic_base_addr_o		,
//output [DATA_WIDTH-1:0]         mhpm_counter3_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter4_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter5_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter6_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter7_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter8_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter9_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter10_o 		, 
//output [DATA_WIDTH-1:0]         mhpm_counter11_o		,
//output [DATA_WIDTH-1:0]         mhpm_counter12_o		,
//output [DATA_WIDTH-1:0]         mhpm_counter13_o		,
//output [DATA_WIDTH-1:0]         mhpm_counter14_o		,
//output [DATA_WIDTH-1:0]         mhpm_counter15_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter16_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter17_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter18_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter19_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter20_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter21_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter22_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter23_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter24_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter25_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter26_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter27_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter28_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter29_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter30_o		,
//output [DATA_WIDTH-1:0]   mhpm_counter31_o	    ,
//output [DATA_WIDTH-1:0] mhpm_event3_o ,     
//output [DATA_WIDTH-1:0] mhpm_event4_o ,
//output [DATA_WIDTH-1:0] mhpm_event5_o ,
//output [DATA_WIDTH-1:0] mhpm_event6_o ,
//output [DATA_WIDTH-1:0] mhpm_event7_o ,
//output [DATA_WIDTH-1:0] mhpm_event8_o ,
//output [DATA_WIDTH-1:0] mhpm_event9_o ,
//output [DATA_WIDTH-1:0] mhpm_event10_o,
//output [DATA_WIDTH-1:0] mhpm_event11_o,
//output [DATA_WIDTH-1:0] mhpm_event12_o,
//output [DATA_WIDTH-1:0] mhpm_event13_o,
//output [DATA_WIDTH-1:0] mhpm_event14_o,
//output [DATA_WIDTH-1:0] mhpm_event15_o,
//output [DATA_WIDTH-1:0] mhpm_event16_o,
//output [DATA_WIDTH-1:0] mhpm_event17_o,
//output [DATA_WIDTH-1:0] mhpm_event18_o,
//output [DATA_WIDTH-1:0] mhpm_event19_o,
//output [DATA_WIDTH-1:0] mhpm_event20_o,
//output [DATA_WIDTH-1:0] mhpm_event21_o,
//output [DATA_WIDTH-1:0] mhpm_event22_o,
//output [DATA_WIDTH-1:0] mhpm_event23_o,
//output [DATA_WIDTH-1:0] mhpm_event24_o,
//output [DATA_WIDTH-1:0] mhpm_event25_o,
//output [DATA_WIDTH-1:0] mhpm_event26_o,
//output [DATA_WIDTH-1:0] mhpm_event27_o,
//output [DATA_WIDTH-1:0] mhpm_event28_o,
//output [DATA_WIDTH-1:0] mhpm_event29_o,
//output [DATA_WIDTH-1:0] mhpm_event30_o,
//output [DATA_WIDTH-1:0] mhpm_event31_o,
//output [DATA_WIDTH-1:0] data_mem_max_addr_o,
input           ebreak_valid_i          ,
//input           trigger_valid_i         ,
input           haltreq_valid_i         ,
//input           single_step_valid_i     ,
input           reset_haltreq_valid_i   ,
output [DATA_WIDTH-1:0]   dcsr_o                  ,
output [PC_WIDTH-1:0]   dpc_o                   ,

input           dbg_csr_write_en_i      ,
input [CSR_ADDR_WIDTH-1:0]    dbg_csr_addr_i          ,
input [DATA_WIDTH-1:0]    dbg_csr_write_data_i    ,
input           debug_mode_valid_i      ,
//input           dbg_ndm_reset_i         ,
//input           dbg_hart_reset_i       ,
//input    [PC_WIDTH-1:0]  branch_pc_i  ,  
//output [DATA_WIDTH-1:0] uart_reset_csr_o
input           mtval_write_valid,
input  [PC_WIDTH-1:0]        mtval_i
);

//wire int_exp_valid_w;
//assign int_exp_valid_w = interrupt_valid ;//| exception_valid ;
wire [7:0]mintststus_w;
wire [7:0] prv_int_lvl_pr_w ;


marchid_csr 
#(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)

marchid_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.march_id_o		(marchid_o		)
);

misa_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
misa_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.misa_csr_o		(misa_o			)
);

mvendorid_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mvendorid_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.mvendor_id_o		(mvendorid_o		) 
);

mimpid_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mimpid_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.mimp_id_o 		(mimpid_o		)
);

mhartid_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mhartid_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.mhart_id_o		(mhartid_o		) 
);

mstatus_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mstatus_csr_inst
(
.csr_clk		         (csr_clk		        ),
.csr_rst		         (csr_rst		        ),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		     (csr_write_data		),
.csr_write_enable	     (csr_write_en	        ),
.csr_write_addr		     (csr_addr		        ),
.csr_set_bit		     (csr_set_bit  		    ),
.csr_clear_bit		     (csr_clear_bit		    ),
.mie_set		         (mie_set		        ),//interrupt occurence
.mie_clear		         (mie_clear		        ),//end of interrupt
.mstatus_o 		         (mstatus_o		        ),
.mstatus_mie_o		     (mstatus_mie_o		    ),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )

);

mscratch_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mscratch_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_enable	(csr_write_en	),
.csr_write_addr		(csr_addr		),
.csr_set_bit		(csr_set_bit  		),
.csr_clear_bit		(csr_clear_bit		),
.mscratch_o 		(mscratch_o		),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )


);

mcause_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mcause_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_en		(csr_write_en		),
.csr_write_addr		(csr_addr		),
//.interrupt_valid	(interrupt_valid	),
.csr_set_bit 		(csr_set_bit		),
.csr_clear_bit		(csr_clear_bit		),
//.exception_valid	(exception_valid	),
//.exception_code		(exception_code		),
.interrupt_code		(interrupt_code		),
.mcause_o   		(mcause_o		),
//.exception_id_write_valid_i(exception_id_write_valid_i),
.interrupt_id_write_valid_i(interrupt_id_write_valid_i),
.mintstatus_i       	(mintststus_w       	),
.prv_int_lvl_pr_o   	(prv_int_lvl_pr_w   	),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )
);

mtval_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mtval_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
.mtval_i        (mtval_i        ),
.mtval_write_valid(mtval_write_valid),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_en		(csr_write_en		),
.csr_write_addr		(csr_addr		),
.csr_set_bit		(csr_set_bit  		),
.csr_clear_bit		(csr_clear_bit		),
//.ld_sd_misalign_valid	(ld_sd_misalign_valid	),	
//.ld_sd_misalign_addr 	(ld_sd_misalign_addr 	),   
//.instr_misalign_valid	(instr_misalign_valid	),	
//.instr_misalign_addr 	(instr_misalign_addr 	),   
//.illegal_instr_valid	(invalid_instr_valid	),
//.illegal_instruction 	(invalid_instruction	),	
//.trap_valid		(exception_valid	),//exceptions
.mtval_o  		(mtval_o		) ,
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )

);
/*
mip_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mip_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_enable	(csr_write_en		),
.csr_write_addr		(csr_addr		),
.csr_set_bit		(csr_set_bit  		),
.csr_clear_bit		(csr_clear_bit		),
.mip_o 			(mip_o			),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )

);
*/
mie_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mie_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_enable	(csr_write_en	),
.csr_write_addr		(csr_addr		),
.csr_set_bit		(csr_set_bit  		),
.csr_clear_bit		(csr_clear_bit		),
.mie_o 			(mie_o			),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      )
.debug_mode_valid_i      (debug_mode_valid_i    )

);

mepc_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mepc_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_en		(csr_write_en		),
.csr_write_addr		(csr_addr		),
//.int_exp_valid		(int_exp_valid_w	),
//.instr_misalign_valid	(instr_misalign_valid	),
.csr_set_bit		(csr_set_bit  		),
.csr_clear_bit		(csr_clear_bit		),
//.pc			(pc			),
.csr_mepc_in		(csr_mepc_in		),
.csr_mepc_write_valid	(csr_mepc_write_valid	),
.csr_mepc_o		(csr_mepc_o		),	
.mepc_csr_o   		(mepc_o			),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      )
.debug_mode_valid_i      (debug_mode_valid_i    )

);

mtvec_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mtvec_csr_inst
(
.csr_clk		(csr_clk),
.csr_rst		(csr_rst),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_enable	(csr_write_en	),
.csr_write_addr		(csr_addr		),
.csr_set_bit		(csr_set_bit  ),
.csr_clear_bit		(csr_clear_bit),
.mtvec_o 		(mtvec_o),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      )
.debug_mode_valid_i      (debug_mode_valid_i    )


);

dcsr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
dcsr_inst
(
.dcsr_clk_i              (csr_clk              ),
.dcsr_rst_i              (csr_rst              ),
//.wdt_reset_i    (wdt_reset_i    ),
.dcsr_write_data_i       (csr_write_data       ),
.dcsr_addr_i             (csr_addr             ),
.dcsr_write_en_i         (csr_write_en         ),
.dcsr_set_en_i           (csr_set_bit          ),
.dcsr_clear_en_i         (csr_clear_bit        ),
.ebreak_valid_i          (ebreak_valid_i       ),
//.trigger_valid_i         (trigger_valid_i      ),
.haltreq_valid_i         (haltreq_valid_i      ),
//.single_step_valid_i     (single_step_valid_i  ),
.reset_haltreq_valid_i   (reset_haltreq_valid_i),
//.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
//.dbg_csr_addr_i          (dbg_csr_addr_i        ),
//.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.debug_mode_valid_i      (debug_mode_valid_i    ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.dcsr_o                  (dcsr_o               )

);

//-----------------new DPC --------------------------
dpc_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
//.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
dpc_inst_2
(
.csr_clk(csr_clk)			,
.csr_rst(csr_rst)			,
.csr_dpc_in(dpc_i)		,
.csr_dpc_write_valid(dpc_valid_i),
.dbg_csr_write_en_i(dbg_csr_write_en_i),
.dbg_csr_addr_i(dbg_csr_addr_i),
.dbg_csr_write_data_i(dbg_csr_write_data_i),
.debug_mode_valid_i(debug_mode_valid_i),
//.dpc_csr_o()		,
.csr_dpc_o(dpc_o)

);
  
      


//----------------------------------------------------
/*
dpc #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
dpc_inst
(
.dpc_clk_i             (csr_clk             ),
.dpc_rst_i             (csr_rst             ),
//.wdt_reset_i    (wdt_reset_i    ),
.dpc_write_en_i        (csr_write_en        ),
.dpc_set_en_i          (csr_set_bit         ),
.dpc_clear_en_i        (csr_clear_bit       ),
.dpc_addr_i            (csr_addr            ),
.dpc_write_data_i      (csr_write_data      ),
.ebreak_valid_i        (ebreak_valid_i      ),
.trigger_valid_i       (trigger_valid_i     ),
.single_step_valid_i   (single_step_valid_i ),
.haltreq_valid_i       (haltreq_valid_i     ),
.pc_i                  (pc                  ),
.dpc_o                 (               ),
//.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
//.dbg_csr_addr_i          (dbg_csr_addr_i        ),
//.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.debug_mode_valid_i      (debug_mode_valid_i    ),
.dbg_ndm_reset_i         (1'd0       ),
.dbg_hart_reset_i        (1'd0      ),
.branch_valid_i    (branch_valid_i), 
.branch_pc_i       (branch_pc_i) ,
.stall_valid_i      (stall_valid_i)

);
*/


satp_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
satp_csr_inst
(
.csr_clk		(csr_clk		),
.csr_rst		(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.csr_write_data		(csr_write_data		),
.csr_write_enable	(csr_write_en	),
.csr_write_addr		(csr_addr		),
.csr_set_bit		(csr_set_bit  		),
.csr_clear_bit		(csr_clear_bit		),
.satp_o 			(satp_o			),
.satp_mode_o  (satp_mode_o),
.satp_asid_o  (satp_asid_o),
.satp_ppn_o 	(satp_ppn_o),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )

);

mintstatus_csr #(
.CSR_ADDR_WIDTH    (CSR_ADDR_WIDTH    ),
.DATA_WIDTH        (DATA_WIDTH        ),
.INSTRUCTION_WIDTH (INSTRUCTION_WIDTH ),
.PC_WIDTH          (PC_WIDTH          )
)
mintstatus_csr_inst
(
.csr_clk					(csr_clk		),
.csr_rst					(csr_rst		),
//.wdt_reset_i    (wdt_reset_i    ),
.interrupt_valid_i				(interrupt_valid	),
//.exception_valid_i              (exception_valid),
.mret_valid_i					(mret_valid_i		),
.int_active_level_priority_i		(interrupt_lvl_pr_i	),
.int_active_level_priority_o		(int_active_level_priority_o)	,
.mintstatus_o           (mintststus_w),
.prv_int_lvl_pr_i        (prv_int_lvl_pr_w),
.dbg_csr_write_en_i      (dbg_csr_write_en_i    ),
.dbg_csr_addr_i          (dbg_csr_addr_i        ),
.dbg_csr_write_data_i    (dbg_csr_write_data_i  ),
//.dbg_ndm_reset_i         (dbg_ndm_reset_i       ),
//.dbg_hart_reset_i        (dbg_hart_reset_i      ),
.debug_mode_valid_i      (debug_mode_valid_i    )

);


endmodule
