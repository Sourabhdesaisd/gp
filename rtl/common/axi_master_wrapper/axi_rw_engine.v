module axi_rw_engine
(
	input         clk,
	input         rst_n,

    //core input signals
   
	input  [31:0] req_addr,
	input         req_read_en,
	input         req_write_en,
	input         req_valid,
	input         start_fsm,

	input  [31:0] req_wdata,
	input  [3:0]  req_byte_en,
    
    //core output signals

	output [31:0] read_data,
	output [1:0]  read_resp,
	output [1:0]  write_resp,

	output        read_valid_out,
	output        read_ready_out,
    output        write_valid_out,
	output        write_ready_out,


    //axi signals

	output reg [31:0] axi_awaddr,
	output reg        axi_awvalid,
	input             axi_awready,

	output reg [31:0] axi_wdata,
	output reg [3:0]  axi_wstrb,
	output reg        axi_wvalid,
	input             axi_wready,

	input      [1:0]  axi_bresp,
	input             axi_bvalid,
	output reg        axi_bready,

	output reg [31:0] axi_araddr,
	output reg        axi_arvalid,
	input             axi_arready,

	input      [31:0] axi_rdata,
	input      [1:0]  axi_rresp,
	input             axi_rvalid,
	output reg        axi_rready
);


// FSM State Encoding

localparam IDLE           = 3'd0;
localparam WRITE_REQ      = 3'd1;
localparam WRITE_RESPONSE = 3'd2;
localparam READ_REQ       = 3'd3;
localparam READ_RESPONSE  = 3'd4;
localparam WAIT_STATE        = 3'd5 ;

// Registers

reg [2:0] state;
reg [2:0] next_state;

reg aw_done;
reg w_done;

reg [31:0] addr_reg;
reg [31:0] wdata_reg;
reg [3:0]  be_reg;

// State Register

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;
end


// Request Capture

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		addr_reg  <= 32'd0;
		wdata_reg <= 32'd0;
		be_reg    <= 4'd0;
	end
	else if(state == IDLE && req_valid && start_fsm)
	begin
		addr_reg  <= req_addr;
		wdata_reg <= req_wdata;
		be_reg    <= req_byte_en;
	end
end


// Write Handshake Tracking

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		aw_done <= 1'b0;
		w_done  <= 1'b0;
	end
	else
	begin
		if(state == IDLE)
		begin
			aw_done <= 1'b0;
        	w_done  <= 1'b0;
		end
		else
		begin
			if(axi_awvalid && axi_awready)
				aw_done <= 1'b1;

			if(axi_wvalid && axi_wready)
				w_done <= 1'b1;
		end
	end
end


// Next State Logic

always @(*)
begin
	next_state = state;

case(state)

    IDLE:
    begin

        if(req_valid && start_fsm)
        begin

            if(req_write_en)
                next_state = WRITE_REQ;

            else if(req_read_en)
                next_state = READ_REQ;

        end

    end

    WRITE_REQ:
    begin

        if(aw_done && w_done)
            next_state = WRITE_RESPONSE;

    end

    WRITE_RESPONSE:
    begin

        if(axi_bvalid && axi_bready)
            next_state = WAIT_STATE;

    end

    READ_REQ:
    begin

        if(axi_arvalid && axi_arready)
            next_state = READ_RESPONSE;

    end

    READ_RESPONSE:
    begin

        if(axi_rvalid && axi_rready)
            next_state = WAIT_STATE;

    end

    WAIT_STATE:   
        next_state = IDLE;

    default:
        next_state = IDLE;

endcase

end

// Output Logic

always @(*)
begin
axi_awaddr  = 32'd0;
axi_awvalid = 1'b0;

axi_wdata   = 32'd0;
axi_wstrb   = 4'd0;
axi_wvalid  = 1'b0;

axi_bready  = 1'b0;

axi_araddr  = 32'd0;
axi_arvalid = 1'b0;

axi_rready  = 1'b0;

case(state)

    WRITE_REQ:
    begin

        if(!aw_done)
        begin
            axi_awaddr  = addr_reg;
            axi_awvalid = 1'b1;
        end

        if(!w_done)
        begin
            axi_wdata   = wdata_reg;
            axi_wstrb   = be_reg;
            axi_wvalid  = 1'b1;
        end

    end

    WRITE_RESPONSE:
    begin
        if(axi_bvalid)
        axi_bready = 1'b1;
    end

    READ_REQ:
    begin
        axi_araddr  = addr_reg;
        axi_arvalid = 1'b1;
    end

    READ_RESPONSE:
    begin
        if(axi_rvalid) begin
        axi_rready = 1'b1;
    end
    end

    WAIT_STATE: begin
        axi_awaddr  = 32'd0;
axi_awvalid = 1'b0;

axi_wdata   = 32'd0;
axi_wstrb   = 4'd0;
axi_wvalid  = 1'b0;

axi_bready  = 1'b1;

axi_araddr  = 32'd0;
axi_arvalid = 1'b0;

axi_rready  = 1'b1;
end

endcase

end

// Response Path

assign read_data  = axi_rdata;
assign read_resp  = axi_rresp;
assign write_resp = axi_bresp;

// Transaction Status

assign read_valid_out = (state == READ_RESPONSE)  ? axi_rvalid : 1'b0;

assign read_ready_out = (state == READ_RESPONSE)  ? axi_rready : 1'b0; 

assign write_valid_out = (state == WRITE_RESPONSE) ? axi_bvalid : 1'b0;

assign write_ready_out = (state == WRITE_RESPONSE) ? axi_bready : 1'b0;



endmodule

