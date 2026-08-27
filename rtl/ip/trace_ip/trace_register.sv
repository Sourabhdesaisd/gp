module trace_register #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter SEL_WIDTH  = 3
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

    // Configuration Registers
    output logic [SEL_WIDTH-1:0]     block_sel_reg,
    output logic [7:0]               event_compare_reg,
    output logic                     capture_enable_reg,
    output logic                     window_mode_reg,
    output logic [31:0]              window_size_reg,
    output logic [31:0]              window_time_reg
);

/////////////////////////////////////////////////////
// Address Map
/////////////////////////////////////////////////////

localparam BLOCK_SEL      = 8'h00;
localparam EVENT_COMPARE  = 8'h04;
localparam CAPTURE_CTRL   = 8'h08;
localparam WINDOW_MODE    = 8'h0C;
localparam WINDOW_SIZE    = 8'h10;
localparam WINDOW_TIME    = 8'h14;

/////////////////////////////////////////////////////
// APB Signals
/////////////////////////////////////////////////////

logic write_en;
logic read_en;
logic addr_valid;

assign write_en = psel & penable & pwrite;
assign read_en  = psel & ~pwrite;

//assign pready = 1'b1;


always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn)
        pready <= 1'b0;
    else
        pready <= 1'b1;
end

/////////////////////////////////////////////////////
// Address Decode
/////////////////////////////////////////////////////

always_comb begin
    case(paddr)

        BLOCK_SEL,
        EVENT_COMPARE,
        CAPTURE_CTRL,
        WINDOW_MODE,
        WINDOW_SIZE,
        WINDOW_TIME :
            addr_valid = 1'b1;

        default :
            addr_valid = 1'b0;

    endcase
end

assign pslverr = (psel & penable) & (~addr_valid);

/////////////////////////////////////////////////////
// Register Write
/////////////////////////////////////////////////////

always_ff @(posedge pclk or negedge presetn) begin

    if(!presetn) begin

        block_sel_reg      <= '0;
        event_compare_reg  <= '0;
        capture_enable_reg <= 1'b0;
        window_mode_reg    <= 1'b0;
        window_size_reg    <= 32'd0;
        window_time_reg    <= 32'd0;

    end

    else if(write_en && addr_valid) begin

        case(paddr)

            BLOCK_SEL:
                block_sel_reg <= pwdata[SEL_WIDTH-1:0];

            EVENT_COMPARE:
                event_compare_reg <= pwdata[7:0];

            CAPTURE_CTRL:
                capture_enable_reg <= pwdata[0];

            WINDOW_MODE:
                window_mode_reg <= pwdata[0];

            WINDOW_SIZE:
                window_size_reg <= pwdata;

            WINDOW_TIME:
                window_time_reg <= pwdata;
           default: ;

        endcase

    end

end

/////////////////////////////////////////////////////
// Read Logic
/////////////////////////////////////////////////////

always_comb begin

    prdata = 32'd0;

    if(read_en && addr_valid) begin

        case(paddr)

            BLOCK_SEL:
                prdata = {{(32-SEL_WIDTH){1'b0}},block_sel_reg};

            EVENT_COMPARE:
                prdata = {24'd0,event_compare_reg};

            CAPTURE_CTRL:
                prdata = {31'd0,capture_enable_reg};

            WINDOW_MODE:
                prdata = {31'd0,window_mode_reg};

            WINDOW_SIZE:
                prdata = window_size_reg;

            WINDOW_TIME:
                prdata = window_time_reg;

            default:
                prdata = 32'd0;

        endcase

    end

end

endmodule
