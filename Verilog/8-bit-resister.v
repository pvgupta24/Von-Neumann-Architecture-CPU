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
		
endmodule