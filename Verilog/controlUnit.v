/*
=================== ================================== ======================
                    8-Bit Von Neumann Architecture CPU
------------------  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ---------------------
                Group 40 :  Praveen Kumar Gupta - 16CO235
                            Durvesh Bhalekar    - 16CO210
-----------------------------------------------------------------------------


=============================================================================
*/

// Define Timesacle for the verilog file.
`timescale 1ns/100ps

module cpu( clk,zero, negative, irload,imload, pcsel,pcload,readwrite,dwrite,
            irvalue,dbus,sbus,dval,pcin,imm,datain,aluout,address,
            dregsel, sregsel, aluop, regsel, addrsel);

    input wire clk,zero, negative, irload,imload, pcsel,pcload,readwrite,dwrite;
    input wire [1:0] dregsel, sregsel, aluop, regsel, addrsel;
    inout wire [7:0] irvalue,dbus,sbus,dval,pcin,imm,datain,aluout,address; 
    //input  address;
    ram RAM(aluout,address,readwrite,clk,datain);
    
    register8 InstrREG(clk,datain,irload,irvalue);
    register8 ImmREG(clk,datain,imload,imm);
    control CTRL(clk, zero, negative, irvalue, dregsel, sregsel, aluop, irload, 
    imload, pcsel, pcload, readwrite, regsel, dwrite, addrsel);
    bit_8_ALU ALU(dbus,sbus,aluop,aluout);  
    registerFile RF(dval,dwrite,dregsel,sregsel,dregsel,zero,negative,dbus,sbus);
    pcBlock PC(clk,pcin,pcload,imm,pcsel,sbus,dbus,addrsel,address);
    

endmodule
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
            pcadd = 8'b00000000;
            //pcout = 8'b00000000;
        end
    register8 PCREG(clk,pcin,pcload,pcout);
    always @(pcout)
        pcadd <= pcout + 1'b1;
    mux_2X1 pcInMux(pcin,imm,pcadd,pcsel);
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
    reg irbit4, irbit5, irbit6, irbit7;
    // OPcodes and destination reg, source reg value (Refer dataflow)
    reg [1:0] op1,op2,rd,rs;

    //Phase : 0-Fetch 1-Decode 2-Execute
    wire [1:0] phase;
    // 4Bits Opcode = concat(op1,op2)
    reg [3:0] op1op2;

    output reg [1:0] dregsel, sregsel, aluop;
    output [1:0] regsel,addrsel;
    output irload, imload, pcsel, pcload, readwrite,  dwrite ;

    always @(irvalue)
        begin
            irbit7 <= irvalue[7];
            irbit6 <= irvalue[6];
            irbit5 <= irvalue[5];
            irbit4 <= irvalue[4];

            op1 <= {irvalue[7],irvalue[6]};
            op2 <= {irvalue[5],irvalue[4]};
            rd  <= {irvalue[3],irvalue[2]};
            rs  <= {irvalue[1],irvalue[0]};
            op1op2 <= {irvalue[7],irvalue[6],irvalue[5],irvalue[4]};
        end

    always @(rd or rs or op2)
    begin
        dregsel <= rd;
        sregsel <= rs;
        aluop <= op2;
    end

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

module irLoad(input [1:0] phase,output reg irload);
    always @(phase)
    begin
        if(phase == 2'b00)
            irload <=1;
        else
            irload <=0;
    end 
endmodule

module imLoad(input [1:0] phase,input irbit7,output reg imload);
    always @(phase)
    begin
        if(phase == 2'b01)
            imload <= irbit7;
        else
            imload <= 0;
    end 
endmodule

module pcSelect(input [1:0] phase,output reg pcsel);
    always @(phase)
    begin
        if(phase[1] == 0)
            pcsel <= 1;
        else
            pcsel <= 0;
    end 
endmodule

module pcLoad(zero, negative, irbit4, irbit5, irbit6, irbit7, op2, phase, pcload);
    input zero,negative,irbit4, irbit5, irbit6, irbit7;
    input [1:0] op2,phase;
    output reg pcload;
    reg mux1out;
    always @(op2)
    begin
        case(op2)
            2'b00 : mux1out <= zero;
            2'b01 : mux1out <= ~zero;
            2'b10 : mux1out <= (~zero)&(~negative);
            2'b11 : mux1out <= negative;
        endcase
    end
    always @(phase or mux1out)
    begin
        case(phase)
            2'b00 : pcload <= 1;
            2'b01 : pcload <= irbit7;
            2'b10 : pcload <= (mux1out & irbit7 & ~irbit6) | (irbit4 & irbit5 & irbit6 & irbit7);
            2'b11 : pcload <= 0;
        endcase
    end
endmodule

module readWrite(irbit4 , irbit5, irbit6, phase, readwrite);
    input irbit4,irbit5,irbit6,irbit7;
    input [1:0] phase;
    output reg readwrite;
    always @(phase)
    begin
        case(phase)
            2'b00 : readwrite <= 0;
            2'b01 : readwrite <= 0;
            2'b10 : readwrite <= irbit4 & ~irbit5 & irbit6;
            2'b11 : readwrite <= 0;
        endcase
    end

endmodule

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
    output reg dwrite;
    reg [1:0] mux1out;
    always @(op1op2)
        begin
            case(op1op2)
                 4'b0000,4'b0001,4'b0010,4'b0011,4'b0100,4'b0110,4'b1100,4'b1110 : mux1out <= 2'b11;
                 default :                           mux1out <= 2'b00;              
            endcase  
        end
    always @(phase or mux1out)
    begin
        case(phase)
            2'b10 : dwrite <= mux1out;
            default : dwrite <= 0;
        endcase
    end 
endmodule


module addressSelect(op1op2,phase,addrsel);
    input [3:0] op1op2;
    input [1:0] phase;
    output reg [1:0] addrsel;
    reg [1:0] mux1out;
    always @(op1op2)
        begin
            case(op1op2)
                 4'b1110,4'b1101 : mux1out <= 2'b01;
                 4'b0100,4'b0101 : mux1out <= 2'b10;
                 default :         mux1out <= 2'b00;              
            endcase  
        end
    always @(phase or mux1out)
    begin
        case(phase)
            2'b10 : addrsel <= mux1out;
            default : addrsel <= 0;
        endcase
    end 
endmodule
