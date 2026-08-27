/*
module system_rst_gen (

    input sys_clk_i,
    input soc_clk_i,
    input per_clk_i,
    input dbg_clk_i,

    input por_ni,
    input mem_core_clk_sync_done,

    input test_mode_debug_rstn_en_i,
    input test_mode_debug_rstn_i,
    input test_mode_peripheral_rstn_en_i,
    input test_mode_peripheral_rstn_i,
    input test_mode_soc_rstn_en_i,
    input test_mode_soc_rstn_i,
    input test_mode_spi_rstn_en_i,
    input test_mode_spi_rstn_i,
    input test_mode_uart_rstn_en_i,
    input test_mode_uart_rstn_i,
    input test_mode_i2c_rstn_en_i,
    input test_mode_i2c_rstn_i,

    // from watchdog module
    input [1:0] wdt_rst_scope_i,
    input wdt_rst_req_i,

    // from debug module
    input non_dbg_rst_req_i,   

    // from apb reg's
    input apb_core_rst_req_i,
    input apb_peripheral_rst_req_i, // all peripherals reset req
    input apb_dbg_rst_req_i,
    input apb_i2c_rst_req_i,
    input apb_uart_rst_req_i,
    input apb_spi_rst_req_i,

    output logic core_rstn_o,
    output logic peripheral_rstn_o,
    output logic dbg_rstn_o,
    output logic i2c_rstn_o,
    output logic uart_rstn_o,
    output logic spi_rstn_o
    );


    logic         wdt_coren_subsytem_rst_req;
    logic         wdt_debug_rst_req;
    logic         wdt_all_peripherals_rst_req;
    logic         wdt_global_rst_req;

    logic test_mode_i2c_rstn_sync_q;
    logic test_mode_uart_rstn_sync_q;
    logic test_mode_spi_rstn_sync_q;
    logic test_mode_soc_rstn_sync_q;
    logic test_mode_per_rstn_sync_q;
    logic test_mode_debug_rstn_sync_q;

    logic rstn_soc_sync;
    logic rstn_peripheral_sync;
    logic rstn_debug_sync;
    logic rstn_i2c_sync;
    logic rstn_uart_sync;
    logic rstn_spi_sync;


typedef enum logic [2:0]
{

    WAIT_MEM_READY,      // Wait mem clk sync after POR

//    WAIT_COMMON_EDGE,    // Wait for clk edge sync detection alignment

    WDT_RESET_REQ,                 // Normal operation

    WDT_RESET_RELEASE           // WDT  reset sequence

} rst_state_e;

rst_state_e state_q;
rst_state_e state_d;

logic global_reset_active;

logic global_release_enable;


always_ff @(posedge soc_clk_i or negedge por_ni)
begin
    if(!por_ni)
        state_q <= WAIT_MEM_READY;
    else
        state_q <= state_d;
end

always_comb
begin

    state_d = state_q;
    global_reset_active  = 1'b0;
    global_release_enable = 1'b1;
    wdt_coren_subsytem_rst_req = 1'b0;
    wdt_debug_rst_req = 1'b0;
    wdt_all_peripherals_rst_req = 1'b0;
    wdt_global_rst_req = 1'b0;


    unique case(state_q)
    //----------------------------------------------------
    // WAIT MEMORY + CORE READY
    //----------------------------------------------------

    WAIT_MEM_READY:
    begin

        // This happens only ONCE after power-up
        global_reset_active   = 1'b1;
        global_release_enable = 1'b0;

        if(mem_core_clk_sync_done) begin
            state_d = WDT_RESET_REQ; //WAIT_COMMON_EDGE;
            global_reset_active   = 1'b0;
            global_release_enable = 1'b1;
         end
    end
*/
/*
    //----------------------------------------------------
    // WAIT COMMON CLOCK EDGE
    //----------------------------------------------------

    WAIT_COMMON_EDGE:
    begin

        // Generated from divider

        if(clk_release_sync) begin
            state_d = WDT_RESET_REQ;
            global_reset_active   = 1'b0;
            global_release_enable = 1'b1;
        end
    end
*/
/*
    //----------------------------------------------------
    // NORMAL OPERATION
    //----------------------------------------------------

    WDT_RESET_REQ:
    begin

        // Only Global WDT enters FSM again

        if(wdt_rst_req_i) begin
            case(wdt_rst_scope_i) 
            2'b00: begin // core & core subsytem reset req
                    wdt_coren_subsytem_rst_req = 1'b1;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b01: begin // Debug reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b1;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b10: begin // all peripharals reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b1;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b11: begin // global reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b1;
                   end
            endcase
            state_d = WDT_RESET_RELEASE;
//            global_reset_active   = 1'b1;
//            global_release_enable = 1'b0;
        end
    end

    //----------------------------------------------------
    // GLOBAL WATCHDOG
    //----------------------------------------------------

    WDT_RESET_RELEASE:
    begin

        // No memory synchronization required

        if(!wdt_rst_req_i) begin
            case(wdt_rst_scope_i) 
            2'b00: begin
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b01: begin
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b10: begin
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b11: begin
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            endcase


            state_d = WDT_RESET_REQ;
//            global_reset_active   = 1'b0;
//            global_release_enable = 1'b1;
        end else begin
            case(wdt_rst_scope_i) 
            2'b00: begin // core & core subsytem reset req
                    wdt_coren_subsytem_rst_req = 1'b1;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b01: begin // Debug reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b1;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b10: begin // all peripharals reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b1;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b11: begin // global reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b1;
                   end
            endcase
        end
    end

    endcase

end



  assign core_rst_req = wdt_coren_subsytem_rst_req || wdt_global_rst_req || non_dbg_rst_req_i || apb_core_rst_req_i;
  assign debug_rst_req = wdt_debug_rst_req || apb_dbg_rst_req_i || wdt_global_rst_req;
  assign per_rst_req = wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || wdt_global_rst_req || non_dbg_rst_req_i;
  assign i2c_rst_req = wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || apb_i2c_rst_req_i || wdt_global_rst_req || non_dbg_rst_req_i;
  assign uart_rst_req = wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || apb_uart_rst_req_i || wdt_global_rst_req || non_dbg_rst_req_i;
  assign spi_rst_req = wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || apb_spi_rst_req_i || wdt_global_rst_req || non_dbg_rst_req_i;



//cdc
   sync #(.STAGES(2)) i_test_mode_soc_rst_sync (
      .clk_i    ( soc_clk_i                   ),
      .rst_ni   ( por_ni                    ),
      .serial_i ( test_mode_soc_rstn_i       ),                        
      .serial_o ( test_mode_soc_rstn_sync_q  )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_per_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_peripheral_rstn_i     ),                        
      .serial_o ( test_mode_per_rstn_sync_q        )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_debug_rst_sync (
      .clk_i    ( dbg_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_debug_rstn_i     ),                        
      .serial_o ( test_mode_debug_rstn_sync_q        )
    );

   sync #(.STAGES(2)) i_test_mode_i2c_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_i2c_rstn_i              ),                        
      .serial_o ( test_mode_i2c_rstn_sync_q        )
    );

   sync #(.STAGES(2)) i_test_mode_uart_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_uart_rstn_i     ),                        
      .serial_o ( test_mode_uart_rstn_sync_q        )
    );

   sync #(.STAGES(2)) i_test_mode_spi_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_spi_rstn_i     ),                        
      .serial_o ( test_mode_spi_rstn_sync_q        )
    );

//   logic non_dbg_rst_req_i;
   logic non_dbg_rst_req_q;
   logic non_dbg_rst_req_per_q1;
   logic non_dbg_rst_req_per_q2;
   logic non_dbg_rst_req_per_q3;
   logic non_dbg_rst_tgle;

always_ff@(posedge dbg_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        non_dbg_rst_req_q <= 1'b0;
        non_dbg_rst_tgle <= 1'b0;
    end else begin
        non_dbg_rst_req_q <= non_dbg_rst_req_i;
        if(!non_dbg_rst_req_q && non_dbg_rst_req_i) begin
            non_dbg_rst_tgle <= ~non_dbg_rst_tgle;
        end
    end
end
*/

/*
always_ff@(posedge dbg_clk_i or negedge por_ni) begin
    if(por_ni) begin
        non_dbg_rst_req_q <= 1'b0;
//        non_dbg_rst_tgle <= 1'b0;
    end else if(non_dbg_rst_req_i) begin
        non_dbg_rst_req_q <= ~non_dbg_rst_req_q;
    end
end

always_ff@(posedge per_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        non_dbg_rst_req_per_q1 <= 1'b0;
        non_dbg_rst_req_per_q2 <= 1'b0;
        non_dbg_rst_req_per_q3 <= 1'b0;
    end else begin
        non_dbg_rst_req_per_q1 <= non_dbg_rst_req_q;
        non_dbg_rst_req_per_q2 <= non_dbg_rst_req_per_q1;
        non_dbg_rst_req_per_q3 <= non_dbg_rst_req_per_q2;
    end
end

assign non_dbg_rst_req_per_q = non_dbg_rst_req_per_q2 || non_dbg_rst_req_per_q3;


*/
/*
   sync #(.STAGES(2)) i_non_dbg_rst_per_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( non_dbg_rst_tgle   ),                        
      .serial_o ( non_dbg_rst_req_per_q        )
    );





  rstgen_bypass i_soc_rstgen (
    .clk_i (soc_clk_i               ),
    .por_ni(por_ni                  ),
    .rst_ni(core_rst_req          ),
    .rst_test_mode_ni(test_mode_soc_rstn_sync_q),
    .test_mode_i(test_mode_soc_rstn_en_i),
    .rst_no (rstn_soc_sync          )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                // not used
  );


  rstgen_bypass i_peripheral_rstgen (
    .clk_i (per_clk_i              ),
    .por_ni(por_ni                          ),
    .rst_ni(per_rst_req           ),
    .rst_test_mode_ni(test_mode_per_rstn_sync_q ),
    .test_mode_i(test_mode_peripheral_rstn_en_i),
    .rst_no (rstn_peripheral_sync           )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );

  rstgen_bypass i_debug_rstgen (
    .clk_i (dbg_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(debug_rst_req                ),
    .rst_test_mode_ni(test_mode_debug_rstn_sync_q      ),
    .test_mode_i(test_mode_debug_rstn_en_i),
    .rst_no (rstn_debug_sync                )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );


    rstgen_bypass i_i2c_rstgen (
    .clk_i (per_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(i2c_rst_req                ),
    .rst_test_mode_ni(test_mode_i2c_rstn_sync_q      ),
    .test_mode_i(test_mode_i2c_rstn_en_i),
    .rst_no (rstn_i2c_sync                )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );


  rstgen_bypass i_uart_rstgen (
    .clk_i (per_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(uart_rst_req                ),
    .rst_test_mode_ni(test_mode_uart_rstn_sync_q      ),
    .test_mode_i(test_mode_uart_rstn_en_i),
    .rst_no (rstn_uart_sync                )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );


  rstgen_bypass i_spi_rstgen (
    .clk_i (per_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(spi_rst_req                ),
    .rst_test_mode_ni(test_mode_spi_rstn_sync_q      ),
    .test_mode_i(test_mode_spi_rstn_en_i),
    .rst_no (rstn_spi_sync                )  // to be used by logic clocked with ref clock in AO domain
//    .init_no()                    // not used
  );

  logic mem_core_clk_sync_done_q;
  logic wdt_global_rst_req_per_q;
  logic rst_perpheral_release_dbg_q;
  logic rst_dbg_release;
  logic rst_perpheral_release;
  logic rst_soc_release;

  logic rst_peripheral_buff;
  logic rst_soc_buff;
  logic rst_dbg_buff;
  logic rst_i2c_buff;
  logic rst_uart_buff;
  logic rst_spi_buff;


     sync #(.STAGES(2)) i_mem_clkswitch_done_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( mem_core_clk_sync_done     ),                        
      .serial_o ( mem_core_clk_sync_done_per_q        )
    );

     sync #(.STAGES(2)) i_wdt_global_per_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( wdt_global_rst_req     ),                        
      .serial_o ( wdt_global_rst_req_per_q        )
    );

    sync #(.STAGES(2)) i_rst_peripheral_release_dbg_sync (
      .clk_i    ( dbg_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( rst_perpheral_release     ),                        
      .serial_o ( rst_perpheral_release_dbg_q        )
    );





  always_ff@(posedge per_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        rst_perpheral_release <= 1'b0;
        rst_peripheral_buff <= 1'b0;
    end else if(mem_core_clk_sync_done_per_q || wdt_global_rst_req_per_q || non_dbg_rst_req_per_q) begin
        rst_peripheral_buff <= ~rstn_peripheral_sync;
        rst_perpheral_release <= 1'b1;
    end else if(per_rst_req)begin
        rst_perpheral_release <= 1'b0;
        rst_peripheral_buff   <= ~rstn_peripheral_sync;
    end
  end

    always_ff@(posedge per_clk_i or negedge por_ni) begin
    if(!por_ni) begin
//        rst_perpheral_release <= 1'b0;
        rst_i2c_buff <= 1'b0;
    end else if(mem_core_clk_sync_done_per_q || wdt_global_rst_req_per_q || non_dbg_rst_req_per_q) begin
        rst_i2c_buff <= (~rstn_i2c_sync || ~rstn_peripheral_sync);
//        rst_perpheral_release <= 1'b1;
    end else if(i2c_rst_req)begin
//        rst_perpheral_release <= 1'b0;
        rst_i2c_buff   <= (~rstn_i2c_sync || ~rstn_peripheral_sync);
    end
  end

  always_ff@(posedge per_clk_i or negedge por_ni) begin
    if(!por_ni) begin
//        rst_perpheral_release <= 1'b0;
        rst_uart_buff <= 1'b0;
    end else if(mem_core_clk_sync_done_per_q || wdt_global_rst_req_per_q || non_dbg_rst_req_per_q) begin
        rst_uart_buff <= (~rstn_uart_sync || ~rstn_peripheral_sync);
//        rst_perpheral_release <= 1'b1;
    end else if(uart_rst_req)begin
//        rst_perpheral_release <= 1'b0;
        rst_uart_buff   <= (~rstn_uart_sync || ~rstn_peripheral_sync);
    end
  end

  always_ff@(posedge per_clk_i or negedge por_ni) begin
    if(!por_ni) begin
//        rst_perpheral_release <= 1'b0;
        rst_spi_buff <= 1'b0;
    end else if(mem_core_clk_sync_done_per_q || wdt_global_rst_req_per_q || non_dbg_rst_req_per_q) begin
        rst_spi_buff <= (~rstn_spi_sync || ~rstn_peripheral_sync);
//        rst_perpheral_release <= 1'b1;
    end else if(spi_rst_req)begin
//        rst_perpheral_release <= 1'b0;
        rst_spi_buff   <= (~rstn_spi_sync || ~rstn_peripheral_sync);
    end
  end


    always_ff@(posedge soc_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        rst_soc_release <= 1'b0;
        rst_soc_buff <= 1'b0;
    end else if(rst_dbg_release) begin
        rst_soc_buff <= ~rstn_soc_sync;
        rst_soc_release <= 1'b1;
    end else if(core_rst_req) begin
        rst_soc_release <= 1'b0;
        rst_soc_buff   <= ~rstn_soc_sync;
    end
  end


  always_ff@(posedge dbg_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        rst_dbg_release <= 1'b0;
        rst_dbg_buff <= 1'b0;
    end else if(rst_perpheral_release_dbg_q) begin
        rst_dbg_buff <= ~rstn_debug_sync;
        rst_dbg_release <= 1'b1;
    end else if(debug_rst_req) begin
        rst_dbg_release <= 1'b0;
        rst_dbg_buff   <= ~rstn_debug_sync;
    end
  end



 assign core_rstn_o = (rst_soc_buff); //  || ~rstn_soc_sync);
 assign peripheral_rstn_o = (rst_peripheral_buff); // || ~rstn_peripheral_sync);
 assign dbg_rstn_o = (rst_dbg_buff); // || ~rstn_debug_sync);
 assign i2c_rstn_o = (rst_i2c_buff); // || ~rstn_i2c_sync);
 assign uart_rstn_o = (rst_uart_buff); // || ~rstn_uart_sync);
 assign spi_rstn_o = (rst_spi_buff); // || ~rstn_spi_sync);





endmodule
*/


// ---------------------------------------------------------------------------------------------------------------------------------

module system_rst_gen (

//    input sys_clk_i,
    input soc_clk_i,
    input per_clk_i,
    input dbg_clk_i,

    input por_ni,
    input mem_core_clk_sync_done,

    input test_mode_debug_rstn_en_i,
    input test_mode_debug_rstn_i,
    input test_mode_peripheral_rstn_en_i,
    input test_mode_peripheral_rstn_i,
    input test_mode_soc_rstn_en_i,
    input test_mode_soc_rstn_i,
    input test_mode_spi_rstn_en_i,
    input test_mode_spi_rstn_i,
    input test_mode_uart_rstn_en_i,
    input test_mode_uart_rstn_i,
    input test_mode_i2c_rstn_en_i,
    input test_mode_i2c_rstn_i,

    // from watchdog module (async, 50kHz — slowest clock in the system)
    input [1:0] wdt_rst_scope_i,
    input wdt_rst_req_i,

    // from debug module
    input non_dbg_rst_req_i,

    // from apb reg's
    input apb_core_rst_req_i,          // already synchronous to soc_clk_i (confirmed)
    input apb_peripheral_rst_req_i,    // all peripherals reset req
    input apb_dbg_rst_req_i,
    input apb_i2c_rst_req_i,
    input apb_uart_rst_req_i,
    input apb_spi_rst_req_i,

    output logic core_rstn_o,
    output logic peripheral_rstn_o,
    output logic dbg_rstn_o,
    output logic i2c_rstn_o,
    output logic uart_rstn_o,
    output logic spi_rstn_o
    );

    // Clock relationship (for reference / documentation only sync stages
    // below are kept fully general and do NOT rely on these ratios):
    //   soc_clk_i (core)  : fastest
    //   dbg_clk_i         : soc_clk_i / 2
    //   per_clk_i         : soc_clk_i / 4
    //   wdt (external)    : 50 kHz, async to everything above
    //
    // Required release order, applies ONLY after (a) POR release and
    // (b) a WDT *global* (scope 2'b11) reset  NOT for any other,
    // standalone reset cause:
    //   1. all peripheral-group resets release, each on its own clock
    //   2. debug releases next, on the next dbg_clk_i edge once (1) is done
    //   3. core releases next, on the next soc_clk_i edge once (2) is done
    //
    // All six *_rstn_o outputs are active-low (1 = normal, 0 = asserted)
    // and are driven exclusively from a flop in their own clock domain 
    // never from a bare combinational assign.

    localparam  CORE_AUTO_RLS_CYCLES = 5'd16;  // TODO: parameterize to top, tune to settle time
    localparam  CORE_CNT_W = 5;//$clog2(CORE_AUTO_RLS_CYCLES);

    logic         wdt_coren_subsytem_rst_req;
    logic         wdt_debug_rst_req;
    logic         wdt_all_peripherals_rst_req;
    logic         wdt_global_rst_req;

    logic test_mode_i2c_rstn_sync_q;
    logic test_mode_uart_rstn_sync_q;
    logic test_mode_spi_rstn_sync_q;
    logic test_mode_soc_rstn_sync_q;
    logic test_mode_per_rstn_sync_q;
    logic test_mode_debug_rstn_sync_q;

    logic rstn_soc_sync;
    logic rstn_peripheral_sync;
    logic rstn_debug_sync;
    logic rstn_i2c_sync;
    logic rstn_uart_sync;
    logic rstn_spi_sync;

    logic core_rst_req, per_rst_req, debug_rst_req, i2c_rst_req, uart_rst_req, spi_rst_req;


typedef enum logic [2:0]
{
    WAIT_MEM_READY,      // Wait mem clk sync after POR
    WDT_RESET_REQ,       // Normal operation
    WDT_RESET_RELEASE    // WDT reset sequence
} rst_state_e;

rst_state_e state_q;
//rst_state_e state_d;

//logic global_reset_active;
//logic global_release_enable;

//======================================================================
// CDC: WDT request/scope + mem_core_clk_sync_done -> soc_clk_i
//
// wdt_rst_req_i and mem_core_clk_sync_done are both async to soc_clk_i.
// The FSM below previously sampled them raw inside always_comb feeding
// state_q that's a single-stage-capture hazard (metastability on the
// specific edge the signal transitions on), independent of how wide the
// pulse is. 3 stages used here given the extreme freq ratio to WDT
// (50kHz), cheap insurance. wdt_rst_scope_i is NOT separately synced:
// it's treated as a stable bus, valid before/throughout the WDT request
// window confirm this holds on the WDT block side.
//======================================================================
logic wdt_rst_req_soc_q;
logic mem_core_clk_sync_done_soc_q;

sync #(.STAGES(3)) i_wdt_req_soc_sync (
    .clk_i    ( soc_clk_i          ),
    .rst_ni   ( por_ni             ),
    .serial_i ( wdt_rst_req_i      ),
    .serial_o ( wdt_rst_req_soc_q  )
);

sync #(.STAGES(3)) i_mem_clkdone_soc_sync (
    .clk_i    ( soc_clk_i                     ),
    .rst_ni   ( por_ni                        ),
    .serial_i ( mem_core_clk_sync_done        ),
    .serial_o ( mem_core_clk_sync_done_soc_q  )
);

logic per_clk_por_detect;
logic per_clk_por_detect_soc_q;

always_ff@(posedge per_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        per_clk_por_detect = 1'b0;
    end else begin
        per_clk_por_detect = 1'b1;
    end
end

sync #(.STAGES(3)) i_per_clkAfter_por_sync (
    .clk_i    ( soc_clk_i                     ),
    .rst_ni   ( por_ni                        ),
    .serial_i ( per_clk_por_detect        ),
    .serial_o ( per_clk_por_detect_soc_q  )
);


//======================================================================
// FULLY REGISTERED FSM — all outputs are flops in soc_clk_i domain.
// No combinational outputs — eliminates glitches on wdt_* signals
// and the one-cycle hole between state_d and state_q that caused
// dbg_needs_tier1_q / core_needs_tier2_q to miss arm edges.
//======================================================================
/*
typedef enum logic [1:0] {
    WAIT_MEM_READY,
    WDT_RESET_REQ,
    WDT_RESET_RELEASE
} rst_state_e;
*/
//rst_state_e state_q;

//logic global_reset_active;
//logic wdt_coren_subsytem_rst_req;
//logic wdt_debug_rst_req;
//logic wdt_all_peripherals_rst_req;
//logic wdt_global_rst_req;

always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni) begin
        state_q                     <= WAIT_MEM_READY;
//        global_reset_active         <= 1'b1;
        wdt_coren_subsytem_rst_req  <= 1'b0;
        wdt_debug_rst_req           <= 1'b0;
        wdt_all_peripherals_rst_req <= 1'b0;
        wdt_global_rst_req          <= 1'b0;
    end else if(per_clk_por_detect_soc_q) begin
        // defaults — held unless overridden below
        wdt_coren_subsytem_rst_req  <= 1'b0;
        wdt_debug_rst_req           <= 1'b0;
        wdt_all_peripherals_rst_req <= 1'b0;
        wdt_global_rst_req          <= 1'b0;
//        global_reset_active         <= 1'b0;

        unique case (state_q)

        //--------------------------------------------------------------
        WAIT_MEM_READY: begin
//            global_reset_active <= 1'b1;       // hold all in reset
            if (mem_core_clk_sync_done_soc_q) begin
//                global_reset_active <= 1'b0;   // release the hold
                state_q             <= WDT_RESET_REQ;
            end
        end

        //--------------------------------------------------------------
        WDT_RESET_REQ: begin
            if (wdt_rst_req_soc_q) begin
                state_q <= WDT_RESET_RELEASE;
                case (wdt_rst_scope_i)
                2'b00: wdt_coren_subsytem_rst_req  <= 1'b1;
                2'b01: wdt_debug_rst_req           <= 1'b1;
                2'b10: wdt_all_peripherals_rst_req <= 1'b1;
                2'b11: wdt_global_rst_req          <= 1'b1;
                endcase
            end
        end

        //--------------------------------------------------------------
        WDT_RESET_RELEASE: begin
            if (!wdt_rst_req_soc_q) begin
                // WDT deasserted  all outputs already defaulted to 0 above
                state_q <= WDT_RESET_REQ;
            end else begin
                // Hold outputs while WDT request is still asserted
                case (wdt_rst_scope_i)
                2'b00: wdt_coren_subsytem_rst_req  <= 1'b0;
                2'b01: wdt_debug_rst_req           <= 1'b0;
                2'b10: wdt_all_peripherals_rst_req <= 1'b0;
                2'b11: wdt_global_rst_req          <= 1'b0;
                endcase
            end
        end
        default: begin
            state_q <= WAIT_MEM_READY;
            end

        endcase
    end
end

/*
always_ff @(posedge soc_clk_i or negedge por_ni)
begin
    if(!por_ni)
        state_q <= WAIT_MEM_READY;
    else if(per_clk_por_detect_soc_q)
        state_q <= state_d;
end

always_comb
begin

    state_d = state_q;
    global_reset_active  = 1'b0;
    global_release_enable = 1'b1;
    wdt_coren_subsytem_rst_req = 1'b0;
    wdt_debug_rst_req = 1'b0;
    wdt_all_peripherals_rst_req = 1'b0;
    wdt_global_rst_req = 1'b0;


    unique case(state_q)
    //----------------------------------------------------
    // WAIT MEMORY + CORE READY
    //----------------------------------------------------

    WAIT_MEM_READY:
    begin

        // This happens only ONCE after power-up
        global_reset_active   = 1'b1;
        global_release_enable = 1'b0;

        if(mem_core_clk_sync_done_soc_q) begin
            state_d = WDT_RESET_REQ;
            global_reset_active   = 1'b0;
            global_release_enable = 1'b1;
         end
    end

    //----------------------------------------------------
    // NORMAL OPERATION
    //----------------------------------------------------

    WDT_RESET_REQ:
    begin

        // Only Global WDT enters FSM again
        if(wdt_rst_req_soc_q) begin
            case(wdt_rst_scope_i)
            2'b00: begin // core & core subsytem reset req
                    wdt_coren_subsytem_rst_req = 1'b1;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b01: begin // Debug reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b1;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b10: begin // all peripharals reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b1;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b11: begin // global reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b1;
                   end
            endcase
            state_d = WDT_RESET_RELEASE;
        end
    end

    //----------------------------------------------------
    // GLOBAL WATCHDOG
    //----------------------------------------------------

    WDT_RESET_RELEASE:
    begin

        // No memory synchronization required
        if(!wdt_rst_req_soc_q) begin
            wdt_coren_subsytem_rst_req = 1'b0;
            wdt_debug_rst_req = 1'b0;
            wdt_all_peripherals_rst_req = 1'b0;
            wdt_global_rst_req = 1'b0;
            state_d = WDT_RESET_REQ;
        end else begin
            case(wdt_rst_scope_i)
            2'b00: begin // core & core subsytem reset req
                    wdt_coren_subsytem_rst_req = 1'b1;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b01: begin // Debug reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b1;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b10: begin // all peripharals reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b1;
                    wdt_global_rst_req = 1'b0;
                   end
            2'b11: begin // global reset req
                    wdt_coren_subsytem_rst_req = 1'b0;
                    wdt_debug_rst_req = 1'b0;
                    wdt_all_peripherals_rst_req = 1'b0;
                    wdt_global_rst_req = 1'b1;
                   end
            endcase
        end
    end

    endcase

end
*/


//======================================================================
// CORE AUTO-RELEASE  WDT core-scope reset, WDT *global* reset, and the
// APB core soft-reset are all cases where core must not depend on an
// external source to drop its request level (nothing outside core is
// guaranteed to clear it in bounded time). Edge-detect each request and
// run a fixed, self-clearing window instead. This does NOT change when
// core_rstn_o is actually allowed to go high after a POR/WDT-global
// event  that release is still gated by the TIER 3 logic further down,
// which waits for debug (and transitively peripherals) to be ready
// regardless of how quickly this internal counter clears.
// non_dbg_rst_req_i is NOT routed through this  it's driven from
// outside the core domain (debug module) and stays level-based.
//======================================================================
logic apb_core_rst_req_q, wdt_core_rst_req_q, wdt_global_rst_req_q;
logic apb_core_rst_pulse, wdt_core_rst_pulse, wdt_global_rst_pulse;
logic core_auto_rst_active;
logic [CORE_CNT_W-1:0] core_auto_cnt;

always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni) begin
        apb_core_rst_req_q  <= 1'b0;
        wdt_core_rst_req_q  <= 1'b0;
        wdt_global_rst_req_q <= 1'b0;
    end else begin
        apb_core_rst_req_q  <= apb_core_rst_req_i;          // already sync to soc_clk_i
        wdt_core_rst_req_q  <= wdt_coren_subsytem_rst_req;  // FSM output, already soc_clk_i domain
        wdt_global_rst_req_q <= wdt_global_rst_req;         // FSM output, already soc_clk_i domain
    end
end
assign apb_core_rst_pulse  = apb_core_rst_req_i        & ~apb_core_rst_req_q;
assign wdt_core_rst_pulse  = wdt_coren_subsytem_rst_req & ~wdt_core_rst_req_q;
assign wdt_global_rst_pulse = wdt_global_rst_req        & ~wdt_global_rst_req_q;

always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni) begin
        core_auto_rst_active <= 1'b0;
        core_auto_cnt        <= {CORE_CNT_W{1'b0}};
    end else if ((apb_core_rst_pulse || wdt_core_rst_pulse || wdt_global_rst_pulse) && !core_auto_rst_active) begin
        core_auto_rst_active <= 1'b1;
//        core_auto_cnt        <= CORE_AUTO_RLS_CYCLES[CORE_CNT_W-1:0];
        core_auto_cnt        <= CORE_AUTO_RLS_CYCLES;        
    end else if (core_auto_rst_active) begin
        if (core_auto_cnt == {CORE_CNT_W{1'b0}})
            core_auto_rst_active <= 1'b0;
        else
            core_auto_cnt <= core_auto_cnt - {{CORE_CNT_W-1{1'b0}},1'b1};
    end
end


//======================================================================
// Reset request equations (active-HIGH: 1 = reset requested)
//
// per_rst_req / i2c_rst_req / uart_rst_req / spi_rst_req additionally
// hold reset asserted until mem_core_clk_sync_done_per_q, since these
// are tier1 (first tier to release) this is folded directly into the
// request, at zero extra latency cost (the async-assert path doesn't
// add cycles; rstgen_bypass's own sync-deassert already handles timing).
//
// core_rst_req no longer carries a raw `wdt_global_rst_req` level term:
// that cause now feeds the auto-release pulse detector above instead,
// so core self-clears rather than waiting on the watchdog to drop its
// request. Debug and the peripheral group are unchanged and still wait
// for wdt_global_rst_req to deassert at the source.
//======================================================================
/*
logic mem_core_clk_sync_done_per_q;

sync #(.STAGES(2)) i_mem_clkswitch_done_sync (
    .clk_i    ( per_clk_i                      ),
    .rst_ni   ( por_ni                         ),
    .serial_i ( mem_core_clk_sync_done         ),
    .serial_o ( mem_core_clk_sync_done_per_q   )
);
*/

assign core_rst_req  = per_clk_por_detect_soc_q ? core_auto_rst_active || non_dbg_rst_req_i : 1'b1 ;
assign debug_rst_req = per_clk_por_detect_soc_q ? wdt_debug_rst_req || apb_dbg_rst_req_i || wdt_global_rst_req : 1'b1;
assign per_rst_req   = per_clk_por_detect_soc_q ? wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || wdt_global_rst_req || non_dbg_rst_req_i : 1'b1; //||  !mem_core_clk_sync_done_per_q;
assign i2c_rst_req   = per_clk_por_detect_soc_q ? wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || apb_i2c_rst_req_i  || wdt_global_rst_req || non_dbg_rst_req_i : 1'b1 ; //|| !mem_core_clk_sync_done_per_q;
assign uart_rst_req  = per_clk_por_detect_soc_q ? wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || apb_uart_rst_req_i || wdt_global_rst_req || non_dbg_rst_req_i : 1'b1 ; //|| !mem_core_clk_sync_done_per_q;
assign spi_rst_req   = per_clk_por_detect_soc_q ? wdt_all_peripherals_rst_req || apb_peripheral_rst_req_i || apb_spi_rst_req_i  || wdt_global_rst_req || non_dbg_rst_req_i : 1'b1 ; //|| !mem_core_clk_sync_done_per_q;


//cdc test mode syncs (unchanged)
   sync #(.STAGES(2)) i_test_mode_soc_rst_sync (
      .clk_i    ( soc_clk_i                   ),
      .rst_ni   ( por_ni                    ),
      .serial_i ( test_mode_soc_rstn_i       ),
      .serial_o ( test_mode_soc_rstn_sync_q  )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_per_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_peripheral_rstn_i     ),
      .serial_o ( test_mode_per_rstn_sync_q        )
    );
//cdc
   sync #(.STAGES(2)) i_test_mode_debug_rst_sync (
      .clk_i    ( dbg_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_debug_rstn_i     ),
      .serial_o ( test_mode_debug_rstn_sync_q        )
    );

   sync #(.STAGES(2)) i_test_mode_i2c_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_i2c_rstn_i              ),
      .serial_o ( test_mode_i2c_rstn_sync_q        )
    );

   sync #(.STAGES(2)) i_test_mode_uart_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_uart_rstn_i     ),
      .serial_o ( test_mode_uart_rstn_sync_q        )
    );

   sync #(.STAGES(2)) i_test_mode_spi_rst_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( test_mode_spi_rstn_i     ),
      .serial_o ( test_mode_spi_rstn_sync_q        )
    );

   // NOTE: kept for potential future use (e.g. an ack/handshake back to
   // debug), but no longer used by any gating logic below — the old
   // rst_perpheral_release chain that consumed non_dbg_rst_req_per_q has
   // been replaced by the tier scheme. Confirm whether you still need
   // this toggle-sync path, or if it should be removed.
/*
logic non_dbg_rst_req_q;
//   logic non_dbg_rst_req_per_q;
   logic non_dbg_rst_tgle;

always_ff@(posedge dbg_clk_i or negedge por_ni) begin
    if(!por_ni) begin
        non_dbg_rst_req_q <= 1'b0;
        non_dbg_rst_tgle <= 1'b0;
    end else begin
        non_dbg_rst_req_q <= non_dbg_rst_req_i;
        if(!non_dbg_rst_req_q && non_dbg_rst_req_i) begin
            non_dbg_rst_tgle <= ~non_dbg_rst_tgle;
        end
    end
end

   sync #(.STAGES(2)) i_non_dbg_rst_per_sync (
      .clk_i    ( per_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( non_dbg_rst_tgle   ),
      .serial_o ( non_dbg_rst_req_per_q        )
    );
*/

//======================================================================
// rstgen_bypass instances — rst_ni is ACTIVE-LOW (confirmed from
// rstgen_bypass.sv: feeds tc_clk_mux2 alongside rst_test_mode_ni, and
// the internal sync chain clears to 0 on !por_ni). The *_rst_req
// signals above are built active-HIGH ("1 = reset requested"), so they
// must be inverted at this connection point. rst_no comes back out
// already active-low (0=asserted,1=released) with the SAME polarity as
// *_rst_req inverted — i.e. it already matches what every *_rstn_o
// output needs, with no further inversion required downstream.
//======================================================================
  rstgen_bypass i_soc_rstgen (
    .clk_i (soc_clk_i               ),
    .por_ni(por_ni                  ),
    .rst_ni(~core_rst_req           ),
    .rst_test_mode_ni(test_mode_soc_rstn_sync_q),
    .test_mode_i(test_mode_soc_rstn_en_i),
    .rst_no (rstn_soc_sync          )
  );

  rstgen_bypass i_peripheral_rstgen (
    .clk_i (per_clk_i              ),
    .por_ni(por_ni                          ),
    .rst_ni(~per_rst_req           ),
    .rst_test_mode_ni(test_mode_per_rstn_sync_q ),
    .test_mode_i(test_mode_peripheral_rstn_en_i),
    .rst_no (rstn_peripheral_sync           )
  );

  rstgen_bypass i_debug_rstgen (
    .clk_i (dbg_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(~debug_rst_req                ),
    .rst_test_mode_ni(test_mode_debug_rstn_sync_q      ),
    .test_mode_i(test_mode_debug_rstn_en_i),
    .rst_no (rstn_debug_sync                )
  );

    rstgen_bypass i_i2c_rstgen (
    .clk_i (per_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(~i2c_rst_req                ),
    .rst_test_mode_ni(test_mode_i2c_rstn_sync_q      ),
    .test_mode_i(test_mode_i2c_rstn_en_i),
    .rst_no (rstn_i2c_sync                )
  );

  rstgen_bypass i_uart_rstgen (
    .clk_i (per_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(~uart_rst_req                ),
    .rst_test_mode_ni(test_mode_uart_rstn_sync_q      ),
    .test_mode_i(test_mode_uart_rstn_en_i),
    .rst_no (rstn_uart_sync                )
  );

  rstgen_bypass i_spi_rstgen (
    .clk_i (per_clk_i                   ),
    .por_ni(por_ni                          ),
    .rst_ni(~spi_rst_req                ),
    .rst_test_mode_ni(test_mode_spi_rstn_sync_q      ),
    .test_mode_i(test_mode_spi_rstn_en_i),
    .rst_no (rstn_spi_sync                )
  );


//======================================================================
// TIER 1 — PERIPHERALS (per_clk_i) — first to release, never gated by
// anything else. Each output is its own flop (never a bare assign),
// directly following its rstgen_bypass result — no extra inversion
// (see note above the rstgen_bypass instances). The "wait for
// mem_core_clk_sync_done" requirement is already folded into
// per/i2c/uart/spi_rst_req above.
//======================================================================
always_ff @(posedge per_clk_i or negedge por_ni) begin
    if (!por_ni) peripheral_rstn_o <= 1'b0;
    else         peripheral_rstn_o <= rstn_peripheral_sync;
end

always_ff @(posedge per_clk_i or negedge por_ni) begin
    if (!por_ni) i2c_rstn_o <= 1'b0;
    else         i2c_rstn_o <= rstn_i2c_sync;
end

always_ff @(posedge per_clk_i or negedge por_ni) begin
    if (!por_ni) uart_rstn_o <= 1'b0;
    else         uart_rstn_o <= rstn_uart_sync;
end

always_ff @(posedge per_clk_i or negedge por_ni) begin
    if (!por_ni) spi_rstn_o <= 1'b0;
    else         spi_rstn_o <= rstn_spi_sync;
end

logic tier1_all_per_rdy;   // level: high once ALL FOUR peripheral blocks are out of reset
assign tier1_all_per_rdy = rstn_peripheral_sync & rstn_i2c_sync & rstn_uart_sync & rstn_spi_sync;

//======================================================================
// Tier1 -> Tier2 CDC (per_clk_i -> dbg_clk_i). Level signal, no
// toggle/pulse handling needed — plain 2-FF sync is the correct
// minimum here.
//======================================================================
logic tier1_rdy_dbg_q;
sync #(.STAGES(2)) i_tier1_rdy_dbg_sync (
    .clk_i    ( dbg_clk_i         ),
    .rst_ni   ( por_ni            ),
    .serial_i ( tier1_all_per_rdy ),
    .serial_o ( tier1_rdy_dbg_q   )
);

// wdt_global_rst_req synced into dbg_clk_i — used ONLY to (re)arm the
// tier-2 sequencing gate below. debug_rst_req above already carries
// wdt_global_rst_req natively for asserting debug's own reset; this
// copy exists solely so the gate knows "this release must wait on
// tier1" versus a standalone debug-only cause.
logic wdt_global_dbg_q;
sync #(.STAGES(2)) i_wdt_global_dbg_sync (
    .clk_i    ( dbg_clk_i        ),
    .rst_ni   ( por_ni           ),
    .serial_i ( wdt_global_rst_req ),
    .serial_o ( wdt_global_dbg_q )
);

//======================================================================
// TIER 2 GATE — debug must not release ahead of the peripheral tier
// after POR or a WDT-global event, but must NOT be held down by any
// other, unrelated cause (e.g. a standalone apb_peripheral_rst_req_i or
// a single-peripheral WDT/APB reset that transiently pulls
// tier1_all_per_rdy low). dbg_seq_pending_q only arms on a genuine POR
// (its reset value) or WDT-global event, and disarms itself the moment
// debug has actually released with tier1 ready — so it re-arms cleanly
// every time a real global event happens, without ever falsely gating
// a standalone reset.
//======================================================================
logic dbg_seq_pending_q, dbg_seq_pending_d;

always_ff @(posedge dbg_clk_i or negedge por_ni) begin
    if (!por_ni) dbg_seq_pending_q <= 1'b1;   // must sequence right after POR
    else         dbg_seq_pending_q <= dbg_seq_pending_d;
end

always_comb begin
    dbg_seq_pending_d = dbg_seq_pending_q;
    if (wdt_global_dbg_q)
        dbg_seq_pending_d = 1'b1;
    else if (dbg_seq_pending_q && tier1_rdy_dbg_q && rstn_debug_sync)
        dbg_seq_pending_d = 1'b0;
end

/*
//======================================================================
// TIER 2 GATE — reworked: "needs tier1" is latched only WHILE debug's
// own reset is actually asserted for a global-scoped cause, and is
// cleared the instant debug_rst_req itself deasserts. This ties the
// flag strictly to debug's own assert/deassert cycle, so an unrelated
// tier1 dip (e.g. non_dbg_rst_req_i resetting only the peripherals)
// can never be misread as "still pending a chained release."
//======================================================================
logic dbg_needs_tier1_q;

always_ff @(posedge dbg_clk_i or negedge por_ni) begin
    if (!por_ni)
        dbg_needs_tier1_q <= 1'b1;                    // POR itself always needs the chain
    else if (debug_rst_req && wdt_global_dbg_q)
        dbg_needs_tier1_q <= 1'b1;                    // latch cause while asserted
    else if (!debug_rst_req)
        dbg_needs_tier1_q <= 1'b0;                    // consumed the instant debug actually releases
end

always_ff @(posedge dbg_clk_i or negedge por_ni) begin
    if (!por_ni)
        dbg_rstn_o <= 1'b0;
    else if (dbg_needs_tier1_q)
        dbg_rstn_o <= tier1_rdy_dbg_q ? rstn_debug_sync : 1'b0;
    else
        dbg_rstn_o <= rstn_debug_sync;
end
*/
//======================================================================
// TIER 2 OUTPUT — dbg_rstn_o, single flop, dbg_clk_i domain. Releases
// on the immediate next dbg_clk_i edge once gated conditions are met.
// Standalone apb_dbg_rst_req_i / WDT debug-scope resets pass straight
// through (dbg_seq_pending_q stays deasserted for those causes).
//======================================================================
always_ff @(posedge dbg_clk_i or negedge por_ni) begin
    if (!por_ni)
        dbg_rstn_o <= 1'b0;
    else if (dbg_seq_pending_q)
        dbg_rstn_o <= tier1_rdy_dbg_q ? rstn_debug_sync : 1'b0;
    else
        dbg_rstn_o <= rstn_debug_sync;
end

//======================================================================
// Tier2 -> Tier3 CDC (dbg_clk_i -> soc_clk_i). dbg_rstn_o is itself a
// flop output, safe to sync directly — "1" means debug is released.
//======================================================================
logic tier2_rdy_soc_q;
sync #(.STAGES(2)) i_tier2_rdy_soc_sync (
    .clk_i    ( soc_clk_i   ),
    .rst_ni   ( por_ni      ),
    .serial_i ( dbg_rstn_o  ),
    .serial_o ( tier2_rdy_soc_q )
);


//======================================================================
// TIER 3 GATE — same scoped-arming scheme as tier2, but for core, in
// soc_clk_i (no CDC needed for wdt_global_rst_req here — the FSM
// already runs in this domain).
//======================================================================
logic core_seq_pending_q, core_seq_pending_d;

always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni) core_seq_pending_q <= 1'b1;   // must sequence right after POR
    else         core_seq_pending_q <= core_seq_pending_d;
end

always_comb begin
    core_seq_pending_d = core_seq_pending_q;
    if (wdt_global_rst_req)
        core_seq_pending_d = 1'b1;
    else if (core_seq_pending_q && tier2_rdy_soc_q && rstn_soc_sync)
        core_seq_pending_d = 1'b0;
end

//======================================================================
// TIER 3 OUTPUT — core_rstn_o, single flop, soc_clk_i domain. Releases
// on the immediate next soc_clk_i edge once gated conditions are met.
// Standalone core-only causes (APB soft reset, WDT core-scope,
// non_dbg_rst_req_i) pass straight through via core_seq_pending_q
// staying deasserted, and rely on the auto-release counter above for
// their own internal deassertion timing.
//======================================================================
always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni)
        core_rstn_o <= 1'b0;
    else if (core_seq_pending_q)
        core_rstn_o <= tier2_rdy_soc_q ? rstn_soc_sync : 1'b0;
    else
        core_rstn_o <= rstn_soc_sync;
end

/*
logic core_needs_tier2_q;

always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni)
        core_needs_tier2_q <= 1'b1;
    else if (core_rst_req && wdt_global_rst_req)
        core_needs_tier2_q <= 1'b1;
    else if (!core_rst_req)
        core_needs_tier2_q <= 1'b0;
end

always_ff @(posedge soc_clk_i or negedge por_ni) begin
    if (!por_ni)
        core_rstn_o <= 1'b0;
    else if (core_needs_tier2_q)
        core_rstn_o <= tier2_rdy_soc_q ? rstn_soc_sync : 1'b0;
    else
        core_rstn_o <= rstn_soc_sync;
end
*/
endmodule
