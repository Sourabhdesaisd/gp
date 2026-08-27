/*module event_mux #(
    parameter DATA_WIDTH  = 32,
    parameter EVENT_WIDTH = 8,
    parameter NUM_BLOCKS  = 8,
    parameter SEL_WIDTH   = 3
)(
    // Inputs from all blocks
    input  wire [NUM_BLOCKS*DATA_WIDTH-1:0]  block_data_i,
    input  wire [NUM_BLOCKS*EVENT_WIDTH-1:0] block_event_i,
  //  input  wire [NUM_BLOCKS-1:0]             block_clk_i,

    // Register input
    input  wire [SEL_WIDTH-1:0]              block_sel_i,

    // Selected outputs
    output reg  [DATA_WIDTH-1:0]             selected_data_o,
    output reg  [EVENT_WIDTH-1:0]            selected_event_o
  //  output reg                               selected_clk_o
);

integer i;

always @(*) begin

    // Default outputs
    selected_data_o  = {DATA_WIDTH{1'b0}};
    selected_event_o = {EVENT_WIDTH{1'b0}};
  //  selected_clk_o   = 1'b0;

    // Select required block
    for(i = 0; i < NUM_BLOCKS; i = i + 1) begin
        if(block_sel_i == i) begin
            selected_data_o  = block_data_i[(i*DATA_WIDTH) +: DATA_WIDTH];
            selected_event_o = block_event_i[(i*EVENT_WIDTH) +: EVENT_WIDTH];
           // selected_clk_o   = block_clk_i[i];
        end
    end

end

endmodule */


module event_mux #(
    parameter DATA_WIDTH  = 32,
    parameter EVENT_WIDTH = 8,
    parameter NUM_BLOCKS  = 8,
    parameter SEL_WIDTH   = 3
)(
    ////////////////////////////////////////////////////////////
    // Inputs from all blocks
    ////////////////////////////////////////////////////////////

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

    // Reserved / Block 7
    input wire [DATA_WIDTH-1:0] debug_data_i,
    input wire [EVENT_WIDTH-1:0] debug_event_i,

    ////////////////////////////////////////////////////////////
    // Register input
    ////////////////////////////////////////////////////////////

    input wire [SEL_WIDTH-1:0] block_sel_i,

    ////////////////////////////////////////////////////////////
    // Selected outputs
    ////////////////////////////////////////////////////////////

    output reg [DATA_WIDTH-1:0] selected_data_o,
    output reg [EVENT_WIDTH-1:0] selected_event_o

);

always @(*) begin

    // Default outputs
    selected_data_o  = {DATA_WIDTH{1'b0}};
    selected_event_o = {EVENT_WIDTH{1'b0}};

    case(block_sel_i)

        3'd0: begin
            selected_data_o  = watchdog_data_i;
            selected_event_o = watchdog_event_i;
        end

        3'd1: begin
            selected_data_o  = i2c_data_i;
            selected_event_o = i2c_event_i;
        end

        3'd2: begin
            selected_data_o  = spi_data_i;
            selected_event_o = spi_event_i;
        end

        3'd3: begin
            selected_data_o  = mmu_data_i;
            selected_event_o = mmu_event_i;
        end

        3'd4: begin
            selected_data_o  = uart_data_i;
            selected_event_o = uart_event_i;
        end

        3'd5: begin
            selected_data_o  = intr_data_i;
            selected_event_o = intr_event_i;
        end

        3'd6: begin
            selected_data_o  = bridge_data_i;
            selected_event_o = bridge_event_i;
        end

        3'd7: begin
            selected_data_o  = debug_data_i;
            selected_event_o = debug_event_i;
        end

        default: begin
            selected_data_o  = {DATA_WIDTH{1'b0}};
            selected_event_o = {EVENT_WIDTH{1'b0}};
        end

    endcase

end

endmodule
