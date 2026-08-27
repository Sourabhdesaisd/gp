module top_cdc_pulse_sync (
    input  logic src_clk,
    input  logic dst_clk,
    input  logic rst_n,

    input  logic pulse_in,
    output logic pulse_out
);

    logic toggle_src;

    logic sync_ff1;
    logic sync_ff2;
    logic sync_ff2_d;

    //==========================================================
    // Source clock domain
    //==========================================================

    always_ff @(posedge src_clk or negedge rst_n) begin
        if (!rst_n) begin
            toggle_src <= 1'b0;
        end
        else if (pulse_in) begin
            toggle_src <= ~toggle_src;
        end
    end

    //==========================================================
    // Destination clock domain
    //==========================================================

    always_ff @(posedge dst_clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_ff1   <= 1'b0;
            sync_ff2   <= 1'b0;
            sync_ff2_d <= 1'b0;
        end
        else begin
            sync_ff1   <= toggle_src;
            sync_ff2   <= sync_ff1;
            sync_ff2_d <= sync_ff2;
        end
    end

    //==========================================================
    // Generate one destination-clock pulse
    //==========================================================

    assign pulse_out = sync_ff2 ^ sync_ff2_d;

endmodule
