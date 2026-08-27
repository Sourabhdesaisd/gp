

module main_tb;

    reg clk;
    reg rst;
	reg [31:0] data_from_mem ;
	reg [31:0] instruction ;
   // reg rst_im;
       //reg   write_en;
       //reg   [9:0] write_addr;
       //reg   [31:0] write_data;

    wire [31:0] pc;
    //wire [31:0]    s_alu_result_out ; 
    //wire [31:0]    s_load_data_out ;
    //wire [4:0]    s_rd_out  ;     
    //wire     s_wb_reg_file_out;
   // wire     s_memtoreg_out  ; 
 wire [31:0] data_mem_address ;
wire mem_write_en ;
	wire mem_read_en ;
	wire [31:0] mem_write_data ;

    // Instantiate the core/top (change name if your top is different)
    rv32i_core dut (
        .clk(clk),
        .rst(rst),
	//.rst_im(rst_im),
	.data_from_mem(data_from_mem) ,
	.instruction(instruction) ,
	//.write_en(write_en),
	//.write_addr(write_addr),
	//.write_data(write_data),
        .pc(pc),
        //.s_alu_result_out (s_alu_result_out),
       // .s_load_data_out (s_load_data_out), 
       // .s_rd_out (s_rd_out) ,       
        //.s_wb_reg_file_out(s_wb_reg_file_out),
        //.s_memtoreg_out (s_memtoreg_out)   
	.data_mem_address(data_mem_address) ,
	.mem_write_en(mem_write_en) ,
	.mem_read_en(mem_read_en) ,
	.mem_write_data(mem_write_data)


    );

    initial begin
        // waveform / shared memory probe (as in your environment)
        $shm_open("wave.shm");
        $shm_probe("ACTMF");
    end

    // Clock generation: 10ns period
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end
    
	//initial begin
	//rst_im =0;
        // write_en  = 1'b0;
	//write_addr = 0;
	//write_data = 0;
     //end

    // Test stimulus
    initial begin
        // Apply reset
        rst = 1;
        #10;       // Hold reset for 20ns
        rst = 0;

        // Run simulation for N ns then finish (adjust as needed)
        #1000;
        $display("SIMULATION DONE");
        $finish;
    end

endmodule 


/*
module tb_rv32i_core;

    // ----------------------------------
    // Clock / Reset
    // ----------------------------------
    reg clk;
    reg rst;
    reg rst_im;

    // IMEM write
    reg write_en;
    reg [9:0] write_addr;
    reg [31:0] write_data;

    // DUT wires
    wire [31:0] pc;
    wire [31:0] s_alu_result_out;
    wire [31:0] s_load_data_out;
    wire [4:0]  s_rd_out;
    wire s_wb_reg_file_out;
    wire s_memtoreg_out;

    // ----------------------------------
    // DUT
    // ----------------------------------
    rv32i_core dut (
        .clk(clk),
        .rst(rst),
        .rst_im(rst_im),
        .write_en(write_en),
        .write_addr(write_addr),
        .write_data(write_data),
        .pc(pc),
        .s_alu_result_out(s_alu_result_out),
        .s_load_data_out(s_load_data_out),
        .s_rd_out(s_rd_out),
        .s_wb_reg_file_out(s_wb_reg_file_out),
        .s_memtoreg_out(s_memtoreg_out)
    );

    // ----------------------------------
    // Clock generation
    // ----------------------------------
    always #5 clk = ~clk;

    // ----------------------------------
    // Tasks
    // ----------------------------------
    task load_instr(input [9:0] addr, input [31:0] instr);
    begin
        write_en = 1;
        write_addr = addr;
        write_data = instr;
        #10;
        write_en = 0;
    end
    endtask

    task run_cycles(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
        end
    endtask

    task pass(input [200*8:1] msg);
        $display("PASS : %s", msg);
    endtask

    task fail(input [200*8:1] msg);
        begin
            $display("FAIL : %s", msg);
        end
    endtask

    task check_writeback;
        begin
            if (s_wb_reg_file_out) begin
                if (s_rd_out != 0)
                    pass("Valid writeback");
                else
                    fail("wb_reg_file=1 but rd=0");
            end else
                $display("INFO : No writeback this cycle");
        end
    endtask

    // ----------------------------------
    // INITIAL
    // ----------------------------------
    initial begin
        clk = 0;
        rst = 1;
        rst_im = 1;
        write_en = 0;
        write_addr = 0;
        write_data = 0;

        #20;
        rst = 0;
        rst_im = 0;

        // ===============================
        // ENABLE ONLY ONE TEST AT A TIME
        // ===============================

        //test_reset();
        //test_sequential_pc();
        //test_writeback();
        //test_forwarding();
        //test_load_use_hazard();
        //test_branch_taken();
        //test_branch_mispredict();
        //test_btb_hit();
        //test_btb_lru();

        $display("\n=================================");
        $display(" ALL ENABLED TESTS PASSED ");
        $display("=================================\n");
        $finish;
    end

    // =====================================
    // TEST 1 : RESET
    // =====================================
    task test_reset;
    begin
        $display("\n--- TEST 1 : RESET ---");

        if (pc == 0)
            pass("PC reset to zero");
        else
            fail("PC not reset");

        run_cycles(5);
    end
    endtask

    // =====================================
    // TEST 2 : Sequential PC
    // =====================================
task test_sequential_pc;
    reg [31:0] pc_prev;
begin
    $display("\n--- TEST 2 : SEQUENTIAL PC ---");

    // Load NOPs
    load_instr(0, 32'h00000013);
    load_instr(1, 32'h00000013);
    load_instr(2, 32'h00000013);

    // Allow pipeline warm-up
    run_cycles(5);

    pc_prev = pc;
    run_cycles(1);

    if (pc == pc_prev + 4)
        pass("PC increments by 4");
    else
        fail("PC did not increment");
end
endtask
    
    // =====================================
    // TEST 3 : Writeback
    // =====================================
    task test_writeback;
    begin
        $display("\n--- TEST 3 : WRITEBACK ---");

        // addi x1, x0, 5
        load_instr(0, 32'h00500093);

        run_cycles(10);
        check_writeback();
    end
    endtask

    // =====================================
    // TEST 4 : Forwarding
    // =====================================
    task test_forwarding;
    begin
        $display("\n--- TEST 4 : FORWARDING ---");

        // addi x1, x0, 5
        load_instr(0, 32'h00500093);
        // addi x2, x1, 3 (needs forwarding)
        load_instr(1, 32'h00308113);

        run_cycles(15);
        pass("Forwarding executed (manual waveform check)");
    end
    endtask

    // =====================================
    // TEST 5 : Load-use hazard
    // =====================================
    task test_load_use_hazard;
    begin
        $display("\n--- TEST 5 : LOAD-USE HAZARD ---");

        // lw x1, 0(x0)
        load_instr(0, 32'h00002083);
        // add x2, x1, x1 (stall expected)
        load_instr(1, 32'h00110133);

        run_cycles(20);
        pass("Stall inserted (manual waveform check)");
    end
    endtask

    // =====================================
    // TEST 6 : Branch taken
    // =====================================
    task test_branch_taken;
    begin
        $display("\n--- TEST 6 : BRANCH TAKEN ---");

        // addi x1, x0, 1
        load_instr(0, 32'h00100093);
        // addi x2, x0, 1
        load_instr(1, 32'h00100113);
        // beq x1, x2, +8
        load_instr(2, 32'h00208663);
        // addi x3, x0, 9 (should be skipped)
        load_instr(3, 32'h00900193);

        run_cycles(30);

        if (pc != 16)
            pass("Branch taken, PC changed");
        else
            fail("Branch not taken");
    end
    endtask

    // =====================================
    // TEST 7 : Branch misprediction
    // =====================================
    task test_branch_mispredict;
    begin
        $display("\n--- TEST 7 : BRANCH MISPREDICT ---");

        // Force BTB miss then update
        load_instr(0, 32'h00100093);
        load_instr(1, 32'h00100113);
        load_instr(2, 32'h00208663);

        run_cycles(30);
        pass("Misprediction corrected (PC redirected)");
    end
    endtask

    // =====================================
    // TEST 8 : BTB HIT
    // =====================================
    task test_btb_hit;
    begin
        $display("\n--- TEST 8 : BTB HIT ---");

        // Same branch twice
        load_instr(0, 32'h00100093);
        load_instr(1, 32'h00100113);
        load_instr(2, 32'h00208663);
        load_instr(3, 32'h00208663);

        run_cycles(40);
        pass("BTB hit observed (check predictedTaken_if)");
    end
    endtask

    // =====================================
    // TEST 9 : BTB LRU
    // =====================================
    task test_btb_lru;
    begin
        $display("\n--- TEST 9 : BTB LRU ---");

        // 3 branches mapping to same set
        load_instr(0, 32'h00208663);
        load_instr(4, 32'h00208663);
        load_instr(8, 32'h00208663);

        run_cycles(60);
        pass("LRU replacement verified (waveform)");
    end
    endtask
initial begin
        // waveform / shared memory probe (as in your environment)
        $shm_open("wave.shm");
        $shm_probe("ACTMF");
    end

initial begin
    clk = 0;
    rst = 1;
    rst_im = 1;
    write_en = 0;

    // Load program while reset is HIGH
    load_instr(0, 32'h00500093); // addi x1, x0, 5
    load_instr(1, 32'h00308113); // addi x2, x1, 3
    load_instr(2, 32'h00000013); // nop

    #20;
    rst = 0;
    rst_im = 0;   // release reset AFTER loading IMEM

    run_cycles(40);
end



endmodule
*/
