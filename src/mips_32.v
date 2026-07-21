`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2026 20:50:34
// Design Name: 
// Module Name: ALU
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


module mips_32(
input clk1
    );

    reg [31:0] PC,IF_ID_NPC,IF_ID_IR;//IF _ID
    reg [31:0] ID_EX_A,ID_EX_B,ID_EX_Imm,ID_EX_NPC,ID_EX_IR;// ID_EX
    reg [31:0] EX_MEM_ALU_OUT,EX_MEM_B,EX_MEM_IR;// EX_MEM
    reg EX_MEM_cond;// single bit(for branch instruction)
    reg [31:0] MEM_WB_LMD,MEM_WB_ALU_OUT,MEM_WB_IR;// MEM_WB
    reg [31:0] R_bank [0:31];// Register bank
    reg [31:0] IM [0:1023]; // instruction memory for storing instructions
    reg [31:0] DM [0:1023];  //Direct Memory for storing data
    reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;// to specify type of instr (RR,RI,LD,STR,BRCH)

    
    parameter ADD = 6'h0 , SUB = 6'h1, AND= 6'h2, OR=6'h3,
              SLT=6'h4, MUL=6'h5, HLT=6'h3F, LW=6'h8,
              SW=6'h9, ADDI=6'hA, SUBI=6'hB, SLTI=6'hC, BNEQZ=6'hD, 
              BEQZ=6'hE, NOP =6'hF;
              
    parameter RR_ALU=3'b000, RM_ALU=3'b001, LOAD=3'b010, STORE=3'b011,
              BRANCH=3'b100, HALT=3'b101, NOPE = 3'b110;
              
    reg HALTED;
    reg TAKEN_BRANCH;
    
    always@(posedge clk1) begin  //IF STAGE
    
    if(HALTED == 0) begin
    if(( EX_MEM_IR[31:26] ==BEQZ)&& (EX_MEM_cond == 1)||( EX_MEM_IR[31:26] ==BNEQZ)&& (EX_MEM_cond == 0)) begin
    
    IF_ID_IR <= IM[EX_MEM_ALU_OUT];
    IF_ID_NPC <= EX_MEM_ALU_OUT +1;
    PC <= EX_MEM_ALU_OUT +1;
    
    end
    else
    begin
    IF_ID_IR <=IM[PC];
    PC <= PC +1;
    IF_ID_NPC <= PC + 1;
    end
    
    end
    end
    
    always@(posedge clk1) begin  // ID STAGE
    
    if(HALTED == 0) begin

    ID_EX_NPC <= IF_ID_NPC;
    ID_EX_IR <= IF_ID_IR;
    ID_EX_Imm <= {{16{IF_ID_IR[15]}},{IF_ID_IR[15:0]}};
    
    if(IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0; // since R0 is 0
    else ID_EX_A <= R_bank[IF_ID_IR[25:21]];
    
    if(IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;
    else ID_EX_B <= R_bank[IF_ID_IR[20:16]];
    
    
      if(TAKEN_BRANCH == 1)ID_EX_type<=NOPE;
      
     
                                                    /* by this time,two extra instructions are fetched and so FLUSH THE EXTRA FETCHED INSTRUCTIONS
                                                  else decode the ID_EX_tupe based on opcode */
       
    else begin
    
    case (IF_ID_IR[31:26])
    ADD, SUB,AND,OR,SLT,MUL: ID_EX_type <= RR_ALU;
    ADDI,SUBI,SLTI         : ID_EX_type <= RM_ALU;
    LW                     : ID_EX_type <= LOAD;
    SW                     : ID_EX_type <= STORE;
    BEQZ                   : begin ID_EX_type <= BRANCH;
                                 if(R_bank[IF_ID_IR[25:21]]==0)
                                  TAKEN_BRANCH <= 1;   // check condition and set branch
                                  end
    BNEQZ                  : begin ID_EX_type <= BRANCH;
                                 if(R_bank[IF_ID_IR[25:21]]!=0)
                                  TAKEN_BRANCH <= 1;
                                  end          
      
    NOP                    : ID_EX_type <= NOPE;
    HLT                    : ID_EX_type <= HALT;
    default                : ID_EX_type <= NOPE;
    endcase
    end
    end
    end
    
    
    always@(posedge clk1) begin  // EX STAGE
    if(HALTED == 0) begin
    EX_MEM_type <= ID_EX_type;
    EX_MEM_IR <= ID_EX_IR;
    
    case (ID_EX_type)
    RR_ALU: begin
               case (ID_EX_IR[31:26])
                 ADD:    EX_MEM_ALU_OUT <= ID_EX_A + ID_EX_B;
                 SUB:    EX_MEM_ALU_OUT <= ID_EX_A - ID_EX_B;
                 AND:    EX_MEM_ALU_OUT <= ID_EX_A & ID_EX_B;
                 OR:    EX_MEM_ALU_OUT <= ID_EX_A | ID_EX_B;
                 SLT:    EX_MEM_ALU_OUT <= ID_EX_A < ID_EX_B;
                 MUL:    EX_MEM_ALU_OUT <= ID_EX_A * ID_EX_B;
                 default:    EX_MEM_ALU_OUT <= 32'hxxxxxxxx;
                 endcase
                 end
     RM_ALU: begin
                case (ID_EX_IR[31:26])
                 ADDI:    EX_MEM_ALU_OUT <= ID_EX_A + ID_EX_Imm;
                 SUBI:    EX_MEM_ALU_OUT <= ID_EX_A - ID_EX_Imm;
                 SLTI:    EX_MEM_ALU_OUT <= ID_EX_A < ID_EX_Imm;
                 default:    EX_MEM_ALU_OUT <= 32'hxxxxxxxx;
                 endcase
                 end 
     LOAD, STORE:
             begin
               EX_MEM_ALU_OUT <= ID_EX_A + ID_EX_Imm;
               EX_MEM_B       <= ID_EX_B;
              end
     BRANCH: begin
                EX_MEM_ALU_OUT <= ID_EX_NPC + ID_EX_Imm;
                EX_MEM_cond    <= (ID_EX_A == 0);
                end
                      
   
     endcase
     end          
     end
        
      always@(posedge clk1) begin   // MEM STAGE
      
      
        if(HALTED==0) begin
      
         MEM_WB_IR <= EX_MEM_IR;
         MEM_WB_type <= EX_MEM_type; 
         
         if(EX_MEM_type == BRANCH) begin
         TAKEN_BRANCH <= 0;                 // reset the TAKEN_BRANCH after two clock cycles
         end
         
         case (EX_MEM_type) 
         RR_ALU, RM_ALU:
                    MEM_WB_ALU_OUT <= EX_MEM_ALU_OUT;
         LOAD:      MEM_WB_LMD     <= DM[EX_MEM_ALU_OUT];
         STORE:     DM[EX_MEM_ALU_OUT] <= EX_MEM_B;
        
         endcase
         end
         end
         
              
    
    always@(posedge clk1) begin   // WB STAGE
    
    case(MEM_WB_type)
      RR_ALU: R_bank[MEM_WB_IR[15:11]] <= MEM_WB_ALU_OUT;
      RM_ALU: R_bank[MEM_WB_IR[20:16]] <= MEM_WB_ALU_OUT;
      LOAD:   R_bank[MEM_WB_IR[20:16]] <= MEM_WB_LMD; 
      HALT:   HALTED <= 1;
      endcase
      end
    
    
    
    
    
endmodule
