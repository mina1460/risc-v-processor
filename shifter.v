module shifter (input [31:0] a, input [4:0] shamt, input [1:0] type, output reg [31:0] r);
//shifter shifter0(.a(a), .shamt(shamt), .type(alufn[1:0]),  .r(sh));

/*
            4'b10_00:  r=sh;        //sll        
            4'b10_01:  r=sh;        //srl
            4'b10_10:  r=sh;        //sra
*/
        always@(*)

            case (type)
                2'b00 :   r = a << shamt;       //sll
                2'b01 :   r = a >> shamt;       //srl
                2'b10 :   r = a >>> shamt;      //sra
                default:  r = a;
            endcase

        end


endmodule 
    

    //https://www.ece.lsu.edu/v/2017/shifter.v.html