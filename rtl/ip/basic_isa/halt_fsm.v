
module halt_fsm(

input clk,
input rst_n,
input stall_i,
input haltreq_i,
input ebreak_halt_i,
input trigger_halt_i,
input single_step_halt_i,
input reset_halt_i,

input resumereq_i,
input dret_valid_i,

input mem_wb_halt_valid_i,

output reg pc_en_o,

output reg if_flush_o,
output reg id_flush_o,

output reg halt_marker_insert_o,

//output reg halt_valid_2_csr_o,

output reg halted_o,

output reg dbg_return_en_o,

output reg debug_mode_o

);

localparam IDLE         =   3'd0;
localparam CAPTURE      =   3'd1;
localparam DRAIN        =   3'd2;
localparam HALTED       =   3'd3;
localparam HALTED_WAIT  =   3'd4;
localparam AFTER_RESUME =   3'd5;


reg [2:0] state;
reg [2:0] next_state;

wire halt_request;

assign halt_request =
        haltreq_i |
        ebreak_halt_i |
        trigger_halt_i |
        single_step_halt_i |
        reset_halt_i;


//////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n)
begin

if(!rst_n)
    state<=IDLE;
else
    state<=next_state;

end

//////////////////////////////////////////////////////////
//reg dbg_return_en_o;
always @(*)
begin

    next_state = state;
    dbg_return_en_o = 1'b0;    

    case(state)

        //----------------------------------------

        IDLE:
        begin
            dbg_return_en_o = 1'b0;
            if(halt_request)
                next_state = CAPTURE;
        end

        //----------------------------------------

        CAPTURE:
        begin
            dbg_return_en_o = 1'b0;            
            if(!stall_i)
                next_state = DRAIN;
            else
                next_state = CAPTURE;
        end

        //----------------------------------------

        DRAIN:
        begin
            dbg_return_en_o = 1'b0;        
            if(!stall_i && mem_wb_halt_valid_i)
                next_state = HALTED;
        end

        //----------------------------------------
        HALTED:
        begin
            dbg_return_en_o = 1'b0;        
            next_state = HALTED_WAIT;
        end
        //----------------------------------------

        HALTED_WAIT:
        begin
        
            if(resumereq_i || dret_valid_i) begin
                dbg_return_en_o = 1'b1;
                next_state = AFTER_RESUME;
            end
        end
        //----------------------------------------

	AFTER_RESUME:
	begin
                next_state = IDLE;	
	end

        default:
                next_state = IDLE;

    endcase

end

//////////////////////////////////////////////////////////

always @(*)
begin

    //----------------------------------------------------
    // Defaults
    //----------------------------------------------------

    pc_en_o               = 1'b1;

    if_flush_o            = 1'b0;

    id_flush_o            = 1'b0;

    halt_marker_insert_o  = 1'b0;

    //halt_valid_2_csr_o   = 1'b0;

    halted_o              = 1'b0;

    debug_mode_o          = 1'b0;

    case(state)

    //----------------------------------------------------
    // IDLE
    //----------------------------------------------------

    IDLE:
    begin
    if_flush_o            = 1'b0;

    id_flush_o            = 1'b0;

        pc_en_o = 1'b1;
    end

    //----------------------------------------------------
    // CAPTURE
    //----------------------------------------------------

    CAPTURE:
    begin
        // Capture pipeline PC and privilege before flushing
        //halt_valid_2_csr_o = 1'b1;

        // Don't stop the pipeline yet
        //pc_en_o = 1'b1;
        
        // Insert one halt marker
            if(!stall_i)        
                halt_marker_insert_o = 1'b1;
            else
                halt_marker_insert_o = 1'b0;
    end

    //----------------------------------------------------
    // DRAIN
    //----------------------------------------------------

    DRAIN:
    begin

        // Stop fetch
        pc_en_o = 1'b0;

        // Flush younger instructions
        if_flush_o = 1'b1;
        id_flush_o = 1'b1;


    end

    //----------------------------------------------------
    // HALTED
    //----------------------------------------------------

    HALTED:
    begin

        pc_en_o = 1'b0;

        halted_o = 1'b1;

        debug_mode_o = 1'b1;

        if_flush_o = 1'b1;
        id_flush_o = 1'b1;

    end

    HALTED_WAIT:
    begin
        pc_en_o      = 1'b0;

        halted_o     = 1'b1;
        debug_mode_o = 1'b1;

        // Flush deasserted
        if_flush_o   = 1'b0;
        id_flush_o   = 1'b0;
    end

	AFTER_RESUME:
	begin
		if_flush_o   = 1'b1;
        id_flush_o   = 1'b1;
	end

    endcase

end
endmodule
