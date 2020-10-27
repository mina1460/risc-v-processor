module and_operation #(parameter N=32) (input [N-1:0] A, B, output [N-1:0] C);
    
    assign C = A & B;
endmodule

module or_operation #(parameter N=32) (input [N-1:0] A, B, output [N-1:0] C);
    
    assign C = A | B;
endmodule