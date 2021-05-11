module part1_onBoard(SW, KEY, LEDR, LEDG, HEX0, HEX1, HEX2, HEX4, HEX5, HEX6);
	input [9:0]SW;
	input [3:0]KEY;
	output [17:0]LEDR;
	output [8:0]LEDG;
	output [6:0]HEX0, HEX1, HEX2, HEX4, HEX5, HEX6;
	
	wire [8:0]buswires, R0, R1, R2, R3, R4, R5, R6, R7;
	wire regClock;
	reg [2:0]count;
	reg [8:0]data;
	
	assign regClock = KEY[2];
	assign LEDR[8:0] = buswires;
	assign LEDR[17:15] = count;
	
	always@(posedge regClock)
		count <= count + 1;
	
	part1_process part1(.DIN(SW[8:0]), .Resetn(KEY[0]), .Clock(KEY[1]), .Run(SW[9]), .Done(LEDG[8]), .BusWires(buswires), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7));
	seven_segment_led_4bit char7seg_buswires0(.BCD(buswires[3:0]), .display(HEX0));
	seven_segment_led_4bit char7seg_buswires1(.BCD(buswires[7:4]), .display(HEX1));
	seven_segment_led_4bit char7seg_buswires2(.BCD(buswires[8]), .display(HEX2));
	
	always@(count)
	begin
		case(count)
			3'b000: data = R0;
			3'b001: data = R1;
			3'b010: data = R2;
			3'b011: data = R3;
			3'b100: data = R4;
			3'b101: data = R5;
			3'b110: data = R6;
			3'b111: data = R7;
		endcase
	end
	
	seven_segment_led_4bit char7seg_data0(.BCD(data[3:0]), .display(HEX4));
	seven_segment_led_4bit char7seg_data1(.BCD(data[7:4]), .display(HEX5));
	seven_segment_led_4bit char7seg_data2(.BCD(data[8]), .display(HEX6));	
	
endmodule
