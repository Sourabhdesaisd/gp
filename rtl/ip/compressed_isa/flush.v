module flush_unit (
    input branch_taken,  // branch taken
    input ctrl_jump,     // jump taken

    output flush_ifid    //flush contant of if pipeline
  //  output flush_idex	  //flush contant of id pipeline
);

    wire flush_1 = branch_taken | ctrl_jump;
  // wire flush_2=branch_taken;
    assign flush_ifid = flush_1;  // kill IF/ID stage
   // assign flush_idex = flush_2;  // kill ID/EX stage

endmodule

