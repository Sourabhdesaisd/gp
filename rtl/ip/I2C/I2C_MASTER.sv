/////////// Master
 
//`timescale 1ns / 1ps
 
module i2c_master( input clk, rst , newd,
input [6:0] addr,
input op,//1-r
inout sda,
output scl,
input [7:0] din,
output [7:0] dout,
output reg busy, ack_err//, done
);
 
reg scl_t ;
reg sda_t ;


parameter sys_freq = 40000000; //40 MHz
parameter i2c_freq = 100000;  //// 100k
 
 
parameter  clk_count4 = (sys_freq/i2c_freq);/// 400
parameter clk_count1 = clk_count4/4; ///100
 
reg[8:0] count1 ;

localparam logic [8:0] CLK1 = 9'(clk_count1 - 9'd1);
localparam logic [8:0] CLK2 = 9'(clk_count1*2 - 9'd1);
localparam logic [8:0] CLK3 = 9'(clk_count1*3 - 9'd1);
localparam logic [8:0] CLK4 = 9'(clk_count1*4 - 9'd1);

//parameter integer CLK4_MAX = clk_count
///////4x clock
reg [1:0] pulse;

always@(posedge clk  )
begin
      if(rst)
       begin
       pulse <= 2'd0;
       count1 <= 9'd0;
       end
       else if (busy == 1'b0) ///pulse count start only after newd
        begin
        pulse <= 2'd0;
        count1 <= 9'd0;
        end
      else if(count1  == CLK1)
       begin
       pulse <= 2'd1;
       count1 <= 9'(count1 + 9'd1);
       end
      else if(count1  == CLK2)
       begin
       pulse <= 2'd2;
       count1 <= count1 + 9'd1;
       end
      else if(count1  == CLK3)
       begin
       pulse <= 2'd3;
       count1 <= count1 + 9'd1;
       end
      else if(count1  == CLK4)
       begin
       pulse <= 2'd0;
       count1 <= 9'd0;
       end
      else
       begin
       count1 <= count1 + 9'd1;
       end
end



 
//////////////////
reg [3:0] bitcount ;
reg [7:0] data_addr , data_tx ;
reg r_ack ;
reg [7:0] rx_data ;
reg sda_en ;
 
 
typedef enum logic [3:0] {idle = 0, start = 1, write_addr = 2, ack_1 = 3, write_data = 4, read_data = 5, stop_1 = 6, ack_2 =7, master_ack = 8} state_type;
state_type state ;
 
always@(posedge clk)
begin
 if(rst)
   begin
    bitcount   <= 4'd0;
    data_addr  <= 8'd0;
    data_tx    <= 8'd0;
    scl_t <= 1'd1;
    sda_t <= 1'd1;
    state <= idle;
    busy  <= 1'b0;
    ack_err <= 1'b0;
    //done    <= 1'b0;
    rx_data <= 8'd0;

   end
else
   begin
                case(state)
                
                //////////////idle state
                      idle:
                      begin
                                                      
                           // done  <= 1'b0;
                            if(newd == 1'b1)
                               begin
                              // scl_t <= 1'b1;
                               data_addr  <= {addr,op};
                               data_tx    <= din;
                               busy  <= 1'b1;
                               state <= start;
                               ack_err <= 1'b0;
                               end
                            else
                               begin
                             //  scl_t <= 1'b1;
                               data_addr  <= 8'd0;
                               data_tx    <= 8'd0;
                               busy  <= 1'b0;
                               state <= idle;
                               ack_err <= 1'b0;
                               end
                      end
                  /////////////////////////////////////////////////////    
                     start: 
                     begin
                         sda_en <= 1'b1; ///send start to slave
                         case(pulse)
                         2'd0: begin scl_t <= 1'b1; sda_t <= 1'b1; end
                         2'd1: begin scl_t <= 1'b1; sda_t <= 1'b1; end
                         2'd2: begin scl_t <= 1'b1; sda_t <= 1'b0; end
                         2'd3: begin scl_t <= 1'b1; sda_t <= 1'b0; end
			 endcase
                         
                             if(count1  == CLK4)
                             begin
                                state <= write_addr;
                                scl_t <= 1'b0;
                             end
                             else
                                state <= start;
                     end
                 ///////////////////////////////////////////     
                   write_addr: 
                   begin
                      sda_en <= 1'b1;  ///send addr to slave
                      if(bitcount <= 4'd7 )
                         begin
                                 case(pulse)
                                 2'd0: begin scl_t <= 1'b0; end //sda_t <= 1'b0; end
                                 2'd1: begin scl_t <= 1'b0;
					case(bitcount)
					4'd0: sda_t <= data_addr[7];
       					4'd1: sda_t <= data_addr[6];
      					4'd2: sda_t <= data_addr[5];
       					4'd3: sda_t <= data_addr[4];
      				        4'd4: sda_t <= data_addr[3];
     					4'd5: sda_t <= data_addr[2];
       					4'd6: sda_t <= data_addr[1];
       					4'd7: sda_t <= data_addr[0];
       					default: sda_t <= 1'b0;
     					endcase
  				  end
                                 2'd2: begin scl_t <= 1'b1;  end
                                 2'd3: begin scl_t <= 1'b1;  end
                                 endcase
                                 if(count1  == CLK4 )
                                 begin
                                    state <= write_addr;
                                    scl_t <= 1'b0;
                                    bitcount <= bitcount + 4'd1;
                                 end
                                 else
                                 begin
                                    state <= write_addr;
                                 end
                             
                         end
                      else
                        begin
                        state <= ack_1;
                        bitcount <= 4'b0;
                        sda_en <= 1'b0;
                        end
                   end   
                   
                   
                   //////////////////////////////////////
                   
                   ack_1 : 
                   begin
                        sda_en <= 1'b0; ///recv ack from slave
                                case(pulse)
                                 2'd0: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                                 2'd1: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                                 2'd2: begin scl_t <= 1'b1; sda_t <= 1'b0; r_ack <= sda; end //r_ack <= 1'b0; end 			// ///recv ack from slave
                                 2'd3: begin scl_t <= 1'b1;  end
                                 endcase
                   
                       if(count1  == CLK4 )
                                  begin
                                      if(r_ack == 1'b0 && data_addr[0] == 1'b0)
                                        begin
                                        state <= write_data;
                                        sda_t <= 1'b0;
                                        sda_en <= 1'b1; /////write data to slave
                                        bitcount <= 4'd0;
                                        scl_t <= 1'b0;
                                        end
                                      else if (r_ack == 1'b0 && data_addr[0] == 1'b1)
                                      begin
                                        state <= read_data;
                                        sda_t <= 1'b1;
                                        sda_en <= 1'b0; ///read data from slave
                                        bitcount <= 4'd0;
                                        scl_t <= 1'b0;
                                      end
                                      else
                                      begin
                                        state <= stop_1;
                                        sda_en <= 1'b1; ////send stop_1 to slave
                                        ack_err <= 1'b1;
                                        scl_t <= 1'b0;
                                      end
                                  end
                                 else
                                  begin
                                    state <= ack_1;
                                  end
                     
                   end
                   
                 write_data: 
                 begin
                   ///write data to slave
                  if(bitcount <= 4'd7)
                         begin
                                 case(pulse)
                                 2'd0: begin scl_t <= 1'b0;   end
                            //     2'd1: begin scl_t <= 1'b0;sda_en <= 1'b1; sda_t <= data_tx[3'd7 - bitcount];end

				2'd1:  begin scl_t <= 1'b0;
					case(bitcount)
					4'd0: sda_t <= data_tx[7];
       					4'd1: sda_t <= data_tx[6];
      					4'd2: sda_t <= data_tx[5];
       					4'd3: sda_t <= data_tx[4];
      				        4'd4: sda_t <= data_tx[3];
     					4'd5: sda_t <= data_tx[2];
       					4'd6: sda_t <= data_tx[1];
       					4'd7: sda_t <= data_tx[0];
       					default: sda_t <= 1'b0;
     					endcase
  				  end
				

                                 2'd2: begin scl_t <= 1'b1;  end
                                 2'd3: begin scl_t <= 1'b1;  end
                                 endcase
                                 if(count1  == CLK4 )
                                 begin
                                    state <= write_data;
                                    scl_t <= 1'b0;
                                    bitcount <= bitcount + 4'd1;
                                 end
                                 else
                                 begin
                                    state <= write_data;
                                 end
                             
                         end
                      else
                        begin
                        state <= ack_2;
                        bitcount <= 4'd0;
                        sda_en <= 1'b0; ///read from slave
                        end
                 
                 
                 end 
                 ///////////////////////////// read_data
                 
                 read_data: 
                 begin
                 sda_en <= 1'b0; ///read from slave
                 if(bitcount <= 4'd7)
                         begin
                                 case(pulse)
                                 2'd0: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                                 2'd1: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                                 2'd2: begin scl_t <= 1'b1; rx_data[7:0] <= (count1 == 9'd200) ? {rx_data[6:0],sda} : rx_data; end
                                 2'd3: begin scl_t <= 1'b1;  end
                                 endcase
                                 if(count1  == CLK4 )
                                 begin
                                    state <= read_data;
                                    scl_t <= 1'b0;
                                    bitcount <= bitcount + 4'd1;
                                 end
                                 else
                                 begin
                                    state <= read_data;
                                 end
                             
                         end
                      else
                        begin
                        state <= master_ack;
                        bitcount <= 4'd0;
                        sda_t <= 1'b1;
                        sda_en <= 1'b1; ///master will send ack to slave
                        end
                 
                 
                 
                 end
                 ////////////////////master ack -> send nack
                 master_ack : 
                   begin
                      sda_en <= 1'b1;
                      
                                case(pulse)
                                 2'd0: begin scl_t <= 1'b0; sda_t <= 1'b1; end
                                 2'd1: begin scl_t <= 1'b0; sda_t <= 1'b1; end
                                 2'd2: begin scl_t <= 1'b1; sda_t <= 1'b1; end 
                                 2'd3: begin scl_t <= 1'b1; sda_t <= 1'b1; end
                                 endcase
                   
                       if(count1  == CLK4 )
                                  begin
                                      sda_t <= 1'b0;
                                      state <= stop_1;
                                      scl_t <= 1'b0;
                                      sda_en <= 1'b1; ///send stop_1 to slave
                                      
                                  end
                                 else
                                  begin
                                    state <= master_ack;
                                  end
                     
                   end
                 
                 
                 
                 /////////////////ack 2
                 
                  ack_2 : 
                   begin
                     sda_en <= 1'b0; ///recv ack from slave
                                case(pulse)
                                 2'd0: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                                 2'd1: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                                 2'd2: begin scl_t <= 1'b1; sda_t <= 1'b0; r_ack <= sda; end //r_ack <= 1'b0; end 				// ///recv ack from slave  
                                 2'd3: begin scl_t <= 1'b1;  end
                                 endcase
                   
                       if(count1  == CLK4 )
                                  begin
                                      sda_t <= 1'b0;
                                      sda_en <= 1'b1; ///send stop_1 to slave
                                      scl_t <= 1'b0;
                                      if(r_ack == 1'b0 )
                                        begin
                                        state <= stop_1;
                                        ack_err <= 1'b0;
                                        end
                                      else
                                        begin
                                        state <= stop_1;
                                        ack_err <= 1'b1;
                                        end
                                  end
                                 else
                                  begin
                                    state <= ack_2;
                                  end
                     
                   end
 
                /////////////////////////////////////////////stop_1  
                   stop_1: 
                     begin
                    // sda_en <= 1'b1; ///send stop_1 to slave
                         case(pulse)
                         2'd0: begin scl_t <= 1'b0; sda_t <= 1'b0; end
                         2'd1: begin scl_t <= 1'b1; sda_t <= 1'b0; end
                         2'd2: begin scl_t <= 1'b1; sda_t <= 1'b1; end
                         2'd3: begin scl_t <= 1'b1; sda_t <= 1'b1; end
                         endcase
                         
                             if(count1  == CLK4 )
                             begin
                                state <= idle;
                                //scl_t <= 1'b0;
                                busy <= 1'b0;
                                sda_en <= 1'b1; ///send start to slave
                             //   done   <= 1'b1;
                             end
                             else
                                state <= stop_1;
                     end
                     
                     //////////////////////////////////////////////
                      
                 default : state <= idle;
               endcase
   end
end
 
assign sda = (sda_en == 1'b1) ? (sda_t == 1'b0) ? 1'b0 : 1'bz : 1'bz; /// en = 1 -> write to slave else read///////////////////////////////changes 1 


assign scl = scl_t;
assign dout = rx_data;
endmodule
 

