
// Define Timescale for the verilog file.
`timescale 1ns/100ps


//The main module of the code
//All the seperate modules used in the code are linked together here
module cpu(clk);

    // Port Declarations
    
    input wire clk;
    wire  zero, negative,/* irload,*/imload, pcsel,pcload,readwrite,dwrite;
    wire irload;
    
    wire [1:0] dregsel, sregsel, aluop, regsel, addrsel;
    wire [7:0] irvalue,dbus,sbus,dval,pcin,imm,datain,aluout,address; 
  
    //Instantiate RAM module
    ram RAM(aluout,address,readwrite,clk,datain);

    //Instantiate Instruction Register module    
    register8 InstrREG(clk,datain,irload,irvalue);

    //Decode module: Interprets the instructions and determines the flags
    control CTRL(clk, zero, negative, irvalue, dregsel, sregsel, aluop, irload, 
    imload, pcsel, pcload, readwrite, regsel, dwrite, addrsel);

    //Instantiate Immediate Register module    
    register8 ImmREG(clk,datain,imload,imm);

    mux_4x1 resMux(imm,sbus,datain,aluout,regsel,dval);

    //Instantiate Register File module
    registerFile RF(dval,dwrite,dregsel,sregsel,clk,zero,negative,dbus,sbus);

    // Arithmetic Logic Unit
    bit_8_ALU ALU(dbus,sbus,aluop,aluout);  

    //Intantiate Program Counter module 
    pcBlock PC(clk,pcin,pcload,imm,pcsel,sbus,dbus,addrsel,address);

endmodule


//Program Counter module : determines the address of the next instruction 
module pcBlock(clk,pcin,pcload,imm,pcsel,sbus,dbus,addrsel,address);

    input clk,pcload,pcsel;
    input [7:0] imm,sbus,dbus;
    inout [7:0] pcin;
    input [1:0] addrsel;
    output [7:0] address;
    
    wire [7:0] pcout;
    wire [7:0] pcadd;
        
    assign pcadd = 8'b11111111;
    assign pcadd = (pcsel == 1)?(pcout + 1'b1):pcadd;

    mux_2X1 pcInMux(pcin,imm,pcadd,pcsel);
    register8 PCREG(clk,pcin,pcload,pcout);
    mux_4x1 addressMux(pcout,imm,sbus,dbus,addrsel,address);

endmodule


// Module for the Control Unit which splits the instruction and
// sets the values for various flags which acts as enable or selector
// for the Multiplexers used in Main CPU module
module control(clk, zero, negative, irvalue, dregsel, sregsel, aluop, irload,
 imload, pcsel, pcload, readwrite, regsel, dwrite, addrsel);

    // 8-Bit value from Instruction Register
    input [7:0] irvalue;
    // Clock & Zero, Negative flag from ALU
    input clk, zero, negative;

    // First 4 Bits of IR
    wire irbit4, irbit5, irbit6, irbit7;
    // OPcodes and destination reg, source reg value (Refer dataflow)
    wire [1:0] op1,op2,rd,rs;

    //Phase : 0-Fetch 1-Decode 2-Execute
    wire [1:0] phase;
    // 4Bits Opcode = concat(op1,op2)
    wire [3:0] op1op2;

    output [1:0] dregsel, sregsel, aluop;
    output [1:0] regsel,addrsel;
    output wire irload, imload, pcsel, pcload, readwrite,  dwrite ;

    
    assign irbit7 = irvalue[7];
    assign irbit6 = irvalue[6];
    assign irbit5 = irvalue[5];
    assign irbit4 = irvalue[4];

    assign  op1 = {irvalue[7],irvalue[6]};
    assign  op2 = {irvalue[5],irvalue[4]};
    assign  rd  = {irvalue[3],irvalue[2]};
    assign  rs  = {irvalue[1],irvalue[0]};
    assign  op1op2 = {irvalue[7],irvalue[6],irvalue[5],irvalue[4]};
       

    
    assign dregsel = rd;
    assign sregsel = rs;
    assign aluop = op2;
   

    phaseCounter PHASE(clk, phase);
    irLoad IR(phase,irload);
    imLoad IM(phase,irbit7,imload);
    pcSelect PC(phase, pcsel);
    pcLoad PCLOAD(zero, negative, irbit4, irbit5, irbit6, irbit7, op2, phase, pcload);
    readWrite RW(irbit4 , irbit5, irbit6, phase, readwrite);
    regSel REGSEL(op1op2,phase,regsel);
    destRegWrite DR(op1op2,phase,dwrite);
    addressSelect AS(op1op2,phase,addrsel);

endmodule


//Determines the current phase of the program
//Von Neumman Architecture functions in three phases
module phaseCounter(input clk,output reg [1:0] phase);
    initial 
        phase = 2'b00;
    always @(posedge clk)
        begin
            if(phase==2'b10)
                phase <= 2'b00;
            else
                phase <= phase+1;
        end
endmodule

// Flag deciding whether or not to load the instruction value
module irLoad(input [1:0] phase,output irload);
 
    assign irload = (phase == 2'b00)?1:0;

endmodule

// Flag deciding whether or not to load the immediate value
module imLoad(input [1:0] phase,input irbit7,output imload);

    assign imload = (phase == 2'b01)?irbit7:0;

endmodule

//select line to decide the new value of the program counter 
module pcSelect(input [1:0] phase,output pcsel);
    
    assign pcsel = (phase[1] == 0)?1:0;

endmodule


//Flag deciding whether or not to update the value of the program counter
module pcLoad(zero, negative, irbit4, irbit5, irbit6, irbit7, op2, phase, pcload);
    input zero,negative,irbit4, irbit5, irbit6, irbit7;
    input [1:0] op2,phase;
    output reg pcload;
    reg mux1out;
    always @(*)
    begin
        case(op2)
            2'b00 : mux1out <= zero;
            2'b01 : mux1out <= ~zero;
            2'b10 : mux1out <= (~zero)&(~negative);
            2'b11 : mux1out <= negative;
        endcase
    end
    always @(*)
    begin
        case(phase)
            2'b00 : pcload <= 1;
            2'b01 : pcload <= irbit7;
            2'b10 : pcload <= (mux1out & irbit7 & ~irbit6) | (irbit4 & irbit5 & irbit6 & irbit7);
            2'b11 : pcload <= 0;
        endcase
    end
endmodule

// Flag for the RAM deciding whether to read or write from the RAM
module readWrite(irbit4 , irbit5, irbit6, phase, readwrite);
    input irbit4,irbit5,irbit6,irbit7;
    input [1:0] phase;
    output readwrite;

    assign readwrite = (phase == 2'b10)?(irbit4 & ~irbit5 & irbit6):0;	

endmodule

// select line to decide what data to store in the register
module regSel(op1op2,phase,regsel);
    input [3:0] op1op2;
    input [1:0] phase;
    output reg [1:0] regsel;
    reg [1:0] mux1out;
    always @(op1op2)
        begin
            case(op1op2)
                 4'b0000,4'b0001,4'b0010,4'b0011   : mux1out <= 2'b11;
                 4'b0100,4'b110  :                   mux1out <= 2'b10;
                 4'b0110:                            mux1out <= 2'b01;
                 default :                           mux1out <= 2'b00;              
            endcase  
        end
    always @(phase or mux1out)
    begin
        case(phase)
            2'b10 : regsel <= mux1out;
            default : regsel <= 0;
        endcase
    end    
endmodule



module destRegWrite(op1op2,phase,dwrite);
    input [3:0] op1op2;
    input [1:0] phase;
    output dwrite;
    wire  [1:0] mux1out;

    assign mux1out = (op1op2 == 4'b0101 | 4'b0111 | 4'b1000 | 4'b1001 | 4'b1010 | 4'b1011 | 4'b1101 | 4'b1111)?0:1 ; 
    assign dwrite = (phase == 2'b10)? mux1out : 0 ;  
 
endmodule




// select line for the mux deciding the address of the next instruction
module addressSelect(op1op2,phase,addrsel);
    input [3:0] op1op2;
    input [1:0] phase;
    output [1:0] addrsel;
    
    wire [1:0] mux1out;
    
    assign mux1out = (op1op2 == 4'b1101 | 4'b1110)?(2'b01):((op1op2==4'b0100 | 4'b0101)?2'b10:0);    
    assign addrsel = (phase == 2'b10)?mux1out:2'b00 ; 
endmodule 




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
	register8 r0(clk , dval, res_enable[0], res0 );
	register8 r1(clk , dval, res_enable[1], res1 );
	register8 r2(clk , dval, res_enable[2], res2 );
	register8 r3(clk , dval, res_enable[3], res3 );
	
	mux_4x1 mux1(res0, res1, res2, res3, dregsel , dbus);
	mux_4x1 mux2(res0, res1, res2, res3, sregsel , sbus);

	always @(posedge clk)
		begin
			negative <= dbus[7];
			zero <= dbus[0]|dbus[1]|dbus[2]|dbus[3]|dbus[4]|dbus[5]|dbus[6]|dbus[7];			
		end
endmodule




//4X1 multiplexer
module mux_4x1(
	input [7:0]I0,I1,I2,I3,
	input [1:0]sel,
	output [7:0]out
	);
	
    assign out = (sel[1] == 0)?((sel[0] == 0)?I0:I1):((sel[0] == 0)?I2:I3); 
endmodule

//1X4 demultiplexer
module demux_1x4(
	input I0,
	input [1:0]sel,
	output o0, o1, o2,o3
	);
	
    assign o0 = (sel[1] == 0)?((sel[0] == 0)?I0:0):((sel[0] == 0)?0:0); 
    assign o1 = (sel[1] == 0)?((sel[0] == 0)?0:I0):((sel[0] == 0)?0:0); 
    assign o2 = (sel[1] == 0)?((sel[0] == 0)?0:0):((sel[0] == 0)?I0:0); 
    assign o3 = (sel[1] == 0)?((sel[0] == 0)?0:0):((sel[0] == 0)?0:I0); 
	
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
		    //Write your program here		
			ram[0] = 8'b11100000;
            ram[1] = 8'b00000100;

            ram[2] = 8'b11100100;            
            ram[3] = 8'b00000010;

            ram[4] = 8'b00100100;
            ram[5] = 8'b00000000;
		    q = ram[0];                        
		end 

	//initial

	always @ (posedge clk)
	begin
	// Write
		if (we)
			ram[addr] <= data;
		
		q <= ram[addr];		
	end	
endmodule

// Arithmetic Logic Unit
// ===============================================  ALU begins  ===============================================

//AND
module bit_8_AND(aANDb,A,B);
	output [7:0] aANDb;
	input [7:0]A,B;
	
	assign 	aANDb = A&B;

endmodule

//OR
module bit_8_OR(aORb,A,B);
	output [7:0]aORb;
	input [7:0]A;
	input [7:0]B;

	assign	aORb = A|B;
	
endmodule

//8 bit adder
module half_adder(sum,carry,A,B);
    output sum,carry;
    input A,B;

    assign sum = A&(~B) | (~A)&B;
    assign carry = A&B;
endmodule

module full_adder(sum,carry_out,A,B,carry_in);
    output sum,carry_out;
    input A,B,carry_in;

    wire sum1,carry1,carry2;
    half_adder add1(sum1,carry1,A,B);
    half_adder add2(sum,carry2,sum1,carry_in);

    assign carry_out = carry1|carry2;
endmodule


module bit_8_ADDER(out,A,B,carry_in);
	output [7:0]out;
	input [7:0]A;
	input [7:0]B;
	input carry_in;
	
    wire carry[6:0];

    full_adder add0(out[0],carry[0],A[0],B[0]^carry_in,carry_in);
    full_adder add1(out[1],carry[1],A[1],B[1]^carry_in,carry[0]);
    full_adder add2(out[2],carry[2],A[2],B[2]^carry_in,carry[1]);
    full_adder add3(out[3],carry[3],A[3],B[3]^carry_in,carry[2]);
    full_adder add4(out[4],carry[4],A[4],B[4]^carry_in,carry[3]);
    full_adder add5(out[5],carry[5],A[5],B[5]^carry_in,carry[4]);
    full_adder add6(out[6],carry[6],A[6],B[6]^carry_in,carry[5]);
    full_adder add7(out[7],carry_out,A[7],B[7]^carry_in,carry[6]);
   
endmodule

//2 X 1 multiplxer
module mux_2X1(
	output [7:0]O,
	input [7:0]I0,
	input [7:0]I1,
	input sel);

    assign O = (sel == 0)?I0:I1; 

endmodule

// main ALU module
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

// ===============================================   ALU Ends  ===============================================
