
/*

	Decoder

*/

module decoder #(

parameter DATA_WIDTH=32,
parameter IMMEDIATE_WIDTH=12,
parameter INSTR_WIDTH=32,
parameter RF_ADDR_BUS_WIDTH=5,
parameter ALU_OP_WIDTH=10


)(

input clk_i,
input reset_i,


//Instruction from ROM
input [INSTR_WIDTH-1:0] instr_i,

//Branch condition on comparison from CSR
input br_cond_equal_i,
input br_cond_b_larger_i,
input br_cond_zero_i,

//PC control signals
output reg pc_ready_o,
output reg br_en_o,

//PC branch addres MUX
output reg [1:0] br_sel_o,

//ALU immediate operands
output reg [DATA_WIDTH-1:0] alu_a_imm_o,
output reg [DATA_WIDTH-1:0] alu_b_imm_o,

//ALU operands MUX
output reg [1:0] alu_a_sel_o,
output reg [1:0] alu_b_sel_o,

//ALU operation 
output reg [ALU_OP_WIDTH-1:0] alu_op_sel_o,

//Register file data write MUX
output reg [1:0] rf_wr_sel_o,

//Register file control signals
output reg rf_wr_en,
output reg [RF_ADDR_BUS_WIDTH-1:0] rf_rd_a_addr_o,
output reg [RF_ADDR_BUS_WIDTH-1:0] rf_rd_b_addr_o,
output reg [RF_ADDR_BUS_WIDTH-1:0] rf_wr_addr_o,

//RAM control signals
output reg RAM_wr_en_o,
output reg RAM_rd_en_o,

output reg [1:0] cycle_counter_debug_o,
output reg [DATA_WIDTH-1:0] instr_reg_debug_o,
output reg instr_new_fetch_debug_o,
output reg cycle_ready_debug_o

	
);

reg [1:0] cycle_counter;
reg [DATA_WIDTH-1:0] instr_reg;

reg instr_new_fetch;
reg cycle_ready;

always @(*)
begin
	
	case(instr_reg[6:0])
	
		//LUI
		7'b0110111: 
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = instr_reg[31:12]<<12;
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b01; //B-immediate
			
			alu_op_sel_o = 0;
			
			rf_rd_a_addr_o = 0; //x0
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = instr_reg[11:7]; 
			
			br_sel_o = 2'b00; //ALU Res
			
			
			RAM_wr_en_o = 1'b0;
			RAM_rd_en_o = 1'b0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
				
			
			end
			2'b01:
			begin
				
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end

			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end
			
			endcase		
		end		
		//AUIPC
		7'b0010111:
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = instr_reg[31:12]<<12;
			
			alu_a_sel_o = 2'b10; //A-PC
			alu_b_sel_o = 2'b01; //B-immediate
			
			alu_op_sel_o = 0;
			
			rf_rd_a_addr_o = 0; //x0
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = instr_reg[11:7]; 
			
			br_sel_o = 2'b00; //ALU Res
			
			
			RAM_wr_en_o = 1'b0;
			RAM_rd_en_o = 1'b0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
				
			
			end
			2'b01:
			begin
				
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end

			default:
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
				
			end
			
			endcase		
		end			
		//JAL
		7'b1101111:
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = {instr_reg[31], instr_reg[19:12], instr_reg[20], instr_reg[30:21]}<<1;
			
			alu_a_sel_o = 2'b10; //A-PC
			alu_b_sel_o = 2'b01; //B-immediate
			
			alu_op_sel_o = 0;
			
			rf_rd_a_addr_o = 0; 
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = instr_reg[11:7]; 
			
			br_sel_o = 2'b00; //ALU Res
			
			
			RAM_wr_en_o = 1'b0;
			RAM_rd_en_o = 1'b0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b1;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
				
			
			end
			2'b01:
			begin
				
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end

			default:
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end			
			
			endcase		
		end		
		//JALR
		7'b1100111:
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = instr_reg[31:20];
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b01; //B-immediate
			
			alu_op_sel_o = instr_reg[14:12];
			
			rf_rd_a_addr_o = instr_reg[19:15]; //rs1 - A
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b10; //Wr-PC
			rf_wr_addr_o = instr_reg[11:7]; 
			
			br_sel_o = 2'b00; //ALU Res
			
			
			RAM_wr_en_o = 1'b0;
			RAM_rd_en_o = 1'b0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b1;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
				
			
			end
			2'b01:
			begin
				
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end

			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end			
			endcase		
		end		
				
		
		
		//B-Type
		7'b1100011:
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = {instr_reg[31],instr_reg[7], instr_reg[30:25], instr_reg[11:8]};
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b00; //B-rs2
			
			alu_op_sel_o = 0;
			
			rf_rd_a_addr_o = instr_reg[19:15]; //rs1 - A
			rf_rd_b_addr_o = instr_reg[24:20]; //rs2 - B
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = 0; 
			
			br_sel_o = 2'b10; //Sign-extended immediate
			
			RAM_wr_en_o = 0;
			RAM_rd_en_o = 0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				
				case(instr_reg[14:12])
				
				3'b000: //BEQ
				begin
						if(br_cond_equal_i == 1'b1) br_en_o = 1'b1;
						else br_en_o = 1'b0;
				end
				
				3'b001: //BNE
				begin
						if(br_cond_equal_i == 1'b1) br_en_o = 1'b0;
						else br_en_o = 1'b1;
				end
				
				3'b100: //BLT 
				begin
						if(br_cond_b_larger_i == 1'b1) br_en_o = 1'b1;
						else br_en_o = 1'b0;
				end
				
				3'b110: //ADD BLTU
				begin
					br_en_o = 1'b0;
				end
				
				3'b101: //BGE
				begin
					if((br_cond_b_larger_i == 1'b0) || (br_cond_equal_i == 1'b1)) br_en_o = 1'b1;
					else br_en_o = 1'b0;
				end
				
				3'b111://ADD BGEU
				begin
					br_en_o = 1'b0;
				end
				
				endcase

				pc_ready_o = 1'b1;
				
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
				
			
			end
			2'b01:
			begin
				
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end

			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end			
			endcase		
		end		
		
		//Load
		7'b0000011:
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = instr_reg[31:20];
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b01; //B-Immediate
			
			alu_op_sel_o = 3'b000; //Add - I have to distinguish between LW, LH, LB
			
			rf_rd_a_addr_o = instr_reg[19:15]; //rs1 - base addres
			rf_rd_b_addr_o = 0; 
			rf_wr_sel_o = 2'b01; //Wr-MEM
			rf_wr_addr_o = instr_reg[11:7]; 
			
			br_sel_o = 2'b00; 
			
			RAM_wr_en_o = 0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				RAM_rd_en_o = 1'b1;
				cycle_ready = 1'b0;	
				
			
			end
			2'b01:
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				RAM_rd_en_o = 1'b0;
				cycle_ready = 1'b1;	
				
			end

			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				RAM_rd_en_o = 1'b0;
				
			end
			endcase		
		end
		
		//Store
		7'b0100011:
		begin
			alu_a_imm_o = 0;
			alu_b_imm_o = {instr_reg[31:25], instr_reg[11:7]};
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b01; //B-Immediate
			
			alu_op_sel_o = 3'b000; //Add - I have to distinguish between SW, SH, SB
			
			rf_rd_a_addr_o = instr_reg[19:15]; //rs1 - base addres
			rf_rd_b_addr_o = instr_reg[24:20]; //rs2 - data to write
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = 0;
			
			br_sel_o = 2'b00;
			
			RAM_rd_en_o = 0;

		
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				RAM_wr_en_o = 1'b1;
				cycle_ready = 1'b0;	
			
			end
			2'b01:
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				RAM_wr_en_o = 1'b0;
				cycle_ready = 1'b1;	
				
			end

			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				RAM_wr_en_o = 1'b0;
				
			end
			endcase		
		end	
		//I-type
		7'b0010011:
		begin
			
			alu_a_imm_o = 0;
			alu_b_imm_o = instr_reg[31:20];
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b01; //B-immediate
			
			if(instr_reg[14:12] == 3'b101) alu_op_sel_o = {7'b010000,instr_reg[14:12]}; //SRAI
			else alu_op_sel_o = {7'b000000,instr_reg[14:12]};
			
			rf_rd_a_addr_o = instr_reg[19:15];
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = instr_reg[11:7];
			
			br_sel_o = 2'b00;
			br_en_o = 1'b0;
			
			RAM_rd_en_o = 1'b0;
			RAM_wr_en_o = 1'b0;
			
			case(cycle_counter)
			
			2'b00: 
			begin
			
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
			
			end
			2'b01:
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end	
			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end
			endcase
						
			
			
		end
		//R-type
		7'b0110011:
		begin
		
			alu_a_imm_o = 0;
			alu_b_imm_o = 0;
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b00; //B-rs2
			
			alu_op_sel_o = {instr_reg[31:25], instr_reg[14:12]};
			
			rf_rd_a_addr_o = instr_reg[19:15];
			rf_rd_b_addr_o = instr_reg[24:20];
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = instr_reg[11:7];
			
			br_sel_o = 2'b00;
			
			RAM_rd_en_o = 1'b0;
			RAM_wr_en_o = 1'b0;
			
			case(cycle_counter)
			
			2'b00: 
			begin
				
				rf_wr_en = 1'b1;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
			
			end
			2'b01:
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end	
			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end
			endcase
			
		end
		//Fence
		7'b0001111:
		begin
		
			alu_a_imm_o = 0;
			alu_b_imm_o = 0;
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b00; //B-rs2
			
			alu_op_sel_o = instr_reg[14:12];
			
			rf_rd_a_addr_o = 0;
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = 0;
			
			br_sel_o = 2'b00;
			
			RAM_rd_en_o = 1'b0;
			RAM_wr_en_o = 1'b0;
			
			case(cycle_counter)
			
			2'b00: 
			begin
				
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
			
			end
			2'b01: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end	
			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end
			endcase
		end
		
		//Ecall,Ebreak
		7'b1110011:
		begin
		
			alu_a_imm_o = 0;
			alu_b_imm_o = 0;
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b00; //B-rs2
			
			alu_op_sel_o = instr_reg[14:12];
			
			rf_rd_a_addr_o = 0;
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = 0;
			
			br_sel_o = 2'b00;
			
			RAM_rd_en_o = 1'b0;
			RAM_wr_en_o = 1'b0;
			
			case(cycle_counter)
			
			2'b00: 
			begin
				
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
			
			end
			2'b01: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end	
			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end
			endcase
		end

		default:
		begin
		
			alu_a_imm_o = 0;
			alu_b_imm_o = 0;
			
			alu_a_sel_o = 2'b00; //A-rs1
			alu_b_sel_o = 2'b00; //B-rs2
			
			alu_op_sel_o = instr_reg[14:12];
			
			rf_rd_a_addr_o = 0;
			rf_rd_b_addr_o = 0;
			rf_wr_sel_o = 2'b00; //Wr-ALU
			rf_wr_addr_o = 0;
			
			br_sel_o = 2'b00;
			
			RAM_rd_en_o = 1'b0;
			RAM_wr_en_o = 1'b0;
			
			case(cycle_counter)
			
			2'b00: 
			begin
				
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b0;
				cycle_ready = 1'b0;	
			
			end
			2'b01: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b1;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end	
			default: 
			begin
			
				rf_wr_en = 1'b0;
				br_en_o = 1'b0;
				pc_ready_o = 1'b0;
				instr_new_fetch = 1'b1;
				cycle_ready = 1'b1;	
				
			end			

			endcase
		end
		
	
	endcase
	
	instr_reg_debug_o = instr_reg;
	cycle_counter_debug_o = cycle_counter;
	cycle_ready_debug_o = cycle_ready;
	instr_new_fetch_debug_o = instr_new_fetch;
	
end


always @(posedge clk_i or posedge reset_i)
begin

	if(reset_i) cycle_counter = 2'b11;
	else
	begin
		if(cycle_ready == 0) cycle_counter = cycle_counter + 1;
		else cycle_counter = 2'b00;
		
		if(instr_new_fetch == 1'b1) instr_reg <= instr_i;
	
	end
end


endmodule