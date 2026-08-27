module tlb_ctrl #(
	    parameter int PPN_WIDTH    = 20
	)(
	    //  Instruction side inputs (itlb)
	    input  logic itlb_hit,
	    input  logic [PPN_WIDTH-1:0] itlb_ppn,
	    input  logic itlb_execute_access_bit,
        input logic mem_read_en,
        input logic mem_write_en,
	
        // l2 tlb inst side
	    input  logic  l2_hit,
	    input  logic [PPN_WIDTH-1:0]   l2_ppn,
        input logic  l2tlb_execute_access_bit ,
	
	    //  Instruction side outputs 
	    output logic  o_hit,
	    output logic [PPN_WIDTH-1:0]   o_ppn_out,
        output logic  inst_execute_permission_fault ,
        
	   	
	    // Memory side inputs (dtlb)
	    input  logic  dtlb_hit,
	    input  logic [PPN_WIDTH-1:0]   dtlb_ppn,
        input logic  dtlb_read_access_bit ,
    	input logic  dtlb_write_access_bit ,
	 //   input  logic  dtlb_dirty,
	
        // l2 tlb  mem side 
	    input  logic  l2_mem_hit,
	    input  logic [PPN_WIDTH-1:0]   l2_mem_ppn,
//	    input  logic  l2_mem_dirty,
        input logic  l2tlb_read_access_bit ,
        input logic  l2tlb_write_access_bit ,

	

	
	    //  Memory side outputs 
	    output logic  o_mem_hit,
	    output logic [PPN_WIDTH-1:0]   o_mem_ppn_out,
//	    output logic   o_mem_dirty_out,
        output logic  mem_read_permission_fault ,
        output logic  mem_write_permission_fault

	    
        );

    logic inst_execute_ok;
    logic mem_read_ok;
    logic mem_write_ok;

	
	    //  Instruction side
	    assign o_hit        = itlb_hit | l2_hit;
	    assign o_ppn_out    = itlb_hit ? itlb_ppn    : l2_ppn;
	
	
	    // Memory side 
	    assign o_mem_hit  = dtlb_hit | l2_mem_hit;
	    assign o_mem_ppn_out  = dtlb_hit ? dtlb_ppn    : l2_mem_ppn;
//	    assign o_mem_dirty_out  = dtlb_hit ? dtlb_dirty  : l2_mem_dirty;
	
	
    assign mem_read_ok  = (dtlb_read_access_bit | l2tlb_read_access_bit); // Read permission
    assign mem_write_ok =   (dtlb_write_access_bit | l2tlb_write_access_bit); // Write permission
    assign inst_execute_ok = (itlb_execute_access_bit | l2tlb_execute_access_bit);
	
    assign inst_execute_permission_fault = o_hit ? ~inst_execute_ok : 1'b0 ;
    assign mem_read_permission_fault = o_mem_hit ?  (mem_read_en ? ~mem_read_ok : 1'b0 ) :1'b0 ;
    assign mem_write_permission_fault = o_mem_hit ? (mem_write_en ? ~mem_write_ok : 1'b0 ) : 1'b0 ;

	
endmodule

