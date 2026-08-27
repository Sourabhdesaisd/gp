module forward_mux (
    input  [31:0] rs_data,
    input  [31:0] ex_data,
    input  [31:0] wb_data,
    input  [1:0]  sel,
    output reg [31:0] for_out
);

always @(sel or rs_data or ex_data or wb_data) begin
    case (sel)
        2'b10: for_out = ex_data;
        2'b01: for_out = wb_data;
        default: for_out = rs_data;
    endcase
end

endmodule

