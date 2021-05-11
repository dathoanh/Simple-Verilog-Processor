module part2 (Resetn, Run, MClock, PClock, BusWires, Done, RegAddr, R0, R1, R2, R3, R4, R5, R6, R7, Data);
	input Resetn, Run, MClock, PClock;
	output [8:0]BusWires, R0, R1, R2, R3, R4, R5, R6, R7;
	output Done;
	
	output [4:0]RegAddr;
	output [8:0]Data;
	
//	upcount counter(.Resetn(Resetn), .Clock(MClock), .Q(RegAddr));
////	ROM_IPCatalog rom_mem (.address(RegAddr), .clock(MClock), .q(Data));
//	ROM_Memory rom_mem (.addr(RegAddr), .clk(MClock), .data(Data));
//	
//	processor proc (.DIN(Data), .Resetn(Resetn), .Clock(PClock), .Run(Run), .BusWires(BusWires), .Done(Done));

	upcount counter(.Resetn(Resetn), .Clock(MClock), .Q(RegAddr));
//	ROM_IPCatalog rom_mem (.address(RegAddr), .clock(MClock), .q(Data));
	ROM_Memory rom_mem (.addr(RegAddr), .clk(MClock), .data(Data));
	
	processor proc (.DIN(Data), .Resetn(Resetn), .Clock(PClock), .Run(Run), .BusWires(BusWires), .Done(Done), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7));
	
endmodule	