`timescale 1ns / 1ps


module NBit_MUX2x1  #(parameter N = 32) (input [N-1:0]A, B,input S, output  [N-1:0]C);  
      
     assign  C = S?A:B;
      
    // always@(*)
    // begin 
    //     C = S?A:B;
    // end

endmodule


