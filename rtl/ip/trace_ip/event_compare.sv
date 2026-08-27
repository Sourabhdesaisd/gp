module event_compare #(
    parameter EVENT_WIDTH = 8
)(
    // Selected event from Event MUX
    input  wire [EVENT_WIDTH-1:0] selected_event_i,

    // Register input from Top Register Module
    input  wire [EVENT_WIDTH-1:0] event_compare_reg_i,

    // Capture Enable Register
 //   input  wire                   capture_enable_i,

    // Output
    output wire                   event_match_o
);

    //----------------------------------------------------------
    // Event Compare Logic
    //----------------------------------------------------------
    assign event_match_o =
            (selected_event_i == event_compare_reg_i);

endmodule
