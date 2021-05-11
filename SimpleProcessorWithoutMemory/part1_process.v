module part1_process(DIN, Resetn, Clock, Run, Done, BusWires, R0, R1, R2, R3, R4, R5, R6, R7);
	input [8:0]DIN;
	input Resetn, Clock, Run;
	output reg Done;
	output reg [8:0]BusWires;
	
	// State of FSM
	parameter T0 = 2'b00,
				 T1 = 2'b01,
				 T2 = 2'b10,
				 T3 = 2'b11;
	reg [2:0]Current_State, Next_State;
		
	reg [0:7]Rin, Rout;
	reg [8:0]Res;    // result of add/sub instruction
	reg AddSub, 			// 
		 Ain, Gin, Gout, // Flag for data in/out of A, G register 
		 DINout,			// Flag for external data
		 IRin;				// Flag of instruction register
	
	
	wire [1:9]IR; // instruction register
	wire [8:0]A,  // register A for pre Add/Sub
				 G;  // register G for storing result after Add/Sub
	output [8:0]R0, R1, R2, R3, R4, R5, R6, R7; // eight 9-bit registers
	
	wire [0:7]Xreg, Yreg;// Register X, Y
	wire [2:0]OP;        // Operation code / Instruction type
	wire [1:10]Sel;
	
	parameter MV  = 3'b000,
				 MVI = 3'b001,
				 ADD = 3'b010,
				 SUB = 3'b011;
		  
	
	// Interpret instruction code into instruction type, register X, register Y
	regn instructionReg(.DataIn(DIN), .Clock(Clock), .Enable(IRin), .DataOut(IR)); 
	assign OP = IR[1:3];  // Instruction code
	dec3to8 decX(.W(IR[4:6]), .Enable(1'b1), .Y(Xreg));
	dec3to8 decY(.W(IR[7:9]), .Enable(1'b1), .Y(Yreg));
	
	// Control FSM state table
	always@(Current_State, Run, Done)
	begin
		if(Done)
			Next_State = T0;
		else
		begin
			case(Current_State)
				// Step T0 
				T0: //data is loaded into IR in this time step
				begin
					if(!Run) 
						Next_State = T0;
					else 
						Next_State = T1;
				end
				
				// Step T1
				T1: 
				begin
					Next_State = T2;
				end
				
				// Step T2
				T2: 
				begin
					Next_State = T3;
				end
				
				// Step T3
				T3: 
				begin
					Next_State = T0;
				end
				
			endcase
		end
	end
	
	// Control FSM output
	always@(Current_State, Xreg, Yreg, OP)
	begin
		// Initialize value
		Rin    = 8'b0;
		Rout   = 8'b0;
		Ain    = 1'b0;
		Gin    = 1'b0;
		Gout 	 = 1'b0;
		AddSub = 1'b0;
		DINout = 1'b0;
		Done	 = 1'b0;
		IRin 	 = 1'b0;
		
		case(Current_State)
			// Step T0
			T0: // store DIN in IR in time step 0
			begin
				IRin = 1'b1;
			end
			// Step T1
			T1: 
			begin
				case(OP)
					// Move instruction
					MV: 
					begin
						Rout = Yreg;
						Rin  = Xreg;
						Done = 1'b1;
					end
					
					// Move immediate instruction
					MVI:
					begin
						Rin 	 = Xreg;
						DINout = 1'b1;
						Done 	 = 1'b1;
					end
					
					// Add/Sub instruction
					ADD, SUB:
					begin
						Rout = Xreg;
						Ain  = 1'b1;
					end
					
					default: ;
				endcase
			end
			
			// Step T2
			T2: 
			begin
				case(OP)
					// Add instruction
					ADD: 
					begin
						Rout   = Yreg;
						Gin    = 1'b1;
					end
					
					// Sub instruction
					SUB:
					begin
						Rout   = Yreg;
						Gin	 = 1'b1;
						AddSub = 1'b1;
					end
					
					default: ;
				endcase
			end
			
			// Step T3
			T3:
			begin
				case(OP)
					// Add/Sub instruction
					ADD, SUB:
					begin
						Gout = 1'b1;
						Rin  = Xreg;
						Done = 1'b1;
					end
					
					default: ;
				endcase
			end
		endcase
	end
	
	always@(posedge Clock, negedge Resetn)
	begin
		if(!Resetn)
			Current_State <= T0;
		else 
			Current_State <= Next_State;
	end
	
	// Instantiate registers and the adder/subtractor unit
	regn reg_0(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[0]), .DataOut(R0));
	regn reg_1(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[1]), .DataOut(R1));			
	regn reg_2(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[2]), .DataOut(R2));
	regn reg_3(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[3]), .DataOut(R3));
	regn reg_4(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[4]), .DataOut(R4));
	regn reg_5(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[5]), .DataOut(R5));
	regn reg_6(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[6]), .DataOut(R6));
	regn reg_7(.DataIn(BusWires), .Clock(Clock), .Enable(Rin[7]), .DataOut(R7));	
	
	regn regA(.DataIn(BusWires), .Clock(Clock), .Enable(Ain), .DataOut(A));
	regn regG(.DataIn(Res), .Clock(Clock), .Enable(Gin), .DataOut(G));
	// Calculate the result of add/sub operation
	always@(BusWires, AddSub, A)
	begin
		if(!AddSub)
			Res = A + BusWires;
		else
			Res = A - BusWires;
	end
	
	// Define BusWires using muxtiplexers
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
			default:			 BusWires = DIN;
		endcase
	end
	
endmodule
	
	
	
		   