

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
`timescale 1ns/100ps

module Verilog_210_235();
    reg clk;

    //Instantiate the CPU module
    VerilogBM_210_235 CPU(clk);
    //VerilogDM_210_235 CPU(clk);

    initial
        begin
            $dumpfile("VerilogBM-210-235.vcd");
            $dumpvars(0,Verilog_210_235);
            $display("8-Bit Von Neumann CPU");
            $display("Loading from RAM.....");
            $display("Loading Complete - 100%");
            $display("CPU simulation started .....");      
            //Initialize the clock      
            clk <= 1'b0;

        end
    initial
        forever
        #5 clk = ~clk;

    initial
        begin
            // Total time
            #100;          
            $finish;
        end

endmodule


//==============================================================================================================
//==============================================================================================================