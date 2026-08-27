module tc_clk_gating #(
  /// This paramaeter is a hint for tool/technology specific mappings of this
  /// tech_cell. It indicates wether this particular clk gate instance is
  /// required for functional correctness or just instantiated for power
  /// savings. If IS_FUNCTIONAL == 0, technology specific mappings might
  /// replace this cell with a feedthrough connection without any gating.
  parameter bit IS_FUNCTIONAL = 1'b1
)(
   input  logic clk_i,
   input  logic en_i,
   input  logic test_en_i,
   output logic clk_o
);

  logic clk_en;
  logic or_of_enables;
  assign or_of_enables = en_i | test_en_i;
  /* verilator lint_off COMBDLY */
  always_latch begin
    if (clk_i == 1'b0) clk_en <= or_of_enables; //en_i | test_en_i;
  end
  /* verilator lint_on COMBDLY */

  assign clk_o = clk_i & clk_en;

endmodule

