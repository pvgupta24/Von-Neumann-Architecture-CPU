module mux_4x1(
	input [7:0]I0,
	input [7:0]I1,
	input [7:0]I2,
	input [7:0]I3,
	input [1:0]sel,
	output reg [7:0]out
	);
	
	always @(*)
		begin
			case (sel)
				2'b00 : out = I0;
				2'b01 : out = I1;
				2'b10 : out = I2;
				2'b11 : out = I3;
			endcase	
			
		end
		
endmodule