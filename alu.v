
/*

	ALU

*/

module alu #(

parameter DATA_WIDTH=32,
parameter ADDR_BUS_WIDTH=5,
parameter OP_WIDTH=10

)(

input clk_i,
input reset_i,

input [DATA_WIDTH-1:0] A_i,
input [DATA_WIDTH-1:0] B_i,
input [OP_WIDTH-1:0] Op_Sel_i,

output reg [DATA_WIDTH-1:0] Res_o,
output reg zero_o,
output reg b_larger_o,
output reg equal_o

);

always @(*)
begin
	case(Op_Sel_i)

		//OP: 7bits of funct7 and 3 bits of funct3

		10'b0000000000: Res_o = A_i + B_i; //ADD 
		10'b0100000000: Res_o = A_i - B_i; //SUB
		10'b0000000001: Res_o = A_i << B_i; //SLL
		10'b0000000010: //SLT
			begin
				if($signed(A_i) < $signed(B_i)) Res_o = 1;
				else Res_o = 0;
			end 
		10'b0000000011: //SLTU
			begin
				if(A_i < B_i) Res_o = 1;
				else Res_o = 0;
			end
		10'b0000000100: Res_o = A_i ^ B_i; //XOR
		10'b0000000101: Res_o = A_i >> B_i;//SRL
		10'b1000000101: Res_o = A_i >>> B_i; //SRA
		10'b0000000110: Res_o = A_i | B_i; //OR
		10'b0000000111: Res_o = A_i & B_i; //AND
		default: 		Res_o = 0;

	endcase
	
	if(Res_o == 0) zero_o = 1'b1;
	else zero_o = 1'b0;
	
	if(B_i > A_i) b_larger_o = 1'b1;
	else b_larger_o = 1'b0;
	
	if(A_i == B_i) equal_o = 1'b1;
	else equal_o = 1'b0;
	
end



endmodule