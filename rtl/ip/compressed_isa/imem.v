module instruction_memory (
    input         clk,
    input         rst_n,

    // Instruction fetch
  //  input         imem_read,
    input  [31:0] rd_addr,   // byte address from PC
    output wire [31:0] instr_out,

    // Write interface
    input         imem_write,
    input  [31:0] wr_addr,   // byte address
    input  [31:0] write_data
);

    //  KB BYTE-ADDRESSABLE MEMORY
    reg [7:0] mem [0:65535];

    reg [1023:0] instr_file;
    initial begin
  
    if (!$value$plusargs("instr_file=%s", instr_file)) begin
    instr_file = "instruction_mem.hex";  
     end

    $display("Loading instruction memory from: %s", instr_file);

    $readmemh(instr_file, mem);
    end

    // Address decode
    wire [15:0] rd_addr;
    wire [15:0] wr_addr;

       
    always @(posedge clk) begin
        if (imem_write) begin
            mem[wr_addr + 0] <= write_data[7:0];
            mem[wr_addr + 1] <= write_data[15:8];
            mem[wr_addr + 2] <= write_data[23:16];
            mem[wr_addr + 3] <= write_data[31:24];
        end
    end

   
              assign instr_out = {
                mem[rd_addr + 3],
                mem[rd_addr + 2],
                mem[rd_addr + 1],
                mem[rd_addr + 0]
            };
        
          

endmodule
