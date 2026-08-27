module cdc_sync (
    input  logic clk,
    input  logic rstn,
    input  logic async_in,
    output logic sync_out
);

(* ASYNC_REG = "TRUE" *) logic sync_ff1;
(* ASYNC_REG = "TRUE" *) logic sync_ff2;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sync_ff1 <= 1'b0;
        sync_ff2 <= 1'b0;
    end
    else begin
        sync_ff1 <= async_in;
        sync_ff2 <= sync_ff1;
    end
end

assign sync_out = sync_ff2;

endmodule
