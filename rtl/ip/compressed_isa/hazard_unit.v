module hazard_unit (
    // From ID stage (instruction being decoded)
    input  [4:0] IF_ID_rs1,
    input  [4:0] IF_ID_rs2,
    input branch_ctrl,
    // From EX stage (instruction ahead)
    input  [4:0] ID_EX_rd,
    input        ID_EX_memread,   // 1 = load instruction
	input EX_regwrite,

    // Control outputs
    output reg stall_pc,
    output reg stall_ifid,
    output reg flush_idex
);

    always @(IF_ID_rs1 or IF_ID_rs2 or ID_EX_rd or ID_EX_memread) begin
        // Default: no stall, no flush
        stall_pc   = 1'b0;
        stall_ifid = 1'b0;
        flush_idex = 1'b0;

        // --------------------------------------------------
        // LOAD-USE hazard detection
        // --------------------------------------------------
        if (ID_EX_memread && (ID_EX_rd != 5'b0) &&((ID_EX_rd == IF_ID_rs1) ||(ID_EX_rd == IF_ID_rs2))) begin

            // Stall pipeline
            stall_pc   = 1'b1;   // hold PC
            stall_ifid = 1'b1;   // hold IF/ID
            flush_idex = 1'b1;   // insert bubble into EX
        end

else if (branch_ctrl && EX_regwrite && (ID_EX_rd != 5'b0) &&((ID_EX_rd == IF_ID_rs1) ||(ID_EX_rd == IF_ID_rs2))) begin

            // Stall pipeline
            stall_pc   = 1'b1;   // hold PC
            stall_ifid = 1'b1;   // hold IF/ID
            flush_idex = 1'b1;   // insert bubble into EX
        end

    end

endmodule

