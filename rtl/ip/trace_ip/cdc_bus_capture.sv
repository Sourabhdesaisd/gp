module cdc_bus_capture #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             valid_sync,
    input  logic [WIDTH-1:0] bus_async,

    output logic [WIDTH-1:0] bus_sync
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        bus_sync <= '0;
    else if (valid_sync)
        bus_sync <= bus_async;
end

endmodule
