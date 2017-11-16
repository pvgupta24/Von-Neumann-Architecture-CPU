/*
=================================================================================================================
         Title   -                     8-Bit Von Neumann Architecture CPU
-------------------------------------  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  --------------------------------------
         Contributors -                    * Praveen Kumar Gupta 
                                           * Durvesh Bhalekar    
-----------------------------------------------------------------------------------------------------------------

        Abstract          |  This verilog program shows the simulation of a 8-bit processor built
                          |  on the principles of the Von Neumman architecture.
                          |  The program can be loaded in the RAM module and the following code carries out
                          |  the instructions accordingly. 

        Functionalities   |  This processor allows supported instructions (as given in the Instruction Set file)
                          |  to be written in the RAM module.
            and           |  An Instruction cycle is broken into 3 phases - Fetch , Decode and Execute

          Desciption      |  Instructions from RAM Module are fetched into the Instruction Register on the 
                          |  appropriate phase, it is decode by the control unit which sets various flags and
                          |  select lines depending on the type of instruction, like 
                          |  * fetching into immediate register
                          |  * writing in register file
                          |  * changing PC value
                          |  * selecting address from imm. or PC
                          |  * selecting the correct register from RF
                          |  * Deciding the ALU operation
                          |  * Sending the ALU output to the required place.


======================================================================================================================
*/


/*
                                         Variable Desciption Table
======================================================================================================================
|          Variables            |                          Description                                          |
-----------------------------------------------------------------------------------------------------------------
|            clk                |      functions as a clock                                                     |    
|            zero               |      flag to check if the destination resistor is zero                        |
|            negative           |      flag to check if the destination resistor is negative                    |                                                   |
|            irload             |      acts as an enable for the instruction register                           |
|            imload             |      acts as an enable for the immediate register                             |
|            pcsel              |      select line for the PC mux                                               |
|            pcload             |      acts as an enable for the PC register                                    |
|            readwrite          |      input signal for the RAM deciding whether to read or write               |
|            dwrite             |      input signal for the register file                                       |
|                                                                                                               |    
|            dregsel            |      select line for register file MUX deciding which register to write in    |
|            sregsel            |      select line for register file MUX deciding which register to read from   |
|            aluop              |      select line for the ALU deciding the operation to be done                |
|            regsel             |      select line for MUX deciding what value to wrie in the register          |
|            addrsel            |      select line for the MUX deciding the output of the program counter       |
|            irvalue            |      value stored in the instrution resistor                                  |
|            dbus               |      stores the value of the destination register                             |
|            sbus               |      stores the value of the source register                                  |
|            dval               |      input data to the register file                                          |
|            pcin               |      input data to the PC register                                            |
|            imm                |      immediate value                                                          |
|            datain             |      instruction data recieved from the RAM                                   |
|            aluout             |      output of the ALU                                                        |
|            address            |      address of the next instruction                                          |    
-----------------------------------------------------------------------------------------------------------------
=================================================================================================================
*/

// Define Timescale for the verilog file.
`timescale 1ns/100ps


//The main module of the code
//All the seperate modules used in the code are linked together here
module CPU(clk);

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
    reg [7:0] pcadd;
    initial
        begin
            pcadd <= 8'b11111111;
        end
    
    always @(*)
            pcadd <= pcout + 1'b1;

    mux_2X1 pcInMux(pcin,imm,pcadd,pcsel);
    register8 PCREG(clk,pcin,pcload,pcout);
    mux_4x1 addressMux(pcout,imm,sbus,dbus,addrsel,address);

endmodule
