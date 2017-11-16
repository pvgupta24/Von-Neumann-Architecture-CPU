
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
    output wire irload, imload, pcsel, pcload, readwrite,  dwrite ;

    always @(*)
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

    always @(*)
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
    destRegWrite DR(op1op2,phase,dwrite,clk);
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
module irLoad(input [1:0] phase,output reg irload);
    always @(*)
    begin
        if(phase == 2'b01)
        //initial
            irload <=1;
        else
           irload <=0;
    end 
endmodule

// Flag deciding whether or not to load the immediate value
module imLoad(input [1:0] phase,input irbit7,output reg imload);
    always @(*)
    begin
        if(phase == 2'b10)
            imload = irbit7;
       // initial
         //   imload <= 1;//irbit7;
        else
            imload <= 0;
    end 
endmodule

//select line to decide the new value of the program counter 
module pcSelect(input [1:0] phase,output reg pcsel);
    always @(phase)
    begin
            pcsel <= 1;
    end 
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

//
module destRegWrite(op1op2,phase,dwrite,clk);
    input [3:0] op1op2;
    input [1:0] phase;
    input clk;
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
        if(phase ==2'b10)
            dwrite = mux1out;
        else
            dwrite = 0;
    end 
endmodule

// select line for the mux deciding the address of the next instruction
module addressSelect(op1op2,phase,addrsel);
    input [3:0] op1op2;
    input [1:0] phase;
    output reg [1:0] addrsel;
    reg [1:0] mux1out;
    always @(*)
        begin
            case(op1op2)
                 4'b1110,4'b1101 : mux1out <= 2'b01;
                 4'b0100,4'b0101 : mux1out <= 2'b10;
                 default :         mux1out <= 2'b00;              
            endcase  
        end
    /*always @(*)
    begin
        case(phase)
            2'b10 : addrsel <= mux1out;
            default : addrsel <= 0;
        endcase
    end */
    initial 
          addrsel <=0;
endmodule   
