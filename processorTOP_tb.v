`timescale 1 ns/100 ps

module processorTOP_tb;

reg clk;
reg reset;


wire [31:0] rom_addr;
wire [31:0] rom_instr;

wire [31:0] RAM_q;
wire [31:0] RAM_data;
wire RAM_wr_en;
wire RAM_rd_en;
wire [31:0] RAM_addr;

wire [1:0] cycle_counter_debug;
wire [31:0] instr_reg_debug;
wire instr_fetch_debug;
wire cycle_ready_debug;
wire pc_en_debug;
wire pc_br_en_debug;

/*
wire [9:0] alu_op_sel_debug;
wire [31:0] alu_A_debug;
wire [31:0] alu_B_debug;

wire rf_write_en_debug;
wire [4:0] rf_write_addr_debug;
wire [4:0] rf_read_1_addr_debug;
wire [4:0] rf_read_2_addr_debug;
wire [31:0] rf_write_data_debug;
*/


Svarog1_Core CORE(

.clk_i(clk),
.reset_i(reset),
.PC_instruction_address_o(rom_addr),
.RAM_q_o(RAM_q),
.RAM_data_o(RAM_data),
.RAM_rd_en_o(RAM_rd_en),
.RAM_wr_en_o(RAM_wr_en),
.RAM_addr_o(RAM_addr),
.ROM_instruction_o(rom_instr),
.cycle_counter_debug_o(cycle_counter_debug),
.instr_reg_debug_o(instr_reg_debug),
.instr_new_fetch_debug_o(instr_fetch_debug),
.cycle_ready_debug_o(cycle_ready_debug),
.pc_br_en_debug_o(pc_br_en_debug),
.pc_en_debug_o(pc_en_debug)/*,

.alu_op_sel_debug_o(alu_op_sel_debug),
.alu_A_debug_o(alu_A_debug),
.alu_B_debug_o(alu_B_debug),
.rf_write_en_debug_o(rf_write_en_debug),
.rf_write_addr_debug_o(rf_write_addr_debug),
.rf_read_1_addr_debug_o(rf_read_1_addr_debug),
.rf_read_2_addr_debug_o(rf_read_2_addr_debug),
.rf_write_data_debug_o(rf_write_data_debug),
*/

);



initial begin

	clk = 1'b0;
	reset = 1'b1;

	#5;
	clk = 1'b1;
	#5;
	reset = 1'b0;
	clk = 1'b0;

	repeat(50)
	begin
		repeat(2)
		begin
			#5;
			clk = !clk;
		end
	end

	
	repeat(8)
	begin
		#5;
		clk = !clk;
	end	

	$stop;

end


endmodule