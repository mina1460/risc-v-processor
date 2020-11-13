module hazard_control_unit (
        input [1:0] pc_selection,  
        output reg controls_zero); 
//
always@(*)
begin 
    case(pc_selection)

        2'b00: controls_zero = 0;
        2'b01: controls_zero = 1;
        2'b10: controls_zero = 1;
        2'b11: controls_zero = 1;
    
    endcase
end

endmodule 