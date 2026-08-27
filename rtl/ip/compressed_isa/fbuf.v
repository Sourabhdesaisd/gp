module fetch_buffer (
    input         clk,
    input         rst_n,

    // Control
    input         flush,

    // From IMEM
    input  [31:0] data_out,
    input         imem_valid,

    // Outputs
    output reg [15:0] instr16_out,
    output reg [31:0] instr32_out,
    output reg        is_16bit
);

    
    // BUFFER (48-bit)
    
    reg [47:0] buffer1, next_buffer;
    reg [2:0]  valid_bytes, next_valid_bytes;

    wire [15:0] buffer_16 = buffer1[15:0];
    wire [31:0] buffer_32 = buffer1[31:0];

    wire can_issue_16 = (valid_bytes >= 3'd2);
    wire can_issue_32 = (valid_bytes >= 3'd4);

    wire instr_is_16 = (buffer_16[1:0] != 2'b11);

   
    wire first_fetch =  imem_valid;
    wire first_is_16 = (data_out[1:0] != 2'b11);

    
    always @(flush or imem_valid or data_out or buffer1 or valid_bytes or instr16_out or instr32_out or can_issue_32 or is_16bit or next_buffer or next_valid_bytes or first_fetch or first_is_16  ) begin
        // Defaults
        instr16_out      = 16'd0;
        instr32_out      = 32'd0;
        is_16bit         = 1'b0;

        next_buffer      = buffer1;
        next_valid_bytes = valid_bytes;

        
        // FLUSH
        
        if (flush) begin
            next_buffer      = 48'd0;
            next_valid_bytes = 3'd0;
        end
        else begin

            
            if (first_fetch) begin
                if (first_is_16) begin
                    // 16-bit
                    instr16_out = data_out[15:0];
                    is_16bit    = 1'b1;

                    next_buffer      = {16'd0, data_out[31:16]};
                    next_valid_bytes = 3'd2;
                end
                else begin
                    // 32-bit
                    instr32_out = data_out;
                    is_16bit    = 1'b0;

                    next_buffer      = 48'd0;
                    next_valid_bytes = 3'd0;
                end
            end

            
            else begin

                // PRIORITY: 32-bit FIRST
                if (can_issue_32 && (buffer_16[1:0] == 2'b11)) begin
                    instr32_out = buffer_32;
                    is_16bit    = 1'b0;

                    next_buffer      = {32'd0, buffer1[47:32]};
                    next_valid_bytes = valid_bytes - 3'd4;
                end

                else if (can_issue_16) begin
                    instr16_out = buffer_16;
                    is_16bit    = 1'b1;

                    next_buffer      = {16'd0, buffer1[47:16]};
                    next_valid_bytes = valid_bytes - 3'd2;
                end

                
                // FILL
                
                if (imem_valid && (next_valid_bytes <= 3'd2)) begin
                    next_buffer      = {next_buffer[15:0], data_out};
                    next_valid_bytes = next_valid_bytes + 3'd4;
                end
            end
        end
    end

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer1     <= 48'd0;
            valid_bytes <= 3'd0;
        end else begin
            buffer1     <= next_buffer;
            valid_bytes <= next_valid_bytes;
        end
    end

endmodule
