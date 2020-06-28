/*

	Registers

*/

module registers
#(
parameter DATA_WIDTH=32,
parameter REGISTERS_NUMBER=32,
parameter ADDR_BUS_WIDTH=5
)
(

input clk_i,
input reset_i,

input write_en_i,
input [ADDR_BUS_WIDTH-1:0] write_addr_i,
input [ADDR_BUS_WIDTH-1:0] read_1_addr_i,
input [ADDR_BUS_WIDTH-1:0] read_2_addr_i,
input [DATA_WIDTH-1:0] write_data_i,

output [DATA_WIDTH-1:0] read_1_data_o,
output [DATA_WIDTH-1:0] read_2_data_o

);

wire write_en_int;
reg [DATA_WIDTH-1:0] GPRx[REGISTERS_NUMBER-1:0];


integer cnt;

initial
begin
		for(cnt = 1; cnt < REGISTERS_NUMBER; cnt=cnt+1)
		begin
			GPRx[cnt] = 0;
		end
end

assign read_1_data_o = (read_1_addr_i == 5'b00000) ? 0 : GPRx[read_1_addr_i];
assign read_2_data_o = (read_2_addr_i == 5'b00000) ? 0 : GPRx[read_2_addr_i];
assign write_en_int = (write_addr_i == 5'b00000) ? 0 : write_en_i;

always @(posedge clk_i)
begin
 if(write_en_int)
	begin
			GPRx[write_addr_i] <= write_data_i;
	end
end





endmodule