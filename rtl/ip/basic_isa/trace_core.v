module trace_core
(
    input               clk,
    input               rst_n,
    input               stall_i,

    input  wire         inst_valid_i,

    input  [19:0]       branch_pc_i,
    input               branch_valid_i,
    input               dbg_mode_i,

    input      [31:0]   instr_i,
    input               branch_taken_i,
    input               exception_i,
    input               interrupt_i,
    input   [7:0]       int_cause_i,
    input [19:0]        pc_ex_i,

    output reg [2:0]    it_priv_o,
    output reg          it_ienable_o,
    output reg [19:0]   it_iaddr_o,
    output reg [7:0]    it_cause_o,
    output reg          it_first_instrn_valid_o,
    output reg [2:0]    it_context_o,
    output reg [19:0]   it_delta_addr_o,
    output reg          it_del_adr_valid_o,
    output reg          it_itype_valid_o,
    output reg [3:0]    it_itype_o
);

wire [6:0] opcode;
wire [4:0] rd;
wire [4:0] rs1;
wire [2:0] funct3;
wire [6:0] funct7;

assign opcode  = instr_i[6:0];
assign rd      = instr_i[11:7];
assign funct3  = instr_i[14:12];
assign rs1     = instr_i[19:15];
assign funct7  = instr_i[31:25];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
         it_delta_addr_o    <= 20'd0;
         it_del_adr_valid_o <= 1'd0;
    end
    else if (branch_valid_i) begin
         it_delta_addr_o    <= branch_pc_i;
         it_del_adr_valid_o <= 1'd1;
    end    
    else begin
         it_delta_addr_o    <= 20'd0;
         it_del_adr_valid_o <= 1'd0;
    end        
end


always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        it_itype_o <= 4'd0;
        it_itype_valid_o <= 1'b0;
    end
    else

    begin
        //----------------------------------------------------------
        // Highest Priority
        //----------------------------------------------------------
        it_itype_valid_o <= 1'b1;
        if(exception_i)
            it_itype_o <= 4'd1;

        else if(interrupt_i)
            it_itype_o <= 4'd2;

        //----------------------------------------------------------
        // MRET / SRET / URET
        //----------------------------------------------------------

        else if(instr_i == 32'h30200073)        // MRET
            it_itype_o <= 4'd3;

        else if(instr_i == 32'h10200073)        // SRET
            it_itype_o <= 4'd3;

        else if(instr_i == 32'h00200073)        // URET
            it_itype_o <= 4'd3;

        //----------------------------------------------------------
        // Conditional Branch
        //----------------------------------------------------------

        else if(opcode == 7'b1100011)
        begin
            if(branch_taken_i)
                it_itype_o <= 4'd5;
            else
                it_itype_o <= 4'd4;
        end

        //----------------------------------------------------------
        // JAL
        //----------------------------------------------------------

        else if(opcode == 7'b1101111)
        begin
            if(rd == 5'd1 || rd == 5'd5)
                it_itype_o <= 4'd9;          // Inferable Call
            else
                it_itype_o <= 4'd15;         // Other Inferable Jump
        end

        //----------------------------------------------------------
        // JALR
        //----------------------------------------------------------

        else if(opcode == 7'b1100111)
        begin

            // RET
            if((rd == 5'd0) &&
               (rs1 == 5'd1 || rs1 == 5'd5))
                it_itype_o <= 4'd13;

            // CALL
            else if(rd == 5'd1 || rd == 5'd5)
                it_itype_o <= 4'd9;

            // Tail Call
            else if(rd == 5'd0)
                it_itype_o <= 4'd11;

            else
                it_itype_o <= 4'd15;

        end

        //----------------------------------------------------------
        // Default
        //----------------------------------------------------------

        else
            it_itype_o <= 4'd0;

    end

end

localparam IDLE   = 1'b0;
localparam ACTIVE = 1'b1;

reg state,next_state,first_inst;

//----------------------------------------------------
// State Register
//----------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*)
    begin
        next_state = state;
        it_first_instrn_valid_o = 1'b0;
        case(state)

            IDLE:
            begin
                if(inst_valid_i) begin
                    next_state = ACTIVE;
                    it_first_instrn_valid_o = 1'b1;
                end
            end

            ACTIVE:
            begin
                it_first_instrn_valid_o = 1'b0;                
                // Stay in ACTIVE until reset
                next_state = ACTIVE;
            end

        endcase
    end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        it_context_o <= 3'd0;
    else if (exception_i)
        it_context_o <= 3'd1;
    else if (interrupt_i)
        it_context_o <= 3'd2;
    else if (dbg_mode_i)
        it_context_o <= 3'd3;
    else
        it_context_o <= 3'd0;        
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        it_ienable_o <= 1'b0;
        it_iaddr_o  <= 20'd0;
        end
    else if(inst_valid_i) begin
        it_ienable_o <= 1'b1;  
        it_iaddr_o  <= pc_ex_i;
        end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        it_priv_o <= 3'd0;
    else 
        it_priv_o <= 3'd3;
        
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        it_cause_o <= 8'd0;
    else if(!stall_i)
        it_cause_o <= int_cause_i;       
end

endmodule
