module ROM_Memory(addr, clk, data);
	input[4:0]addr;
	input clk;
	output reg [8:0]data;
	
	(*ram_init_file = "inst_mem.mif"*)reg[8:0]mem[0:32];
	
	always@(posedge clk)
		data <= mem[addr];
		
endmodule

		