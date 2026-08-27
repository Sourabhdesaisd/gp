module clk_mux_2to1 (
 input  logic clk_0_i,
 input  logic rst_ni,
 input  logic clk_1_i,
 input  logic sel_i,
// input  logic clk_0_dead_i, // clk dead detection done outside this block
// input  logic clk_1_dead_i,
 input  logic test_clk_i,
 input  logic test_en_i,
 output logic clk_o
 );


// clock 0 path signals
 logic clk_0_w;
 logic clk_0_sel_w;
 logic clk_0_sel_q1;
 logic clk_0_sel_q2;
 logic clk_0_sel_q3;
 logic clk_0_mux_clksel_w;

// clock 1 path signals
 logic clk_1_w;
 logic clk_1_sel_w;
 logic clk_1_sel_q1;
 logic clk_1_sel_q2;
 logic clk_1_sel_q3;
 logic clk_1_mux_clksel_w;

// latch signals of clk 0 and 1
 logic clk_0_clksel_latch;
 logic clk_1_clksel_latch;

 logic clk_or_w;
 logic final_clk;

 logic [1:0] s_one_hot_w;

// below commented logic is for the without dead clock switch it will work
// logic [1:0] clk_sel_i;

// assign       clk_sel_i[0] = sel[0] && !clk_1_sel_w;
// assign       clk_sel_i[1] = sel[1] && !clk_0_sel_w;

  always_comb begin
    s_one_hot_w = 2'b0;
    s_one_hot_w[sel_i] = 1'b1;
  end
 


     sync #(.STAGES(2)) i_sync_clk0_en(
      .clk_i    ( clk_0_i                       ),
      .rst_ni   ( rst_ni ), //&& ~clk_0_dead_i                       ),
      .serial_i ( s_one_hot_w[0]                ),                         // clk_sel[0]
      .serial_o ( clk_0_sel_w                   )
    );

    sync #(.STAGES(2)) i_sync_clk1_en(
      .clk_i    ( clk_1_i                       ),
      .rst_ni   ( rst_ni ), // && ~clk_1_dead_i                       ),
      .serial_i ( s_one_hot_w[1]                ),                        // clk_sel[1]
      .serial_o ( clk_1_sel_w                   )
    );



  always_ff@(posedge clk_0_i or negedge rst_ni) begin
    if(!rst_ni) begin
       clk_0_sel_q1 <= 1'b0;
       clk_0_sel_q2 <= 1'b0;
       clk_0_sel_q3 <= 1'b0;
    end
    else begin 
       clk_0_sel_q1 <= clk_0_sel_w; 
       clk_0_sel_q2 <= clk_0_sel_q1;
       clk_0_sel_q3 <= clk_0_sel_q2;
    end
  end

  always_ff@(posedge clk_1_i or negedge rst_ni) begin
    if(!rst_ni) begin
       clk_1_sel_q1 <= 1'b0;
       clk_1_sel_q2 <= 1'b0;
       clk_1_sel_q3 <= 1'b0;
    end
    else begin 
       clk_1_sel_q1 <= clk_1_sel_w; 
       clk_1_sel_q2 <= clk_1_sel_q1;
       clk_1_sel_q3 <= clk_1_sel_q2;
    end
  end

  tc_clk_mux2 i_test_clk0_mux(
    .clk0_i(clk_0_sel_w         ),
    .clk1_i(clk_0_sel_q3        ),
    .clk_sel_i(clk_0_sel_w      ),
    .clk_o(clk_0_mux_clksel_w   )
  );

  tc_clk_mux2 i_test_clk1_mux(
    .clk0_i(clk_1_sel_w         ),
    .clk1_i(clk_1_sel_q3        ),
    .clk_sel_i(clk_1_sel_w      ),
    .clk_o(clk_1_mux_clksel_w   )
  );




  always @(clk_0_i or clk_0_mux_clksel_w) begin
    if (~clk_0_i) begin
        clk_0_clksel_latch <= clk_0_mux_clksel_w;
    end
  end

  always @(clk_1_i or clk_1_mux_clksel_w) begin
    if (~clk_1_i) begin
        clk_1_clksel_latch <= clk_1_mux_clksel_w;
    end
  end


 assign clk_0_w = (clk_0_clksel_latch && clk_0_mux_clksel_w && clk_0_i); 
 assign clk_1_w = (clk_1_clksel_latch && clk_1_mux_clksel_w && clk_1_i);

 assign clk_or_w = (clk_0_w || clk_1_w );
 
/*
   tc_clk_mux2 i_test_clk_mux(
    .clk0_i(clk_or_w),
    .clk1_i(test_clk_i),
    .clk_sel_i(test_en_i),
    .clk_o(final_clk)
  );
*/
  clk_mux_2to1_test i_scan_mode_test (
                .clk_0_i(clk_or_w),
                .rst_ni(rst_ni),
                .clk_1_i(test_clk_i),
                .sel_i(test_en_i),
//                .clk_0_dead_i(0), // clk dead detection done outside this block
//                .clk_1_dead_i(0),
//                .test_clk_i(0),
//                .test_en_i(0),
                .clk_o(final_clk)
 );


 assign clk_o = final_clk;

endmodule
