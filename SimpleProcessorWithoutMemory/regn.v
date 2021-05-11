module regn(DataIn, Clock, Enable, DataOut);
	parameter n = 9;
	input [n-1:0]DataIn;
	input Clock, Enable;
	output reg [n-1:0]DataOut;
	
	always@(posedge Clock)
		if(Enable)
			DataOut <= DataIn;

endmodule
