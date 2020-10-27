`timescale 1ns / 1ps


module n_bit_shift_1_left #(parameter N = 32) (input [N-1:0] i, output [N-1:0] o);

  assign o = {i[N-2:0],1'b0};
endmodule

