module capture_controller
(
    input  wire        clk,
    input  wire        rst_n,

    // Configuration
    input  wire        capture_enable_i,
    input  wire        window_mode_i,      // 0 = Sample Mode, 1 = Time Mode

    input  wire [31:0] window_size_i,
    input  wire [31:0] window_time_i,

    // Event Compare
    input  wire        event_match_i,

    // Output
    output reg         capture_valid_o
);

reg [31:0] sample_counter;
reg [31:0] time_counter;

reg event_match_d;

wire event_match_pulse;

assign event_match_pulse = event_match_i & ~event_match_d;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        sample_counter  <= 32'd0;
        time_counter    <= 32'd0;
        event_match_d   <= 1'b0;
        capture_valid_o <= 1'b0;
    end
    else
    begin
        event_match_d   <= event_match_i;
        capture_valid_o <= 1'b0;

        if(!capture_enable_i)
        begin
            sample_counter <= 32'd0;
            time_counter   <= 32'd0;
        end

        //------------------------------------------
        // Sample Window Mode
        //------------------------------------------
        else if(window_mode_i == 1'b0)
        begin
            if(event_match_pulse)
            begin
                if(sample_counter < window_size_i)
                begin
                    sample_counter  <= sample_counter + 32'b1;
                    capture_valid_o <= 1'b1;
                end
            end
        end

        //------------------------------------------
        // Time Window Mode
        //------------------------------------------
        else
        begin
            if(time_counter < window_time_i)
            begin
                time_counter <= time_counter + 32'b1;

                if(event_match_pulse)
                    capture_valid_o <= 1'b1;
            end
        end
    end
end

endmodule
