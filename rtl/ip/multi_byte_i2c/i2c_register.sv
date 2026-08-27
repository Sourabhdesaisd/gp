/*module i2c_register #(
parameter ADDR_WIDTH = 8,
parameter DATA_WIDTH = 32
)(
// APB Interface
input logic                  pclk,
input logic                  presetn,
input logic [ADDR_WIDTH-1:0] paddr,
input logic                  psel,
input logic                  penable,
input logic                  pwrite,
input logic [DATA_WIDTH-1:0] pwdata,


output logic [DATA_WIDTH-1:0] prdata,
output logic                  pready,
output logic                  pslverr,

// Outputs to I2C Master
output logic [3:0]           control_reg,
// CONTROL REGISTER
// control_reg[0] : START
// control_reg[1] : RW_OP
//                  0 = WRITE
//                  1 = READ
// control_reg[2] : MODE_SEL
//                  0 = Single-byte transfer
//                  1 = Multi-byte (4-byte) transfer
// control_reg[3] : Reserved
output logic [6:0]           addr_reg,
output logic [7:0]           reg_addr_out,
output logic [31:0]          data_in_reg,
output logic [15:0]          clk_div_reg,

// Inputs from I2C Master
input logic                  i2c_busy,
input logic                  i2c_done,
input logic                  i2c_ack_err,
input logic [31:0]           i2c_rx_data
);
// Address Map
// Address Map

localparam CONTROL    = 8'h00;  // control_reg
                                // bit[0] : START
                                // bit[1] : RW_OP
                                // bit[2] : MODE_SEL: 0 = Single-byte transfer, 1 = Multi-byte (4-byte) transfer
                                // bit[3] : Reserved
localparam ADDR       = 8'h04;  // addr -> slave_addr, // bit[6:0]
                                // bit[6:0]
                                // Example slave address : 7'h11
localparam REG_ADDR   = 8'h08;  // reg_addr -> slave register address
                                // bit[31:0]
localparam DATA_IN    = 8'h0C;  // data_in -> TX data
                                // Single-byte mode : bit[7:0]
                                // Multi-byte mode : bit[31:0]
localparam DATA_OUT   = 8'h10;  // data_out -> RX data
                                // Single-byte mode : bit[7:0]
                                // Multi-byte mode : bit[31:0]
localparam STATUS     = 8'h14;  // status -> ack_err, done, busy
                                // bit[2] : ack_err
                                // bit[1] : d// bit[0] : busy
                                // bit[0] : busy

localparam CLK_DIV    = 8'h18;
// Internal Registers

logic [6:0] slave_addr_reg;
logic [7:0] reg_addr_reg;

logic [31:0] data_reg;
logic [2:0] status_reg;
logic [15:0] clk_div_reg_int;

logic write_en;
logic read_en;
//logic access_en;

logic addr_valid;
// APB Control
assign write_en  = psel & penable & pwrite;
assign read_en   = psel & penable & ~pwrite;
//assign access_en = psel & penable;

// APB Response Signals
assign pready = presetn && psel && penable;
// Address Decode
always_comb begin
 addr_valid = 1'b0;

    case (paddr)
        CONTROL,
        ADDR,
        REG_ADDR,
        DATA_IN,
        DATA_OUT,
        STATUS,
        CLK_DIV :
            addr_valid = 1'b1;
        default : addr_valid = 1'b0;
    endcase
end

// APB Error Respone
assign pslverr =
    presetn &&
    pready &&
    (
        !addr_valid ||
        (
            pwrite &&
            (
                (paddr == STATUS) ||
                (paddr == DATA_OUT)
            )
        )
    );
// Register Writes
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        control_reg      <= 4'b0000;
        slave_addr_reg   <= 7'd0;
        reg_addr_reg     <= 8'd0;
        data_reg         <= 32'd0;
        status_reg       <= 3'd0;
        clk_div_reg_int  <= 16'd100;
    end
    else begin

        //-----------------
        // Register Write Logic
        //-----------------
        if (write_en && addr_valid) begin
            case (paddr)

                CONTROL :
                    control_reg <= pwdata[3:0];

                ADDR :
                    slave_addr_reg <= pwdata[6:0];

                REG_ADDR :
                    reg_addr_reg <= pwdata[7:0];

                DATA_IN :
                    data_reg <= pwdata;

                CLK_DIV :
                    if (pwdata[15:0] >= 16'd4)
                        clk_div_reg_int <= pwdata[15:0];

                default : begin  //no action
end
            endcase
        end

        //-----------------
        // Status Register
        //-----------------
        if (!write_en)
            status_reg <= {
                i2c_ack_err,
                i2c_done,
                i2c_busy
            };

        //-----------------
        // Auto clear START
        //-----------------
        if (control_reg[0] && i2c_busy)
            control_reg[0] <= 1'b0;

    end
end
// Outputs to I2C Master
assign addr_reg     = slave_addr_reg;
assign reg_addr_out = reg_addr_reg;
assign data_in_reg  = data_reg;
assign clk_div_reg  = clk_div_reg_int;
// Read Logic
logic [31:0] prdata_int;

always_comb begin
 prdata_int = 32'd0;

    if(psel && penable && addr_valid) begin
    case (paddr)
CONTROL :
            prdata_int = {28'd0, control_reg};

        ADDR :
            prdata_int = {25'd0, slave_addr_reg};

        REG_ADDR :
            prdata_int = {24'd0, reg_addr_reg};

        DATA_IN :
            prdata_int = data_reg;

        DATA_OUT :
            prdata_int = i2c_rx_data;

        STATUS :
            prdata_int = {29'd0, status_reg};

        CLK_DIV :
            prdata_int = {16'd0, clk_div_reg_int};

        default :
            prdata_int = 32'd0;

    endcase
end
end

assign prdata = (read_en) ? prdata_int : 32'd0;
endmodule*/


module i2c_register #(
parameter ADDR_WIDTH = 8,
parameter DATA_WIDTH = 32
)(
// APB Interface
input logic                  pclk,
input logic                  presetn,
input logic [ADDR_WIDTH-1:0] paddr,
input logic                  psel,
input logic                  penable,
input logic                  pwrite,
input logic [DATA_WIDTH-1:0] pwdata,

output logic [DATA_WIDTH-1:0] prdata,
output logic                  pready,
output logic                  pslverr,

// Outputs to I2C Master
output logic [3:0]           control_reg,
// CONTROL REGISTER
// control_reg[0] : START
// control_reg[1] : RW_OP
//                  0 = WRITE
//                  1 = READ
// control_reg[2] : MODE_SEL
//                  0 = Single-byte transfer
//                  1 = Multi-byte (4-byte) transfer
// control_reg[3] : Reserved
output logic [6:0]           addr_reg,
output logic [7:0]           reg_addr_out,
output logic [31:0]          data_in_reg,
output logic [15:0]          clk_div_reg,

// Inputs from I2C Master
input logic                  i2c_busy,
input logic                  i2c_done,
input logic                  i2c_ack_err,
input logic [31:0]           i2c_rx_data
);
// Address Map
// Address Map

localparam CONTROL      = 8'h00; // control_reg
                                 // bit[0] : START
                                 // bit[1] : RW_OP
                                 // bit[2] : MODE_SEL: 0 = Single-byte transfer, 1 = Multi-byte
                                 // bit[3] : Reserved
localparam ADDR         = 8'h04; // addr -> slave_addr, // bit[6:0]
                                 // bit[6:0]
                                 // Example slave address : 7'h11
localparam REG_ADDR     = 8'h08; // reg_addr -> slave register address
                                 // bit[31:0]
localparam DATA_IN      = 8'h0C; // data_in -> TX data
                                 // Single-byte mode : bit[7:0]
                                 // Multi-byte mode : bit[31:0]
localparam DATA_OUT     = 8'h10; // data_out -> RX data
                                 // Single-byte mode : bit[7:0]
                                 // Multi-byte mode : bit[31:0]
localparam STATUS       = 8'h14; // status -> ack_err, done, busy
                                 // bit[2] : ack_err
                                 // bit[1] : d// bit[0] : busy
                                 // bit[0] : busy

localparam CLK_DIV      = 8'h18;
// Internal Registers

logic [6:0] slave_addr_reg;
logic [7:0] reg_addr_reg;

logic [31:0] data_reg;
logic [2:0] status_reg;
logic [15:0] clk_div_reg_int;

logic write_en;
logic read_en;
//logic access_en;

logic addr_valid;

// Reset tracking flag (feeds combinational pready/pslverr so presetn
// itself never appears directly in combinational logic)
logic reset_done;

// APB Control
assign write_en  = psel & penable & pwrite;
assign read_en   = psel & penable & ~pwrite;
//assign access_en = psel & penable;

// Reset Tracking
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn)
        reset_done <= 1'b0;
    else
        reset_done <= 1'b1;
end

// APB Response Signal (combinational, same-cycle - no extra register delay)
assign pready = reset_done;

// Address Decode
always_comb begin
    addr_valid = 1'b0;

    case (paddr)
        CONTROL,
        ADDR,
        REG_ADDR,
        DATA_IN,
        DATA_OUT,
        STATUS,
        CLK_DIV :
            addr_valid = 1'b1;
        default : addr_valid = 1'b0;
    endcase
end

// APB Error Response (combinational, same-cycle, gated by psel && penable
// so it never asserts when the slave is not selected)
assign pslverr =
    reset_done &&
    psel && penable &&
    (
        !addr_valid ||
        (
            pwrite &&
            (
                (paddr == STATUS) ||
                (paddr == DATA_OUT)
            )
        )
    );

// Register Writes
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        control_reg     <= 4'b0000;
        slave_addr_reg  <= 7'd0;
        reg_addr_reg    <= 8'd0;
        data_reg        <= 32'd0;
        status_reg      <= 3'd0;
        clk_div_reg_int <= 16'd100;

    end
    else begin
        //---------------
        // Register Write Logic
        //---------------
        // if (write_en && addr_valid)
        if (psel && penable && pwrite && addr_valid)
        begin
            case (paddr)

                CONTROL :
                    control_reg <= pwdata[3:0];

                ADDR :
                    slave_addr_reg <= pwdata[6:0];

                REG_ADDR :
                    reg_addr_reg <= pwdata[7:0];

                DATA_IN :
                    data_reg <= pwdata;

                CLK_DIV :
                    if (pwdata[15:0] >= 16'd4)
                        clk_div_reg_int <= pwdata[15:0];

                default: ;

            endcase
        end

        //---------------
        // Status Register
        //---------------

        //if (!write_en)
        if (!(psel && penable && pwrite))
            status_reg <= {
                i2c_ack_err,
                i2c_done,
                i2c_busy
            };

        // Auto clear START bit only after I2C master accepts the command
        if (control_reg[0] && i2c_busy)
            control_reg[0] <= 1'b0;
    end
end
// Outputs to I2C Master
assign addr_reg     = slave_addr_reg;
assign reg_addr_out = reg_addr_reg;
assign data_in_reg  = data_reg;
assign clk_div_reg  = clk_div_reg_int;
// Read Logic
logic [31:0] prdata_int;

always_comb begin
    prdata_int = 32'd0;

    if(psel && penable && addr_valid) begin
        case (paddr)
            CONTROL :
                prdata_int = {28'd0, control_reg};

            ADDR :
                prdata_int = {25'd0, slave_addr_reg};

            REG_ADDR :
                prdata_int = {24'd0, reg_addr_reg};

            DATA_IN :
                prdata_int = data_reg;

            DATA_OUT :
                prdata_int = i2c_rx_data;

            STATUS :
                prdata_int = {29'd0, status_reg};

            CLK_DIV :
                prdata_int = {16'd0, clk_div_reg_int};

            default :
                prdata_int = 32'd0;

        endcase
    end
end

assign prdata = (read_en) ? prdata_int : 32'd0;
endmodule
