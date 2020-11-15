module forwarding_unit(
        input [4:0] rs1, rs2,
        input [4:0] rd,
        input RegWrite,
        output forwardA, forwardB
        );
        assign forwardA = (rd != 0 && rs1 == rd && RegWrite);
        assign forwardB = (rd != 0 && rs2 == rd && RegWrite);

endmodule 