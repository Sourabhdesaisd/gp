//`timescale 1ns/1ps

module int_ctrl_logic
(
    input  wire         clk,
    input  wire         rst_n,

    //------------------------------------------------------
    // Interrupt Controller Interface
    //------------------------------------------------------
    input  wire         int_req_i,
    input  wire [7:0]   int_id_i,

    output reg          ack_read_valid_o,
    output reg          eoi_write_valid_o,
    output reg  [7:0]   eoi_id_o,

    //------------------------------------------------------
    // CSR Interface
    //------------------------------------------------------
    input  wire [7:0]   mcause_id_i,
    input  wire         mie_i,

    output reg          csr_mcause_write_en_o,

    //------------------------------------------------------
    // MSTATUS Control
    //------------------------------------------------------

    output reg          csr_mstatus_mie_set_o,
    output reg          csr_mstatus_mie_clear_o,

    output reg          interrupt_valid_o,
    output reg          exception_valid_o,
    output reg [7:0]    trap_id_o,
    //------------------------------------------------------
    // Decoder
    //------------------------------------------------------
    input wire          mret_valid_i
);


////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////

localparam FIRST_EXCEPTION_ID = 8'd16;
localparam LAST_EXCEPTION_ID  = 8'd25;
localparam LAST_INTERRUPT_ID  = 8'd31;

////////////////////////////////////////////////////////////
// FSM States
////////////////////////////////////////////////////////////

localparam IDLE           = 2'd0;
//localparam CHECK_REQ      = 3'd1;
localparam TAKE_INTERRUPT = 2'd1;
localparam TAKE_EXCEPTION = 2'd2;
localparam MRET_STATE     = 2'd3;

reg [1:0] current_state;
reg [1:0] next_state;

////////////////////////////////////////////////////////////
// Exception Detection
////////////////////////////////////////////////////////////

wire exception_req;
wire interrupt_req;

assign exception_req =
        int_req_i &&
        (int_id_i >= FIRST_EXCEPTION_ID) &&
        (int_id_i <= LAST_EXCEPTION_ID);

assign interrupt_req = (int_req_i && (int_id_i <= LAST_INTERRUPT_ID) && (int_id_i > LAST_EXCEPTION_ID) && mie_i);
 
////////////////////////////////////////////////////////////
// State Register
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) 
        current_state <= IDLE;
    else
        current_state <= next_state;
end

////////////////////////////////////////////////////////////
// Next State Logic
////////////////////////////////////////////////////////////
reg [7:0] temp_trap_id_r;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) 
        temp_trap_id_r = 8'd0;
    else
        temp_trap_id_r = int_id_i;
end

always @(*)
begin
    
    next_state = current_state;

    case (current_state)

        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------
        IDLE:
        begin
          //  temp_trap_id_r = int_id_i;
            if (mret_valid_i)
                next_state = MRET_STATE;
/*
            else if (interrupt_req)
                next_state = CHECK_REQ;
*/
            // Exception
            else if (exception_req) begin
                next_state = TAKE_EXCEPTION;
            
            end
            // Interrupt only if MIE is enabled
            else if (interrupt_req) begin
                next_state = TAKE_INTERRUPT; 
            
            end
            else
                next_state = IDLE;
        end


        //--------------------------------------------------
        // CHECK REQUEST
        //--------------------------------------------------
        /*CHECK_REQ:
        begin

            // Exception
            if (exception_req)
                next_state = TAKE_EXCEPTION;

            // Interrupt only if MIE is enabled
            else if (int_req_i && mie_i)
                next_state = TAKE_INTERRUPT;

            else
                next_state = IDLE;

        end
*/

        //--------------------------------------------------
        // TAKE INTERRUPT
        //--------------------------------------------------
        TAKE_INTERRUPT:
        begin
            next_state = IDLE;
        end


        //--------------------------------------------------
        // TAKE EXCEPTION
        //--------------------------------------------------
        TAKE_EXCEPTION:
        begin
            next_state = IDLE;
        end


        //--------------------------------------------------
        // MRET
        //--------------------------------------------------
        MRET_STATE:
        begin
            next_state = IDLE;
        end


        default:
        begin
            next_state = IDLE;
        end

    endcase

end


////////////////////////////////////////////////////////////
// Output Logic
////////////////////////////////////////////////////////////

always @(*)
begin

    //------------------------------------------------------
    // Default Values
    //------------------------------------------------------

    ack_read_valid_o          = 1'b0;

    eoi_write_valid_o         = 1'b0;
    eoi_id_o                  = 8'd0;

    csr_mcause_write_en_o     = 1'b0;

    csr_mstatus_mie_set_o     = 1'b0;
    csr_mstatus_mie_clear_o   = 1'b0;

    interrupt_valid_o         = 1'b0;
    exception_valid_o         = 1'b0;
    trap_id_o                 = 8'd0;

    case (current_state)

        //--------------------------------------------------
        // TAKE INTERRUPT
        //--------------------------------------------------
        TAKE_INTERRUPT:
        begin
            
            trap_id_o = temp_trap_id_r;

            // Tell core that interrupt is valid
            interrupt_valid_o = 1'b1;

            // Acknowledge interrupt controller
            ack_read_valid_o = 1'b1;

            // Write MCAUSE
            csr_mcause_write_en_o = 1'b1;

            // Disable global interrupt
            csr_mstatus_mie_clear_o = 1'b1;

            
        end


        //--------------------------------------------------
        // TAKE EXCEPTION
        //--------------------------------------------------
        TAKE_EXCEPTION:
        begin

            trap_id_o = temp_trap_id_r;
            // Exception valid
            exception_valid_o = 1'b1;

            // Acknowledge request
            ack_read_valid_o = 1'b1;

            // Write MCAUSE
            csr_mcause_write_en_o = 1'b1;

            // Disable global interrupt
            csr_mstatus_mie_clear_o = 1'b1;

        end


        //--------------------------------------------------
        // MRET
        //--------------------------------------------------
        MRET_STATE:
        begin

            // Restore MIE
            csr_mstatus_mie_set_o = 1'b1;

            // Send EOI
            eoi_write_valid_o = 1'b1;

            // Send the cause ID
            eoi_id_o = mcause_id_i;

        end


        default:
        begin

        end

    endcase

end


endmodule
