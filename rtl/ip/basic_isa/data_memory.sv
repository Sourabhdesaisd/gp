module data_memory (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [31:0] addr,
    input  [31:0] write_data,
    input  [3:0]  byte_enable,
    output [31:0] mem_data_out
);

    parameter MEM_BYTES = 1024*1024;
    parameter ADDR_BITS = 20;

    //--------------------------------------------------
    // Main RAM
    //--------------------------------------------------
    reg [7:0] mem [0:MEM_BYTES-1];

    //--------------------------------------------------
    // Sparse Memory
    //--------------------------------------------------
    byte sparse_mem [longint unsigned];

    //--------------------------------------------------
    // Memory Region
    //--------------------------------------------------
    localparam RAM_BASE = 32'h8000_0000;
    localparam RAM_END  = 32'h800F_FFFF;

    wire ram_access;

    assign ram_access =
           (addr >= RAM_BASE) &&
           (addr <= RAM_END);

    //--------------------------------------------------
    // Address Mapping
    //--------------------------------------------------
    wire [ADDR_BITS-1:0] mem_addr;
    wire [ADDR_BITS-1:0] base_addr;

    assign mem_addr =
           ram_access ?
           (addr - RAM_BASE) :
           {ADDR_BITS{1'b0}};

    assign base_addr =
           {mem_addr[ADDR_BITS-1:2],2'b00};

    //--------------------------------------------------
    // Existing HEX load code
    //--------------------------------------------------

        reg [1023:0] data_file;
    reg [31:0] word_data;

    integer i;
    integer fd;
    integer ret;
    integer load_addr;

    initial begin

        for(i=0;i<MEM_BYTES;i=i+1)
            mem[i] = 8'h00;

        if(!$value$plusargs("data_file=%s",data_file))
            data_file = "program_data.hex";

        $display("========================================");
        $display("Loading Memory File : %s",data_file);
        $display("Memory Size         : %0d Bytes",MEM_BYTES);
        $display("Address Mapping     : addr[19:0]");
        $display("========================================");

        fd = $fopen(data_file,"r");

        if(fd == 0) begin
            $display("ERROR: Cannot open %s",data_file);
            $finish;
        end

        load_addr = 0;

        while(!$feof(fd)) begin

            ret = $fscanf(fd,"%h",word_data);

            if(ret == 1) begin

                if(load_addr+3 < MEM_BYTES) begin

                    mem[load_addr+0] = word_data[7:0];
                    mem[load_addr+1] = word_data[15:8];
                    mem[load_addr+2] = word_data[23:16];
                    mem[load_addr+3] = word_data[31:24];

                end

                load_addr = load_addr + 4;

            end

        end

        $fclose(fd);

        $display("Loaded %0d bytes",load_addr);

    end

    always @(posedge clk) begin

        if(mem_write) begin

            //----------------------------------
            // Main RAM Region
            //----------------------------------
            if(ram_access) begin

                if(byte_enable[0])
                    mem[base_addr+0] <= write_data[7:0];

                if(byte_enable[1])
                    mem[base_addr+1] <= write_data[15:8];

                if(byte_enable[2])
                    mem[base_addr+2] <= write_data[23:16];

                if(byte_enable[3])
                    mem[base_addr+3] <= write_data[31:24];

            end

            //----------------------------------
            // Sparse Memory Region
            //----------------------------------
            else begin

                if(byte_enable[0])
                    sparse_mem[addr+0] = write_data[7:0];

                if(byte_enable[1])
                    sparse_mem[addr+1] = write_data[15:8];

                if(byte_enable[2])
                    sparse_mem[addr+2] = write_data[23:16];

                if(byte_enable[3])
                    sparse_mem[addr+3] = write_data[31:24];

            end

        end

    end

    longint unsigned sparse_base;
    reg [31:0] sparse_read_data;

    always @(*) begin

        sparse_base = {addr[31:2],2'b00};

        sparse_read_data = {

            sparse_mem.exists(sparse_base+3) ?
                sparse_mem[sparse_base+3] :
                8'h00,

            sparse_mem.exists(sparse_base+2) ?
                sparse_mem[sparse_base+2] :
                8'h00,

            sparse_mem.exists(sparse_base+1) ?
                sparse_mem[sparse_base+1] :
                8'h00,

            sparse_mem.exists(sparse_base+0) ?
                sparse_mem[sparse_base+0] :
                8'h00
        };

    end


        assign mem_data_out =

        mem_read ?

        (

            ram_access ?

            {
                mem[base_addr+3],
                mem[base_addr+2],
                mem[base_addr+1],
                mem[base_addr+0]
            }

            :

            sparse_read_data

        )

        :

        32'h00000000;

endmodule
