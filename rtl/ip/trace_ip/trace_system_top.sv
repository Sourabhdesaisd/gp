module trace_system_top #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter SEL_WIDTH  = 3
)(
    //==========================================================
    // CLOCKS
    //==========================================================

    input logic sys_clk,
    input logic sys_rst_n,

    input logic pclk,
    input logic presetn,

    input logic debug_clk,
    input logic debug_rst,


    //==========================================================
    // APB
    //==========================================================

    input logic [ADDR_WIDTH-1:0] paddr,
    input logic                  psel,
    input logic                  penable,
    input logic                  pwrite,
    input logic [DATA_WIDTH-1:0] pwdata,

    output logic [DATA_WIDTH-1:0] prdata,
    output logic                  pready,
    output logic                  pslverr,


    //==========================================================
    // PCLK TRACE SOURCES
    //==========================================================

    input logic [31:0] watchdog_data_i,
    input logic [7:0]  watchdog_event_i,

    input logic [31:0] i2c_data_i,
    input logic [7:0]  i2c_event_i,

    input logic [31:0] spi_data_i,
    input logic [7:0]  spi_event_i,

    input logic [31:0] uart_data_i,
    input logic [7:0]  uart_event_i,

    input logic [31:0] bridge_data_i,
    input logic [7:0]  bridge_event_i,


    //==========================================================
    // SYS_CLK TRACE SOURCES
    //==========================================================

    input logic [31:0] mmu_data_i,
    input logic [7:0]  mmu_event_i,

    input logic [31:0] intr_data_i,
    input logic [7:0]  intr_event_i,


    //==========================================================
    // DEBUG DOMAIN TRACE SOURCE
    //==========================================================

    input logic [31:0] debug_data_i,
    input logic [7:0]  debug_event_i,


    //==========================================================
    // GPIO
    //==========================================================

    output logic [15:0] gpio_data_o,
    output logic        gpio_valid_o,
    output logic        dob_trigger_o
);


    //==========================================================
    // CONFIGURATION:
    // PCLK -> DEBUG_CLK
    //==========================================================

    logic [SEL_WIDTH-1:0] block_sel_pclk;
    logic [7:0]           event_compare_pclk;
    logic                 capture_enable_pclk;
    logic                 window_mode_pclk;
    logic [31:0]          window_size_pclk;
    logic [31:0]          window_time_pclk;


    logic [SEL_WIDTH-1:0] block_sel_debug;
    logic [7:0]           event_compare_debug;
    logic                 capture_enable_debug;
    logic                 window_mode_debug;
    logic [31:0]          window_size_debug;
    logic [31:0]          window_time_debug;


    //==========================================================
    // TRACE DATA AFTER CDC
    //==========================================================

    logic [31:0] watchdog_data_debug;
    logic [7:0]  watchdog_event_debug;

    logic [31:0] i2c_data_debug;
    logic [7:0]  i2c_event_debug;

    logic [31:0] spi_data_debug;
    logic [7:0]  spi_event_debug;

    logic [31:0] uart_data_debug;
    logic [7:0]  uart_event_debug;

    logic [31:0] bridge_data_debug;
    logic [7:0]  bridge_event_debug;

    logic [31:0] mmu_data_debug;
    logic [7:0]  mmu_event_debug;

    logic [31:0] intr_data_debug;
    logic [7:0]  intr_event_debug;


    //==========================================================
    // 1. TRACE WRAPPER
    //
    // IMPORTANT:
    // trace_wrapper has ONLY PCLK + DEBUG_CLK.
    //
    // Its configuration outputs are PCLK-domain signals.
    //==========================================================

    trace_wrapper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SEL_WIDTH (SEL_WIDTH)
    ) u_trace_wrapper (

        // Clocks
        .debug_clk(debug_clk),
        .debug_rst(debug_rst),

        .pclk(pclk),
        .presetn(presetn),

        // APB
        .paddr(paddr),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .pwdata(pwdata),

        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr),

        //======================================================
        // DATA ALREADY IN DEBUG DOMAIN
        //======================================================

        .watchdog_data_i (watchdog_data_debug),
        .watchdog_event_i(watchdog_event_debug),

        .i2c_data_i      (i2c_data_debug),
        .i2c_event_i     (i2c_event_debug),

        .spi_data_i      (spi_data_debug),
        .spi_event_i     (spi_event_debug),

        .mmu_data_i      (mmu_data_debug),
        .mmu_event_i     (mmu_event_debug),

        .uart_data_i     (uart_data_debug),
        .uart_event_i    (uart_event_debug),

        .intr_data_i     (intr_data_debug),
        .intr_event_i    (intr_event_debug),

        .bridge_data_i   (bridge_data_debug),
        .bridge_event_i  (bridge_event_debug),

        // Already DEBUG domain
        .debug_data_i    (debug_data_i),
        .debug_event_i   (debug_event_i),

        // PCLK configuration outputs
        .block_sel_wire      (block_sel_pclk),
        .event_compare_wire  (event_compare_pclk),
        .capture_enable_wire (capture_enable_pclk),
        .window_mode_wire    (window_mode_pclk),
        .window_size_wire    (window_size_pclk),
        .window_time_wire    (window_time_pclk),

        // DEBUG configuration from CDC
        .block_sel_sync      (block_sel_debug),
        .event_compare_sync  (event_compare_debug),
        .capture_enable_sync (capture_enable_debug),
        .window_mode_sync    (window_mode_debug),
        .window_size_sync    (window_size_debug),
        .window_time_sync    (window_time_debug),

        // GPIO
        .gpio_data_o(gpio_data_o),
        .gpio_valid_o(gpio_valid_o)
    );


    //==========================================================
    // 2. TRACE CDC
    //
    // ALL CDC IS HERE.
    //
    // PCLK      -> DEBUG_CLK
    // SYS_CLK   -> DEBUG_CLK
    //==========================================================

    trace_cdc #(
        .SEL_WIDTH(SEL_WIDTH)
    ) u_trace_cdc (

        //======================================================
        // CLOCKS
        //======================================================

        .pclk(pclk),
        .presetn(presetn),

        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),

        .debug_clk(debug_clk),
        .debug_rst(debug_rst),

        //======================================================
        // PCLK CONFIGURATION
        //======================================================

        .block_sel_wire      (block_sel_pclk),
        .event_compare_wire  (event_compare_pclk),
        .capture_enable_wire (capture_enable_pclk),
        .window_mode_wire    (window_mode_pclk),
        .window_size_wire    (window_size_pclk),
        .window_time_wire    (window_time_pclk),

        //======================================================
        // DEBUG CONFIGURATION
        //======================================================

        .block_sel_sync      (block_sel_debug),
        .event_compare_sync  (event_compare_debug),
        .capture_enable_sync (capture_enable_debug),
        .window_mode_sync    (window_mode_debug),
        .window_size_sync    (window_size_debug),
        .window_time_sync    (window_time_debug),

        //======================================================
        // PCLK SOURCES
        //======================================================

        .watchdog_data_i  (watchdog_data_i),
        .watchdog_event_i (watchdog_event_i),

        .i2c_data_i       (i2c_data_i),
        .i2c_event_i      (i2c_event_i),

        .spi_data_i       (spi_data_i),
        .spi_event_i      (spi_event_i),

        .uart_data_i      (uart_data_i),
        .uart_event_i     (uart_event_i),

        .bridge_data_i    (bridge_data_i),
        .bridge_event_i   (bridge_event_i),

        //======================================================
        // SYS_CLK SOURCES
        //======================================================

        .mmu_data_i       (mmu_data_i),
        .mmu_event_i      (mmu_event_i),

        .intr_data_i      (intr_data_i),
        .intr_event_i     (intr_event_i),

        //======================================================
        // DEBUG OUTPUTS
        //======================================================

        .watchdog_data_sync  (watchdog_data_debug),
        .watchdog_event_sync (watchdog_event_debug),

        .i2c_data_sync       (i2c_data_debug),
        .i2c_event_sync      (i2c_event_debug),

        .spi_data_sync       (spi_data_debug),
        .spi_event_sync      (spi_event_debug),

        .uart_data_sync      (uart_data_debug),
        .uart_event_sync     (uart_event_debug),

        .bridge_data_sync    (bridge_data_debug),
        .bridge_event_sync   (bridge_event_debug),

        .mmu_data_sync       (mmu_data_debug),
        .mmu_event_sync      (mmu_event_debug),

        .intr_data_sync      (intr_data_debug),
        .intr_event_sync     (intr_event_debug)
    );

    assign dob_trigger_o = capture_enable_debug;

endmodule
