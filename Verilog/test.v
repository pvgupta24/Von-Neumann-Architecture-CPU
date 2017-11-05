`timescale 1ns/100ps

module test;
    reg clk,zero, negative, irload,imload, pcsel,pcload,readwrite,dwrite;

    //wire [7:0] irvalue;
    wire [7:0] irvalue,dbus,sbus,dval,pcin,imm,datain,aluout,address;
    reg [1:0] dregsel, sregsel, aluop, regsel, addrsel;

    cpu CPU(clk,zero, negative, irload,imload, pcsel,pcload,readwrite,dwrite,
            irvalue,dbus,sbus,dval,pcin,imm,datain,aluout,address,
            dregsel, sregsel, aluop,regsel, addrsel);


    initial
        begin
            $dumpfile("wave.vcd");
            $dumpvars(0,test);
            $display("8-Bit Von Neumann CPU");
            //$display("");

            clk <= 1'b0;
            zero <= 1'b0;
            negative <= 1'b0;
            irload <= 1'b0;
            imload <= 1'b0;
            pcsel <= 1'b0;
            pcload <= 1'b0;
            readwrite <= 1'b0;
            dwrite <= 1'b0;
            
            /*
            //irvalue <= 8'b00000000;
            dbus <= 8'b00000000;
            sbus <= 8'b00000000;
            dval <= 8'b00000000;
            pcin <= 8'b00000000;
            imm <= 8'b00000000;
            datain <= 8'b00000000;
            aluout <= 8'b00000000;
            address <= 8'b00000000;
            imm <= 8'b00000000;*/

            dregsel <= 2'b00;
            sregsel <= 2'b00;
            aluop <= 2'b00;
            regsel <= 2'b00;
            addrsel <= 2'b00;

        end
    initial
        forever
        #5 clk = ~clk;

    initial
        begin//fork
            #100;          
            $finish;
        end//join
    initial
            $monitor("Phasekk = %b",);
            //$monitor("%gns\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",$time,ir,irbit7,irbit6,irbit5,irbit4,op1,op2,rs,rd,op1op2);

endmodule
