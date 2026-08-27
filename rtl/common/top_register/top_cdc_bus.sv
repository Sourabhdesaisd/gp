module top_cdc_bus #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             rstn,

    input  logic             valid_sync,

    input  logic [WIDTH-1:0] bus_async,

    output logic [WIDTH-1:0] bus_sync
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        bus_sync <= '0;

    else if (valid_sync)
        bus_sync <= bus_async;
end

endmodule
