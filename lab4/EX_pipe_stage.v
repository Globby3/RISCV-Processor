`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [3:0] alu_control_out; 
    wire [31:0] muxA_out;
    wire [31:0] ALUmux_out;
    
    ALUControl ALUcontrol(
        .ALUOp(id_ex_alu_op), //[1:0]
        .Function(id_ex_instr[5:0]), // [5:0] 
        .ALU_Control(alu_control_out)); //[3:0]
        
    ALU alu (    
    .a(muxA_out), // [31:0]   
    .b(ALUmux_out), // [31:0] 
    .alu_control(alu_control_out), // [3:0] 
    .zero(), //UNCONNECTED PORT
    .alu_result(alu_result)); // [31:0]          
        
    mux4 #(.mux_width(32)) muxA (
        .a(reg1), // [mux_width-1:0] 
        .b(mem_wb_write_back_result), // [mux_width-1:0]
        .c(ex_mem_alu_result),// [mux_width-1:0]
        .d(), //UNCONNECTED PORT
        .sel(Forward_A), // [1:0] 
        .y(muxA_out)); // [mux_width-1:0]     
        
    mux4 #(.mux_width(32)) muxB (
        .a(reg2), // [mux_width-1:0] 
        .b(mem_wb_write_back_result), // [mux_width-1:0]
        .c(ex_mem_alu_result),// [mux_width-1:0]
        .d(), //UNCONNECTED PORT
        .sel(Forward_B), // [1:0] 
        .y(alu_in2_out)); // [mux_width-1:0]        
        
    mux2 #(.mux_width(32)) ALUmux (
        .a(alu_in2_out), // [mux_width-1:0]
        .b(id_ex_imm_value), // [mux_width-1:0]
        .sel(id_ex_alu_src),
        .y(ALUmux_out)); // [mux_width-1:0]
               
       
endmodule

