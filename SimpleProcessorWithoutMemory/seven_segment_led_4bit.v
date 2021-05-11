module seven_segment_led_4bit(BCD, display);
	input  [3:0]BCD;
	output [6:0]display;
	
	assign display = (BCD == 4'd0) ? 7'b1000000:  // digit 0           
						  (BCD == 4'd1) ? 7'b1111001:  // digit 1
						  (BCD == 4'd2) ? 7'b0100100:  // digit 2
						  (BCD == 4'd3) ? 7'b0110000:  // digit 3
						  (BCD == 4'd4) ? 7'b0011001:  // digit 4
						  (BCD == 4'd5) ? 7'b0010010:  // digit 5
						  (BCD == 4'd6) ? 7'b0000010:  // digit 6
						  (BCD == 4'd7) ? 7'b1111000:  // digit 7
						  (BCD == 4'd8) ? 7'b0000000:  // digit 8
						  (BCD == 4'd9) ? 7'b0010000:  // digit 9
						  (BCD == 4'd10)? 7'b0001000:  // hex A
						  (BCD == 4'd11)? 7'b0000011:  // hex B
						  (BCD == 4'd12)? 7'b1000110:  // hex C
						  (BCD == 4'd13)? 7'b0100001:  // hex D
						  (BCD == 4'd14)? 7'b0000110:  // hex E
						  (BCD == 4'd15)? 7'b0001110:  // hex F
						  7'b1111111;                  // nothing
	
endmodule
