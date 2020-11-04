`timescale 1ns / 1ps


module processor_main(
    input clk, reset, 
    input [1:0] ledSel, 
    input [3:0] ssdSel,
    output reg [7:0] leds, 
    output reg [12:0] ssd
    );
    
    
    /*******    IF   ********/
    wire [31:0] pc, pc_next,  pc_adder_branch, pc_add4;
    wire pc_cout;
    wire [31:0] instruction;


    /*******    IF/ID   ********/
    wire [63:0] input_if_id;
    wire [31:0] output_if_id_inst, output_if_id_pc;
    wire [31:0] immgenOut;
    wire [7:0] controls;
    wire [31:0] read_data_1, read_data_2;


    /*******    ID/EX   ********/
    wire [154:0] input_id_ex;
    wire [7:0] output_id_ex_controls;
    wire [31:0] output_id_ex_pc, output_id_ex_read_data_1, output_id_ex_read_data_2, output_id_ex_immgenOut;
    wire [3:0] output_id_ex_aluControl;
    wire [4:0] output_id_ex_destReg;
    wire [9:0] zero_future=0;
    wire [3:0] alu_selection;
    wire [31:0] ALU2ndInput;
    wire [31:0] ALUresult;
    wire zeroFlag;
    wire [31:0] shiftedImm;


    /*******    EX/MEM   ********/
    wire [106:0] input_ex_mem;
    wire [4:0] output_ex_mem_controls;
    wire [31:0] output_ex_mem_pc_addbranch, output_ex_mem_alu_result, output_ex_mem_read_data_2;
    wire output_ex_mem_zeroflag;
    wire [4:0] output_ex_mem_destReg;
    wire pc_selection;


    /*******    MEM/WB   ********/
    wire [70:0] input_mem_wb;
    wire [4:0] output_mem_wb_destReg;
    wire [1:0] output_mem_wb_controls;
    wire [31:0] output_mem_wb_alu_result, output_mem_wb_data_out;

    wire [31:0] write_data;     //output of MUX (selection between ALU output & read data memory)
    
    wire load = 1;
    
    
    n_bit_register PC (pc_next, clk,reset, load, pc);
    adder PC_add4 (pc, 4, 0, pc_add4, pc_cout);
 
    InstMem MEMinstructions (pc[7:2], instruction);
    
 
    assign input_if_id = {pc, instruction};
    n_bit_register #(64) IF_ID_reg(input_if_id, clk, reset, 1, {output_if_id_pc, output_if_id_inst});
    
        cu controlUnit (output_if_id_inst, controls);    // Control = [Branch, MemRead, MemToReg, 2 ALUOP, MemWrite, ALUSrc, RegWrite]
                                                    //                    7       6       5         4 3       2        1        0                
        reg_file registerfile (write_data, output_if_id_inst[19:15], output_if_id_inst[24:20], output_mem_wb_destReg, output_mem_wb_controls[0], ~clk, reset, read_data_1, read_data_2);
        ImmGen immediategen (immgenOut, output_if_id_inst);


    assign input_id_ex = {controls, output_if_id_pc, read_data_1, read_data_2, immgenOut, output_if_id_inst[30], output_if_id_inst[14:12], output_if_id_inst[11:7]};
    n_bit_register #(155) ID_EX_reg (input_id_ex, clk, reset, 1, 
    {zero_future,output_id_ex_controls, output_id_ex_pc,output_id_ex_read_data_1, output_id_ex_read_data_2, output_id_ex_immgenOut, output_id_ex_aluControl,output_id_ex_destReg});
    
        
        wire [31:0] fake_inst_alu = {1'b0,output_id_ex_aluControl[3],15'b0,output_id_ex_aluControl[2:0],12'b0}; 
        alu_cu ALUCntrl (fake_inst_alu, output_id_ex_controls[4:3], alu_selection);                                                                      
                                                                                                            
        NBit_MUX2x1 alu2input (output_id_ex_immgenOut, output_id_ex_read_data_2, output_id_ex_controls[1], ALU2ndInput); 
        N_bit_ALU_with_Zero_flag ALU (alu_selection, output_id_ex_read_data_1, ALU2ndInput, ALUresult, zeroFlag); 
        
        n_bit_shift_1_left leftshiftImm (output_id_ex_immgenOut,shiftedImm);
        adder PC_addImm (output_id_ex_pc, shiftedImm, 0, pc_adder_branch, pc_cout);
    
    
    
    assign input_ex_mem = {output_id_ex_controls[7:5],output_id_ex_controls[2],output_id_ex_controls[0],pc_adder_branch,ALUresult,zeroFlag,output_id_ex_read_data_2,output_id_ex_destReg};
    n_bit_register #(107) EX_MEM_reg (input_ex_mem, clk, reset, 1,
     {output_ex_mem_controls, output_ex_mem_pc_addbranch, output_ex_mem_alu_result, output_ex_mem_zeroflag, output_ex_mem_read_data_2, output_ex_mem_destReg});
        
        // output_ex_mem_controls      --> Branch 4, MemRead 3, MemToReg 2, MemWrite 1, RegWrite 0
        
        wire [31:0] data_in = output_ex_mem_read_data_2;
        wire [31:0] data_out;
        DataMem datamem (clk, output_ex_mem_controls[3], output_ex_mem_controls[1], output_ex_mem_alu_result[7:2], data_in, data_out);
        
        and(pc_selection, output_ex_mem_zeroflag, output_ex_mem_controls[4]);
        NBit_MUX2x1 pc_input_mux (output_ex_mem_pc_addbranch, pc_add4, pc_selection, pc_next);
        
        
    assign input_mem_wb = {output_ex_mem_controls[2] ,output_ex_mem_controls[0], output_ex_mem_alu_result, data_out, output_ex_mem_destReg};
    n_bit_register #(71) MEM_WB_reg (input_mem_wb, clk, reset, 1, {output_mem_wb_controls, output_mem_wb_alu_result, output_mem_wb_data_out, output_mem_wb_destReg});
               
        // output_mem_wb_controls --> MemToReg 1, RegWrite 0
             
        NBit_MUX2x1 Write_back_value (output_mem_wb_data_out, output_mem_wb_alu_result, output_mem_wb_controls[1], write_data);

    

    always @(*) begin
        
        case (ledSel)
            2'b00: leds = controls;
            2'b01: leds = {1'b0, alu_selection, zeroFlag, controls[7], pc_selection};
            2'b10: leds = {pc[7:0]};
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
            4'b1000: ssd = shiftedImm;
            4'b1001: ssd = ALU2ndInput;
            4'b1010: ssd = ALUresult;
            4'b1011: ssd = data_out;
            default: ssd = instruction;
        endcase
    
    
    end

endmodule




