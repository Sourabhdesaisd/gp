module replace_2_port #(
    parameter int TLB_ENTRIES = 32
)(
    input  logic                           clk,
    input  logic                           rst_n,
    input  logic                           i_update,
    output logic [$clog2(TLB_ENTRIES)-1:0] o_replace_index
);
    logic [30:0] plru_tree;

    // REPLACEMENT: constant indices only
    logic [4:0] rep_idx;

    always_comb begin
        rep_idx[4] = plru_tree[0];
        rep_idx[3] = rep_idx[4] ? plru_tree[2]  : plru_tree[1];
        rep_idx[2] = rep_idx[4] ? (rep_idx[3] ? plru_tree[6]  : plru_tree[5])
                                : (rep_idx[3] ? plru_tree[4]  : plru_tree[3]);
        rep_idx[1] = rep_idx[4] ? (rep_idx[3] ? (rep_idx[2] ? plru_tree[14] : plru_tree[13])
                                               : (rep_idx[2] ? plru_tree[12] : plru_tree[11]))
                                : (rep_idx[3] ? (rep_idx[2] ? plru_tree[10] : plru_tree[9])
                                               : (rep_idx[2] ? plru_tree[8]  : plru_tree[7]));
        rep_idx[0] = rep_idx[4] ? (rep_idx[3] ? (rep_idx[2] ? (rep_idx[1] ? plru_tree[30] : plru_tree[29])
                                                              : (rep_idx[1] ? plru_tree[28] : plru_tree[27]))
                                               : (rep_idx[2] ? (rep_idx[1] ? plru_tree[26] : plru_tree[25])
                                                              : (rep_idx[1] ? plru_tree[24] : plru_tree[23])))
                                : (rep_idx[3] ? (rep_idx[2] ? (rep_idx[1] ? plru_tree[22] : plru_tree[21])
                                                              : (rep_idx[1] ? plru_tree[20] : plru_tree[19]))
                                               : (rep_idx[2] ? (rep_idx[1] ? plru_tree[18] : plru_tree[17])
                                                              : (rep_idx[1] ? plru_tree[16] : plru_tree[15])));
        o_replace_index = rep_idx;
    end

    
    // ACCESS DECODE
    
    logic [4:0] access_idx;
    logic       do_update;

    always_comb begin
        do_update  = 1'b0;
        access_idx = 5'h00;
        if (i_update) begin
            access_idx = o_replace_index;
            do_update  = 1'b1;
        end
    end

    // UPDATE: per-node wen/wdat  
    logic [30:0] tree_wen;
    logic [30:0] tree_wdat;

    always_comb begin
        // Level 0
        tree_wen[0]  = do_update;   tree_wdat[0] = ~access_idx[4];
        // Level 1
        tree_wen[1]  = do_update & ~access_idx[4];  tree_wdat[1]  = ~access_idx[3];
        tree_wen[2]  = do_update &  access_idx[4];  tree_wdat[2]  = ~access_idx[3];
        // Level 2
        tree_wen[3]  = do_update & ~access_idx[4] & ~access_idx[3];  tree_wdat[3]  = ~access_idx[2];
        tree_wen[4]  = do_update & ~access_idx[4] &  access_idx[3];  tree_wdat[4]  = ~access_idx[2];
        tree_wen[5]  = do_update &  access_idx[4] & ~access_idx[3];  tree_wdat[5]  = ~access_idx[2];
        tree_wen[6]  = do_update &  access_idx[4] &  access_idx[3];  tree_wdat[6]  = ~access_idx[2];
        // Level 3
        tree_wen[7]  = do_update & ~access_idx[4] & ~access_idx[3] & ~access_idx[2];  tree_wdat[7]  = ~access_idx[1];
        tree_wen[8]  = do_update & ~access_idx[4] & ~access_idx[3] &  access_idx[2];  tree_wdat[8]  = ~access_idx[1];
        tree_wen[9]  = do_update & ~access_idx[4] &  access_idx[3] & ~access_idx[2];  tree_wdat[9]  = ~access_idx[1];
        tree_wen[10] = do_update & ~access_idx[4] &  access_idx[3] &  access_idx[2];  tree_wdat[10] = ~access_idx[1];
        tree_wen[11] = do_update &  access_idx[4] & ~access_idx[3] & ~access_idx[2];  tree_wdat[11] = ~access_idx[1];
        tree_wen[12] = do_update &  access_idx[4] & ~access_idx[3] &  access_idx[2];  tree_wdat[12] = ~access_idx[1];
        tree_wen[13] = do_update &  access_idx[4] &  access_idx[3] & ~access_idx[2];  tree_wdat[13] = ~access_idx[1];
        tree_wen[14] = do_update &  access_idx[4] &  access_idx[3] &  access_idx[2];  tree_wdat[14] = ~access_idx[1];
        // Level 4
        tree_wen[15] = do_update & ~access_idx[4] & ~access_idx[3] & ~access_idx[2] & ~access_idx[1];  tree_wdat[15] = ~access_idx[0];
        tree_wen[16] = do_update & ~access_idx[4] & ~access_idx[3] & ~access_idx[2] &  access_idx[1];  tree_wdat[16] = ~access_idx[0];
        tree_wen[17] = do_update & ~access_idx[4] & ~access_idx[3] &  access_idx[2] & ~access_idx[1];  tree_wdat[17] = ~access_idx[0];
        tree_wen[18] = do_update & ~access_idx[4] & ~access_idx[3] &  access_idx[2] &  access_idx[1];  tree_wdat[18] = ~access_idx[0];
        tree_wen[19] = do_update & ~access_idx[4] &  access_idx[3] & ~access_idx[2] & ~access_idx[1];  tree_wdat[19] = ~access_idx[0];
        tree_wen[20] = do_update & ~access_idx[4] &  access_idx[3] & ~access_idx[2] &  access_idx[1];  tree_wdat[20] = ~access_idx[0];
        tree_wen[21] = do_update & ~access_idx[4] &  access_idx[3] &  access_idx[2] & ~access_idx[1];  tree_wdat[21] = ~access_idx[0];
        tree_wen[22] = do_update & ~access_idx[4] &  access_idx[3] &  access_idx[2] &  access_idx[1];  tree_wdat[22] = ~access_idx[0];
        tree_wen[23] = do_update &  access_idx[4] & ~access_idx[3] & ~access_idx[2] & ~access_idx[1];  tree_wdat[23] = ~access_idx[0];
        tree_wen[24] = do_update &  access_idx[4] & ~access_idx[3] & ~access_idx[2] &  access_idx[1];  tree_wdat[24] = ~access_idx[0];
        tree_wen[25] = do_update &  access_idx[4] & ~access_idx[3] &  access_idx[2] & ~access_idx[1];  tree_wdat[25] = ~access_idx[0];
        tree_wen[26] = do_update &  access_idx[4] & ~access_idx[3] &  access_idx[2] &  access_idx[1];  tree_wdat[26] = ~access_idx[0];
        tree_wen[27] = do_update &  access_idx[4] &  access_idx[3] & ~access_idx[2] & ~access_idx[1];  tree_wdat[27] = ~access_idx[0];
        tree_wen[28] = do_update &  access_idx[4] &  access_idx[3] & ~access_idx[2] &  access_idx[1];  tree_wdat[28] = ~access_idx[0];
        tree_wen[29] = do_update &  access_idx[4] &  access_idx[3] &  access_idx[2] & ~access_idx[1];  tree_wdat[29] = ~access_idx[0];
        tree_wen[30] = do_update &  access_idx[4] &  access_idx[3] &  access_idx[2] &  access_idx[1];  tree_wdat[30] = ~access_idx[0];
    end

    // SEQUENTIAL: explicit per-bit only
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) plru_tree <= 31'h00000000;
        else begin
            if (tree_wen[0])  plru_tree[0]  <= tree_wdat[0];
            if (tree_wen[1])  plru_tree[1]  <= tree_wdat[1];
            if (tree_wen[2])  plru_tree[2]  <= tree_wdat[2];
            if (tree_wen[3])  plru_tree[3]  <= tree_wdat[3];
            if (tree_wen[4])  plru_tree[4]  <= tree_wdat[4];
            if (tree_wen[5])  plru_tree[5]  <= tree_wdat[5];
            if (tree_wen[6])  plru_tree[6]  <= tree_wdat[6];
            if (tree_wen[7])  plru_tree[7]  <= tree_wdat[7];
            if (tree_wen[8])  plru_tree[8]  <= tree_wdat[8];
            if (tree_wen[9])  plru_tree[9]  <= tree_wdat[9];
            if (tree_wen[10]) plru_tree[10] <= tree_wdat[10];
            if (tree_wen[11]) plru_tree[11] <= tree_wdat[11];
            if (tree_wen[12]) plru_tree[12] <= tree_wdat[12];
            if (tree_wen[13]) plru_tree[13] <= tree_wdat[13];
            if (tree_wen[14]) plru_tree[14] <= tree_wdat[14];
            if (tree_wen[15]) plru_tree[15] <= tree_wdat[15];
            if (tree_wen[16]) plru_tree[16] <= tree_wdat[16];
            if (tree_wen[17]) plru_tree[17] <= tree_wdat[17];
            if (tree_wen[18]) plru_tree[18] <= tree_wdat[18];
            if (tree_wen[19]) plru_tree[19] <= tree_wdat[19];
            if (tree_wen[20]) plru_tree[20] <= tree_wdat[20];
            if (tree_wen[21]) plru_tree[21] <= tree_wdat[21];
            if (tree_wen[22]) plru_tree[22] <= tree_wdat[22];
            if (tree_wen[23]) plru_tree[23] <= tree_wdat[23];
            if (tree_wen[24]) plru_tree[24] <= tree_wdat[24];
            if (tree_wen[25]) plru_tree[25] <= tree_wdat[25];
            if (tree_wen[26]) plru_tree[26] <= tree_wdat[26];
            if (tree_wen[27]) plru_tree[27] <= tree_wdat[27];
            if (tree_wen[28]) plru_tree[28] <= tree_wdat[28];
            if (tree_wen[29]) plru_tree[29] <= tree_wdat[29];
            if (tree_wen[30]) plru_tree[30] <= tree_wdat[30];
        end
    end

endmodule
