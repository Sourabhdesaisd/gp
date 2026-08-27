module i2c_register #(
  parameter ADDR_WIDTH = 8,
  parameter DATA_WIDTH = 32
)(
  // APB Interface
  input  logic                     pclk,
  input  logic                     presetn,
  input  logic [ADDR_WIDTH-1:0]    paddr,
  input  logic                     psel,
  input  logic                     penable,
  input  logic                     pwrite,
  input  logic [DATA_WIDTH-1:0]    pwdata,
  output logic [DATA_WIDTH-1:0]    prdata,
  output logic                     pready,
  output logic                     pslverr,

  //inout wire sda,
 // output wire scl
//Internal register for apb
	
 output	logic [1:0] control_reg,				//2-bit start trigger
 output	logic [6:0] addr_reg, 				//7-bit slave_address
 output	logic [7:0] data_in_reg,				//8 bit TX data
 //output	logic       operation_reg;			//1 bit read/write op

//Internal wire connection to thr I2C master

 input	logic i2c_busy,
// input	logic i2c_done,
 input	logic i2c_ack_err,
 input	logic [7:0] i2c_rx_data



);

  // -------------------------------------------------
  // Address Map


	localparam CONTROL   = 8'h00;			//control_reg -> start/stop bit 0 (Start trigger) 
	localparam ADDR      = 8'h04;			//addr -> slave_addr        bit 6:0 
	localparam DATA_IN   = 8'h08;			//data_in 		    bit 7:0
//	localparam OPERATION = 8'h0c;			//operation -> read/write   bit 0
	localparam STATUS    = 8'h0c;			//status -> done,ack_err,busy  Bit 2: ack_err, Bit 1: done, Bit 0: busy
	localparam DATA_OUT  = 8'h10;			//data_out -> out          bit 7:0



  // -------------------------------------------------
  // APB Control Signals
  // -------------------------------------------------
  logic write_en, read_en, access_en;
  assign write_en  = psel & penable & pwrite;
  assign read_en   = psel & ~pwrite ;
  assign access_en = psel & penable;
  assign pready = 1'b1;

  // -------------------------------------------------
  // Address Decode
  // -------------------------------------------------
  logic addr_valid;

  always_comb begin
    case (paddr)
          CONTROL,
	  ADDR,
	  DATA_IN,
	 // OPERATION,
	  STATUS,
	  DATA_OUT: addr_valid = 1'b1;
     	  default : addr_valid = 1'b0;
    endcase
  end

  // -------------------------------------------------
  // APB Response
  // -------------------------------------------------
 
  // Slave error conditions:
  // 1. Invalid address access
  // 2. Write to read-only register (STATUS)

  logic write_to_ro;

  assign write_to_ro = write_en && ((paddr == STATUS) || (paddr == DATA_OUT));

  assign pslverr = access_en && ( ~addr_valid || write_to_ro );

  // -------------------------------------------------
  // CONTROL Register (RW)
  // -------------------------------------------------
/*  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
      control_reg <= 2'b0;
      addr_reg <= 7'b0;
      data_in_reg <= 8'b0;
     // operation_reg <= 1'b0;
    end
	else  begin
	control_reg <= 1'b0;

	 if(write_en && addr_valid) begin
		case(paddr)
		CONTROL  :   begin control_reg[0]   <= pwdata[0]; control_reg[1] <= pwdata[1]; end
                ADDR     :   begin  addr_reg      <= pwdata[6:0];end
                DATA_IN  :   begin  data_in_reg   <= pwdata[7:0]; end
               // OPERATION:   operation_reg <= pwdata[0];
	endcase
	end
end
end*/

always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        control_reg <= 2'b0;
        addr_reg    <= 7'b0;
        data_in_reg <= 8'b0;
    end
    else begin
        if (write_en && addr_valid) begin
            case (paddr)
                CONTROL : control_reg <= pwdata[1:0];
                ADDR    : addr_reg    <= pwdata[6:0];
                DATA_IN : data_in_reg <= pwdata[7:0];
            endcase
        end
        if (control_reg[0] == 1'b1) begin
            control_reg[0] <= 2'b00;  // auto-clear only when no write happening
        end
    end
end






  // -------------------------------------------------
  // Read logic
  // -------------------------------------------------
  always_comb begin
	prdata = '0;  ///////Default to 0 to prevent lacthes and clean the bus
  if(read_en && addr_valid) begin
    case (paddr)
		CONTROL:   prdata = {30'd0, control_reg};
                ADDR:      prdata = {25'd0, addr_reg};
                DATA_IN:   prdata = {24'd0, data_in_reg};
              //  OPERATION: prdata = {31'd0, operation_reg};
                STATUS:    prdata = {30'd0, i2c_ack_err , i2c_busy};
                DATA_OUT:  prdata = {24'd0, i2c_rx_data};
                default    : prdata = '0;   // safe default
    endcase
  end
end


endmodule



