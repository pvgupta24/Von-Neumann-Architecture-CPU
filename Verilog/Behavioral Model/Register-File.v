
// Register File
// decides whether to read from or write to a register
// decides which register to read or write from
module registerFile(
	input [7:0]dval,
	input dwrite,
	input [1:0]dregsel,
	input [1:0]sregsel,
    input clk,
	output reg zero,
	output reg negative,
	output [7:0]dbus,
	output [7:0]sbus
	);
	
	wire [3:0]res_enable;
	wire [7:0]res0,res1,res2,res3;

	demux_1x4 demux1(dwrite, dregsel, res_enable[0],res_enable[1],res_enable[2],res_enable[3]);

	register8RF r0(clk , dval, res_enable[0], res0 );
	register8RF r1(clk , dval, res_enable[1], res1 );
	register8RF r2(clk , dval, res_enable[2], res2 );
	register8RF r3(clk , dval, res_enable[3], res3 );
	
	mux_4x1 mux1(res0, res1, res2, res3, dregsel , dbus);
	mux_4x1 mux2(res0, res1, res2, res3, sregsel , sbus);

	always @(posedge clk)
		begin
			negative <= dbus[7];
			zero <= dbus[0]|dbus[1]|dbus[2]|dbus[3]|dbus[4]|dbus[5]|dbus[6]|dbus[7];			
		end
    initial
        begin
            zero <= 0;
            negative <=0;
        end
endmodule

// 8 bit register module
module register8(
	input clk,
	input [7:0]data_in,
	input enable,
	output reg [7:0]data_out
	);
	
	always @(posedge clk & enable)
		begin
				data_out <= data_in;
		end		

    initial 
        data_out <= 8'b00000000;        
endmodule

// 8 bit registerRF module
module register8RF(
	input clk,
	input [7:0]data_in,
	input enable,
	output reg [7:0]data_out
	);
	
	always @(posedge clk && enable)
		begin
				data_out <= data_in;
		end		

    initial 
        data_out <= 8'b00000000;        
endmodule
