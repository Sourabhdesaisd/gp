module trace_top #(
    parameter DATA_WIDTH   = 32,
    parameter EVENT_WIDTH  = 8,
    parameter NUM_BLOCKS   = 8,
    parameter SEL_WIDTH    = 3,
    parameter ADDR_WIDTH   = 10,
    parameter DEPTH        = 1024
)(
    input  wire                                clk,
    input  wire                                rst_n,

    //==========================================================
    // Inputs from Debug Blocks
    //==========================================================
  

// Watchdog Timer
input wire [DATA_WIDTH-1:0] watchdog_data_i,
input wire [EVENT_WIDTH-1:0] watchdog_event_i,

// I2C
input wire [DATA_WIDTH-1:0] i2c_data_i,
input wire [EVENT_WIDTH-1:0] i2c_event_i,

// SPI
input wire [DATA_WIDTH-1:0] spi_data_i,
input wire [EVENT_WIDTH-1:0] spi_event_i,

// MMU
input wire [DATA_WIDTH-1:0] mmu_data_i,
input wire [EVENT_WIDTH-1:0] mmu_event_i,

// UART / Debug
input wire [DATA_WIDTH-1:0] uart_data_i,
input wire [EVENT_WIDTH-1:0] uart_event_i,

// Interrupt Controller
input wire [DATA_WIDTH-1:0] intr_data_i,
input wire [EVENT_WIDTH-1:0] intr_event_i,

// APB-AXI Bridge
input wire [DATA_WIDTH-1:0] bridge_data_i,
input wire [EVENT_WIDTH-1:0] bridge_event_i,

// Reserved / Block7
input wire [DATA_WIDTH-1:0] debug_data_i,
input wire [EVENT_WIDTH-1:0] debug_event_i,

    //==========================================================
    // Configuration Registers
    //==========================================================
    input  wire [SEL_WIDTH-1:0]                block_sel_i,
    input  wire [7:0]                          event_compare_reg_i,
    input  wire                                capture_enable_i,
    input  wire                                window_mode_i,
    input  wire [31:0]                         window_size_i,
    input  wire [31:0]                         window_time_i,

    //==========================================================
    // GPIO Outputs
    //==========================================================
    output wire [15:0]                         gpio_data_o,
    output wire                                gpio_valid_o
 //   output wire                                gpio_clk_o
);

    //----------------------------------------------------------
    // Internal Signals
    //----------------------------------------------------------

    wire [31:0] selected_data;
    wire [7:0]  selected_event;
  //  wire        selected_clk;

    wire        event_match;
    wire        capture_valid;

    wire [31:0] buffer_data;

    wire [ADDR_WIDTH-1:0] wr_ptr;
    wire [ADDR_WIDTH-1:0] rd_ptr;

    wire rd_en;
reg [31:0] captured_data;
    // New signal
  //  wire data_available;

 //   assign data_available = (wr_ptr != rd_ptr);

    //----------------------------------------------------------
    // Event MUX
    //----------------------------------------------------------

   /* event_mux #(
        .DATA_WIDTH(DATA_WIDTH),
        .EVENT_WIDTH(EVENT_WIDTH),
        .NUM_BLOCKS(NUM_BLOCKS),
        .SEL_WIDTH(SEL_WIDTH)
    )
    u_event_mux
    (
        .block_data_i(block_data_i),
        .block_event_i(block_event_i),
       

        .block_sel_i(block_sel_i),

        .selected_data_o(selected_data),
        .selected_event_o(selected_event)
        //.selected_clk_o(selected_clk)
    );

   // assign gpio_clk_o = selected_clk; */


   event_mux #(
    .DATA_WIDTH(DATA_WIDTH),
    .EVENT_WIDTH(EVENT_WIDTH),
    .NUM_BLOCKS(NUM_BLOCKS),
    .SEL_WIDTH(SEL_WIDTH)
)
u_event_mux
(
    .watchdog_data_i(watchdog_data_i),
    .watchdog_event_i(watchdog_event_i),

    .i2c_data_i(i2c_data_i),
    .i2c_event_i(i2c_event_i),

    .spi_data_i(spi_data_i),
    .spi_event_i(spi_event_i),

    .mmu_data_i(mmu_data_i),
    .mmu_event_i(mmu_event_i),

    .uart_data_i(uart_data_i),
    .uart_event_i(uart_event_i),

    .intr_data_i(intr_data_i),
    .intr_event_i(intr_event_i),

    .bridge_data_i(bridge_data_i),
    .bridge_event_i(bridge_event_i),

    .debug_data_i(debug_data_i),
    .debug_event_i(debug_event_i),

    .block_sel_i(block_sel_i),

    .selected_data_o(selected_data),
    .selected_event_o(selected_event)
);

    //----------------------------------------------------------
    // Event Compare
    //----------------------------------------------------------

    event_compare
    u_event_compare
    (
        .selected_event_i(selected_event),
        .event_compare_reg_i(event_compare_reg_i),
       // .capture_enable_i(capture_enable_i),

      .event_match_o(event_match)
    );


    always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        captured_data <= 32'd0;
    else if (event_match)
        captured_data <= selected_data;
end

    //----------------------------------------------------------
    // Capture Controller
    //----------------------------------------------------------

    capture_controller
    u_capture_controller
    (
        .clk(clk),
        .rst_n(rst_n),

        .capture_enable_i(capture_enable_i),

        .window_mode_i(window_mode_i),
        .window_size_i(window_size_i),
        .window_time_i(window_time_i),

        .event_match_i(event_match),

        .capture_valid_o(capture_valid)
    );
//wire [31:0] wr_count;
//wire [31:0] rd_count;
    //----------------------------------------------------------
    // Write Pointer
    //----------------------------------------------------------

    write_pointer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    )
    u_write_pointer
    (
        .clk(clk),
        .rst_n(rst_n),

        .wr_en_i(capture_valid),

        .wr_ptr_o(wr_ptr)
       // .wr_count_o(wr_count)

    );

    //----------------------------------------------------------
    // Read Pointer
    //----------------------------------------------------------

    read_pointer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    )
    u_read_pointer
    (
        .clk(clk),
        .rst_n(rst_n),

        .rd_en_i(rd_en),

        .rd_ptr_o(rd_ptr)
       // .rd_count_o(rd_count)


    );


        //----------------------------------------------------------
    // Circular Buffer
    //----------------------------------------------------------

    /*circular_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    u_circular_buffer
    (
        .clk(clk),

        // Write Interface
        .wr_en_i(capture_valid),
        .wr_ptr_i(wr_ptr),
        .wr_data_i(selected_data),

        // Read Interface
        .rd_ptr_i(rd_ptr),

        // Output
        .rd_data_o(buffer_data)
    ); */

    circular_buffer #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
)
u_circular_buffer
(
    .clk(clk),

    // Write
    .wr_en_i(capture_valid),
    .wr_ptr_i(wr_ptr),
    .wr_data_i(captured_data),

    // Read
    .rd_ptr_i(rd_ptr),

    // Output
    .rd_data_o(buffer_data)
);


    //----------------------------------------------------------
    // GPIO Output
    //----------------------------------------------------------

    /*gpio_output
    u_gpio_output
    (
        .clk(clk),
        .rst_n(rst_n),

        .capture_enable_i(capture_enable_i),

    

        .buffer_data_i(buffer_data),

        .gpio_data_o(gpio_data_o),
        .gpio_valid_o(gpio_valid_o),

        .rd_en_o(rd_en)
    );*/


    gpio_output u_gpio_output
(
    .clk(clk),
    .rst_n(rst_n),

    .capture_enable_i(capture_enable_i),
    .capture_valid_i(capture_valid),    // NEW

    .buffer_data_i(buffer_data),

    .gpio_data_o(gpio_data_o),
   .gpio_valid_o(gpio_valid_o),

    .rd_en_o(rd_en)
);

endmodule
