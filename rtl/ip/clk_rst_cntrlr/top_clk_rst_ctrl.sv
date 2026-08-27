module top_clk_rst_ctrl #(
    parameter ADDR_WIDTH      = 8,
              DATA_WIDTH      = 32,
              HARD_RST_COUNTER=50,              
//              NUM_INPUTS      = 2,
//              NUM_SYNC_STAGES = 2,
              RATIO           = 4,       // clk div, how much a clk need to divide it by ratio
              REGISTER_WIDTH_CLK_RST = ($clog2(RATIO+1))+1
              
    )(
  // APB Interface
  input  logic                      pclk_i,
//  input  logic                      presetn_i,
  input  logic [ADDR_WIDTH-1:0]     paddr_i,
  input  logic                      psel_i,
  input  logic                      penable_i,
  input  logic                      pwrite_i,
  input  logic [3+REGISTER_WIDTH_CLK_RST-1:0]     pwdata_i,
  output logic [DATA_WIDTH-1:0]     prdata_o,
  output logic                      pready_o,
  output logic                      pslverr_o,

  // clk rst ctrl 
  input  logic                      sys_clk_i,
  input  logic                      rc_clk_i,
  input  logic                      mem_clksel_rst_ctrl_i,

  input  logic [1:0]                wdt_rst_scope_i,
  input  logic                      wdt_rst_req_i,

  input  logic                      non_dbg_rst_req_i,

  input  logic                      por_ni,

  input  logic                      debug_clksel_i,
  
  input  logic                      test_mode_soc_rst_i,
  input  logic                      test_mode_soc_rst_en_i,

  input  logic                      test_mode_peripheral_rst_i,
  input  logic                      test_mode_peripheral_rst_en_i,

  input  logic                      test_mode_debug_rst_i,
  input  logic                      test_mode_debug_rst_en_i,

  input logic                       test_mode_spi_rstn_en_i,
  input logic                       test_mode_spi_rstn_i,

  input logic                       test_mode_uart_rstn_en_i,
  input logic                       test_mode_uart_rstn_i,

  input logic                       test_mode_i2c_rstn_en_i,
  input logic                       test_mode_i2c_rstn_i,


  input  logic                      test_mode_clk_peripheral_mux_i,
  input  logic                      test_mode_clk_soc_mux_i,
//  input  logic                      test_mode_clk_cluster_mux_i,

  input  logic                      test_mode_en_peripheral_mux_i,
  input  logic                      test_mode_en_soc_mux_i,
//  input  logic                      test_mode_en_cluster_mux_i,

  input  logic                      test_mode_div_peripheral_i,
  input  logic                      test_mode_div_debug_i,

  output logic                      rstn_soc_sync_o,
  output logic                      rstn_peripheral_sync_o,
  output logic                      rstn_debug_sync_o,
  output logic                      rstn_i2c_sync_o,
  output logic                      rstn_uart_sync_o,
  output logic                      rstn_spi_sync_o,
  
  output logic                      clk_soc_o,
  output logic                      clk_per_o,
  output logic                      clk_for_debug_o

);

//    localparam REGISTER_WIDTH_CLK_RST = ($clog2(RATIO+1))+1;
    localparam [REGISTER_WIDTH_CLK_RST-1:0] DEFAULT_PER_VALUE = 4'hC;
    localparam [REGISTER_WIDTH_CLK_RST-1:0] DEFAULT_DEBUG_VALUE = 4'hA;


    /*AUTOLOGIC*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    logic [REGISTER_WIDTH_CLK_RST-1:0]		apb2mux_sync_clk_div_per_ctrl_w;	// From i_apb_clk_rst_gen of apb_reg_clk_rst_ctrl.v
    logic [REGISTER_WIDTH_CLK_RST-1:0]		apb2mux_sync_clk_div_dbg_ctrl_w;	// From i_apb_clk_rst_gen of apb_reg_clk_rst_ctrl.v
    logic [5:0]		apb2mux_sync_rst_ctrl_w;	// From i_apb_clk_rst_gen of apb_reg_clk_rst_ctrl.v
    logic [8:0]		mux_sync2apb_status_d;// From i_sys_clk_rst_gen of system_clk_rst_gen.v
    // End of automatics

    logic mux_ctrl_sync_q;
    logic mux_ctrl_sync_d;

    logic mux_sync_ctrl_status_d;
    logic mux_sync_ctrl_status_q;

    logic [REGISTER_WIDTH_CLK_RST-1:0]     sync2clk_rst_div_per_ctrl_q;
    logic [REGISTER_WIDTH_CLK_RST-1:0]     sync2clk_rst_div_debug_ctrl_q;
    logic [5:0]     mux_sync2clk_rst_gen_rst_ctrl_q;
    logic [8:0]     mux_sync2apb_status_q;



/*
    system_clk_rst_gen AUTO_TEMPLATE "i_sys_\(.*\)" (
                    .clk_ctrl_reg_i(apb2@_clk_ctrl_w),
                    .clk_div_en_reg_i(apb2@_clk_div_en_w),
                    .rst_ctrl_reg_i(apb2@_rst_ctrl_w),
                    .status_reg_o(@2apb_status_w),
);

    apb_reg_clk_rst_ctrl AUTO_TEMPLATE "^i_apb_\(.*\)_ctrl$" (
                    .clk_ctrl_reg_o(apb2@_gen_clk_ctrl_w),
                    .clk_div_en_o(apb2@_gen_clk_div_en_w),
                    .rst_ctrl_reg_o(apb2@_gen_rst_ctrl_w),
                    .clk_rst_ctrl_status_i(@gen2apb_status_w),);
*/

   logic dbg_clksel_soc_clk_sync;
   logic dbg_clksel_sys_clk_sync;


//cdc
   sync #(.STAGES(2)) i_debug_clksel_soc_clk_mux_sync (
      .clk_i    ( clk_soc_o    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( debug_clksel_i     ),                        
      .serial_o ( dbg_clksel_soc_clk_sync        )
    );

   sync #(.STAGES(2)) i_debug_clksel_sys_clk_mux_sync (
      .clk_i    ( sys_clk_i    ),
      .rst_ni   ( por_ni                            ),
      .serial_i ( dbg_clksel_soc_clk_sync     ),                        
      .serial_o ( dbg_clksel_sys_clk_sync        )
    );




    system_clk_rst_gen #(/*AUTOINSTPARAM*/
			 // Parameters
			 .DATA_WIDTH		(DATA_WIDTH),
             .RST_COUNTER       (HARD_RST_COUNTER),             
//			 .NUM_INPUTS		(NUM_INPUTS),
//			 .NUM_SYNC_STAGES	(NUM_SYNC_STAGES),
			 .RATIO			(RATIO)) i_sys_clk_rst_gen (/*AUTOINST*/
									    // Outputs
									    .status_reg_o	(mux_sync2apb_status_d), // Templated
                                        .mux_sync_status_ctrl_o (mux_sync_ctrl_status_d),
									    .rstn_soc_sync_o	(rstn_soc_sync_o),
									    .rstn_peripheral_sync_o(rstn_peripheral_sync_o),
                                        .rstn_debug_sync_o (rstn_debug_sync_o),
                                        .rstn_i2c_sync_o    (rstn_i2c_sync_o),
                                        .rstn_uart_sync_o   (rstn_uart_sync_o),
                                        .rstn_spi_sync_o    (rstn_spi_sync_o),
									    .clk_soc_o		(clk_soc_o),
									    .clk_per_o		(clk_per_o),
                                        .clk_for_debug_o(clk_for_debug_o),
//									    .clk_slow_o		(clk_slow_o),
//									    .clk_cluster_o	(clk_cluster_o),

									    // Inputs
									    .sys_clk_i		(sys_clk_i),
                                        .rc_clk_i       (rc_clk_i),
                                        .mem_clksel_rst_ctrl_i (mem_clksel_rst_ctrl_i),
                                        .debug_clksel_i (dbg_clksel_sys_clk_sync),
                                        .wdt_rst_scope_i (wdt_rst_scope_i),
                                        .wdt_rst_req_i   (wdt_rst_req_i),
                                        .non_dbg_rst_req_i (non_dbg_rst_req_i),
//									    .ref_clk_i		(ref_clk_i),
//									    .clk_ctrl_reg_i	(apb2clk_rst_gen_clk_ctrl_w), // Templated
									    .clk_div_per_reg_i	(sync2clk_rst_div_per_ctrl_q), // Templated
                                        .clk_div_debug_reg_i(sync2clk_rst_div_debug_ctrl_q),
									    .rst_ctrl_reg_i	(mux_sync2clk_rst_gen_rst_ctrl_q), // Templated
									    .por_ni	(por_ni),
                                        
									    .test_mode_soc_rstn_i(test_mode_soc_rst_i),
                                        .test_mode_soc_rstn_en_i(test_mode_soc_rst_en_i),
									    .test_mode_peripheral_rstn_i(test_mode_peripheral_rst_i),
                                        .test_mode_peripheral_rstn_en_i(test_mode_peripheral_rst_en_i),
                                        .test_mode_debug_rstn_i(test_mode_debug_rst_i),
                                        .test_mode_debug_rstn_en_i(test_mode_debug_rst_en_i),
                                        .test_mode_spi_rstn_en_i(test_mode_spi_rstn_en_i),
                                        .test_mode_spi_rstn_i(test_mode_spi_rstn_i),
                                        .test_mode_uart_rstn_en_i(test_mode_uart_rstn_en_i),
                                        .test_mode_uart_rstn_i(test_mode_uart_rstn_i),
                                        .test_mode_i2c_rstn_en_i(test_mode_i2c_rstn_en_i),
                                        .test_mode_i2c_rstn_i(test_mode_i2c_rstn_i),

									    .test_mode_clk_peripheral_mux_i(test_mode_clk_peripheral_mux_i),
									    .test_mode_clk_soc_mux_i(test_mode_clk_soc_mux_i),
//									    .test_mode_clk_cluster_mux_i(test_mode_clk_cluster_mux_i),
									    .test_mode_en_peripheral_mux_i(test_mode_en_peripheral_mux_i),
									    .test_mode_en_soc_mux_i(test_mode_en_soc_mux_i),
//									    .test_mode_en_cluster_mux_i(test_mode_en_cluster_mux_i),
									    .test_mode_div_peripheral_i	(test_mode_div_peripheral_i),
                                        .test_mode_div_debug_i (test_mode_div_debug_i));
//cdc
    sync #(.STAGES(2)) i_mux_ctrl_apb_reg_sync(
      .clk_i    ( sys_clk_i                       ),
      .rst_ni   ( por_ni                        ),
      .serial_i ( mux_ctrl_sync_d               ),                        
      .serial_o ( mux_ctrl_sync_q                  )
    );
//cdc
    always_ff@(posedge sys_clk_i or negedge por_ni) begin
      if(!por_ni) begin
          mux_sync2clk_rst_gen_rst_ctrl_q           <= 6'b0; //{1'b0,{DATA_WIDTH-5{1'b0}},4'h0};
          sync2clk_rst_div_per_ctrl_q               <= {DEFAULT_PER_VALUE}; //{1'b1,{DATA_WIDTH-5{1'b0}},4'h2};
          sync2clk_rst_div_debug_ctrl_q             <= {DEFAULT_DEBUG_VALUE}; //{1'b1,{DATA_WIDTH-5{1'b0}},4'h4};
      end else if(mux_ctrl_sync_q) begin
          sync2clk_rst_div_debug_ctrl_q             <= apb2mux_sync_clk_div_dbg_ctrl_w;
          sync2clk_rst_div_per_ctrl_q               <= apb2mux_sync_clk_div_per_ctrl_w;
          mux_sync2clk_rst_gen_rst_ctrl_q           <= apb2mux_sync_rst_ctrl_w;
      end
    end
//cdc    
    sync #(.STAGES(2)) i_mux_ctrl_status_sync(
      .clk_i    ( pclk_i                       ),
      .rst_ni   ( por_ni                        ),
      .serial_i ( mux_sync_ctrl_status_d               ),                        
      .serial_o ( mux_sync_ctrl_status_q                  )
    );
//cdc
  always_ff@(posedge pclk_i or negedge por_ni) begin
    if(!por_ni) begin
        mux_sync2apb_status_q <= 9'b0; //{DATA_WIDTH{1'b0}};
    end else if(mux_sync_ctrl_status_q) begin
        mux_sync2apb_status_q <= mux_sync2apb_status_d;
    end
  end


/*
   tc_clk_mux2 i_test_clk_mux(
    .clk0_i(clk_or_w),
    .clk1_i(test_clk_i),
    .clk_sel_i(mux),
    .clk_o(final_clk)
   );
*/
 

    apb_reg_clk_rst_ctrl #(/*AUTOINSTPARAM*/
			   // Parameters
			   .ADDR_WIDTH		(ADDR_WIDTH),
			   .DATA_WIDTH		(DATA_WIDTH),
               .REGISTER_WIDTH  (($clog2(RATIO+1))+1)) i_apb_clk_rst_gen (/*AUTOINST*/
										 // Outputs
										 .prdata_o		(prdata_o),
										 .pready_o		(pready_o),
										 .pslverr_o		(pslverr_o),
//										 .clk_ctrl_reg_o	(apb2clk_rst_gen_clk_ctrl_w), // Templated
                                         .clk_div_debug_ctrl_o (apb2mux_sync_clk_div_dbg_ctrl_w),
										 .clk_div_per_reg_o		(apb2mux_sync_clk_div_per_ctrl_w), // Templated
										 .rst_ctrl_reg_o	(apb2mux_sync_rst_ctrl_w), // Templated
                                         
                                         .mux_sync_ctrl_o(mux_ctrl_sync_d),

										 // Inputs
										 .pclk_i		(pclk_i),
										 .presetn_i		(por_ni),
										 .paddr_i		(paddr_i),
										 .psel_i		(psel_i),
										 .penable_i		(penable_i),
										 .pwrite_i		(pwrite_i),
										 .pwdata_i		(pwdata_i),
										 .clk_rst_ctrl_status_i	(mux_sync2apb_status_q)); // Templated

    

endmodule
