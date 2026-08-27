

module gpio_output
(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        capture_enable_i,
    input  wire        capture_valid_i,

    input  wire [31:0] buffer_data_i,

    output reg [15:0]  gpio_data_o,
    output reg         gpio_valid_o,
    output reg         rd_en_o
);

localparam IDLE    = 3'd0;
localparam WAIT_ST  = 3'd1;
localparam LOAD    = 3'd2;
localparam LOWER   = 3'd3;
localparam UPPER   = 3'd4;
localparam ADVANCE = 3'd5;

reg [2:0]  state;
reg [31:0] data_reg;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state        <= IDLE;
        data_reg     <= 32'd0;

        gpio_data_o  <= 16'd0;
        gpio_valid_o <= 1'b0;
        rd_en_o      <= 1'b0;
    end
    else
    begin
        // Default outputs
       gpio_valid_o <= 1'b0;
        rd_en_o      <= 1'b0;

        case(state)

        //----------------------------------
        // WAIT_ST for a NEW capture
        //----------------------------------
        IDLE:
        begin
            if(capture_enable_i && capture_valid_i)
                state <= WAIT_ST;
        end

        //----------------------------------
        // WAIT_ST one clock
        //----------------------------------
        WAIT_ST:
        begin
            state <= LOAD;
        end

        //----------------------------------
        // Latch current buffer word
        //----------------------------------
        LOAD:
        begin
            data_reg <= buffer_data_i;
            state    <= LOWER;
        end

        //----------------------------------
        // Lower 16 bits
        //----------------------------------
        LOWER:
        begin
            gpio_data_o  <= data_reg[31:16];
           gpio_valid_o <= 1'b1;
            state        <= UPPER;
        end

        //----------------------------------
        // Upper 16 bits
        //----------------------------------
        UPPER:
        begin
            gpio_data_o  <= data_reg[15:0];
            gpio_valid_o <= 1'b1;
            state        <= ADVANCE;
        end

        //----------------------------------
        // Advance read pointer ONCE
        //----------------------------------
        ADVANCE:
        begin
            rd_en_o <= 1'b1;
            state   <= IDLE;
        end

        default:
            state <= IDLE;

        endcase
    end
end

endmodule



