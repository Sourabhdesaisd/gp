module spi_wrapper #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
//    parameter CLK_DIV    = 4   // newly commented
)(
    // APB Interface
    input pclk,
    input presetn,
    input [ADDR_WIDTH-1:0] paddr,
    input psel,
    input penable,
    input pwrite,
    input [DATA_WIDTH-1:0] pwdata,
    output [DATA_WIDTH-1:0] prdata,
    output pready,
    output pslverr,

    // External SPI Interface
    input miso,
    output mosi,
    output sclk,
    output ss,

    // Trace & Debug
    output reg [7:0] trace_event,
    output reg [31:0] trace_debug
);

    // Internal Interconnect Wires
    wire spi_start;
    wire spi_cpol;
    wire spi_cpha;
    wire [DATA_WIDTH-1:0] spi_tx_data;
    wire spi_busy;
    wire spi_done;
    wire [DATA_WIDTH-1:0] spi_rx_data;
    wire [7:0]          clk_div;
    // Wires for debug
    wire [2:0] debug_state;
    wire [$clog2(DATA_WIDTH):0] debug_bit_cnt;
    wire debug_shift_tick;
    wire debug_sample_tick;

    // Register Bank Instance
    spi_regs #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi_regs (
        .pclk          (pclk),
        .presetn       (presetn),
        .paddr         (paddr),
        .psel          (psel),
        .penable       (penable),
        .pwrite        (pwrite),
        .pwdata        (pwdata),
        .prdata        (prdata),
        .pready        (pready),
        .pslverr       (pslverr),
        
        .spi_start     (spi_start),
        .spi_cpol      (spi_cpol),
        .spi_cpha      (spi_cpha),
        .clk_div_q      (clk_div),      //newly added
        .spi_tx_data   (spi_tx_data),
        .spi_busy      (spi_busy),
        .spi_done      (spi_done),
        .spi_rx_data   (spi_rx_data)
    );

    // SPI Master Core Instance
    spi_master #(
        .DATA_WIDTH(DATA_WIDTH)
  //      .CLK_DIV(CLK_DIV)
    ) u_spi_core (
        .clk           (pclk),      
        .rst_n         (presetn),   
        .start         (spi_start),
        .tx_data       (spi_tx_data),
        .cpol          (spi_cpol),
        .cpha          (spi_cpha),
        .busy          (spi_busy),
        .done          (spi_done),
        .rx_data       (spi_rx_data),
        .miso          (miso),
        .mosi          (mosi),
        .sclk          (sclk),
        .ss            (ss),
        .clk_div      (clk_div),      //newly added

	.debug_state       (debug_state),
        .debug_bit_cnt     (debug_bit_cnt),
        .debug_shift_tick  (debug_shift_tick),
        .debug_sample_tick (debug_sample_tick)
    );

    // TRACE & DEBUG LOGIC
    
    wire evt_apb_setup = psel & ~penable;                  		// APB Address Setup Phase
    wire evt_apb_write = psel & penable & pwrite;          		// APB Write Data Phase
    wire evt_apb_read = psel & penable & ~pwrite;         		// APB Read Data Phase
    wire evt_spi_start = spi_start;                        		// Core triggered
    wire evt_spi_shift = (debug_state == 3'd2) & debug_shift_tick;  	// Serial Shift Tick
    wire evt_spi_sample= (debug_state == 3'd2) & debug_sample_tick; 	// Serial Sample Tick
    wire evt_spi_done = spi_done;                         		// Transfer complete
    wire evt_spi_err = (spi_start & spi_busy) | (debug_state > 3'd4); 	// State error

    // Map clubbed signals directly to the 8-bit output
    always @(posedge pclk or negedge presetn) begin
       if (!presetn) begin
	  trace_event <= 8'b0;
       end
       else begin
	  trace_event <= {evt_spi_err, evt_spi_done, evt_spi_sample, evt_spi_shift, evt_spi_start, evt_apb_read, evt_apb_write, evt_apb_setup};
       end
    end

    // Capture the actual payload based on which event is active
    always @(posedge pclk or negedge presetn) begin
       if (!presetn) begin
          trace_debug <= 32'b0;
       end
       else begin
          if (evt_spi_err) begin
	     trace_debug <= {27'b0, spi_busy, spi_done, debug_state};
          end
          else if (evt_spi_start) begin
             trace_debug <= spi_tx_data;           // Capture TX Payload
          end
          else if (evt_apb_setup) begin
             trace_debug <= {paddr}; 	          // Capture Address
          end
          else if (evt_apb_write) begin
             trace_debug <= pwdata;                // Capture Write Data
          end
          else if (evt_apb_read) begin
             trace_debug <= prdata;                // Capture Read Data
          end
          else if (evt_spi_shift) begin
             trace_debug <= {mosi, debug_bit_cnt};
          end
          else if (evt_spi_sample) begin
             trace_debug <= {miso, debug_bit_cnt};
          end
          else if (evt_spi_done) begin
             trace_debug <= spi_rx_data;
          end
	  else begin
	     trace_debug <= 32'b0;
	  end
       end
    end
 
endmodule
