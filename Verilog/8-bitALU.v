
// #####################################################              ALU begins            ##############################################################

module bit_8_AND(aANDb,A,B);
	output reg [7:0] aANDb;
	input [7:0]A,B;
	always @(*)
		begin
			aANDb <= A&B;
		end
endmodule

module bit_8_OR(
	output reg [7:0]aORb,
	input [7:0]A,
	input [7:0]B
);
	always @(*)
		begin
			aORb <= A|B;
		end
endmodule

module bit_8_ADDER(
	output reg [7:0]aPlusb,
	input [7:0]A,
	input [7:0]B,
	input carry_in
);
	reg BB;
	always @(*)
		begin
			if(carry_in == 1)
				BB = ~B;
			else
				BB = B;
			aPlusb = A + BB;
		end
endmodule

module mux_2X1(
	output reg [7:0]O,
	input [7:0]I0,
	input [7:0]I1,
	input sel);

	always @(*)
		begin
			if(sel == 0)
				O <= I0;
			else
				O <= I1;
		end
endmodule


module bit_8_ALU(
	input [7:0]in_A,
	input [7:0]in_B,
	input [1:0]in_operation,
	output [7:0]out_c
);
	
	wire [7:0]out_and,out_or,out_adder,mux1;
	
	bit_8_AND i1(out_and,in_A,in_B);
	bit_8_OR i2(out_or,in_A,in_B);
	bit_8_ADDER i3(out_adder,in_A,in_B,in_operation[0]);
	
	mux_2X1 i4(mux1,out_and,out_or,in_operation[0]);
	mux_2X1 i5(out_c,mux1,out_adder,in_operation[1]);
	
endmodule

// #####################################################              ALU Ends               ##############################################################
