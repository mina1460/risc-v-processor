`timescale 1ns / 1ps

 /* Control =          
     ImmSel     1bit    (signed or unsigned)
     MemRead    1bit    (read from memory)
     MemWrite   1bit    (write to memory)
     ToReg      2bits   (write to register)
     ALUOP      2bits   (Alu operation)   
     ALUSrc1    1bit    (First MUX selection to ALU)    
     ALUSrc2    1bit    (Second MUX selection to ALU)    
     RegWrite   1bit    (Write to register file)
     __________________________________________________
                10 bits
*/



module cu(input [31:0] instruction, output reg [9:0] controls);

    always @(*) begin
        casez (instruction[6:2])
        
            5'b01100:       //R-format Operations
                controls = 10'b0_0_0_01_10_0_0_1;
                
            5'b00000:       //Load Instructions
                controls = 10'b0_1_0_10_00_0_1_1;
        
            5'b01000:       //Store Instructions
                controls = 10'b0_0_1_00_00_0_1_0;

            5'b11000:       //Branch Instructions
                controls = 10'b0_0_0_00_01_0_1_0;     
            
            5'b01101:       //lui
                controls = 10'b0_0_0_01_11_0_1_1;

            5'b00101:       //auipc
                controls = 10'b0_0_0_11_00_1_1_1;  

            5'b11011:       //jal
                controls = 10'b0_0_0_00_00_1_1_1;

            5'b11001:       //jalr 
                controls = 10'b0_0_0_00_00_0_1_1;

            5'b00100:       //I type
                controls = 10'b0_0_0_01_10_0_1_1;
            
            default: 
                controls = 10'd0_0_0_00_00_0_0_0;

        endcase
    end
endmodule
