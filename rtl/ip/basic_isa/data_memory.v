/*module data_memory (
    input          clk,
    input          mem_read,
    input          mem_write,
    input   [31:0] addr,          // byte address
    input   [31:0] write_data,    // from store datapath
    input   [3:0]  byte_enable,   // from store datapath
    output  [31:0] mem_data_out   // to load datapath
);
  //  parameter MEM_BYTES = 4294967296;
    parameter ADDR_BITS = 32;   // log2(1024)

    reg [7:0] mem [ 0 : 32767 ];

    wire [ADDR_BITS-1:0] mem_addr = addr; //[ADDR_BITS-1:0];

    integer i;
    initial begin
        for(i=0;i<32768;i=i+1)
            mem[i] = 8'b0; // avoid X in simulation
    end

    // WRITE — Byte controlled
    always @(posedge clk) begin
        if (mem_write) begin
          //  if (byte_enable[0]) mem[addr]     <= write_data[7:0];
            //if (byte_enable[1]) mem[addr+1]   <= write_data[15:8];
            //if (byte_enable[2]) mem[addr+2]   <= write_data[23:16];
            //if (byte_enable[3]) mem[addr+3]   <= write_data[31:24];

	    if (byte_enable[0]) mem[mem_addr] <= write_data[7:0];
            if (byte_enable[1]) mem[mem_addr + {{(ADDR_BITS-1){1'b0}}, 1'b1}] <= write_data[15:8];
            if (byte_enable[2]) mem[mem_addr + {{(ADDR_BITS-2){1'b0}}, 2'b10}] <= write_data[23:16];
            if (byte_enable[3]) mem[mem_addr + {{(ADDR_BITS-2){1'b0}}, 2'b11}] <= write_data[31:24];	
        end
    end

    // READ — Form 32-bit word from 4 bytes (combinational)
   // always @(mem_read  or addr ) begin
     //   if (mem_read) begin
       //     mem_data_out = { mem[addr+3], mem[addr+2], mem[addr+1], mem[addr] };
        //end else begin
          //  mem_data_out = 32'b0;
        //end 
    //end 
assign mem_data_out = mem_read ? { mem[mem_addr + {{(ADDR_BITS-2){1'b0}}, 2'b11}],
             			   mem[mem_addr + {{(ADDR_BITS-2){1'b0}}, 2'b10}],
             			   mem[mem_addr + {{(ADDR_BITS-1){1'b0}}, 1'b1}],
           		           mem[mem_addr]  } : 32'b0 ;
endmodule

*/

module data_memory (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,          // full 32-bit address
    input  [31:0] write_data,
    input  [3:0]  byte_enable,
    output [31:0] mem_data_out
);

    // ============================================================
    // CONFIGURATION
    // ============================================================
    parameter MEM_BYTES = 1024 * 1024;   // 1MB actual memory
    parameter ADDR_BITS = 20;            // log2(1MB)

    reg [7:0] mem [0:MEM_BYTES-1];

    // ============================================================
    // ADDRESS MAPPING
    // 0x80000000 becomes 0x00000 because lower 20 bits are used
    // ============================================================
    wire [ADDR_BITS-1:0] mem_addr;

    assign mem_addr = addr[ADDR_BITS-1:0];

    wire [ADDR_BITS-1:0] base_addr;

    assign base_addr = {mem_addr[ADDR_BITS-1:2], 2'b00};

    // ============================================================
    // INITIALIZATION
    // Load 32-bit program_data.hex into byte-addressable memory
    //
    // program_data.hex format:
    // dab73d13
    // 6441c283
    // b8c18483
    //
    // This code stores each 32-bit word into byte memory as:
    // mem[N+0] = word[7:0]
    // mem[N+1] = word[15:8]
    // mem[N+2] = word[23:16]
    // mem[N+3] = word[31:24]
    // ============================================================
    reg [1023:0] data_file;

    integer i;
    integer fd;
    integer ret;
    integer load_addr;

    reg [31:0] word_data;

    initial begin

        // First clear memory to avoid X
        for (i = 0; i < MEM_BYTES; i = i + 1)
            mem[i] = 8'h00;

        // Get hex file from plusarg
        if (!$value$plusargs("data_file=%s", data_file))
            data_file = "program_data.hex";

        $display("================================================");
        $display("Loading data memory from: %s", data_file);
        $display("Memory type             : byte memory");
        $display("Input hex type          : 32-bit word hex");
        $display("Address mapping         : addr[19:0]");
        $display("================================================");

        fd = $fopen(data_file, "r");

        if (fd == 0) begin
            $display("ERROR: Cannot open data file: %s", data_file);
            $finish;
        end

        load_addr = 0;

        while (!$feof(fd)) begin
            ret = $fscanf(fd, "%h", word_data);

            if (ret == 1) begin

                if ((load_addr + 3) < MEM_BYTES) begin
                    mem[load_addr + 0] = word_data[7:0];
                    mem[load_addr + 1] = word_data[15:8];
                    mem[load_addr + 2] = word_data[23:16];
                    mem[load_addr + 3] = word_data[31:24];
                end
                else begin
                    $display("WARNING: program_data.hex exceeds memory at byte address %h", load_addr);
                end

                load_addr = load_addr + 4;
            end
        end

        $fclose(fd);

        $display("Memory load completed. Total bytes loaded = %0d", load_addr);

    end

    // ============================================================
    // WRITE LOGIC - BYTE ENABLE SUPPORT
    // ============================================================
    always @(posedge clk) begin
        if (mem_write) begin
            if (byte_enable[0])
                mem[mem_addr] <= write_data[7:0];

            if (byte_enable[1])
                mem[mem_addr + 1] <= write_data[15:8];

            if (byte_enable[2])
                mem[mem_addr + 2] <= write_data[23:16];

            if (byte_enable[3])
                mem[mem_addr + 3] <= write_data[31:24];
        end
    end

    // ============================================================
    // READ LOGIC - ALIGNED WORD, LITTLE ENDIAN
    // ============================================================
    assign mem_data_out = mem_read ? {
        mem[base_addr + 3],
        mem[base_addr + 2],
        mem[base_addr + 1],
        mem[base_addr]
    } : 32'b0;

endmodule
