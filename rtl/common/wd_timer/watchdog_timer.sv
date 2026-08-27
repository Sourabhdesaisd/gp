module watchdog_timer #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter XLEN       = 32
)(
    //--------------------------------------------------
    // APB Interface
    //--------------------------------------------------
    input  logic                     pclk,
    input  logic                     presetn,
    input  logic                     psel,
    input  logic                     penable,
    input  logic                     pwrite,
    input  logic [ADDR_WIDTH-1:0]    paddr,  
    input  logic [DATA_WIDTH-1:0]    pwdata,
    output logic [DATA_WIDTH-1:0]    prdata,   
    output logic                     pready,
    output logic                     pslverr,

    //--------------------------------------------------
    // Watchdog Clock/Reset
    //--------------------------------------------------
    input  logic                     wdt_clk,
    input  logic                     wdt_rstn,

    //--------------------------------------------------
    // Debug Interface
    //--------------------------------------------------
    input  logic                     cpu_dbg_halt,

    //--------------------------------------------------
    // Optional CPU Tracking
    //--------------------------------------------------
    input  logic [XLEN-1:0]          cpu_commit_pc,
    input  logic                     cpu_commit_valid,

    //--------------------------------------------------
    // Outputs
    //--------------------------------------------------
    output logic                      wdt_reset,
    //output logic                      wdt_timeout,
    output logic [1:0]                reset_scope,

    //-------------------------------------------------
    // trace event outputs
    //------------------------------------------------
    output logic [7:0] 		 trace_event_id,
    output logic [31:0] 	 trace_data
);

//--------------------------------------------------
// APB Definitions
//--------------------------------------------------

logic apb_write;
//logic apb_read;

assign apb_write = psel & penable & pwrite;
//assign apb_read  = psel & penable & (~pwrite);

//--------------------------------------------------
// logicister Address Map
//--------------------------------------------------
localparam WDT_CTRL_ADDR         = 8'h00;
localparam WDT_TIMEOUT_ADDR      = 8'h04;
localparam WDT_WINDOW_ADDR       = 8'h08;
localparam WDT_REFRESH_ADDR      = 8'h0C;
localparam WDT_STATUS_ADDR       = 8'h10;
localparam WDT_LOCK_ADDR         = 8'h14;
localparam WDT_COUNT_ADDR        = 8'h18;
localparam WDT_RESET_CAUSE_ADDR  = 8'h1C;
localparam WDT_LAST_PC_ADDR      = 8'h20;
localparam WDT_BOOT_STATUS_ADDR  = 8'h24;
localparam WDT_RESET_WIDTH_ADDR  = 8'h28;

//--------------------------------------------------
//  trace event registers
//--------------------------------------------------
// configuration registers

localparam TRACE_APB_NONE	       = 8'h00;
localparam TRACE_WDT_NONE	       = 8'h04;
localparam TRACE_CTRL_UPDATE           = 8'h08;
localparam TRACE_TIMEOUT_UPDATE        = 8'h0C;
localparam TRACE_WINDOW_UPDATE         = 8'h10;
localparam TRACE_RESET_WIDTH_UPDATE    = 8'h14;
localparam TRACE_CONFIG_LOCK           = 8'h18;
localparam TRACE_CONFIG_UNLOCK         = 8'h1C;

//runtime events
localparam TRACE_WDT_STARTED           = 8'h20;
localparam TRACE_REFRESH_ACCEPTED      = 8'h24;
localparam TRACE_COUNTER_RELOADED      = 8'h28;
localparam TRACE_REFRESH_ERROR_KEY1    = 8'h2C;
localparam TRACE_REFRESH_ERROR_KEY2    = 8'h30;

//fault/reset events
localparam TRACE_WINDOW_VIOLATION      = 8'h40;
localparam TRACE_TIMEOUT_RESET_ASSERT  = 8'h44;
localparam TRACE_RESET_DEASSERT        = 8'h48;
localparam TRACE_WV_RESET_ASSERT       = 8'h4C; 

//status events
localparam TRACE_STATUS_UPDATE         = 8'h60;
localparam TRACE_RESET_CAUSE_UPDATE    = 8'h64;

//cpu debug events
localparam TRACE_CPU_DEBUG_ASSERT      = 8'h80;
localparam TRACE_CPU_DEBUG_RELEASE     = 8'h84;

//snapshort events
localparam TRACE_SNAPSHOT_CAPTURED     = 8'hA4;
localparam TRACE_WRITE_REJECTED        = 8'hC0;

//--------------------------------------------------
// Refresh Keys
//--------------------------------------------------
localparam REFRESH_KEY1 = 32'h000000A5;
localparam REFRESH_KEY2 = 32'h0000005A;

//--------------------------------------------------
// Lock Keys
//--------------------------------------------------
localparam LOCK_KEY_UNLOCK = 32'h1ACCE551;
localparam LOCK_KEY_LOCK   = 32'h00000000;

//--------------------------------------------------
// CTRL logicister Fields
//--------------------------------------------------
logic        enable;
logic        reset_en;
logic        window_en;
logic        dbg_freeze_en;
logic        lock_en;
logic [1:0]  reset_scope_logic;
logic [3:0]  hart_id;

//--------------------------------------------------
// Configuration logicisters
//--------------------------------------------------
logic [31:0] timeout_value;
logic [31:0] window_value;
logic [15:0] reset_cycles;

//--------------------------------------------------
// Status logicisters
//--------------------------------------------------
logic refresh_error;
logic wdt_reset_cause;

//--------------------------------------------------
// Optional Diagnostic logicisters
//--------------------------------------------------
logic [XLEN-1:0] last_pc;
logic prev_reset_wdt_pcl;
logic recovery_boot_req;

//--------------------------------------------------
// Internal Logic
//--------------------------------------------------
logic [31:0] watchdog_counter;
logic [15:0] reset_counter;
logic [1:0]  refresh_state;
logic        refresh_toggle;
logic        locked;
////////////////////////////////////////////////////

logic timeout_flag_apb;
logic window_violation_apb;
logic reset_issued_apb;
logic prev_reset_wdt_apb;

/////////////////////////////////////////////

logic enable_wdt;
logic reset_en_wdt;
logic window_en_wdt;
logic dbg_freeze_en_wdt;

logic wdt_reset_cause_apb;
logic cpu_dbg_halt_wdt;
logic cpu_dbg_halt_prev;

logic [31:0]  trace_data_pcl;
logic [7:0] trace_event_id_pcl;

////////////////////////////////////////////////

logic [31:0] timeout_value_wdt;
logic [31:0] window_value_wdt;
logic [15:0] reset_cycles_wdt;
logic [31:0] trace_data_wdt;
logic [7:0]  trace_event_id_wdt;

//////////////////////////////////////////////

logic counter_loaded;
logic timeout_active;
logic trace_toggle;

logic timeout_flag_wdt;
logic window_violation_wdt;
logic reset_issued_wdt;
logic prev_reset_wdt_wdt;
logic cfg_toggle;
logic ctrl_toggle;
logic counter_toggle;

////////////////////////////////////////////////////

logic refresh_valid;
logic freeze_condition;
logic prev_reset_wdt_pulse;
logic cpu_commit_valid_pcl;

assign pslverr = ~(( paddr == WDT_CTRL_ADDR ) || (paddr == WDT_TIMEOUT_ADDR) || (paddr == WDT_WINDOW_ADDR ) || ( paddr == WDT_RESET_WIDTH_ADDR ) || ( paddr == WDT_REFRESH_ADDR ) || ( paddr == WDT_STATUS_ADDR) || (paddr == WDT_LOCK_ADDR) || (paddr == WDT_COUNT_ADDR) || (paddr == WDT_LAST_PC_ADDR) || (paddr == WDT_BOOT_STATUS_ADDR) || (paddr == WDT_RESET_CAUSE_ADDR)) || ( apb_write & locked & ((paddr == WDT_CTRL_ADDR) || (paddr == WDT_TIMEOUT_ADDR) || (paddr ==  WDT_WINDOW_ADDR) || (paddr ==
WDT_RESET_WIDTH_ADDR))) ;
//--------------------------------------------------
// Reset Scope Output
//--------------------------------------------------
always_comb  begin
    reset_scope = reset_scope_logic;
end

//--------------------------------------------------
// Last PC Capture
//--------------------------------------------------
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        last_pc <= {XLEN{1'b0}};
        pready  <= 1'b0;
        end

    else begin
        pready <= 1'b1;
        if (cpu_commit_valid_pcl) begin
        last_pc <= cpu_commit_pc;
        end
        end
end

/////////////////////////////////////////////////////

logic status_toggle1;
logic status_toggle2;
logic status_toggle3;

logic [31:0] counter_snapshort;
logic [31:0] counter_pcl_data;

logic clr_f1;
logic clr_f2;
logic clr_f3;

//--------------------------------------------------
// APB Write Logic
//--------------------------------------------------
always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn) begin
        enable                <= 1'b0;
        reset_en              <= 1'b1;
        window_en             <= 1'b0;
        dbg_freeze_en         <= 1'b1;
        lock_en               <= 1'b0;
        reset_scope_logic       <= 2'b11;
        hart_id               <= 4'h0;

        timeout_value         <= 32'h0000FFFF;
        window_value          <= 32'h00000000;
        reset_cycles          <= 16'd32;

        refresh_error         <= 1'b0;

        prev_reset_wdt_pcl    <= 1'b0;
        recovery_boot_req     <= 1'b0;
        locked                <= 1'b0;
	
    	refresh_state	      <= 2'd0;
        refresh_toggle 	      <= 1'b0;
        cfg_toggle            <= 1'b0;

    	status_toggle1	      <= 1'b0;
 	status_toggle2	      <= 1'b0;
	status_toggle3	      <= 1'b0;
        ctrl_toggle           <= 1'b0;
	trace_event_id	      <= TRACE_APB_NONE;
	trace_data	      <= 32'b0;

    end
    else begin

	trace_event_id   <= trace_event_id_pcl;
	trace_data       <= trace_data_pcl;

	//-----------------------------------------------
	//refresh logic
	//-----------------------------------------------
	
        if (apb_write && paddr == WDT_REFRESH_ADDR) begin

            case (refresh_state)

                2'd0: begin
                    if (pwdata == REFRESH_KEY1)
                        refresh_state <= 2'd1;

                    else begin
                        refresh_error <= 1'b1;
                        refresh_state <= 2'd0;
		   	 trace_event_id <= TRACE_REFRESH_ERROR_KEY1;
		    	trace_data      <= pwdata;

                    end
                end

                2'd1: begin
                    if (pwdata == REFRESH_KEY2) begin
                        refresh_toggle <= ~refresh_toggle;
                        refresh_state <= 2'd0;

		    trace_event_id <= TRACE_REFRESH_ACCEPTED;
		    trace_data	   <= pwdata;

                    end
                    else begin
                        refresh_error <= 1'b1;
                        refresh_state <= 2'd0;
			trace_event_id <= TRACE_REFRESH_ERROR_KEY2;
		   	trace_data     <= pwdata;

                    end
                end

                default: begin
                    refresh_state <= 2'd0;
                end

            endcase
        end

        //--------------------------------------------------
        // Status W1C
        //--------------------------------------------------
        if (apb_write && (paddr == WDT_STATUS_ADDR)) begin
		if(pwdata[0]) status_toggle1 <= ~status_toggle1;
	    	if(pwdata[1]) status_toggle2 <= ~status_toggle2;
	    	if(pwdata[3]) status_toggle3 <= ~status_toggle3;

	    	if(pwdata[2]) refresh_error  <= 1'b0;

		trace_event_id  <= TRACE_STATUS_UPDATE;
	   	trace_data      <= {28'd0,reset_issued_apb,refresh_error,window_violation_apb,timeout_flag_apb} ;

          end

        //--------------------------------------------------
        // Lock logicister
        //--------------------------------------------------
        if (apb_write && paddr == WDT_LOCK_ADDR) begin
            if (pwdata == LOCK_KEY_UNLOCK) begin
                locked <= 1'b0;
		trace_event_id <= TRACE_CONFIG_UNLOCK;
		trace_data	   <= pwdata;
		end

            else if (pwdata == LOCK_KEY_LOCK) begin
                locked <= 1'b1;
	    	trace_event_id <= TRACE_CONFIG_LOCK;
	    	trace_data	   <= pwdata;
		end

        end
        //--------------------------------------------------
        // Protected Writes
        //--------------------------------------------------
        if (apb_write && !locked && paddr == WDT_CTRL_ADDR) begin

                //------------------------------------------
                // CTRL logicister
                //------------------------------------------
                    enable          <= pwdata[0];
                    reset_en        <= pwdata[1];
                    window_en       <= pwdata[2];
                    dbg_freeze_en   <= pwdata[3];
                    lock_en         <= pwdata[4];
                    reset_scope_logic <= pwdata[7:6];
                    hart_id         <= pwdata[11:8];
                    ctrl_toggle     <= ~ctrl_toggle;

		    trace_event_id <= TRACE_CTRL_UPDATE;
		    trace_data	   <= pwdata;
                end

                //------------------------------------------
                // Timeout logicister
                //------------------------------------------
        if (apb_write && !locked && paddr == WDT_TIMEOUT_ADDR) begin
                    timeout_value <= pwdata;
                    cfg_toggle    <= ~cfg_toggle;

		    trace_event_id <= TRACE_TIMEOUT_UPDATE;
		    trace_data	   <= pwdata;

                end

                //------------------------------------------
                // Window logicister
                //------------------------------------------
        if (apb_write && !locked && paddr == WDT_WINDOW_ADDR) begin
                    window_value <= pwdata;
                    cfg_toggle   <= ~cfg_toggle;

		    trace_event_id <= TRACE_WINDOW_UPDATE;
		    trace_data	   <= pwdata;

                end

                //------------------------------------------
                // Boot Status logicister
                //------------------------------------------
        if (apb_write && !locked && paddr == WDT_BOOT_STATUS_ADDR) begin
                    if (pwdata[0]) 
		        prev_reset_wdt_pcl <= ~ prev_reset_wdt_pcl;

                        recovery_boot_req <= pwdata[1];
                        
                end

                //------------------------------------------
                // Reset Width logicister
                //------------------------------------------
        if (apb_write && !locked && paddr == WDT_RESET_WIDTH_ADDR) begin
                    reset_cycles <= pwdata[15:0];
                    cfg_toggle   <= ~cfg_toggle;

		    trace_event_id <= TRACE_RESET_WIDTH_UPDATE;
		    trace_data	   <= pwdata;

                end
	if ( apb_write & locked & 
			 ((paddr == WDT_CTRL_ADDR) ||
			  (paddr == WDT_TIMEOUT_ADDR) ||
			  (paddr ==  WDT_WINDOW_ADDR) || 
			  (paddr == WDT_RESET_WIDTH_ADDR))) begin

		    trace_event_id <= TRACE_WRITE_REJECTED;
		    trace_data	   <= {24'd0, paddr};

		end
                   
        end
    end

//--------------------------------------------------
// APB Read Logic
//--------------------------------------------------

always_ff @(posedge pclk or negedge presetn) begin
	if(!presetn) begin
	   prdata <= 32'h0;
	  // snapshort_toggle <= 1'b0;
     end
else begin 
//	snapshort_toggle <= snapshort_toggle;
    case (paddr)

        //----------------------------------------------
        // CTRL logicister
        //----------------------------------------------
        WDT_CTRL_ADDR: prdata <= {20'd0,hart_id,reset_scope_logic,1'b0,lock_en,dbg_freeze_en,window_en,reset_en,enable} ;
            
        //----------------------------------------------
        // Timeout logicister
        //----------------------------------------------
        WDT_TIMEOUT_ADDR:
            prdata <= timeout_value;

        //----------------------------------------------
        // Window logicister
        //----------------------------------------------
        WDT_WINDOW_ADDR:
            prdata <= window_value;

        //----------------------------------------------
        // Status logicister
        //----------------------------------------------
        WDT_STATUS_ADDR: begin
		 prdata <= {28'd0,reset_issued_apb,refresh_error,window_violation_apb,timeout_flag_apb} ;
	   		end

            
        //----------------------------------------------
        // Count logicister
        //----------------------------------------------
        WDT_COUNT_ADDR: begin
               // snapshort_toggle <= ~snapshort_toggle;   
                 prdata <= counter_pcl_data;

                end

        //----------------------------------------------
        // Reset Cause logicister
        //----------------------------------------------
        WDT_RESET_CAUSE_ADDR: begin
		 prdata <= {31'd0,wdt_reset_cause_apb};
		end
            
        //----------------------------------------------
        // Last PC logicister
        //----------------------------------------------
        WDT_LAST_PC_ADDR:
            prdata <= last_pc;

        //----------------------------------------------
        // Boot Status logicister
        //----------------------------------------------
        WDT_BOOT_STATUS_ADDR: begin
		 prdata <= {30'd0,recovery_boot_req,prev_reset_wdt_apb};
		 end

        //----------------------------------------------
        // Reset Width logicister
        //----------------------------------------------
        WDT_RESET_WIDTH_ADDR:prdata <= {16'd0,reset_cycles};
           
	default  : begin
			prdata <= 32'b0;
	end    
        
    endcase
end
end

//--------------------------------------------------
// Watchdog Counter Logic
//--------------------------------------------------
assign freeze_condition = (dbg_freeze_en_wdt & cpu_dbg_halt_wdt);

////////////////////////////////////////////////////////////////////////////////

always_ff @(posedge wdt_clk or negedge wdt_rstn) begin

    if (!wdt_rstn) begin

        watchdog_counter <= 32'h0;
        //wdt_timeout      <= 1'b0;
        wdt_reset        <= 1'b0;

        reset_counter    <= 16'h0;
        counter_loaded   <= 1'b0;
        timeout_active   <= 1'b0;

    	wdt_reset_cause  <= 1'b0;
    	timeout_flag_wdt	 <= 1'b0;
    	window_violation_wdt <= 1'b0;

        reset_issued_wdt     <= 1'b0;
        prev_reset_wdt_wdt   <= 1'b0;
        counter_snapshort      <= 32'b0;
	counter_toggle		<= 1'b0;
	cpu_dbg_halt_prev	<= 1'b0;
	trace_event_id_wdt		<= TRACE_WDT_NONE;
	trace_data_wdt		<= 32'b0;
	trace_toggle		<= 1'b0;
       
    end
    else begin

            counter_snapshort <=  watchdog_counter;
            counter_toggle    <= ~counter_toggle;

	    	 trace_event_id_wdt  <= TRACE_SNAPSHOT_CAPTURED;
		     trace_data_wdt	 <= watchdog_counter;
		     trace_toggle	<= ~trace_toggle;
		 

        //----------------------------------------------
        // Default
        //----------------------------------------------
          if(!cpu_dbg_halt_prev && dbg_freeze_en_wdt && cpu_dbg_halt_wdt) begin
		 trace_event_id_wdt  <= TRACE_CPU_DEBUG_ASSERT;
		 trace_data_wdt	 <= watchdog_counter;
		 trace_toggle	<= ~trace_toggle;

	end

	  if(cpu_dbg_halt_prev && !dbg_freeze_en_wdt && cpu_dbg_halt_wdt) begin
		 trace_event_id_wdt  <= TRACE_CPU_DEBUG_RELEASE;
		 trace_data_wdt	 <= watchdog_counter;
		 trace_toggle	<= ~trace_toggle;	

	end
	cpu_dbg_halt_prev <= cpu_dbg_halt_wdt; 

             if(clr_f1) begin
                timeout_flag_wdt <= 1'b0;
		end

             if(clr_f2) begin
                 window_violation_wdt <= 1'b0;
		end

             if(clr_f3) begin
                 reset_issued_wdt <=1'b0;
                  end

            if(prev_reset_wdt_pulse)
                prev_reset_wdt_wdt <= 1'b0;

        

        //----------------------------------------------
        // Reset Pulse Generation
        //----------------------------------------------
        if (wdt_reset) begin

            if (reset_counter >= reset_cycles_wdt) begin
                wdt_reset    <= 1'b0;
                reset_counter <= 16'h0;
		 trace_event_id_wdt <= TRACE_RESET_DEASSERT;
		 trace_data_wdt	   <= {16'b0,reset_cycles_wdt};
	 	 trace_toggle	<= ~trace_toggle;
		    
            end
            else begin
                reset_counter <= reset_counter + 16'b1;
            end
        end

        //----------------------------------------------
        // Watchdog Operation
        //----------------------------------------------
        if (enable_wdt && !freeze_condition) begin

            //------------------------------------------
            // Initial Load
            //------------------------------------------
            if (!counter_loaded) begin
                watchdog_counter <= timeout_value_wdt;
                counter_loaded   <= 1'b1;

	       trace_event_id_wdt <= TRACE_WDT_STARTED;
	       trace_data_wdt     <= timeout_value_wdt;
		 trace_toggle	<= ~trace_toggle;
		
                end

              //------------------------------------------
              // Refresh Logic
              //------------------------------------------
              else if (refresh_valid) begin

                //--------------------------------------
                // Window Violation
                //--------------------------------------
                if (window_en_wdt && (watchdog_counter > window_value_wdt)) begin

                    window_violation_wdt <= 1'b1;
		    trace_event_id_wdt <= TRACE_WINDOW_VIOLATION;
		    trace_data_wdt	   <= watchdog_counter;
   	            trace_toggle	<= ~trace_toggle;
		   

                    if (reset_en_wdt) begin
                        wdt_reset      <= 1'b1;
                        reset_issued_wdt   <= 1'b1;
                        prev_reset_wdt_wdt <= 1'b1;
		       trace_event_id_wdt  <= TRACE_WV_RESET_ASSERT; // for trace with this event we will get reset_issued signal
		       trace_data_wdt      <= watchdog_counter;
		       trace_toggle	<= ~trace_toggle;
			
                    end
                  end
                
              else begin
                  watchdog_counter <= timeout_value_wdt;
                  timeout_active   <= 1'b0;
                  timeout_flag_wdt     <= 1'b0;

		    trace_event_id_wdt <= TRACE_COUNTER_RELOADED;
		    trace_data_wdt	   <= timeout_value_wdt;
		    trace_toggle	<= ~trace_toggle;
		    
                  end
              end

            //------------------------------------------
            // Normal Countdown
            //------------------------------------------
            else if (watchdog_counter > 0) begin
                watchdog_counter <= watchdog_counter - 32'b1;
            end

            //------------------------------------------
            // Timeout Condition
            //------------------------------------------
            else if (!timeout_active) begin

                timeout_active  	<= 1'b1;
                timeout_flag_wdt    	<= 1'b1;
                wdt_reset_cause 	<= 1'b1;
		 trace_event_id_wdt    <= TRACE_RESET_CAUSE_UPDATE; // along with this timeout_flag will be high 
        	 trace_data_wdt        <= {31'd0,wdt_reset_cause_apb};
		 trace_toggle   	<= ~trace_toggle;		

                if (reset_en_wdt) begin
                    wdt_reset          <= 1'b1;
                    reset_issued_wdt   <= 1'b1;
                    prev_reset_wdt_wdt <= 1'b1;
		       trace_event_id_wdt  <= TRACE_TIMEOUT_RESET_ASSERT; // for trace with this event we will get reset_issued signal
		       trace_data_wdt      <= watchdog_counter;
		       trace_toggle	<= ~trace_toggle;		

                end
            end

        end
    end
end


watchdog_sync watchdog_sync_instance (
    
        .pclk                       (pclk),
        .presetn                    (presetn),
        .wdt_clk                    (wdt_clk),
        .wdt_rstn                   (wdt_rstn),

        .status_toggle_sync1        (status_toggle1),
        .status_toggle_sync2        (status_toggle2),
        .status_toggle_sync3        (status_toggle3),
	    .timeout_flag_wdt_sync      (timeout_flag_wdt),
        .window_violation_wdt_sync  (window_violation_wdt),         
        .reset_issued_wdt_sync      (reset_issued_wdt),
        .prev_reset_wdt_wdt_sync    (prev_reset_wdt_wdt),
        .wdt_reset_cause_sync       (wdt_reset_cause),

        .timeout_flag_apb_sync      (timeout_flag_apb), 
        .window_violation_apb_sync  (window_violation_apb),
        .reset_issued_apb_sync      (reset_issued_apb),
        .prev_reset_wdt_apb_sync    (prev_reset_wdt_apb),
        .wdt_reset_cause_apb_sync   (wdt_reset_cause_apb),
        
        .refresh_toggle_sync        (refresh_toggle),
        .enable_sync                (enable),
        .reset_en_sync              (reset_en),
        .window_en_sync             (window_en),
        .dbg_freeze_en_sync         (dbg_freeze_en),
        .cfg_toggle_sync            (cfg_toggle),
        .prev_reset_wdt_pcl_sync    (prev_reset_wdt_pcl),
                                                          
        .enable_wdt_sync            (enable_wdt),
        .reset_en_wdt_sync          (reset_en_wdt),
        .window_en_wdt_sync         (window_en_wdt),
        .dbg_freeze_en_wdt_sync     (dbg_freeze_en_wdt),

        .refresh_valid_sync         (refresh_valid),
        .prev_reset_wdt_pulse_sync  (prev_reset_wdt_pulse),
        .clr_f1_sync                (clr_f1),
        .clr_f2_sync                (clr_f2),
        .clr_f3_sync                (clr_f3),

        .timeout_value_wdt_sync     (timeout_value_wdt),
        .window_value_wdt_sync      (window_value_wdt),
        .reset_cycles_wdt_sync      (reset_cycles_wdt),
        .cpu_dbg_halt_sync          (cpu_dbg_halt),
        .cpu_dbg_halt_wdt_sync      (cpu_dbg_halt_wdt),

        .timeout_value_sync         (timeout_value),
        .window_value_sync          (window_value),
        .reset_cycles_sync          (reset_cycles),

        .ctrl_toggle_sync           (ctrl_toggle),

        .cpu_commit_valid_pcl_sync  (cpu_commit_valid_pcl),
        .cpu_commit_valid_sync      (cpu_commit_valid),

        .counter_toggle_sync        (counter_toggle),
        .counter_snapshort_sync     (counter_snapshort),
        .counter_snapshort_pcl      (counter_pcl_data),

	.trace_toggle_sync	    (trace_toggle),
	.trace_event_id_wdt_sync    (trace_event_id_wdt),
	.trace_data_wdt_sync	    (trace_data_wdt),
	.trace_data_pcl_sync	    (trace_data_pcl),
	.trace_event_id_pcl_sync    (trace_event_id_pcl)			
    );


endmodule



