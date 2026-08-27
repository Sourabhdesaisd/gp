module top_register #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    // APB Interface
    input  logic                     pclk,
    input  logic                     presetn,
    input  logic [ADDR_WIDTH-1:0]    paddr,
    input  logic                     psel,
    input  logic                     penable,
    input  logic                     pwrite,
    input  logic [DATA_WIDTH-1:0]    pwdata,
    output logic [DATA_WIDTH-1:0]    prdata,
    output logic                     pready,
    output logic                     pslverr,

    // MMU Control Outputs
    output logic                     pre_fetch_en,
    output logic                     mmu_timeout_enable,

    // MMU Status Inputs
    // These inputs are already synchronized to pclk
    input  logic                     ptw_timeout_event,

    // MMU Fault Inputs
    // These inputs are already synchronized to pclk
    input  logic                     instr_page_fault,
    input  logic                     mem_page_fault,
    input  logic                     instr_permission_fault,
    input  logic                     read_permission_fault,
    input  logic                     write_permission_fault,

    // Error Inputs
    // These inputs are already synchronized to pclk
    input  logic                     mem_addr_decode_error,
    input  logic                     mem_addr_read_slverr,
    input  logic                     mem_addr_write_slverr,

    // Instruction memory address error
    input  logic                     instr_mem_addr_decode_error,
    input  logic [31:0]              captured_instr_error_pc,

    // AXI Addresses
    input  logic [31:0]              addr_error
);


    //--------------------------------------------------------
    // Address Map
    //--------------------------------------------------------

    localparam CONTROL              = 8'h00;
    localparam STATUS               = 8'h08;
    localparam FAULT_STATUS         = 8'h0C;
    localparam ADDR_DECODE_ERR      = 8'h10;
    localparam SLAVE_ERR            = 8'h14;
    localparam ERROR_ADDR           = 8'h18;
    localparam INSTR_ADDR_DECODE_ERR = 8'h1C;
    localparam INSTR_ERROR_PC       = 8'h20;


    logic write_en;
    logic read_en;
    logic access_en;

    assign write_en  = psel & penable & pwrite & pready;
    assign read_en   = psel & penable & ~pwrite & pready;
    assign access_en = psel & penable;


    //--------------------------------------------------
    // APB READY
    //--------------------------------------------------

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn)
            pready <= 1'b0;
        else
            pready <= 1'b1;

    end


    //--------------------------------------------------
    // Internal Registers
    //--------------------------------------------------

    logic mem_addr_decode_error_reg;
    logic mem_addr_read_slverr_reg;
    logic mem_addr_write_slverr_reg;

    logic instr_mem_addr_decode_error_reg;

    logic [31:0] instr_error_pc_reg;
    logic [31:0] error_addr_reg;


    //--------------------------------------------------
    // Address Decode
    //--------------------------------------------------

    logic addr_valid;

    always_comb begin

        case (paddr)

            CONTROL,
            STATUS,
            FAULT_STATUS,
            ADDR_DECODE_ERR,
            SLAVE_ERR,
            ERROR_ADDR,
            INSTR_ADDR_DECODE_ERR,
            INSTR_ERROR_PC:

                addr_valid = 1'b1;

            default:

                addr_valid = 1'b0;

        endcase

    end


    //--------------------------------------------------
    // APB Error Handling
    //--------------------------------------------------

    logic write_to_ro;

    assign write_to_ro =
        write_en &&
        (
            (paddr == STATUS) ||
            (paddr == FAULT_STATUS) ||
            (paddr == ADDR_DECODE_ERR) ||
            (paddr == SLAVE_ERR) ||
            (paddr == ERROR_ADDR) ||
            (paddr == INSTR_ADDR_DECODE_ERR) ||
            (paddr == INSTR_ERROR_PC)
        );


    assign pslverr =
        access_en &&
        (~addr_valid || write_to_ro);


    //--------------------------------------------------
    // RW Registers
    //--------------------------------------------------

    logic [31:0] control_reg;

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn)

            control_reg <= 32'h0;

        else if (write_en && addr_valid) begin

            case (paddr)

                CONTROL:
                    control_reg <= pwdata;

                default:
                    control_reg <= control_reg;

            endcase

        end

    end


    //--------------------------------------------------
    // Control Outputs
    //--------------------------------------------------

    assign pre_fetch_en       = control_reg[0];
    assign mmu_timeout_enable = control_reg[1];


    //--------------------------------------------------
    // Sticky Error Capture
    //--------------------------------------------------

    always_ff @(posedge pclk or negedge presetn) begin

        if (!presetn) begin

            mem_addr_decode_error_reg <= 1'b0;
            mem_addr_read_slverr_reg  <= 1'b0;
            mem_addr_write_slverr_reg <= 1'b0;

            error_addr_reg <= 32'd0;

            instr_mem_addr_decode_error_reg <= 1'b0;
            instr_error_pc_reg              <= 32'd0;

        end

        else begin

            //--------------------------------------------------
            // Memory Address Decode Error
            //--------------------------------------------------

            if (write_en &&
                (paddr == ADDR_DECODE_ERR) &&
                pwdata[0]) begin

                mem_addr_decode_error_reg <= 1'b0;

            end

            else if (mem_addr_decode_error) begin

                mem_addr_decode_error_reg <= 1'b1;
                error_addr_reg            <= addr_error;

            end


            //--------------------------------------------------
            // Memory Read SLVERR
            //--------------------------------------------------

            if (write_en &&
                (paddr == SLAVE_ERR) &&
                pwdata[0]) begin

                mem_addr_read_slverr_reg <= 1'b0;

            end

            else if (mem_addr_read_slverr) begin

                mem_addr_read_slverr_reg <= 1'b1;
                error_addr_reg           <= addr_error;

            end


            //--------------------------------------------------
            // Memory Write SLVERR
            //--------------------------------------------------

            if (write_en &&
                (paddr == SLAVE_ERR) &&
                pwdata[1]) begin

                mem_addr_write_slverr_reg <= 1'b0;

            end

            else if (mem_addr_write_slverr) begin

                mem_addr_write_slverr_reg <= 1'b1;
                error_addr_reg            <= addr_error;

            end


            //--------------------------------------------------
            // Instruction Decode Error
            //--------------------------------------------------

            if (write_en &&
                (paddr == INSTR_ADDR_DECODE_ERR) &&
                pwdata[0]) begin

                instr_mem_addr_decode_error_reg <= 1'b0;

            end

            else if (instr_mem_addr_decode_error) begin

                instr_mem_addr_decode_error_reg <= 1'b1;

                instr_error_pc_reg <= captured_instr_error_pc;

            end

        end

    end


    //--------------------------------------------------
    // Read Logic
    //--------------------------------------------------

    always_comb begin

        prdata = '0;

        if (read_en && addr_valid) begin

            case (paddr)

                //------------------------------------------------
                // CONTROL
                //------------------------------------------------

                CONTROL:

                    prdata = {
                        30'd0,
                        mmu_timeout_enable,
                        pre_fetch_en
                    };


                //------------------------------------------------
                // STATUS
                //------------------------------------------------

                STATUS:

                    prdata = {
                        31'd0,
                        ptw_timeout_event
                    };


                //------------------------------------------------
                // FAULT STATUS
                //------------------------------------------------

                FAULT_STATUS:

                    prdata = {
                        27'd0,
                        write_permission_fault,
                        read_permission_fault,
                        instr_permission_fault,
                        mem_page_fault,
                        instr_page_fault
                    };


                //------------------------------------------------
                // ADDRESS DECODE ERROR
                //------------------------------------------------

                ADDR_DECODE_ERR:

                    prdata = {
                        31'd0,
                        mem_addr_decode_error_reg
                    };


                //------------------------------------------------
                // SLAVE ERROR
                //------------------------------------------------

                SLAVE_ERR:

                    prdata = {
                        30'd0,
                        mem_addr_write_slverr_reg,
                        mem_addr_read_slverr_reg
                    };


                //------------------------------------------------
                // ERROR ADDRESS
                //------------------------------------------------

                ERROR_ADDR:

                    prdata = error_addr_reg;


                //------------------------------------------------
                // INSTRUCTION ADDRESS DECODE ERROR
                //------------------------------------------------

                INSTR_ADDR_DECODE_ERR:

                    prdata = {
                        31'd0,
                        instr_mem_addr_decode_error_reg
                    };


                //------------------------------------------------
                // INSTRUCTION ERROR PC
                //------------------------------------------------

                INSTR_ERROR_PC:

                    prdata = instr_error_pc_reg;


                //------------------------------------------------
                // DEFAULT
                //------------------------------------------------

                default:

                    prdata = 32'h0;

            endcase

        end

    end

endmodule
