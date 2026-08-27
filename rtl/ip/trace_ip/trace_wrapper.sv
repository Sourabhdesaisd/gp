

module trace_wrapper #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter SEL_WIDTH  = 3
)(
    //====================================================
    // CLOCKS
    //====================================================
    input  logic debug_clk,
    input  logic debug_rst,

    input  logic pclk,
    input  logic presetn,

    //====================================================
    // APB
    //====================================================
    input  logic [ADDR_WIDTH-1:0] paddr,
    input  logic                  psel,
    input  logic                  penable,
    input  logic                  pwrite,
    input  logic [DATA_WIDTH-1:0] pwdata,

    output logic [DATA_WIDTH-1:0] prdata,
    output logic                  pready,
    output logic                  pslverr,

    //====================================================
    // TRACE INPUTS
    // These inputs are already in DEBUG_CLK domain
    // after trace_cdc.
    //====================================================

    input logic [31:0] watchdog_data_i,
    input logic [7:0]  watchdog_event_i,

    input logic [31:0] i2c_data_i,
    input logic [7:0]  i2c_event_i,

    input logic [31:0] spi_data_i,
    input logic [7:0]  spi_event_i,

    input logic [31:0] mmu_data_i,
    input logic [7:0]  mmu_event_i,

    input logic [31:0] uart_data_i,
    input logic [7:0]  uart_event_i,

    input logic [31:0] intr_data_i,
    input logic [7:0]  intr_event_i,

    input logic [31:0] bridge_data_i,
    input logic [7:0]  bridge_event_i,

    input logic [31:0] debug_data_i,
    input logic [7:0]  debug_event_i,

    //====================================================
    // TRACE CONFIGURATION
    // PCLK side outputs from trace_register
    //====================================================

    output logic [SEL_WIDTH-1:0] block_sel_wire,
    output logic [7:0]           event_compare_wire,
    output logic                 capture_enable_wire,
    output logic                 window_mode_wire,
    output logic [31:0]          window_size_wire,
    output logic [31:0]          window_time_wire,

    //====================================================
    // DEBUG DOMAIN CONFIGURATION
    // These come back from trace_cdc
    //====================================================

    input logic [SEL_WIDTH-1:0] block_sel_sync,
    input logic [7:0]           event_compare_sync,
    input logic                 capture_enable_sync,
    input logic                 window_mode_sync,
    input logic [31:0]          window_size_sync,
    input logic [31:0]          window_time_sync,

    //====================================================
    // GPIO
    //====================================================
    output logic [15:0] gpio_data_o,
    output logic        gpio_valid_o
);

    //====================================================
    // TRACE REGISTER
    // PCLK DOMAIN
    //====================================================

    trace_register #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .SEL_WIDTH  (SEL_WIDTH)
    ) u_trace_register (
        .pclk    (pclk),
        .presetn (presetn),

        .paddr   (paddr),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .pwdata  (pwdata),

        .prdata  (prdata),
        .pready  (pready),
        .pslverr (pslverr),

        .block_sel_reg      (block_sel_wire),
        .event_compare_reg  (event_compare_wire),
        .capture_enable_reg (capture_enable_wire),
        .window_mode_reg    (window_mode_wire),
        .window_size_reg    (window_size_wire),
        .window_time_reg    (window_time_wire)
    );

    //====================================================
    // TRACE TOP
    // DEBUG CLOCK DOMAIN
    //====================================================

    trace_top u_trace_top (
        .clk (debug_clk),
        .rst_n (debug_rst),

        // Trace data
        .watchdog_data_i (watchdog_data_i),
        .watchdog_event_i(watchdog_event_i),

        .i2c_data_i      (i2c_data_i),
        .i2c_event_i     (i2c_event_i),

        .spi_data_i      (spi_data_i),
        .spi_event_i     (spi_event_i),

        .mmu_data_i      (mmu_data_i),
        .mmu_event_i     (mmu_event_i),

        .uart_data_i     (uart_data_i),
        .uart_event_i    (uart_event_i),

        .intr_data_i     (intr_data_i),
        .intr_event_i    (intr_event_i),

        .bridge_data_i   (bridge_data_i),
        .bridge_event_i  (bridge_event_i),

        .debug_data_i    (debug_data_i),
        .debug_event_i   (debug_event_i),

        // Configuration
        .block_sel_i          (block_sel_sync),
        .event_compare_reg_i  (event_compare_sync),
        .capture_enable_i     (capture_enable_sync),
        .window_mode_i        (window_mode_sync),
        .window_size_i        (window_size_sync),
        .window_time_i        (window_time_sync),

        // GPIO
        .gpio_data_o  (gpio_data_o),
        .gpio_valid_o (gpio_valid_o)
    );

endmodule
