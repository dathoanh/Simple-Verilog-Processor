module processor(DIN, Clock, Resetn, Run, BusWires, Done, R0, R1, R2, R3, R4, R5, R6, R7);
	input [8:0]DIN;
	input Clock, Resetn, Run;
	
	output reg [8:0]BusWires;
	output reg Done;
	
	parameter PRE = 3'b000,
				 T0 = 3'b001,
				 T1 = 3'b010,
				 T2 = 3'b011,
				 T3 = 3'b100;
	reg [2:0] current_state, next_state;
	reg [0:7]Rin, Rout;
	reg Ain, 
		 Gin, 
		 Gout,
		 DINout,
		 AddSub,
		 IRin;
	reg [8:0]Sum;
	
//	wire [8:0]R[0:7];
	output [8:0]R0, R1, R2, R3, R4, R5, R6, R7;
	wire [8:0]A, G;
	wire [1:9]IR;
	wire [0:7]Xreg, Yreg;
	wire [1:10]Sel;
	wire [2:0]I;
	
	parameter mv  = 3'b000,
				 mvi = 3'b001,
				 add = 3'b010,
				 sub = 3'b011;
	
	assign I = IR[1:3];
	dec3to8 decX(.W(IR[4:6]), .Enable(1'b1), .Y(Xreg));
	dec3to8 decY(.W(IR[7:9]), .Enable(1'b1), .Y(Yreg));
	
	regn instructionReg(.DataIn(DIN), .Clock(Clock), .Enable(IRin), .DataOut(IR));
	
	always@(Done, current_state, Run)
	begin
		if(Done)
			next_state = PRE;
		else 
		begin
			case(current_state)
			PRE: if(!Run) next_state = PRE;
				 else 	 next_state = T0;
				 
			T0: next_state = T1;	 
			T1: next_state = T2;
			T2: next_state = T3;
			T3: next_state = T0;
			endcase
		end
	end
	
	always@(current_state, Xreg, Yreg, I)
	begin
		Rin	 = 8'b0;
		Rout	 = 8'b0;
		Ain 	 = 1'b0;
		AddSub = 1'b0;
		Gin	 = 1'b0;
		Gout	 = 1'b0;
		DINout = 1'b0;
		IRin	 = 1'b0;
		Done	 = 1'b0;
		
		case (current_state)
			PRE: 
				IRin  = 1'b1;
				
			T0: 
			begin
				case(I)
				mv: 
				begin
					Rout = Yreg;
					Rin  = Xreg;
	//				Done = 1'b1;
				end
					
				mvi:
				begin
					DINout = 1'b1;
					Rin 	 = Xreg;
	//				Done 	 = 1'b1;
				end
				
				add, sub:
				begin
					Rout = Xreg;
					Ain  = 1'b1;
				end
				
				default: ;
				
				endcase
			end
				
			T1:
			begin
				case(I)
				mv, mvi:
					Done = 1'b1;
				
				add: 
				begin
					Rout   = Yreg;
					AddSub = 1'b0;
					Gin	 = 1'b1;
				end
				
				sub:
				begin
					Rout   = Yreg;
					AddSub = 1'b1;
					Gin	 = 1'b1;
				end
				
				default: ;
				
				endcase
			end
			
			T2: 
			begin
				case(I)
				add, sub:
				begin
					Gout = 1'b1;
					Rin  = Xreg;
	//				Done = 1'b1;
				end
					
				default: ;
				endcase
			end
			
			T3:
			begin
				case(I)
				add,sub:
					Done = 1'b1;
				
				default: ;
				endcase
			
			end
		endcase
	end
	
	always@(posedge Clock, negedge Resetn)
	begin
		if(!Resetn)
			current_state = PRE;
		else 
			current_state <= next_state;
	end
	
	regn reg_0 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[0]), .DataOut(R0));
	regn reg_1 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[1]), .DataOut(R1));
	regn reg_2 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[2]), .DataOut(R2));
	regn reg_3 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[3]), .DataOut(R3));
	regn reg_4 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[4]), .DataOut(R4));
	regn reg_5 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[5]), .DataOut(R5));
	regn reg_6 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[6]), .DataOut(R6));
	regn reg_7 (.DataIn(BusWires), .Clock(Clock), .Enable(Rin[7]), .DataOut(R7));
	
	regn reg_A (.DataIn(BusWires), .Clock(Clock), .Enable(Ain), .DataOut(A));
	
	always@(A, BusWires, AddSub)
	begin
		if(!AddSub)
			Sum = A + BusWires;
		else 
			Sum = A - BusWires;
	end
	
	regn reg_G (.DataIn(Sum), .Clock(Clock), .Enable(Gin), .DataOut(G));
	
	assign Sel = {Rout, Gout, DINout};
	always@(Sel, R0, R1, R2, R3, R4, R5, R6, R7, G, DIN)
	begin
		case(Sel)
		10'b1000000000: BusWires = R0;
		10'b0100000000: BusWires = R1;
		10'b0010000000: BusWires = R2;
		10'b0001000000: BusWires = R3;
		10'b0000100000: BusWires = R4;
		10'b0000010000: BusWires = R5;
		10'b0000001000: BusWires = R6;
		10'b0000000100: BusWires = R7;
		10'b0000000010: BusWires = G;
		default		  : BusWires = DIN;
		endcase
	end
	
endmodule


module dec3to8 (W, Enable, Y);
	input [2:0]W;
	input Enable;
	output reg [0:7]Y;
	
	always@(W, Enable)
	begin
		if(Enable)
		begin
			case(W)
			3'b000: Y = 8'b10000000;
			3'b001: Y = 8'b01000000;
			3'b010: Y = 8'b00100000;
			3'b011: Y = 8'b00010000;
			3'b100: Y = 8'b00001000;
			3'b101: Y = 8'b00000100;
			3'b110: Y = 8'b00000010;
			3'b111: Y = 8'b00000001;
			endcase
		end
	end

endmodule

module regn (DataIn, Clock, Enable, DataOut);
	parameter n = 9;
	input [n-1:0]DataIn;
	input Clock, Enable;
	output reg [n-1:0]DataOut;
	
	always@(posedge Clock)
		if(Enable)
			DataOut <= DataIn;
			
endmodule

	