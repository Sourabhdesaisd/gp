module watchdog_sync (

    //apb interface
    input logic     pclk,
    input logic     presetn,


    //watchdog clk and rst
    input logic      wdt_clk,
    input logic      wdt_rstn,

    //
    input logic  status_toggle_sync1,
    input logic  status_toggle_sync2,
    input logic  status_toggle_sync3,
    input logic  timeout_flag_wdt_sync,

    input logic  window_violation_wdt_sync,
    input logic  reset_issued_wdt_sync,
    input logic  prev_reset_wdt_wdt_sync,
    input logic  wdt_reset_cause_sync,

    input logic refresh_toggle_sync,   
    input logic enable_sync,
    input logic reset_en_sync,
    input logic window_en_sync,

    input logic dbg_freeze_en_sync,
    input logic cfg_toggle_sync,
    input logic prev_reset_wdt_pcl_sync,
    input logic ctrl_toggle_sync,

    input logic cpu_dbg_halt_sync,
   // input logic snapshort_toggle_sync,
    input logic counter_toggle_sync,
    input logic cpu_commit_valid_sync,

    input logic trace_toggle_sync,


    input logic  [31:0]   timeout_value_sync,
    input logic  [31:0]   window_value_sync,
    input logic  [15:0]   reset_cycles_sync,
    input logic  [31:0]   counter_snapshort_sync,
    input logic  [7:0]    trace_event_id_wdt_sync,
    input logic  [31:0]   trace_data_wdt_sync,

///////////////////////////////////////////////////

    output logic   	  timeout_flag_apb_sync,                        
    output logic   	  window_violation_apb_sync, 
    output logic  	  reset_issued_apb_sync, 
    output logic   	  prev_reset_wdt_apb_sync,   
    output logic   	  wdt_reset_cause_apb_sync,

    output logic  	  enable_wdt_sync,
    output logic   	  reset_en_wdt_sync,
    output logic  	  window_en_wdt_sync,
    output logic  	  dbg_freeze_en_wdt_sync,

    output logic	  refresh_valid_sync,
    output logic 	  prev_reset_wdt_pulse_sync,
    output logic 	  clr_f1_sync,
    output logic 	  clr_f2_sync,
    output logic 	  clr_f3_sync,

    output logic    cpu_dbg_halt_wdt_sync,
   // output logic    snapshort_wdt_pulse,

    output logic    cpu_commit_valid_pcl_sync,

    output logic   [31:0]  timeout_value_wdt_sync,
    output logic   [31:0]  window_value_wdt_sync,
    output logic   [15:0]  reset_cycles_wdt_sync,
    output logic   [31:0]  counter_snapshort_pcl,
    output logic   [7:0]   trace_event_id_pcl_sync,
    output logic   [31:0]  trace_data_pcl_sync
    
    );


logic [1:0] sync_f1,sync_f2,sync_f3;
logic       dly_f1, dly_f2, dly_f3;
//////////////////////////////////////
logic   timeout_flag_meta;      
logic   window_violation_meta;                  
logic   reset_issued_meta;    
logic   prev_reset_wdt_meta; 
                   
logic   wdt_reset_cause_meta; 
logic   cpu_dbg_halt_meta;
logic   trace_toggle_sync1;	
logic 	trace_toggle_sync2;	
logic	trace_toggle_sync3;	

////////////////////////////////////

logic refresh_toggle_sync1;  
logic refresh_toggle_sync2;  
logic refresh_toggle_sync2_d;

logic ctrl_toggle_wdt_sync1;
logic ctrl_toggle_wdt_sync2;
logic ctrl_toggle_wdt_sync2_d;

logic ctrl_toggle_pulse;              
logic reset_en_meta;                         
logic window_en_meta;   
                    
logic cpu_commit_valid_meta;  
//logic snapshort_toggle_sync1;
//logic snapshort_toggle_sync2;
//logic snapshort_toggle_sync3;

///////////////////////////////////
                
logic  cfg_sync1;             
logic  cfg_sync2;             
logic  cfg_sync2_d;           
                
logic  prev_reset_wdt_sync1;  
logic  prev_reset_wdt_sync2;  
logic  prev_reset_wdt_sync2_d;

logic  counter_toggle_sync1;
logic  counter_toggle_sync2;
logic  counter_toggle_sync3;

//////////////////////////////////////

logic 	cfg_update_sync;
logic   counter_toggle_pulse;
logic   trace_pulse;

////////////////////////////////////////////////////

always @(posedge pclk or negedge presetn) begin
    if(!presetn) begin

        timeout_flag_meta           <= 1'b0;
        timeout_flag_apb_sync       <= 1'b0;

        window_violation_meta       <= 1'b0;
        window_violation_apb_sync   <= 1'b0;

        reset_issued_meta           <= 1'b0;
        reset_issued_apb_sync       <= 1'b0;

        prev_reset_wdt_meta         <= 1'b0;
        prev_reset_wdt_apb_sync     <= 1'b0;

	    wdt_reset_cause_meta        <= 1'b0;
    	wdt_reset_cause_apb_sync    <= 1'b0;

        cpu_commit_valid_meta       <= 1'b0;
        cpu_commit_valid_pcl_sync   <= 1'b0;


        counter_toggle_sync1        <= 1'b0;
        counter_toggle_sync2        <= 1'b0;
        counter_toggle_sync3        <= 1'b0;

	trace_toggle_sync1	    <= 1'b0;
	trace_toggle_sync2	    <= 1'b0;
	trace_toggle_sync3	    <= 1'b0;

        

    end
    else begin

        timeout_flag_meta          <= timeout_flag_wdt_sync;
        timeout_flag_apb_sync      <= timeout_flag_meta;

        window_violation_meta      <= window_violation_wdt_sync;
        window_violation_apb_sync  <= window_violation_meta;

        reset_issued_meta          <= reset_issued_wdt_sync;
        reset_issued_apb_sync      <= reset_issued_meta;

        prev_reset_wdt_meta        <= prev_reset_wdt_wdt_sync;
        prev_reset_wdt_apb_sync    <= prev_reset_wdt_meta;

	    wdt_reset_cause_meta       <= wdt_reset_cause_sync;
    	wdt_reset_cause_apb_sync   <= wdt_reset_cause_meta;	 
    
        cpu_commit_valid_meta      <= cpu_commit_valid_sync;
        cpu_commit_valid_pcl_sync  <= cpu_commit_valid_meta;


        counter_toggle_sync1        <= counter_toggle_sync;
        counter_toggle_sync2        <= counter_toggle_sync1;
        counter_toggle_sync3        <= counter_toggle_sync2;  

	trace_toggle_sync1	    <= trace_toggle_sync;
	trace_toggle_sync2	    <= trace_toggle_sync1;
	trace_toggle_sync3	    <= trace_toggle_sync2;  
	
    end
end

//////////////////////////////////////////////////////////////

always_ff @(posedge pclk or negedge presetn) begin
    if(!presetn) begin
        counter_snapshort_pcl   <= 32'h0;
	trace_event_id_pcl_sync   <= 8'b0;
	trace_data_pcl_sync       <= 32'b0;

        end
        else begin
	    if (counter_toggle_pulse) begin
            counter_snapshort_pcl <= counter_snapshort_sync;
            end

	    if(trace_pulse) begin
	    trace_event_id_pcl_sync   <= trace_event_id_wdt_sync;
	    trace_data_pcl_sync       <= trace_data_wdt_sync;
	end
	end
end

///////////////////////////////////////////////////////////////

always @(posedge wdt_clk or negedge wdt_rstn) begin
 if(!wdt_rstn) begin
	sync_f1 <= 2'b00;
	sync_f2 <= 2'b00;
	sync_f3 <= 2'b00;

	dly_f1 <= 1'b0;
	dly_f2 <= 1'b0;
	dly_f3 <= 1'b0;

end
else begin
	sync_f1 <= {sync_f1[0], status_toggle_sync1};
	sync_f2 <= {sync_f2[0], status_toggle_sync2};
	sync_f3 <= {sync_f3[0], status_toggle_sync3};

	dly_f1 <= sync_f1[1];
	dly_f2 <= sync_f2[1];
	dly_f3 <= sync_f3[1];
end
end

////////////////////////////////////////////////////////////////

always@(posedge wdt_clk or negedge wdt_rstn) begin
if(!wdt_rstn) begin
            refresh_toggle_sync1   <= 1'b0;
            refresh_toggle_sync2   <= 1'b0;
            refresh_toggle_sync2_d <= 1'b0;

            reset_en_meta          <= 1'b0;
            reset_en_wdt_sync      <= 1'b0;

            window_en_meta         <= 1'b0;
            window_en_wdt_sync     <= 1'b0;

            cfg_sync1              <= 1'b0;
            cfg_sync2              <= 1'b0;
            cfg_sync2_d            <= 1'b0;

	    prev_reset_wdt_sync1   <= 1'b0;
	    prev_reset_wdt_sync2   <= 1'b0; 
	    prev_reset_wdt_sync2_d <= 1'b0; 
            

            cpu_dbg_halt_meta      <= 1'b0;
            cpu_dbg_halt_wdt_sync  <= 1'b0;

           // snapshort_toggle_sync1 <= 1'b0;
          //  snapshort_toggle_sync2 <= 1'b0;
          //  snapshort_toggle_sync3 <= 1'b0;

           ctrl_toggle_wdt_sync1   <= 1'b0;
           ctrl_toggle_wdt_sync2   <= 1'b0;
           ctrl_toggle_wdt_sync2_d <= 1'b0;
	
    end
    else begin

           refresh_toggle_sync1   <= refresh_toggle_sync;
           refresh_toggle_sync2   <= refresh_toggle_sync1;
           refresh_toggle_sync2_d <= refresh_toggle_sync2;           

           reset_en_meta          <= reset_en_sync;
           reset_en_wdt_sync      <= reset_en_meta;

           window_en_meta         <= window_en_sync;
           window_en_wdt_sync     <= window_en_meta;
           
           cfg_sync1              <= cfg_toggle_sync;
           cfg_sync2              <= cfg_sync1;
           cfg_sync2_d            <= cfg_sync2;

           prev_reset_wdt_sync1   <= prev_reset_wdt_pcl_sync;
	       prev_reset_wdt_sync2   <= prev_reset_wdt_sync1;
           prev_reset_wdt_sync2_d <= prev_reset_wdt_sync2;

           ctrl_toggle_wdt_sync1   <= ctrl_toggle_sync;
           ctrl_toggle_wdt_sync2   <= ctrl_toggle_wdt_sync1;
           ctrl_toggle_wdt_sync2_d <= ctrl_toggle_wdt_sync2; 

           cpu_dbg_halt_meta      <= cpu_dbg_halt_sync;
           cpu_dbg_halt_wdt_sync  <= cpu_dbg_halt_meta;

         //  snapshort_toggle_sync1  <= snapshort_toggle_sync;
         //  snapshort_toggle_sync2  <= snapshort_toggle_sync1;
         //  snapshort_toggle_sync3  <= snapshort_toggle_sync2;
    
        end   
end

//////////////////////////////////////////////////////////////////////////////

always@(posedge wdt_clk or negedge wdt_rstn) begin
if(!wdt_rstn) begin
    enable_wdt_sync         <= 1'b0;
    dbg_freeze_en_wdt_sync     <= 1'b0;
    end

    else if (ctrl_toggle_pulse) begin
        enable_wdt_sync         <= enable_sync;
        dbg_freeze_en_wdt_sync  <= dbg_freeze_en_sync;
        
        end
end 

///////////////////////////////////////////////////////////////////////////////

always@(posedge wdt_clk or negedge wdt_rstn) begin
    if(!wdt_rstn) begin
            timeout_value_wdt_sync       <= 32'h0000FFFF;
            window_value_wdt_sync        <= 32'h00000000;
            reset_cycles_wdt_sync        <= 16'd32;

        end

        else begin
            if(cfg_update_sync) begin
                timeout_value_wdt_sync   <= timeout_value_sync;
                window_value_wdt_sync    <= window_value_sync;
                reset_cycles_wdt_sync    <= reset_cycles_sync;
                end

            end
end

////////////////////////////////////////////////////////////////////////////

assign refresh_valid_sync = refresh_toggle_sync2 ^ refresh_toggle_sync2_d;

//assign snapshort_wdt_pulse = snapshort_toggle_sync2 ^ snapshort_toggle_sync3;

assign counter_toggle_pulse = counter_toggle_sync2 ^ counter_toggle_sync3;

assign trace_pulse = trace_toggle_sync3 ^ trace_toggle_sync2;

assign cfg_update_sync = cfg_sync2 ^ cfg_sync2_d;

assign prev_reset_wdt_pulse_sync = prev_reset_wdt_sync2 ^ prev_reset_wdt_sync2_d;

assign ctrl_toggle_pulse = ctrl_toggle_wdt_sync2_d ^ ctrl_toggle_wdt_sync2;

assign clr_f1_sync = dly_f1 ^ sync_f1[1];

assign clr_f2_sync = dly_f2 ^ sync_f2[1];

assign clr_f3_sync = dly_f3 ^ sync_f3[1];


endmodule
