
/*

	Svarog-1 Core

*/


module Svarog1_Core #(
parameter DATA_WIDTH=32,
parameter IMMEDIATE_WIDTH=12,
parameter REGISTERS_NUMBER=32,
parameter ADDR_BUS_WIDTH=5,
parameter OP_WIDTH=10
)(

input clk_i,
input reset_i,


output [DATA_WIDTH-1:0] PC_instruction_address_o,

output [DATA_WIDTH-1:0] ROM_instruction_o,

output [DATA_WIDTH-1:0] RAM_q_o,
output [DATA_WIDTH-1:0] RAM_data_o,
output RAM_rd_en_o,
output RAM_wr_en_o,
output [DATA_WIDTH-1:0] RAM_addr_o,


output [1:0] cycle_counter_debug_o,
output [DATA_WIDTH-1:0] instr_reg_debug_o,
output instr_new_fetch_debug_o,
output cycle_ready_debug_o,
output pc_br_en_debug_o,
output pc_en_debug_o
);


wire pc_en;
wire pc_branch_en;
wire [DATA_WIDTH-1:0] pc_instr_addr;
wire [DATA_WIDTH-1:0] ROM_instr;
wire [DATA_WIDTH-1:0] pc_branch_addr;

wire rf_write_en;
wire [ADDR_BUS_WIDTH-1:0] rf_write_addr;
wire [ADDR_BUS_WIDTH-1:0] rf_read_1_addr;
wire [ADDR_BUS_WIDTH-1:0] rf_read_2_addr;
wire [DATA_WIDTH-1:0] rf_write_data;

wire [DATA_WIDTH-1:0] rf_read_1_data;
wire [DATA_WIDTH-1:0] rf_read_2_data;

wire [DATA_WIDTH-1:0] alu_A;
wire [DATA_WIDTH-1:0] alu_B;
wire [OP_WIDTH-1:0] alu_op_sel;

wire [DATA_WIDTH-1:0] alu_res;
wire alu_zero;
wire alu_equal;
wire alu_b_larger;


wire [1:0] dec_br_sel;

wire [DATA_WIDTH-1:0] dec_a_imm;
wire [DATA_WIDTH-1:0] dec_b_imm;

reg [DATA_WIDTH-1:0] b_imm_branch_addr;

wire [1:0] dec_a_sel;
wire [1:0] dec_b_sel;
 
wire [1:0] dec_rf_wr_sel;

wire [DATA_WIDTH-1:0] RAM_q;
wire [DATA_WIDTH-1:0] RAM_data;
wire [DATA_WIDTH-1:0] RAM_addr;
wire RAM_rd_en;
wire RAM_wr_en;


wire [DATA_WIDTH-1:0] extended_branch_imm_addr;
wire [19:0] branch_addr_sign;
wire [IMMEDIATE_WIDTH:0] b_imm_ext;



pc Program_Counter(

.clk_i(clk_i),
.reset_i(reset_i),
.pc_en_i(pc_en),
.branch_en_i(pc_branch_en),
.branch_addr_i(pc_branch_addr),
.instr_addr_o(pc_instr_addr)

);

registers Register_File(

.clk_i(clk_i),
.reset_i(reset_i),
.write_en_i(rf_write_en),
.write_addr_i(rf_write_addr),
.read_1_addr_i(rf_read_1_addr),
.read_2_addr_i(rf_read_2_addr),
.write_data_i(rf_write_data),
.read_1_data_o(rf_read_1_data),
.read_2_data_o(rf_read_2_data)

);

alu ALU(

.clk_i(clk_i),
.reset_i(reset_i),
.A_i(alu_A),
.B_i(alu_B),
.Op_Sel_i(alu_op_sel),
.Res_o(alu_res),
.zero_o(alu_zero),
.b_larger_o(alu_b_larger),
.equal_o(alu_equal)

);

decoder Decoder(

.clk_i(clk_i),
.reset_i(reset_i),
.instr_i(ROM_instr),
.br_cond_equal_i(alu_equal),
.br_cond_b_larger_i(alu_b_larger),
.br_cond_zero_i(alu_zero),
.pc_ready_o(pc_en),
.br_en_o(pc_branch_en),
.br_sel_o(dec_br_sel),
.alu_a_imm_o(dec_a_imm),
.alu_b_imm_o(dec_b_imm),
.alu_a_sel_o(dec_a_sel),
.alu_b_sel_o(dec_b_sel),
.alu_op_sel_o(alu_op_sel),
.rf_wr_sel_o(dec_rf_wr_sel),
.rf_wr_en(rf_write_en),
.rf_rd_a_addr_o(rf_read_1_addr),
.rf_rd_b_addr_o(rf_read_2_addr),
.rf_wr_addr_o(rf_write_addr),
.RAM_wr_en_o(RAM_wr_en),
.RAM_rd_en_o(RAM_rd_en),
.cycle_counter_debug_o(cycle_counter_debug_o),
.instr_reg_debug_o(instr_reg_debug_o),
.instr_new_fetch_debug_o(instr_new_fetch_debug_o),
.cycle_ready_debug_o(cycle_ready_debug_o)

);

Mux_4_to_1 Mux_A(

.data0_i(rf_read_1_data),
.data1_i(dec_a_imm),
.data2_i(pc_instr_addr),
.data3_i(0),
.select_i(dec_a_sel),
.data_o(alu_A)

);

Mux_4_to_1 Mux_B(

.data0_i(rf_read_2_data),
.data1_i(dec_b_imm),
.data2_i(pc_instr_addr),
.data3_i(0),
.select_i(dec_b_sel),
.data_o(alu_B)

);

Mux_4_to_1 Mux_Writeback(

.data0_i(alu_res),
.data1_i(RAM_q),
.data2_i(pc_instr_addr),
.data3_i(0),
.select_i(dec_rf_wr_sel),
.data_o(rf_write_data)

);

Mux_4_to_1 Mux_Branch(
.data0_i(alu_res),
.data1_i(RAM_q),
.data2_i(extended_branch_imm_addr),
.data3_i(0),
.select_i(dec_br_sel),
.data_o(pc_branch_addr)
);

InstrMem ROM1(
.address(pc_instr_addr>>2),
.clock(!clk_i),
.q(ROM_instr)
);

DataMem RAM1(
.address(RAM_addr),
.clock(!clk_i),
.data(RAM_data),
.rden(RAM_rd_en),
.wren(RAM_wr_en),
.q(RAM_q)
);




assign b_imm_ext = dec_b_imm<<1;
assign branch_addr_sign = {20{b_imm_ext[12]}};
assign extended_branch_imm_addr = {branch_addr_sign, (b_imm_ext[11:0])};

assign RAM_data = rf_read_2_data;
assign RAM_addr = alu_res;

assign RAM_data_o = RAM_data;
assign RAM_addr_o = RAM_addr;
assign RAM_rd_en_o = RAM_rd_en;
assign RAM_wr_en_o = RAM_wr_en;
assign RAM_q_o = RAM_q;

assign PC_instruction_address_o = pc_instr_addr;

assign ROM_instruction_o = ROM_instr;

assign pc_en_debug_o = pc_en;
assign pc_br_en_debug_o = pc_branch_en;





endmodule