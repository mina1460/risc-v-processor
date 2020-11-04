`include "defines.v"

//https://blogs.sw.siemens.com/verificationhorizons/2020/06/09/systemverilog-multidimensional-arrays/
//http://classweb.ece.umd.edu/enee359a/verilog_tutorial.pdf
//https://link.springer.com/content/pdf/bbm%3A978-3-642-45309-0%2F1.pdf
//https://en.wikipedia.org/wiki/Endianness

// PC   ->  clk, posedge clk_slow, 0, 0, PC, X, LW, instr
// DATA 

/*
    addr MUX 2x1 - PC, ALU Result

    Memory mem (clk, clk_slow, MemRead, MemWrite, addr, data_in, funct3, data_out);

        MemRead -> output_ex_mem_controls [3];
        MemWrite -> output_ex_mem_controls [1];
        
        wire [8:0] memory_address;
        assign memory_address = clk_slow ? PC : ALU_result;
        Memory mem (clk, clk_slow, output_ex_mem_controls[3], output_ex_mem_controls[1], memory_address, read_data_2, funct3, data_out);

*/
module Memory (
    input clk, clk_slow,
    input MemRead, input MemWrite,
    input [8:0] addr,           //address is now 9 BITS to represent 512 
    input [31:0] data_in, 
    input [2:0] funct3, 
    output reg [31:0] data_out, inst_out
    );
 
    reg [7:0] mem [0:511]; //4 KB

    // assign data_out = MemRead==1?mem[addr]:0;
    
    wire msbb, msbh, msbw;
    assign msbb = mem[addr][7];         //most significant bit of byte
    assign msbh = mem[addr+1][7];       //most significant bit of half-word (2 bytes)

    initial begin
     mem[0]=32'd5;
     mem[2]=32'd2;
     mem[3]=32'd1;
    end 
    
    ///////Fetching Instructions////////// 
    /*need to make sure that memread and memwrite are never 1 when we want to fetch*/
    always@(*)
    begin
        if(clk_slow)
            inst_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
        else inst_out = 32'h51; //NOP   CHECK!!!!!
    end

    /////////loading//////////
    always@(*)
    begin
        if(MemRead == 1) begin
            case(funct3)
                `F3_LB:     data_out = {{24{msbb}}, mem[addr]};                               //LB
                `F3_LH:     data_out = {{16{msbh}}, mem[addr+1], mem[addr]};                  //LH
                `F3_LW:     data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};  //LW
                `F3_LBU:    data_out = {24'b0, mem[addr]};                  //LBU
                `F3_LHU:    data_out = {16'b0, mem[addr+1], mem[addr]};     //LHU
                default:    data_out = 32'b0;
            endcase
        end 
        else data_out = 32'b0;
    end


    /////////storing//////////
    always @(posedge clk) begin
        if (MemWrite==1) begin
            case (funct3)
                `F3_SB: mem[addr] = data_in[7:0]; //SB 
                `F3_SH: begin   //SH
                        mem[addr]   = data_in[7:0];
                        mem[addr+1] = data_in[15:7];    
                end
                `F3_SW: begin   //SW
                        mem[addr]   = data_in[7:0];
                        mem[addr+1] = data_in[15:8];  
                        mem[addr+2] = data_in[23:16];
                        mem[addr+3] = data_in[31:24];   
                end
                //default: mem[addr] = mem[addr];
            endcase  
        end
    end

endmodule
