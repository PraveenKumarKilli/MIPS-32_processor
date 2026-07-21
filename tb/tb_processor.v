`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 16:42:37
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_mips_32(

    );
    
    reg clk1;
    integer i;
    mips_32 A(clk1);
    initial begin
    clk1 = 0;
    end
    
    always #5 clk1 = ~clk1;
    
    initial begin
    
    A.PC =0;
    A.HALTED = 0;
    A.TAKEN_BRANCH = 0;
    A.DM[200] = 10;
    for(i=0;i<31;i=i+1) A.R_bank[i] = 0; // initialisg register bank with 0
    
    A.IM[0] = 32'h280A00C8; //ADDI R10,R0,200
    A.IM[1] = 32'h28020001; //ADDI R2,R0,1
    A.IM[2] = 32'h3FFFFFFF; // NOP, R10 is not updated yet
    A.IM[3] = 32'h3FFFFFFF; // NOP , R10 is not updated yet
    A.IM[4] = 32'h21430000; //LW R3,0(R10)
    A.IM[5] = 32'h3FFFFFFF; // NOP
    A.IM[6] = 32'h3FFFFFFF; // NOP
    A.IM[7] = 32'h3FFFFFFF; // NOP, R3 hasn't updated yet
    A.IM[8] = 32'h14431000; // Loop: MUL R2,R2,R3
    A.IM[9] = 32'h2C630001; // SUBI R3,R3,1
    A.IM[10] = 32'h3FFFFFFF; // NOP
    A.IM[11] = 32'h3FFFFFFF; // NOP
    A.IM[12] = 32'h3FFFFFFF; // NOP , R3 hasn't updated
    A.IM[13] = 32'h3460FFFA; // BNEQZ R3, Loop
    A.IM[14] = 32'h2542FFFE; // SW R2,-2(R10)
    A.IM[15] = 32'hFFFFFFFF; // HLT

    end
    
    
endmodule
