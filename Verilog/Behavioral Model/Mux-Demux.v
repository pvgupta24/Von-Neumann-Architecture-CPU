
//4X1 multiplexer
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

//1X4 demultiplexer
module demux_1x4(
	input I0,
	input [1:0]sel,
	output reg o0,
	output reg o1,
	output reg o2,
	output reg o3
	);
	
	always @(*)
		begin
			case (sel)
				2'b00 : 
						begin 
							o0 <= I0;
							o1 <= 1'b0;
							o2 <= 1'b0;
							o3 <= 1'b0;
						end
				2'b01 : 
						begin 
							o0 <= 1'b0;
							o1 <= I0;
							o2 <= 1'b0;
							o3 <= 1'b0;
						end
				2'b10 : 
						begin 
							o0 <= 1'b0;
							o1 <= 1'b0;
							o2 <= I0;
							o3 <= 1'b0;
						end
				2'b11 : 
						begin 
							o0 <= 1'b0;
							o1 <= 1'b0;
							o2 <= 1'b0;
							o3 <= I0;
						end
			endcase				
		end		
endmodule
