module data_memory (
    input                clk,
    input                memread,
    input                memwrite,
    input       [31:0]   addr,        // byte address from ALU
    input       [31:0]   write_data,
    output reg  [31:0]   read_data
);

    // 1KB memory = 256 words × 4 bytes
    reg [31:0] mem [0:255];

    // Initialize memory to zero
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
       
        // $readmemh("data.hex", mem);
    end

    // Word address (byte addr / 4)
    wire [7:0] word_addr;
    assign word_addr = addr[9:2];

    
    // READ (LW) 
    always @(memread or word_addr) begin
        if (memread)
            read_data = mem[word_addr];
        else
            read_data = 32'b0;
    end

    
    // WRITE (SW) 
    always @(posedge clk) begin
        if (memwrite)
            mem[word_addr] <= write_data;
    end

endmodule
