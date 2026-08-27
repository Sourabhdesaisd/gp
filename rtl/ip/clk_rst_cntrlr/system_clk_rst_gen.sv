// Copyright 2023 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// This module generates the clocks for ControlPULP in different use-cases:
// 1. External clocks: two external clocks generates soc, cluster, peripheral and
//    timer clocks via clock dividers.
//    Used with ControlPULP  IP.

// 2. External clocks, FPGA map: a reference clock feeds Xilinx clock generators,
//    which generate soc, cluster, periph and timer clocks.
//    Used for ControlPULP on FPGA.

//`include "pulp_soc_defines.sv"

module system_clk_rst_gen #(
    parameter DATA_WIDTH = 32,
              RST_COUNTER=50,
    
//              NUM_INPUTS = 2,
//              NUM_SYNC_STAGES = 2,
              RATIO = 5,
              REGISTER_WIDTH_CLK_RST = ($clog2(RATIO+1))+1
//              SelWidth = $clog2(NUM_INPUTS)
    )(
  // from boot  
  input logic  sys_clk_i,
  input logic  rc_clk_i,
//  input logic  clk_sel_i,

  // memory clk switch indication
  input logic mem_clksel_rst_ctrl_i,

  // from apb reg's
//  input logic [DATA_WIDTH-1:0] clk_ctrl_reg_i,
  input logic [REGISTER_WIDTH_CLK_RST-1:0] clk_div_per_reg_i,
  input logic [REGISTER_WIDTH_CLK_RST-1:0] clk_div_debug_reg_i,
  input logic [5:0] rst_ctrl_reg_i,

  // status output
  output logic [8:0] status_reg_o,

  output logic                  mux_sync_status_ctrl_o,

  // from watchdog
  input logic [1:0] wdt_rst_scope_i,
  input logic       wdt_rst_req_i,

  // from debug
  input logic non_dbg_rst_req_i,

  // from core
  input  logic debug_clksel_i,

  // from boot
  input logic  por_ni,

  // generated reset outputs
  output logic rstn_soc_sync_o,
  output logic rstn_peripheral_sync_o,
  output logic rstn_debug_sync_o,
  output logic rstn_i2c_sync_o,
  output logic rstn_uart_sync_o,
  output logic rstn_spi_sync_o,

  // DFT ports for scan testing
  input logic  test_mode_soc_rstn_i,
  input logic  test_mode_soc_rstn_en_i,

  input logic  test_mode_peripheral_rstn_i,
  input logic  test_mode_peripheral_rstn_en_i,

  input logic  test_mode_debug_rstn_i,
  input logic  test_mode_debug_rstn_en_i,

  input logic test_mode_spi_rstn_en_i,
  input logic test_mode_spi_rstn_i,

  input logic test_mode_uart_rstn_en_i,
  input logic test_mode_uart_rstn_i,

  input logic test_mode_i2c_rstn_en_i,
  input logic test_mode_i2c_rstn_i,

  input logic  test_mode_clk_peripheral_mux_i,
  input logic  test_mode_clk_soc_mux_i,

  input logic  test_mode_en_peripheral_mux_i,
  input logic  test_mode_en_soc_mux_i,

  input logic  test_mode_div_peripheral_i,
  input logic  test_mode_div_debug_i,

  // generated output clocks
  output logic clk_soc_o,
  output logic clk_per_o,
  output logic clk_for_debug_o
);

  localparam RST_CNT_BIT_WIDTH=$clog2(RST_COUNTER)+1;
//  localparam REGISTER_WIDTH_CLK_RST = ($clog2(RATIO+1))+1;

  logic wdt_rst_req_sys_q;
  logic [1:0] wdt_rst_scope_q;

  

  logic clk_soc;
  logic clk_per;
  logic clk_for_peripheral;
  logic clk_for_debug;


//  logic rstn_soc;
//  logic rstn_soc_sync;
//  logic rstn_peripheral_sync;
//  logic rstn_debug_sync;

  logic mem_clksel_rst_ctrl_rc_q;
  logic mem_clksel_rst_ctrl_sys_q;

//  logic so_rstn;
//  logic pe_rstn;
//  logic de_rstn;
 
//  logic hard_rst_gen_q;
//  logic [RST_CNT_BIT_WIDTH-1:0] hard_rst_cnt_q;

//  logic rstn_soc_local;
//  logic rstn_peripheral_local;
//  logic rstn_debug_local;

  logic soc_rst_value_q1;
  logic soc_rst_value_q2;
  logic per_rst_value_q1;
  logic per_rst_value_q2;
  logic debug_rst_value_q1;
  logic debug_rst_value_q2;
  logic i2c_rst_value_q1;
  logic i2c_rst_value_q2;
  logic uart_rst_value_q1;
  logic uart_rst_value_q2;
  logic spi_rst_value_q1;
  logic spi_rst_value_q2;




// internal wires from reg to clk divider ctrl
//  logic div_per_en_w;
//  logic div_valid_w;
//  logic div_ready_w;
  logic [($clog2(RATIO+1))-1:0] div_per_value_w;

//  logic div_debug_en_w;
  logic [($clog2(RATIO+1))-1:0] div_debug_value_w;

  logic test_mode_div_peripheral_sync_q;
  logic test_mode_div_debug_sync_q;
//  logic div_ready_status_clear_w;

// cdc signals
   logic rstn_soc_sync_q1;
   logic rstn_soc_sync_q2;
   logic rstn_peripheral_sync_q1;
   logic rstn_peripheral_sync_q2;
   logic rstn_debug_sync_q1;
   logic rstn_debug_sync_q2;
   logic debug_clksel_q1;
   logic debug_clksel_q2;
   logic clk_div_per_en_q1;
   logic clk_div_per_en_q2;
   logic clk_div_debug_en_q1;
   logic clk_div_debug_en_q2;
   logic rstn_i2c_sync_q1;
   logic rstn_i2c_sync_q2;
   logic rstn_uart_sync_q1;
   logic rstn_uart_sync_q2;
   logic rstn_spi_sync_q1;
   logic rstn_spi_sync_q2;



  // division block ctrl signals assigning
//  assign div_per_en_w         = clk_div_per_reg_i[DATA_WIDTH-1];
//  assign div_valid_w    = clk_div_reg_i[DATA_WIDTH-2];
  assign div_per_value_w      = clk_div_per_reg_i[($clog2(RATIO+1))-1:0];
//  assign div_ready_status_clear_w = clk_div_reg_i[DATA_WIDTH-3];

  assign div_debug_value_w    = clk_div_debug_reg_i[($clog2(RATIO+1))-1:0];
//  assign div_debug_en_w       = clk_div_debug_reg_i[DATA_WIDTH-1];

//cdc
    sync #(.STAGES(2)) i_test_mode_div_peripheral_sync (
      .clk_i    ( sys_clk_i                       ),
      .rst_ni   ( por_ni                        ),
      .serial_i ( test_mode_div_peripheral_i               ),                        
      .serial_o ( test_mode_div_peripheral_sync_q                  )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_div_debug_sync (
      .clk_i    ( sys_clk_i                       ),
      .rst_ni   ( por_ni                        ),
      .serial_i ( test_mode_div_debug_i               ),                        
      .serial_o ( test_mode_div_debug_sync_q                  )
    );

//  logic div_per_en_r;
//  logic div_debug_en_r;
/*
   sync #(.STAGES(2)) i_div_per_en_r_sync (
      .clk_i    ( sys_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( clk_div_per_reg_i[REGISTER_WIDTH_CLK_RST-1]     ),                        
      .serial_o ( div_per_en_r        )
    );

   sync #(.STAGES(2)) i_div_debug_en_r_sync (
      .clk_i    ( sys_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( clk_div_debug_reg_i[REGISTER_WIDTH_CLK_RST-1]     ),                        
      .serial_o ( div_debug_en_r        )
    );
*/



   clk_int_div #(                                           
           .DIV_VALUE_WIDTH($clog2(RATIO+1)),                     
           .DEFAULT_DIV_VALUE(RATIO)                              
         ) i_clk_int_div_peripheral (                                         
           .clk_i(sys_clk_i                             ),                                                
           .rst_ni(por_ni                               ),                                               
           .test_mode_en_i(test_mode_div_peripheral_sync_q   ),                           
           .en_i(clk_div_per_reg_i[REGISTER_WIDTH_CLK_RST-1]                           ),           // from apb                                      
           .div_i(div_per_value_w                       ), // Ignored, used default value\n             
           .div_valid_i(1'b1                            ),                                    
//           .div_ready_o(),                                        
           .clk_o(clk_for_peripheral                    )
//           .cycl_count_o()
         );                         

   clk_int_div #(                                           
           .DIV_VALUE_WIDTH($clog2(RATIO+1)),                     
           .DEFAULT_DIV_VALUE(RATIO)                              
         ) i_clk_int_div_debug (                                         
           .clk_i(sys_clk_i                             ),                                                
           .rst_ni(por_ni                               ),                                               
           .test_mode_en_i(test_mode_div_debug_sync_q        ),                           
           .en_i(clk_div_debug_reg_i[REGISTER_WIDTH_CLK_RST-1]                         ),           // from apb                                      
           .div_i(div_debug_value_w                     ), // Ignored, used default value\n             
           .div_valid_i(1'b1                            ),                                    
//           .div_ready_o(),                                        
           .clk_o(clk_for_debug                         )
//           .cycl_count_o()
         );                              



  // Allow clock muxing if dividers are faulty: ref_clk passthrough

/*
    clk_mux_glitch_free AUTO_TEMPLATE "i_clk_mux_\(.*\)" (
                    .clks_i({sys_clk_i,ref_clk_i}),
                    .test_clk_i(),
                    .test_en_i(),
                    .async_rstn_i(rstn_glob_i),
                    .async_sel_i(clk_sel_i),
                    .clk_o(clk_@),
);
*/
   
  logic test_mode_en_soc_mux_sync_q;
  logic test_mode_en_per_mux_sync_q;

//cdc
   sync #(.STAGES(2)) i_test_mode_clk_mux_soc_sync (
      .clk_i    ( test_mode_clk_soc_mux_i           ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_en_soc_mux_i            ),                        
      .serial_o ( test_mode_en_soc_mux_sync_q        )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_clk_mux_per_sync (
      .clk_i    ( test_mode_clk_peripheral_mux_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_en_peripheral_mux_i     ),                        
      .serial_o ( test_mode_en_per_mux_sync_q        )
    );




 clk_mux_2to1 i_mux_clk_soc (
                    .clk_0_i(sys_clk_i                      ),
                    .rst_ni(por_ni                          ),
                    .clk_1_i(clk_for_debug                  ),
                    .sel_i(debug_clksel_i                   ),
                    .test_clk_i(test_mode_clk_soc_mux_i     ),
                    .test_en_i(test_mode_en_soc_mux_sync_q       ),
                    .clk_o(clk_soc                          )
 );


  clk_mux_2to1 i_mux_clk_peripheral (
                    .clk_0_i(clk_for_peripheral                     ),
                    .rst_ni(por_ni                                  ),
                    .clk_1_i(clk_for_debug                          ),
                    .sel_i(debug_clksel_i                           ),
                    .test_clk_i(test_mode_clk_peripheral_mux_i      ),
                    .test_en_i(test_mode_en_per_mux_sync_q        ),
                    .clk_o(clk_per                                  )
 );






  // Reset synchronization
//  assign rstn_soc = rstn_glob_i;


  always_ff@(posedge clk_soc or negedge por_ni) begin
    if(!por_ni) begin
        soc_rst_value_q1 <= 1'b0;
        soc_rst_value_q2 <= 1'b0;
    end else begin
        soc_rst_value_q1 <= rst_ctrl_reg_i[0];
        soc_rst_value_q2 <= soc_rst_value_q1;

    end
  end

    always_ff@(posedge clk_per or negedge por_ni) begin
    if(!por_ni) begin
        per_rst_value_q1 <= 1'b0;
        per_rst_value_q2 <= 1'b0;
    end else begin
        per_rst_value_q1 <= rst_ctrl_reg_i[1];
        per_rst_value_q2 <= per_rst_value_q1;

    end
  end

    always_ff@(posedge clk_for_debug or negedge por_ni) begin
    if(!por_ni) begin
        debug_rst_value_q1 <= 1'b0;
        debug_rst_value_q2 <= 1'b0;
    end else begin
        debug_rst_value_q1 <= rst_ctrl_reg_i[2];
        debug_rst_value_q2 <= debug_rst_value_q1;

    end
  end

      always_ff@(posedge clk_per or negedge por_ni) begin
    if(!por_ni) begin
        i2c_rst_value_q1 <= 1'b0;
        i2c_rst_value_q2 <= 1'b0;
    end else begin
        i2c_rst_value_q1 <= rst_ctrl_reg_i[3];
        i2c_rst_value_q2 <= i2c_rst_value_q1;

    end
  end

    always_ff@(posedge clk_per or negedge por_ni) begin
    if(!por_ni) begin
        uart_rst_value_q1 <= 1'b0;
        uart_rst_value_q2 <= 1'b0;
    end else begin
        uart_rst_value_q1 <= rst_ctrl_reg_i[4];
        uart_rst_value_q2 <= uart_rst_value_q1;

    end
  end

    always_ff@(posedge clk_per or negedge por_ni) begin
    if(!por_ni) begin
        spi_rst_value_q1 <= 1'b0;
        spi_rst_value_q2 <= 1'b0;
    end else begin
        spi_rst_value_q1 <= rst_ctrl_reg_i[5];
        spi_rst_value_q2 <= spi_rst_value_q1;

    end
  end



/*
  assign rstn_soc_local         =  soc_rst_value_q2;
  assign rstn_peripheral_local  =  per_rst_value_q2;
  assign rstn_debug_local       =  debug_rst_value_q2;



//  assign rstn_soc_local         = por_ni & rst_ctrl_reg_i[0];
//  assign rstn_peripheral_local  = por_ni & rst_ctrl_reg_i[1];
//  assign rstn_debug_local       = por_ni & rst_ctrl_reg_i[2];

  logic test_mode_soc_rstn_sync_q;
  logic test_mode_per_rstn_sync_q;
  logic test_mode_debug_rstn_sync_q;
//cdc
   sync #(.STAGES(2)) i_test_mode_soc_rst_sync (
      .clk_i    ( clk_soc                   ),
      .rst_ni   ( por_ni                    ),
      .serial_i ( test_mode_soc_rstn_i       ),                        
      .serial_o ( test_mode_soc_rstn_sync_q  )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_per_rst_sync (
      .clk_i    ( clk_per    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_peripheral_rstn_i     ),                        
      .serial_o ( test_mode_per_rstn_sync_q        )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_debug_rst_sync (
      .clk_i    ( clk_for_debug    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_debug_rstn_i     ),                        
      .serial_o ( test_mode_debug_rstn_sync_q        )
    );




  rstgen_bypass i_soc_rstgen (
    .clk_i (clk_soc               ),
    .por_ni(por_ni                  ),
    .rst_ni(rstn_soc_local          ),
    .rst_test_mode_ni(test_mode_soc_rstn_sync_q),
    .test_mode_i(test_mode_soc_rstn_en_i),
    .rst_no (rstn_soc_sync          )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                // not used
  );


  rstgen_bypass i_peripheral_rstgen (
    .clk_i (clk_per              ),
    .por_ni(por_ni                          ),
    .rst_ni(rstn_peripheral_local           ),
    .rst_test_mode_ni(test_mode_per_rstn_sync_q ),
    .test_mode_i(test_mode_peripheral_rstn_en_i),
    .rst_no (rstn_peripheral_sync           )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );

  rstgen_bypass i_debug_rstgen (
    .clk_i (clk_for_debug                   ),
    .por_ni(por_ni                          ),
    .rst_ni(rstn_debug_local                ),
    .rst_test_mode_ni(test_mode_debug_rstn_sync_q      ),
    .test_mode_i(test_mode_debug_rstn_en_i),
    .rst_no (rstn_debug_sync                )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );

*/
/*
  logic div_ready_sticky_r;

always_ff @(posedge ref_clk_i or negedge rstn_glob_i) begin
  if (!rstn_glob_i)
    div_ready_sticky_r <= 1'b0;

  else if (div_ready_w)
    div_ready_sticky_r <= 1'b1;

  else if (div_ready_status_clear_w)
    div_ready_sticky_r <= 1'b0;
end
*/

//  logic mux_sync_status_ctrl;

//cdc
    always_ff@(posedge clk_per or negedge por_ni) begin
      if(!por_ni) begin
          rstn_soc_sync_q1          <= 1'b0;
          rstn_soc_sync_q2          <= 1'b0;
          rstn_peripheral_sync_q1   <= 1'b0;
          rstn_peripheral_sync_q2   <= 1'b0;
          rstn_debug_sync_q1        <= 1'b0;
          rstn_debug_sync_q2        <= 1'b0;
          rstn_i2c_sync_q1          <= 1'b0;
          rstn_i2c_sync_q2          <= 1'b0;
          rstn_uart_sync_q1         <= 1'b0;
          rstn_uart_sync_q2         <= 1'b0;
          rstn_spi_sync_q1          <= 1'b0;
          rstn_spi_sync_q2          <= 1'b0;
          debug_clksel_q1           <= 1'b0;
          debug_clksel_q2           <= 1'b0;
          clk_div_per_en_q1         <= 1'b1;
          clk_div_per_en_q2         <= 1'b1;
          clk_div_debug_en_q1       <= 1'b1;
          clk_div_debug_en_q2       <= 1'b1;
      end else begin
          rstn_soc_sync_q1          <= rstn_soc_sync_o;
          rstn_soc_sync_q2          <= rstn_soc_sync_q1;
          rstn_peripheral_sync_q1   <= rstn_peripheral_sync_o;
          rstn_peripheral_sync_q2   <= rstn_peripheral_sync_q1;
          rstn_debug_sync_q1        <= rstn_debug_sync_o;
          rstn_debug_sync_q2        <= rstn_debug_sync_q1;
          rstn_i2c_sync_q1          <= rstn_i2c_sync_o;
          rstn_i2c_sync_q2          <= rstn_i2c_sync_q1;
          rstn_uart_sync_q1         <= rstn_uart_sync_o;
          rstn_uart_sync_q2         <= rstn_uart_sync_q1;
          rstn_spi_sync_q1          <= rstn_spi_sync_o;
          rstn_spi_sync_q2          <= rstn_spi_sync_q1;
          debug_clksel_q1           <= debug_clksel_i;
          debug_clksel_q2           <= debug_clksel_q1;
          clk_div_per_en_q1         <= clk_div_per_reg_i[REGISTER_WIDTH_CLK_RST-1]; //div_per_en_w;
          clk_div_per_en_q2         <= clk_div_per_en_q1;
          clk_div_debug_en_q1       <= clk_div_debug_reg_i[REGISTER_WIDTH_CLK_RST-1]; //div_debug_en_w;
          clk_div_debug_en_q2       <= clk_div_debug_en_q1;
      end
    end



  always_ff@(posedge clk_per or negedge por_ni) begin
    if(!por_ni) begin
        status_reg_o         <= 9'b0; //{DATA_WIDTH{1'b0}};
        mux_sync_status_ctrl_o <= 1'b0;
    end else begin
        status_reg_o         <= {clk_div_debug_en_q2,clk_div_per_en_q2,rstn_spi_sync_q2, rstn_uart_sync_q2,
                                    rstn_i2c_sync_q2,rstn_debug_sync_q2,rstn_peripheral_sync_q2, rstn_soc_sync_q2,debug_clksel_q2};
        mux_sync_status_ctrl_o <= 1'b1;
    end

//            status_reg_o[0] = debug_clksel_i;
//
//            status_reg_o[1] = rstn_soc_sync;
//            status_reg_o[2] = rstn_peripheral_sync;
//            status_reg_o[3] = rstn_debug_sync;
//
//            status_reg_o[4] = clk_div_per_reg_i[DATA_WIDTH-1];
//            status_reg_o[5] = clk_div_debug_reg_i[DATA_WIDTH-1];
  end

//  logic [5:0] hard_rst_cnt_q;


   sync #(.STAGES(2)) i_mem_clksel_rst_ctrl_rc_sync (
      .clk_i    ( rc_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( ~mem_clksel_rst_ctrl_i     ),                        
      .serial_o ( mem_clksel_rst_ctrl_rc_q        )
    );


   sync #(.STAGES(2)) i_mem_clksel_rst_ctrl_sys_sync (
      .clk_i    ( clk_soc    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( mem_clksel_rst_ctrl_rc_q     ),                        
      .serial_o ( mem_clksel_rst_ctrl_sys_q        )
    );
/*
logic wdt_rst_req_rc_q;

      sync #(.STAGES(2)) i_wdt_req_rc_sync (
      .clk_i    ( rc_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( wdt_rst_req_i     ),                        
      .serial_o ( wdt_rst_req_rc_q        )
    );
*/

      sync #(.STAGES(2)) i_wdt_req_rc2sys_sync (
      .clk_i    ( clk_soc    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( wdt_rst_req_i     ),                        
      .serial_o ( wdt_rst_req_sys_q        )
    );

   always_ff@(posedge clk_soc or negedge por_ni) begin
    if(!por_ni) begin
        wdt_rst_scope_q <= 2'b0;
    end else if(wdt_rst_req_sys_q) begin
        wdt_rst_scope_q <= wdt_rst_scope_i;
    end
   end



   system_rst_gen i_rst_gen (

//      .sys_clk_i(sys_clk_i),
      .soc_clk_i(clk_soc),
      .per_clk_i(clk_per),
      .dbg_clk_i(clk_for_debug),

      .por_ni(por_ni),
      .mem_core_clk_sync_done(mem_clksel_rst_ctrl_sys_q),

      .test_mode_debug_rstn_en_i(test_mode_debug_rstn_en_i),
      .test_mode_debug_rstn_i(test_mode_debug_rstn_i),
      .test_mode_peripheral_rstn_en_i(test_mode_peripheral_rstn_en_i),
      .test_mode_peripheral_rstn_i(test_mode_peripheral_rstn_i),
      .test_mode_soc_rstn_en_i(test_mode_soc_rstn_en_i),
      .test_mode_soc_rstn_i(test_mode_soc_rstn_i),
      .test_mode_spi_rstn_en_i(test_mode_spi_rstn_en_i),
      .test_mode_spi_rstn_i(test_mode_spi_rstn_i),
      .test_mode_uart_rstn_en_i(test_mode_uart_rstn_en_i),
      .test_mode_uart_rstn_i(test_mode_uart_rstn_i),
      .test_mode_i2c_rstn_en_i(test_mode_i2c_rstn_en_i),
      .test_mode_i2c_rstn_i(test_mode_i2c_rstn_i),

    // from watchdog module
      .wdt_rst_scope_i(wdt_rst_scope_q),
      .wdt_rst_req_i(wdt_rst_req_sys_q),

    // from debug module
      .non_dbg_rst_req_i(non_dbg_rst_req_i),   

    // from apb reg's
      .apb_core_rst_req_i(soc_rst_value_q2),
      .apb_peripheral_rst_req_i(per_rst_value_q2), // all peripherals reset req
      .apb_dbg_rst_req_i(debug_rst_value_q2),
      .apb_i2c_rst_req_i(i2c_rst_value_q2),
      .apb_uart_rst_req_i(uart_rst_value_q2),
      .apb_spi_rst_req_i(spi_rst_value_q2),

      .core_rstn_o(rstn_soc_sync_o),
      .peripheral_rstn_o(rstn_peripheral_sync_o),
      .dbg_rstn_o(rstn_debug_sync_o),
      .i2c_rstn_o(rstn_i2c_sync_o),
      .uart_rstn_o(rstn_uart_sync_o),
      .spi_rstn_o(rstn_spi_sync_o)
    );


/*  

    always_ff@(posedge clk_soc or negedge por_ni) begin
    if(!por_ni) begin
        hard_rst_gen_q <= 1'b1;
        hard_rst_cnt_q <= {RST_CNT_BIT_WIDTH{1'b0}};
//        $display($time,"===========RST======== hard_rst_cnt_q =%d hard_rst_gen_q=%d",hard_rst_cnt_q,hard_rst_gen_q);
    end else if(hard_rst_cnt_q == ({RST_CNT_BIT_WIDTH})'({RST_COUNTER-1})) begin
        hard_rst_gen_q <= 1'b0;
        hard_rst_cnt_q <= (RST_CNT_BIT_WIDTH)'({RST_COUNTER-1});
//        $display($time,"===========CNT=============== hard_rst_cnt_q =%d hard_rst_gen_q=%d",hard_rst_cnt_q,hard_rst_gen_q);
        
    end else if(mem_clksel_rst_ctrl_sys_q) begin
        hard_rst_cnt_q <= hard_rst_cnt_q + {{RST_CNT_BIT_WIDTH-1{1'b0}},1'b1};
        hard_rst_gen_q <= 1'b1;
//        $display($time,"===========ELSE================= hard_rst_cnt_q =%d hard_rst_gen_q=%d",hard_rst_cnt_q,hard_rst_gen_q);
        
    end
  end


//  assign so_rstn =  soc_rst_value_q2 ? ~rstn_soc_sync : hard_rst_gen_q; //rstn_soc_sync;
//  assign pe_rstn = per_rst_value_q2 ? ~rstn_peripheral_sync : hard_rst_gen_q; //rstn_peripheral_sync;
//  assign de_rstn = debug_rst_value_q2 ? ~rstn_debug_sync : hard_rst_gen_q; //rstn_debug_sync;

  logic hard_rst_gen_soc_sync_q;

     synch #(.STAGES(20)) i_hardrst_soc_sync (
      .clk_i    ( clk_soc    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( hard_rst_gen_q     ),                        
      .serial_o ( hard_rst_gen_soc_sync_q        )
    );

//cdc
  always_ff@(posedge clk_soc or negedge por_ni) begin
    if(!por_ni) begin
        so_rstn <= 1'b0;
//    end else if(soc_rst_value_q2) begin
//        so_rstn <= ~rstn_soc_sync;
    end else begin
        so_rstn <= ~(rstn_soc_sync | hard_rst_gen_soc_sync_q);
    end
  end

  logic hard_rst_gen_per_sync_q;

     synch #(.STAGES(2)) i_hardrst_per_sync (
      .clk_i    ( clk_per    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( hard_rst_gen_q     ),                        
      .serial_o ( hard_rst_gen_per_sync_q        )
    );



//cdc
    always_ff@(posedge clk_per or negedge por_ni) begin
    if(!por_ni) begin
        pe_rstn <= 1'b0;
//    end else if(per_rst_value_q2) begin
//        pe_rstn <= ~rstn_peripheral_sync;
    end else begin
        pe_rstn <= ~(rstn_peripheral_sync | hard_rst_gen_per_sync_q);
    end
  end

  logic hard_rst_gen_debug_sync_q;

     synch #(.STAGES(10)) i_hardrst_debug_sync (
      .clk_i    ( clk_for_debug    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( hard_rst_gen_q     ),                        
      .serial_o ( hard_rst_gen_debug_sync_q        )
    );


//cdc
  always_ff@(posedge clk_for_debug or negedge por_ni) begin
    if(!por_ni) begin
        de_rstn <= 1'b0;
//    end else if(debug_rst_value_q2) begin
//        de_rstn <= ~rstn_debug_sync;
    end else begin
        de_rstn <= ~(rstn_debug_sync | hard_rst_gen_debug_sync_q);
    end
  end
*/
  


  // Output assignment
  assign clk_soc_o           = clk_soc;
  assign clk_per_o           = clk_per;
  assign clk_for_debug_o       = clk_for_debug;

//  assign rstn_soc_sync_o        = so_rstn;
//  assign rstn_peripheral_sync_o = pe_rstn;
//  assign rstn_debug_sync_o      = de_rstn;


//  assign rstn_soc_sync_o        = rstn_soc_sync;
//  assign rstn_peripheral_sync_o = rstn_peripheral_sync;
//  assign rstn_debug_sync_o      = rstn_debug_sync;

endmodule  // system_clk_rst_gen

