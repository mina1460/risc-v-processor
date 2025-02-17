module mux_4x1 #(parameter N=32) (input [N-1:0] a, b, c, d, input [1:0] selection, output reg [N-1:0] o);

always @(*)
    case(selection)
        2'b00: o = a;
        2'b01: o = b;
        2'b10: o = c;
        2'b11: o = d;
    endcase
end

endmodule 
