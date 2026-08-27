module replace_1_port_dtlb #(
    parameter int TLB_ENTRIES = 16
)(
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          i_hit,
    input  logic [$clog2(TLB_ENTRIES)-1:0] i_hit_index,
    input  logic                          i_update,
    input logic [$clog2(TLB_ENTRIES)-1:0] i_update_index,
    output logic [$clog2(TLB_ENTRIES)-1:0] o_replace_index
);
    logic [14:0] plru_tree;

    // Tree walk result built bit-by-bit from root downward
    logic [3:0] rep_idx;

    always_comb begin
        rep_idx[3] = plru_tree[0];
        rep_idx[2] = rep_idx[3] ? plru_tree[2] : plru_tree[1];
        rep_idx[1] = rep_idx[3] ? (rep_idx[2] ? plru_tree[6]  : plru_tree[5])
                                : (rep_idx[2] ? plru_tree[4]  : plru_tree[3]);
        rep_idx[0] = rep_idx[3] ? (rep_idx[2] ? (rep_idx[1] ? plru_tree[14] : plru_tree[13])
                                               : (rep_idx[1] ? plru_tree[12] : plru_tree[11]))
                                : (rep_idx[2] ? (rep_idx[1] ? plru_tree[10] : plru_tree[9])
                                               : (rep_idx[1] ? plru_tree[8]  : plru_tree[7]));
        o_replace_index = rep_idx;
    end

    // ACCESS DECODE
    logic [3:0] access_idx;
    logic       do_update;

    always_comb begin
        do_update  = 1'b0;
        access_idx = 4'h0;

        if (i_update) begin
            access_idx = i_update_index;
            do_update  = 1'b1;
        end
        else if (i_hit) begin
            access_idx = i_hit_index;
            do_update  = 1'b1;
        end
    end

    // Node n at level L is on path to leaf idx iff
    //   idx[3]=b3, idx[2]=b2, ... idx[4-L]=bL

    logic [14:0] tree_wen;
    logic [14:0] tree_wdat;

    always_comb begin
        // Level 0  node 0 (root): always on path
        tree_wen[0]  = do_update;
        tree_wdat[0] = ~access_idx[3];
        // Level 1  nodes 1,2
        tree_wen[1]  = do_update & ~access_idx[3];  tree_wdat[1]  = ~access_idx[2];
        tree_wen[2]  = do_update &  access_idx[3];  tree_wdat[2]  = ~access_idx[2];
        // Level 2  nodes 3..6
        tree_wen[3]  = do_update & ~access_idx[3] & ~access_idx[2];  tree_wdat[3]  = ~access_idx[1];
        tree_wen[4]  = do_update & ~access_idx[3] &  access_idx[2];  tree_wdat[4]  = ~access_idx[1];
        tree_wen[5]  = do_update &  access_idx[3] & ~access_idx[2];  tree_wdat[5]  = ~access_idx[1];
        tree_wen[6]  = do_update &  access_idx[3] &  access_idx[2];  tree_wdat[6]  = ~access_idx[1];
        // Level 3  nodes 7..14
        tree_wen[7]  = do_update & ~access_idx[3] & ~access_idx[2] & ~access_idx[1];  tree_wdat[7]  = ~access_idx[0];
        tree_wen[8]  = do_update & ~access_idx[3] & ~access_idx[2] &  access_idx[1];  tree_wdat[8]  = ~access_idx[0];
        tree_wen[9]  = do_update & ~access_idx[3] &  access_idx[2] & ~access_idx[1];  tree_wdat[9]  = ~access_idx[0];
        tree_wen[10] = do_update & ~access_idx[3] &  access_idx[2] &  access_idx[1];  tree_wdat[10] = ~access_idx[0];
        tree_wen[11] = do_update &  access_idx[3] & ~access_idx[2] & ~access_idx[1];  tree_wdat[11] = ~access_idx[0];
        tree_wen[12] = do_update &  access_idx[3] & ~access_idx[2] &  access_idx[1];  tree_wdat[12] = ~access_idx[0];
        tree_wen[13] = do_update &  access_idx[3] &  access_idx[2] & ~access_idx[1];  tree_wdat[13] = ~access_idx[0];
        tree_wen[14] = do_update &  access_idx[3] &  access_idx[2] &  access_idx[1];  tree_wdat[14] = ~access_idx[0];
    end

    // SEQUENTIAL
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) plru_tree <= 15'h0000;
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
        end
    end

endmodule


