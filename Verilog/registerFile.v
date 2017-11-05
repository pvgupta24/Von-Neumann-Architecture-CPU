/*module register8(
	input clk,
	input [7:0]data_in,
	input enable,
	output reg [7:0]data_out
	);
	
	always @(posedge clk & enable)
		begin
				data_out <= data_in;
		end
		
endmodule
*/
module mux(I0,I1,I2,I3,sel,out);
	input [7:0]I0,I1,I2,I3;
	input [1:0] sel;
	output reg [7:0] out;
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


module demux(
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
							o0 = I0;
							o1 = 1'b0;
							o2 = 1'b0;
							o3 = 1'b0;
						end
				2'b01 : 
						begin 
							o0 = 1'b0;
							o1 = I0;
							o2 = 1'b0;
							o3 = 1'b0;
						end
				2'b10 : 
						begin 
							o0 = 1'b0;
							o1 = 1'b0;
							o2 = I0;
							o3 = 1'b0;
						end
				2'b11 : 
						begin 
							o0 = 1'b0;
							o1 = 1'b0;
							o2 = 1'b0;
							o3 = I0;
						end
			endcase				
		end		
endmodule

module registerFile(
	input [7:0]dval,
	input dwrite,
	input [1:0]dresel,
	input [1:0]sregel,
	input [1:0] drs,
	output reg zero,
	output reg negative,
	output [7:0]dbus,
	output [7:0]sbus
	);
	
	wire [3:0]res_enable;
	wire [7:0]res0,res1,res2,res3;
	demux demux1(dwrite, drs, res_enable[0],res_enable[1],res_enable[2],res_enable[3]);
	register8 r0(clk , dval, res_enable[0], res0 );
	register8 r1(clk , dval, res_enable[1], res1 );
	register8 r2(clk , dval, res_enable[2], res2 );
	register8 r3(clk , dval, res_enable[3], res3 );
	
	mux mux1(res0, res1, res2, res3, dresel , dbus);
	mux mux2(res0, res1, res2, res3, sregel , sbus);

	always @(posedge clk)
		begin
			negative <= dbus[7];
			zero <= dbus[0]|dbus[1]|dbus[2]|dbus[3]|dbus[4]|dbus[5]|dbus[6]|dbus[7];			
		end
endmodule
