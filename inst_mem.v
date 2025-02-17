
module InstMem (input [5:0] addr, output [31:0] data_out);
 reg [31:0] mem [0:63];
 assign data_out = mem[addr];
 
 initial begin
   /* mem[0]=32'b0000000_00000_00000_000_00000_0110011 ;       //add x0, x0, x0
    mem[1]=32'b000000000000_00000_010_00001_0000011 ;        //lw x1, 0(x0)
    mem[2]=32'b000000000100_00000_010_00010_0000011 ;        //lw x2, 4(x0)
    mem[3]=32'b000000001000_00000_010_00011_0000011 ;        //lw x3, 8(x0)
    mem[4]=32'b0000000_00010_00001_110_00100_0110011 ;       //or x4, x1, x2
    mem[5]=32'b0_000000_00011_00100_000_0100_0_1100011 ;     //beq x4, x3, L
    mem[6]=32'b0000000_00010_00001_000_00011_0110011 ;       //add x3, x1, x2
    mem[7]=32'b0000000_00010_00011_000_00101_0110011 ;       //L: add x5,x3,x2
    mem[8]=32'b0000000_00101_00000_010_01100_0100011;        //sw x5, 12(x0)
    mem[9]=32'b000000001100_00000_010_00110_0000011 ;        //lw x6, 12(x0)
    mem[10]=32'b0000000_00001_00110_111_00111_0110011 ;      //and x7, x6, x1
    mem[11]=32'b0100000_00010_00001_000_01000_0110011 ;      //sub x8, x1, x2
    mem[12]=32'b0000000_00010_00001_000_00000_0110011 ;      //add x0, x1, x2
    mem[13]=32'b0000000_00001_00000_000_01001_0110011 ;      //add x9, x0, x1
   */
 
 /*  
   mem[0]=32'h00002083;     //lw x1, 0(x0)
   mem[1]=32'h00802103;     //lw x2, 8(x0)
   mem[2]=32'h0010A023;     //sw x1, 0(x1)     
   mem[3]=32'h0000A103;     //lw x2, 0(x1)
   mem[4]=32'h00208463;     //beq x1, x2, sherif_mina    
   mem[5]=32'h00100033;     //add x0, x0, x1
   mem[6]=32'h00112023;     //sw x1, 0(x2)
   mem[7]=32'h001170B3;     //and x1, x2, x1
   mem[8]=32'h001160B3;     //or x1, x2, x1
   mem[9]=32'h401100B3;     //sub x1, x2, x1
   */
   
      mem[0]=32'h00002083;     //lw x1, 0(x0)
      mem[1]=32'h00802103;     //lw x2, 8(x0)
      mem[2]=32'h00C02183;     //lw x3, 12(x0)     
      mem[3]=32'h00210133;     //loop: add x2, x2, x2
      mem[4]=32'h403080B3;     //sub x1, x1, x3    
      mem[5]=32'h00008463;     //beq x1, x0, end_loop
      mem[6]=32'hFE000AE3;     //beq x0, x0, loop
      mem[7]=32'h0001F1B3;     //end_loop: and x3, x3, x0
      mem[8]=32'h003161B3;     //or x3, x2, x3
      mem[9]=32'h00302E23;     //sw x3, 28(x0)
 end
 
endmodule

//32'h4D62A303 1238 (binary 010011010110) LW 010011010110 00101 010 00110_0000011
//32'hDCA7AF23 -546 (binary 1101110 11110) SW 1101110 01010 01111 010 11110 0100011
//32'h18E18F63 207 (binary 0 0 001100 1111) BEQ 0001100 01110 00011 000 11110 1100011