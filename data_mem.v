module DataMem (
    input clk, input MemRead, input MemWrite,
    input [5:0] addr, input [31:0] data_in, 
    output [31:0] data_out);
 
    reg [7:0] mem [0:255];

    assign data_out = MemRead==1?mem[addr]:0;
    initial begin
     mem[0]=32'd5;
     mem[2]=32'd2;
     mem[3]=32'd1;
    end 
    
    always @(posedge clk) begin
        
        if (MemWrite==1) begin
            mem[addr] = data_in;
        end
    end

endmodule
