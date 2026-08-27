module spi_master #(
    parameter DATA_WIDTH = 32
    //parameter CLK_DIV = 4
)(
    input clk,
    input rst_n,

    // Controller interface
    input start,
    input [DATA_WIDTH-1:0] tx_data,
    input cpol,
    input cpha,
    input [7:0] clk_div,    //newly added

    output busy,  
    output done,  
    output reg [DATA_WIDTH-1:0] rx_data,

    // SPI interface
    input miso,
    output reg mosi,
    output reg sclk,
    output ss,
    
    // Trace monitor
    output [2:0] debug_state,
    output [$clog2(DATA_WIDTH):0] debug_bit_cnt,
    output debug_shift_tick,
    output debug_sample_tick      
);

    // FSM States
    localparam IDLE     = 3'd0;
    localparam START_FSM = 3'd1;
    localparam TRANSFER = 3'd2;
    localparam WAIT_SS  = 3'd3;
    localparam DONE_FSM = 3'd4;

    reg [2:0] state;
    reg [DATA_WIDTH-1:0] tx_reg, rx_reg;
    reg [$clog2(DATA_WIDTH):0] bit_cnt;
    
    reg start_d1;
    reg start_d2;

    always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
	   start_d1 <= 1'b0;
	   start_d2 <= 1'b0;
	end
	else begin
	   start_d1 <= start;
	   start_d2 <= start_d1;
	end
    end

    // Internal Clocking & Timing
    //reg [$clog2(CLK_DIV/2 > 0 ? CLK_DIV/2 : 1)-1:0] clk_cnt;
    reg [6:0] clk_cnt ;
    reg [6:0] clk_div_w ;           // newly added
    reg tick;

    wire [2:0] state_w;
    assign state_w = state;
    assign clk_div_w = clk_div[7:1] + {6'd0,clk_div[0]}  ;       //  newly added

    // Combinational Outputs
    assign busy = (state != IDLE) && (state != DONE_FSM);
    assign done = (state == DONE_FSM);
    // SS stays low through START_FSM, TRANSFER, and the new WAIT_SS state
    assign ss   = (state == START_FSM || state == TRANSFER || state == WAIT_SS) ? 1'b0 : 1'b1;

    // Clock/Tick Generation
    // Tick generation continues into WAIT_SS so we can measure the hold time
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= '0;
            tick <= '0;
        end
	else if (state_w == TRANSFER || state_w == WAIT_SS) begin
            if (clk_cnt == (clk_div_w - 1)) begin       //newly changed
                clk_cnt <= '0;
                tick <= 1'b1;
            end
	    else begin
                clk_cnt <= clk_cnt + 1'b1;
                tick <= '0;
            end
        end
	else begin
            clk_cnt <= '0;
            tick <= '0;
        end
    end

    reg sclk_r;

    wire tick_w;
    assign tick_w = tick;
    // Physical SCLK Driver
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sclk <= '0;
            sclk_r <= '0;
        end
	else if (state_w == IDLE || state_w == START_FSM || state_w == WAIT_SS || state_w == DONE_FSM) begin
            sclk <= cpol; // Force clean return to idle state
            sclk_r <= cpol; 
        end
	else if (state_w == TRANSFER && tick_w) begin
            sclk <= ~sclk_r;
	    sclk_r <= ~sclk_r;
        end
    end

    wire leading_tick;
    wire trailing_tick;

    assign leading_tick = tick && (sclk_r == cpol);
    assign trailing_tick = tick && (sclk_r == ~cpol);

    wire sample_tick;
    wire shift_tick;

    assign sample_tick = (cpha == 0) ? leading_tick  : trailing_tick;
    assign shift_tick = (cpha == 0) ? trailing_tick : leading_tick;

    // Debug Capture
    assign debug_state = state;
    assign debug_bit_cnt = bit_cnt;
    assign debug_shift_tick = shift_tick;
    assign debug_sample_tick = sample_tick;
    
    // MAIN FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            mosi  <= '0;
            tx_reg <= '0;
            rx_reg <= '0;
            bit_cnt <= '0;
            rx_data <= '0;
        end
	else begin
            
            case (state)
                IDLE: begin
                    if (start_d2) begin
                        state <= START_FSM;
                    end
                    bit_cnt <= '0;
                end

                START_FSM: begin
                    state <= TRANSFER;
                    rx_reg <= '0;
                    
                    if (cpha == 0) begin
                        mosi <= tx_data[DATA_WIDTH-1]; 
                        tx_reg <= {tx_data[DATA_WIDTH-2:0], 1'b0};
                    end
		    else begin
                        mosi <= '0; 
                        tx_reg <= tx_data;
                    end
                end

                TRANSFER: begin
                    // SHIFT Action
                    if (shift_tick && bit_cnt < DATA_WIDTH) begin
                        mosi <= tx_reg[DATA_WIDTH-1];
                        tx_reg <= {tx_reg[DATA_WIDTH-2:0], 1'b0};
                    end

                    // SAMPLE Action
                    if (sample_tick && bit_cnt < DATA_WIDTH) begin
                        rx_reg <= {rx_reg[DATA_WIDTH-2:0], miso};
                        bit_cnt <= bit_cnt + 1'b1;
                    end

                    // END OF TRANSACTION LOGIC
                    if (trailing_tick) begin
                        if ((cpha == 0 && bit_cnt == DATA_WIDTH) || 
                            (cpha == 1 && bit_cnt == DATA_WIDTH - 1)) begin
                            // Transition to WAIT_SS instead of DONE_FSM
                            state <= WAIT_SS;
                        end
                    end
                end

                WAIT_SS: begin
                    // Wait for one final tick (half SCLK cycle) to give the slave hold time
                    if (tick_w) begin
                        state <= DONE_FSM;
                        rx_data <= rx_reg; // Safely assign data EXACTLY when state becomes DONE_FSM
                    end
                end

                DONE_FSM: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
