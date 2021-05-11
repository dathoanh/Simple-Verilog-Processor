module part2_onBoard(SW, KEY, LEDR, LEDG, HEX0, HEX1, HEX2, HEX4, HEX5, HEX6);
	input [9:0]SW;
	input [3:0]KEY;
	output [17:0]LEDR;
	output [8:0]LEDG;
	output [6:0]HEX0, HEX1, HEX2, HEX4, HEX5, HEX6;
	
	wire [8:0]buswires;
	
//	part2 part2_inst(.Resetn(KEY[0]), .Run(SW[9]), .MClock(KEY[1]), .PClock(KEY[2]), .BusWires(buswires), .Done(LEDR[9]));

	wire Resetn, Run, MClock, PClock, RegClock;
	wire Done;
	wire [4:0]RegAddr;
	wire [8:0]Data, R0, R1, R2, R3, R4, R5, R6, R7;
	reg [8:0]RegData;
	reg [2:0]RegCount;
	
	assign Resetn = KEY[0];
	assign Run = SW[9];
	assign MClock = KEY[1];
	assign PClock = KEY[2];
	assign LEDG[8] = Done;
	assign LEDR[8:0] = Data;
	assign LEDG[7:3] = RegAddr;
	assign RegClock = KEY[3];
	assign LEDR[17:15] = RegCount;
	
	always@(posedge RegClock)
		RegCount <= RegCount + 1;
	
	upcount counter(.Resetn(Resetn), .Clock(MClock), .Q(RegAddr));
//	ROM_IPCatalog rom_mem (.address(RegAddr), .clock(MClock), .q(Data));
	ROM_Memory rom_mem (.addr(RegAddr), .clk(MClock), .data(Data));
	
	processor proc (.DIN(Data), .Resetn(Resetn), .Clock(PClock), .Run(Run), .BusWires(buswires), .Done(Done), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7));
	
	always@(RegCount, R0, R1, R2, R3, R4, R5, R6, R7)
	begin
		case(RegCount)
			3'b000: RegData = R0;
			3'b001: RegData = R1;
			3'b010: RegData = R2;
			3'b011: RegData = R3;
			3'b100: RegData = R4;
			3'b101: RegData = R5;
			3'b110: RegData = R6;
			3'b111: RegData = R7;
		endcase
	end
	
	seven_segment_led_4bit char7seg_buswires0(.BCD(buswires[3:0]), .display(HEX0));
	seven_segment_led_4bit char7seg_buswires1(.BCD(buswires[7:4]), .display(HEX1));
	seven_segment_led_4bit char7seg_buswires2(.BCD(buswires[8]), .display(HEX2));
	
	seven_segment_led_4bit char7seg_regdata0(.BCD(RegData[3:0]), .display(HEX4));
	seven_segment_led_4bit char7seg_regdata1(.BCD(RegData[7:4]), .display(HEX5));
	seven_segment_led_4bit char7seg_regdata2(.BCD(RegData[8]), .display(HEX6));
	
endmodule
