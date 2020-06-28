/*

	Program Counter

*/


module pc #(
parameter DATA_WIDTH=32
)
(

input	clk_i,
input	reset_i,

input pc_en_i,
input	branch_en_i,			//0-no branch PC<-PC+4, 1-branch PC<-PC+branch_addr_i
input	[31:0]	branch_addr_i,

output reg [31:0] instr_addr_o


);


initial
begin
	instr_addr_o = 0;
end

always @(posedge clk_i)
begin
	if(reset_i == 1'b1)
	begin
		instr_addr_o <= 0;
	end
	else
		if(pc_en_i == 1'b1)
		begin
			
			if(branch_en_i == 1'b1) instr_addr_o <= instr_addr_o + branch_addr_i;
			else instr_addr_o <= instr_addr_o + 4;
		
		end	
		else instr_addr_o <= instr_addr_o;
		 
		
end

endmodule