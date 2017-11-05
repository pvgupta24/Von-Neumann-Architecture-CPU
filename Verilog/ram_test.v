/*`timescale 1ns/100ps

module ram_test;
    reg clk,we;
    reg [7:0]data,addr;
    wire [7:0] q;    
    
    ram RAM(.data(data),.addr(addr),.we(we),.clk(clk),.q(q));
    initial
        begin//fork
            clk=1'b0;
            we = 1'b1;
            addr=8'b00000000;
            data =8'b00000000;
            #5;       
            we=1'b0;
            addr=8'b00000000;
            #5;      
            addr=8'b00000010;
            #5;   
            $finish;
        end//join    
    initial
        forever
        #5 clk = ~clk;
    initial
            $monitor("RAM %d = %b",addr,q);
            //$monitor("%gns\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b",$time,ir,irbit7,irbit6,irbit5,irbit4,op1,op2,rs,rd,op1op2);

endmodule*/