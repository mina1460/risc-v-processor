
module InstMem (input [5:0] addr, output [31:0] data_out);
 reg [31:0] mem [0:63];
 assign data_out = mem[addr];
 
 initial begin
   // $readmemh ("C:\mina_sherif\hex_program.hex", mem);   
   mem[0] = 32'h00002083;
   mem[1] = 32'h00502103;
   mem[2] = 32'h001100b3;
   mem[3] = 32'h402080b3;
   mem[4] = 32'h00004f97;
   mem[5] = 32'h004fdf93;
   mem[6] = 32'h001fff93;
   mem[7] = 32'h00106f13;
   mem[8] = 32'h05ef9063;
   mem[9] = 32'h001fcf93;
   mem[10] = 32'h000f8463;
   mem[11] = 32'h00000fe7;
   mem[12] = 32'hfffff537;
   mem[13] = 32'h40c55513;
   mem[14] = 32'h02055463;
   mem[15] = 32'h00500193;
   mem[16] = 32'h0011f233;
   mem[17] = 32'h00100213;
   mem[18] = 32'h004212b3;
   mem[19] = 32'h005262b3;
   mem[20] = 32'h0042d2b3;
   mem[21] = 32'h00002083;
   mem[22] = 32'h00502103;
   mem[23] = 32'h01400c6f;
   mem[24] = 32'hfff00a13;
   mem[25] = 32'h01401023;
   mem[26] = 32'h00001b03;
   mem[27] = 32'h014b0c63;
   mem[28] = 32'hffe00593;
   mem[29] = 32'h00b015a3;
   mem[30] = 32'h00b00183;
   mem[31] = 32'h00b04203;
   mem[32] = 32'hfe4180e3;
 end
 
endmodule

