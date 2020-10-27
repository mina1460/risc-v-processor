`timescale 1ns / 1ps


module processor_main(
    input clk, reset, 
    input [1:0] ledSel, 
    input [3:0] ssdSel,
    output reg [7:0] leds, 
    output reg [12:0] ssd
    );

/*
    data memory needs to handle loading and storing byte, half-words, and words with also unsigned
*/

    wire [31:0] pc, pc_next,  pc_adder_branch, pc_add4;
    wire pc_cout;
    wire [31:0] instruction;
///////////////////////////////
    wire [9:0] controls;
///////////////////////////////    
    wire [3:0] alu_selection;
    wire [31:0] write_data;     //output of MUX (selection between ALU output & read data memory)
    wire [31:0] read_data_1, read_data_2;
    wire [31:0] immgenOut;
    wire [31:0] ALU1ndInput, ALU2ndInput;
    wire [1:0] pc_selection;
    wire [31:0] ALUresult;
    wire zeroFlag;

    wire load = 1;
    n_bit_register PC (pc_next, clk,reset, load, pc);
    adder PC_add4 (pc, 4, 0, pc_add4, pc_cout);

    InstMem MEMinstructions (pc[7:2], instruction);
    cu controlUnit (instruction, controls);  
      
wire ImmSel   = controls[0];
wire MemRead  = controls[1];
wire MemWrite = controls[2];
wire [1:0] ToReg    = controls[4:3];
wire [1:0] ALUOP    = controls[6:5];
wire ALUSrc1  = controls[7];
wire ALUSrc2  = controls[8];
wire RegWrite = controls[9];

alu_cu ALUCntrl (instruction, ALUOP, alu_selection);

reg_file registerfile (write_data, instruction[19:15], instruction[24:20], instruction[11:7], controls[0], clk, reset, read_data_1, read_data_2);

ImmGen immediategen (immgenOut, instruction);

adder PC_addImm (pc, immgenOut, 0, pc_adder_branch, pc_cout);


wire cf, zf, vf, sf;
wire [4:0] shamt = instruction[24:20];
// NBit_MUX2x1 alu1input (PC, read_data_1, ALUSrc1, ALU1ndInput); 
NBit_MUX2x1 alu2input (immgenOut, read_data_2, ALUSrc2, ALU2ndInput); 
prv32_ALU ALU (ALU1ndInput, ALU2ndInput, shamt, ALUresult, cf, zf, vf, sf, alu_selection); 

branch_controls brcontrols (instruction[6:0], instruction[14:12], cf, zf, vf, sf, pc_selection);

wire [31:0] data_in = read_data_2;
wire [31:0] data_out;
DataMem datamem (clk, MemRead, MemWrite, ALUresult[7:0], data_in, data_out);
mux_4x1 wbmux (pc_add4, ALUresult, data_out, pc_adder_branch, ToReg, write_data);   

mux_4x1 pcmux (pc_add4, ALUresult, pc_adder_branch, 32'b0, pc_selection, pc_next);
