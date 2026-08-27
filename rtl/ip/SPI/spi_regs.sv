module spi_regs #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32
)(
  // APB Interface
  input pclk,
  input presetn,
  input [ADDR_WIDTH-1:0] paddr,
  input psel,
  input penable,
  input pwrite,
  input [DATA_WIDTH-1:0] pwdata,
  output reg [DATA_WIDTH-1:0] prdata,
  output reg pready,
  output pslverr,

  // SPI Master Control Outputs
  output spi_start,
  output reg spi_cpol,
  output reg spi_cpha,
  output [DATA_WIDTH-1:0] spi_tx_data,
  output reg [7:0]      clk_div_q ,  //newly added

  // SPI Master Status Inputs
  input spi_busy,
  input spi_done,
  input [DATA_WIDTH-1:0] spi_rx_data
);

  // Address Map
  localparam ADDR_CTRL = 8'h00;
  localparam ADDR_TX_DATA = 8'h04;
  localparam ADDR_STATUS = 8'h08;
  localparam ADDR_RX_DATA = 8'h0C;
  localparam ADDR_CLK_DIV = 8'h10;      //newly added


  // Internal Registers
  //reg [DATA_WIDTH-1:1] ctrl_q;        //  commented newly
  reg [DATA_WIDTH-1:0] tx_data_q;
  reg done_flag;

  // APB Control Signals
  wire write_en = psel & penable & pwrite;
  wire read_en = psel & penable & ~pwrite;
  wire access_en = psel & penable;

  // Address Decode & Error Logic
  reg addr_valid;
  always @(*) begin
    case (paddr)
      ADDR_CTRL,
      ADDR_TX_DATA,
      ADDR_STATUS,
      ADDR_RX_DATA,
      ADDR_CLK_DIV: //newly added
      addr_valid = 1'b1;
      default : addr_valid = 1'b0;
    endcase
  end

  wire write_to_ro; 
  assign write_to_ro = write_en && ((paddr == ADDR_STATUS) || (paddr == ADDR_RX_DATA));
/*
  always_comb begin
    if (!presetn) begin
      pready = 1'b0;
      pslverr = 1'b0;
    end
    else begin
      pready = psel & penable;
      pslverr = access_en && ( ~addr_valid || write_to_ro );
    end
  end
*/

always @(posedge pclk or negedge presetn)
begin
    if(!presetn)
        pready <= 1'b0 ;
    else
        pready <= 1'b1 ;
end

assign pslverr = access_en && ( ~addr_valid || write_to_ro );

  // Write Logic (CTRL and TX_DATA)
  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
 //     ctrl_q <= {(DATA_WIDTH-1){1'b0}};   //newly commented
        spi_cpha <= 1'b0 ;
        spi_cpol <= 1'b0 ;
      tx_data_q <= {DATA_WIDTH{1'b0}};
      clk_div_q <= 8'd4 ;   //newly added
    end
    else if (write_en && addr_valid) begin
      case (paddr)
          ADDR_CTRL: begin  spi_cpha <= pwdata[1];          //newly added              
                            spi_cpol <= pwdata[2];          //newly added
                        end                                         // Mask bit 0 (start pulse)
        ADDR_TX_DATA: tx_data_q <= pwdata;
        ADDR_CLK_DIV: clk_div_q <= pwdata[7:0];                         //newly added
	default: begin
		//ctrl_q <= ctrl_q;             // newly commented
        spi_cpha <= spi_cpha ;          // newly added 
        spi_cpol <= spi_cpol ;          // newly added
        clk_div_q <= clk_div_q ;        // newly added
		tx_data_q <= tx_data_q;
	end
      endcase
    end
  end

  // SPI Control Assignments
  assign spi_start = (write_en && (paddr == ADDR_CTRL) && pwdata[0]);
//  assign spi_cpha = ctrl_q[1];            // commended newly
//  assign spi_cpol = ctrl_q[2];            // commended newly
  assign spi_tx_data = tx_data_q;

  // Read Logic & Status Tracking (Sticky Done Flag)
  wire clear_done;
  assign clear_done = read_en && (paddr == ADDR_RX_DATA);

  always @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      done_flag <= 1'b0;
    end
    else if (spi_done) begin
      done_flag <= 1'b1;
    end
    else if (clear_done) begin
      done_flag <= 1'b0;
    end
  end

  // Read Data Mux
 always @(*) begin
    if (read_en) begin
      case (paddr)
        ADDR_CTRL    : prdata = {29'd0,spi_cpol,spi_cpha, 1'b0};        // newly modified
        ADDR_TX_DATA : prdata = tx_data_q;
        ADDR_STATUS  : prdata = {{(DATA_WIDTH-2){1'b0}}, done_flag, spi_busy};
        ADDR_RX_DATA : prdata = spi_rx_data;
        ADDR_CLK_DIV : prdata = {24'd0,clk_div_q};  //newly added
        default      : prdata = {DATA_WIDTH{1'b0}};
      endcase
    end
    else begin
      prdata = {DATA_WIDTH{1'b0}};
    end
  end



endmodule
