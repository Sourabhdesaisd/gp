module		write_stage_register 	(

input clk ,
input rst ,

input 	EXE_WR_write_en_reg ,
input 	[4:0] 	EXE_WR_rd_address ,
input 	[31:0] 	EXE_WR_data_in_for_reg ,

output 	reg	write_stage_write_en_reg ,
output 	reg	[4:0]	write_stage_rd_address ,
output	reg	[31:0]	write_stage_data_in_for_reg 

) ;


always@(posedge clk or posedge rst)
begin

if(rst)
begin

write_stage_write_en_reg <= 1'd0 ;
write_stage_rd_address 	<= 5'd0 ;
write_stage_data_in_for_reg	<= 32'd0 ;

end

else
begin

write_stage_write_en_reg <= EXE_WR_write_en_reg ;
write_stage_rd_address 	<= EXE_WR_rd_address ;
write_stage_data_in_for_reg	<= EXE_WR_data_in_for_reg ;

end

end


endmodule

