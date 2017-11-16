
//RAM module
//Module that stores instruction to be executed
module ram (data,addr,we, clk,q);
	input [7:0] data, addr;
	input we, clk;	
	output reg [7:0] q;

	// Declare the RAM variable
	reg [7:0] ram[255:0];
	
	// Variable to hold the registered read address
	reg [7:0] addr_reg;

	initial
		begin

//******************Write your program here**********//

                ram[0] <= 8'b11100000;
                ram[1] <= 8'b00000000;
                ram[2] <= 8'b00000100;
                ram[3] <= 8'b11100100;            
                ram[4] <= 8'b11100100;            
                ram[5] <= 8'b00000010;
                ram[6] <= 8'b00000010;
                ram[7] <= 8'b00100100;       
                ram[8] <= 8'b00000000;	
                ram[9] <= 8'b00000000;	
                ram[10] <= 8'b00000000;	

//******************Write your program here**********//

		end 
        initial
            q = 8'b00000000;

	always @ (posedge clk)
	begin
	// Write
		if (we)
			ram[addr] <= data;		
		q <= ram[addr];		
	end	
endmodule

