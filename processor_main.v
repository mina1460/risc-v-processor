`timescale 1ns / 1ps


module processor_main(
    input clk, reset, 
    input [1:0] ledSel, 
    input [3:0] ssdSel,
    output reg [7:0] leds, 
    output reg [12:0] ssd
    );

/*
    ✔︎    1- merge inst and data memory 
    ✔︎    2- make them byte addressable 
    ✔︎    3- load data differently from different locations 
    ✔︎    4- make a slower clock using 1 bit counter for the outer clock. inner clock should have the same speed
    ✔︎    5- pipeline 
        6- add forwarding between EX and ID stage
        7- support FENCE, ECALL, EBREAK 
*/


    reg clk_slow;
    always @(posedge clk) begin
        clk_slow = clk_slow + 1;
    end


    /*******    IF   ********/
    wire [31:0] pc, pc_next,  pc_adder_branch, pc_add4;
    wire pc_cout;
    wire [31:0] instruction;
    wire [8:0] memory_address;  


    /*******    IF/ID   ********/
    wire [95:0] input_if_id;
    wire [31:0] output_if_id_inst, output_if_id_pc, output_if_id_pc_add4;
    wire [31:0] immgenOut;
    wire [9:0] controls;
    wire [31:0] read_data_1, read_data_2;


    /*******    ID/EX   ********/
    wire [195:0] input_id_ex;
    wire [9:0] output_id_ex_controls;
    wire [31:0] output_id_ex_pc, output_id_ex_pc_add4, output_id_ex_read_data_1, output_id_ex_read_data_2, output_id_ex_immgenOut;
    wire [3:0] output_id_ex_aluControl;
    wire [4:0] output_id_ex_destReg;
    wire [6:0] output_id_ex_opCode;
    wire [9:0] zero_future=0;
    wire [3:0] alu_selection;
    wire [31:0] ALU2ndInput;
    wire [31:0] ALUresult;
    wire cf, zf, vf, sf;
    wire [4:0] shamt;


    /*******    EX/MEM   ********/
    wire [151:0] input_ex_mem;
    wire [4:0] output_ex_mem_controls;
    wire [31:0] output_ex_mem_pc_addbranch, output_ex_mem_pc_add4, output_ex_mem_alu_result, output_ex_mem_read_data_2;
    wire output_ex_mem_cf, output_ex_mem_zf, output_ex_mem_vf, output_ex_mem_sf;
    wire [4:0] output_ex_mem_destReg;
    wire [6:0] output_ex_mem_opCode;
    wire [2:0] output_ex_mem_funct3;
    wire [1:0] pc_selection;


    /*******    MEM/WB   ********/
    wire [135:0] input_mem_wb;
    wire [4:0] output_mem_wb_destReg;
    wire [2:0] output_mem_wb_controls;
    wire [31:0] output_mem_wb_alu_result, output_mem_wb_data_out, output_mem_wb_pc_add4, output_mem_wb_pc_addbranch;

    wire [31:0] write_data;     //output of MUX (selection between ALU output & read data memory)
    
    wire load = 1;


    /*** IF STAGE ***/
        n_bit_register PC (pc_next, clk,reset, load, pc);
        adder PC_add4 (pc, 4, 0, pc_add4, pc_cout);
        
        assign memory_address = clk_slow ? pc[8:0] : output_ex_mem_alu_result [8:0];
        Memory mem (clk, clk_slow, output_ex_mem_controls[3], output_ex_mem_controls[2], memory_address, output_ex_mem_read_data_2, funct3, data_out, instruction);
        //InstMem MEMinstructions (pc[7:2], instruction);

    /*** ID STAGE ***/
    assign input_if_id = {pc, instruction, pc_add4};
    n_bit_register #(96) IF_ID_reg(input_if_id, clk, reset, 1, {output_if_id_pc, output_if_id_inst, output_if_id_pc_add4});
    
        cu controlUnit (output_if_id_inst, controls);    
        // wire Extra    = controls[9];
        // wire MemRead  = controls[8];
        // wire MemWrite = controls[7];
        // wire [1:0] ToReg  = controls[6:5];
        // wire [1:0] ALUOP  = controls[4:3];
        // wire ALUSrc1  = controls[2];
        // wire ALUSrc2  = controls[1];
        // wire RegWrite = controls[0];

        reg_file registerfile (write_data, output_if_id_inst[19:15], output_if_id_inst[24:20], output_mem_wb_destReg, output_mem_wb_controls[0], ~clk, reset, read_data_1, read_data_2);
        rv32_ImmGen immediategen (output_if_id_inst, immgenOut);


    /*** EX STAGE ***/
    assign input_id_ex = {controls, output_if_id_pc, read_data_1, read_data_2, immgenOut, output_if_id_inst[30], output_if_id_inst[14:12], output_if_id_inst[11:7], output_if_id_inst[6:0], output_if_id_pc_add4};
    n_bit_register #(196) ID_EX_reg (input_id_ex, clk, reset, 1, 
    {zero_future,output_id_ex_controls, output_id_ex_pc,output_id_ex_read_data_1, output_id_ex_read_data_2, output_id_ex_immgenOut, output_id_ex_aluControl, output_id_ex_destReg, output_id_ex_opCode, output_id_ex_pc_add4});
    
        wire [31:0] fake_inst_alu = {1'b0, output_id_ex_aluControl[3], 15'b0, output_id_ex_aluControl[2:0], 12'b0}; 
        alu_cu ALUCntrl (fake_inst_alu, output_id_ex_controls[4:3], alu_selection);
                                                                                                                                                                                 
        NBit_MUX2x1 alu2input (output_id_ex_immgenOut, output_id_ex_read_data_2, output_id_ex_controls[1], ALU2ndInput); 

        assign shamt = output_id_ex_read_data_2;
        prv32_ALU ALU (output_id_ex_read_data_1, ALU2ndInput, shamt, ALUresult, cf, zf, vf, sf, alu_selection); 

        adder PC_addImm (output_id_ex_pc, immgenOut, 0, pc_adder_branch, pc_cout);

    /*
        FORWARDING HERE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    */  
    
    /*** MEM STAGE ***/
    assign input_ex_mem = {output_id_ex_controls[8:5], output_id_ex_controls[0],pc_adder_branch,ALUresult,cf,zf,vf,sf,output_id_ex_read_data_2, output_id_ex_aluControl[2:0], output_id_ex_destReg, output_id_ex_opCode, output_id_ex_pc_add4};
    n_bit_register #(152) EX_MEM_reg (input_ex_mem, clk, reset, 1,
     {output_ex_mem_controls, output_ex_mem_pc_addbranch, output_ex_mem_alu_result, output_ex_mem_cf, output_ex_mem_zf, output_ex_mem_vf, output_ex_mem_sf, output_ex_mem_read_data_2, output_ex_mem_funct3, output_ex_mem_destReg, output_ex_mem_opCode, output_ex_mem_pc_add4});
        //output_ex_mem_controls -> MemRead 4 , MemWrite 3 , ToReg 2 1, RegWrite 0
        
        branch_controls brcontrols (output_ex_mem_opCode, output_ex_mem_funct3, output_ex_mem_cf, output_ex_mem_zf, output_ex_mem_vf, output_ex_mem_sf, pc_selection);
        
        mux_4x1 pcmux (pc_add4, output_ex_mem_alu_result, output_ex_mem_pc_addbranch, pc, pc_selection, pc_next);


    /*** WB STAGE***/        
    assign input_mem_wb = {output_ex_mem_controls[2:0], output_ex_mem_alu_result, data_out, output_ex_mem_destReg, output_ex_mem_pc_add4, output_ex_mem_pc_addbranch};
    n_bit_register #(136) MEM_WB_reg (input_mem_wb, clk, reset, 1, {output_mem_wb_controls, output_mem_wb_alu_result, output_mem_wb_data_out, output_mem_wb_destReg, output_mem_wb_pc_add4, output_mem_wb_pc_addbranch});     
        // output_mem_wb_controls --> ToReg 2 1, RegWrite 0
        
        mux_4x1 wbmux (output_mem_wb_pc_add4, output_mem_wb_alu_result, output_mem_wb_data_out, output_mem_wb_pc_addbranch, output_mem_wb_controls[2:1], write_data);   

    
    always @(*) begin
        
        case (ledSel)
            2'b00: leds = {controls[8:3], controls[1:0]};
            2'b01: leds = {ALUOP, cf, zf, vf, sf, pc_selection};
            2'b10: leds = alu_selection;
            2'b11: leds = ALUresult[7:0];      
        endcase
        
        case (ssdSel)
            4'b0000: ssd = pc;
            4'b0001: ssd = pc_add4;
            4'b0010: ssd = pc_adder_branch;
            4'b0011: ssd = pc_next;
            4'b0100: ssd = read_data_1;
            4'b0101: ssd = read_data_2;
            4'b0110: ssd = write_data;
            4'b0111: ssd = immgenOut;
            4'b1000: ssd = pc_selection;
            4'b1001: ssd = ALU2ndInput;
            4'b1010: ssd = ALUresult;
            4'b1011: ssd = data_out;
            default: ssd = instruction;
        endcase
       end
  
endmodule