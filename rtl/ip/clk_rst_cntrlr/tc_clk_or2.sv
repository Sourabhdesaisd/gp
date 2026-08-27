module tc_clk_or2 (
  input logic clk0_i,
  input logic clk1_i,
  output logic clk_o
);

  assign clk_o = clk0_i | clk1_i;

endmodule

