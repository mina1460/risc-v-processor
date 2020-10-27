`timescale 1ns / 1ps

/*
            // arithmetic
            4'b00_00 : r = add;     //add
            4'b00_01 : r = add;     //subtract
            4'b00_11 : r = b;       //propagate
            // logic
            4'b01_00:  r = a | b;   //or
            4'b01_01:  r = a & b;   //and
            4'b01_11:  r = a ^ b;   //xor
            // shift
            4'b10_00:  r=sh;        
            4'b10_01:  r=sh;
            4'b10_10:  r=sh;
            // slt & sltu
            4'b11_01:  r = {31'b0,(sf != vf)}; 
            4'b11_11:  r = {31'b0,(~cf)};    
*/

/*
  ALUOp
    00    add
    01    subtract
    10    depending on funct3 & funct7
    11    propagate
*/


module alu_cu( input [31:0] instr, input [1:0] aluOP, output reg [3:0] alu_selection );

    wire [5:0] controlW;
    
    // assign controlW = {aluOP,instr[14:12],instr[30]};
    assign controlW = {instr[30],instr[14:12],instr[6:0]};
    // wire [6:0] opcode = instr[6:0];

    always @(*) begin
        case (aluOP)
        6'b00 : alu_selection = 4'b00_00;      //add        (load, store, jalr)
        
        6'b01 : alu_selection = 4'b00_01;      //subtract   (branching)

        6'b11 : alu_selection = 4'b00_11;      //propagate  (LUI)

        6'b10 :                                //check opcode, funct3, & funct7
          begin
            casez (controlW)
              11'bX_000_0010011 : alu_selection = 4'b00_00;   //add   (ADDI)
              11'bX_010_0010011 : alu_selection = 4'b11_01;   //slt   (SLTI)
              11'bX_011_0010011 : alu_selection = 4'b11_11;   //sltu  (SLTIU)
              11'bX_100_0010011 : alu_selection = 4'b01_11;   //xor   (XORI)
              11'bX_110_0010011 : alu_selection = 4'b01_00;   //or    (ORI)
              11'bX_111_0010011 : alu_selection = 4'b01_01;   //and   (ANDI)
              11'b0_001_0010011 : alu_selection = 4'b10_00;   //sll   (SLLI)
              11'b0_101_0010011 : alu_selection = 4'b10_01;   //srl   (SRLI)
              11'b1_010_0010011 : alu_selection = 4'b10_10;   //sra   (SRAI)
              
              11'b0_000_0110011 : alu_selection = 4'b00_00;   //add   (ADD)
              11'b1_000_0110011 : alu_selection = 4'b00_01;   //sub   (SUB)
              11'b0_001_0110011 : alu_selection = 4'b10_00;   //sll   (SLL)
              11'b0_010_0110011 : alu_selection = 4'b11_01;   //slt   (SLT)
              11'b0_011_0110011 : alu_selection = 4'b11_11;   //sltu  (SLTU)
              11'b0_100_0110011 : alu_selection = 4'b01_11;   //xor   (XOR)
              11'b0_101_0110011 : alu_selection = 4'b10_01;   //srl   (SRL)
              11'b1_000_0110011 : alu_selection = 4'b10_10;   //sra   (SRA)
              11'b0_110_0110011 : alu_selection = 4'b01_00;   //or    (OR)
              11'b0_111_0110011 : alu_selection = 4'b01_01;   //and   (AND)
              
              default: alu_selection = 4'b00_11;

            endcase
          end

        default: alu_selection = 4'b00_00;   
      endcase  
      
    end
    
endmodule
