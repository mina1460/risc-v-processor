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
        {mem[3], mem[2], mem[1], mem[0]} = 32'h00000033;
        
        
        // {mem[7], mem[6], mem[5], mem[4]} = 32'h01900093; 
        // {mem[11], mem[10], mem[9], mem[8]} = 32'h06600113; 
        // {mem[15], mem[14], mem[13], mem[12]} = 32'h0020e133; 
        // {mem[19], mem[18], mem[17], mem[16]} = 32'h00c00193; 
        // {mem[23], mem[22], mem[21], mem[20]} = 32'h00100213; 
        // {mem[27], mem[26], mem[25], mem[24]} = 32'h004191b3; 
        // {mem[31], mem[30], mem[29], mem[28]} = 32'h0040d0b3; 
        // {mem[35], mem[34], mem[33], mem[32]} = 32'hffd00293; 
        // {mem[39], mem[38], mem[37], mem[36]} = 32'h4042d2b3; 
        // {mem[43], mem[42], mem[41], mem[40]} = 32'h00224233; 
        // {mem[47], mem[46], mem[45], mem[44]} = 32'h0030f1b3; 
        // {mem[51], mem[50], mem[49], mem[48]} = 32'h001280b3;
        // {mem[55], mem[54], mem[53], mem[52]} = 32'h40510133;
        // {mem[59], mem[58], mem[57], mem[56]} = 32'h00000073;
         








         
        {mem[7], mem[6], mem[5], mem[4]}     = 32'h00100093;
        {mem[11], mem[10], mem[9], mem[8]}   = 32'h0010a493;
        {mem[15], mem[14], mem[13], mem[12]} = 32'hffe00113;
        {mem[19], mem[18], mem[17], mem[16]} = 32'h00012433;
        {mem[23], mem[22], mem[21], mem[20]} = 32'h000133b3;
        {mem[27], mem[26], mem[25], mem[24]} = 32'hffc00193;
        {mem[31], mem[30], mem[29], mem[28]} = 32'h0041b313;
        {mem[35], mem[34], mem[33], mem[32]} = 32'h00000073; 
        // {mem[39], mem[38], mem[37], mem[36]} = 32'h;


    end 
    
    ///////Fetching Instructions////////// 
    /*need to make sure that memread and memwrite are never 1 when we want to fetch*/
    always@(*)
    begin
        if(clk_slow)
            inst_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
        else inst_out = 32'h33; //NOP   CHECK!!!!!
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
