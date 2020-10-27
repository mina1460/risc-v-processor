
module branch_controls (input [6:0] opcode, input [2:0] funct3, input cf, zf, vf, sf, output [1:0] pc_selection);
always@(*)
    case(opcode)
        7'b1101111:  //jal
            pc_selection = 2'b10;       //result adder branch
        7'b1100111:
            pc_selection = 2'b01;       //ALU result jalr (pc = rs1 + immed << 1) 
        7'b1100011:
            begin 
                case(funct3)
                    3'b000: pc_selection = zf ? 2'b10 : 2'b00;  //BEQ 
                    
                    3'b001: pc_selection = zf ? 2'b00 : 2'b10;  //BNE (branch if ~zf)

                    3'b100: pc_selection = (sf != vf) ? 2'b10 : 2'b00;  //BLT

                    3'b101: pc_selection = (sf == vf) ? 2'b10 : 2'b00;  //BGE

                    3'b110: pc_selection = cf ? 2'b00 : 2'b10;  //BLTU (branch if ~cf)

                    3'b111: pc_selection = cf ? 2'b10 : 2'b00;  //BGEU
                    
                    default: pc_selection = 2'b11;
                endcase
            end

        default: pc_selection = 2'b11;
    
    endcase

end
endmodule 