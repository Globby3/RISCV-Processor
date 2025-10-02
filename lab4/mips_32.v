`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2

wire [9:0] jump_address;
wire [9:0] branch_address;
wire branch_taken;
wire jump;
wire [9:0] pc_plus_4, if_id_pc_plus4;
wire [31:0] instr, if_id_instr, id_ex_instr, ex_mem_instr;
wire Data_Hazard;
wire IF_Flush;
wire [31:0] write_back_data;
wire mem_to_reg, id_ex_mem_to_reg, ex_mem_mem_to_reg, mem_wb_mem_to_reg;
wire [1:0] alu_op, id_ex_alu_op;
wire mem_read, id_ex_mem_read, ex_mem_mem_read;
wire mem_write, id_ex_mem_write, ex_mem_mem_write;
wire alu_src, id_ex_alu_src;
wire reg_write, id_ex_reg_write, ex_mem_reg_write, mem_wb_reg_write;
wire [31:0] reg1, reg2, id_ex_reg1, id_ex_reg2;
wire [31:0] imm_value, id_ex_imm_value;
wire [4:0] destination_reg, id_ex_destination_reg, ex_mem_destination_reg, mem_wb_destination_reg;
wire [31:0] alu_result, ex_mem_alu_result, mem_wb_alu_result;
wire [31:0] alu_in2_out, ex_mem_alu_in2_out;
wire [1:0] Forward_A, Forward_B;
wire [31:0] mem_read_data, mem_wb_mem_read_data;


// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    IF_pipe_stage Instruction_Fetch (
        .clk(clk), 
        .reset(reset),
        .en(Data_Hazard),
        .branch_address(branch_address), //[9:0]
        .jump_address(jump_address), // [9:0] 
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus_4), //[9:0]
        .instr(instr)); //[31:0]

///////////////////////////// Instruction Decode 
	ID_pipe_stage Instruction_decode (
        .clk(clk), 
        .reset(reset),
        .pc_plus4(if_id_pc_plus4), //[9:0]
        .instr(if_id_instr), //[31:0]
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg), //[4:0]
        .mem_wb_write_back_data(write_back_data), //[31:0]
        .Data_Hazard(Data_Hazard),
        .Control_Hazard(IF_Flush), //
        .reg1(reg1), //[31:0]
        .reg2(reg2), //[31:0]
        .imm_value(imm_value), //[31:0]
        .branch_address(branch_address), //[9:0] 
        .jump_address(jump_address), //[9:0] 
        .branch_taken(branch_taken),
        .destination_reg(destination_reg), //[4:0] 
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op), //[1:0]
        .mem_read(mem_read),  
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump));

///////////////////////////// Execution    
	// Complete your code here
	 EX_pipe_stage Execution (
         .id_ex_instr(id_ex_instr), //[31:0]
         .reg1(id_ex_reg1), //[31:0]
         .reg2(id_ex_reg2), //[31:0]
         .id_ex_imm_value(id_ex_imm_value), //[31:0]
         .ex_mem_alu_result(ex_mem_alu_result), //[31:0]
         .mem_wb_write_back_result(write_back_data), //[31:0]
         .id_ex_alu_src(id_ex_alu_src),
         .id_ex_alu_op(id_ex_alu_op), //[1:0]
         .Forward_A(Forward_A), //[1:0]
         .Forward_B(Forward_B), //[1:0]
         .alu_in2_out(alu_in2_out), //[31:0]
         .alu_result(alu_result)); //[31:0]

///////////////////////////// Hazard_detection unit
	Hazard_detection Hazard_detection(
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_destination_reg(id_ex_destination_reg), //[4:0]
        .if_id_rs(if_id_instr[25:21]), //[4:0] 
        .if_id_rt(if_id_instr[20:16]), //[4:0]
        .branch_taken(branch_taken), 
        .jump(jump),
        .Data_Hazard(Data_Hazard),
        .IF_Flush(IF_Flush)); //
       
        
///////////////////////////// Forwarding unit
    EX_Forwarding_unit Forwarding_unit(
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_write_reg_addr(ex_mem_destination_reg), //[4:0] 
        .id_ex_instr_rs(id_ex_instr[25:21]), //[4:0] 
        .id_ex_instr_rt(id_ex_instr[20:16]), //[4:0] 
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg), //[4:0]
        .Forward_A(Forward_A), //[1:0] 
        .Forward_B(Forward_B)); //[1:0] 
        
///////////////////////////// memory  
    data_memory data_mem (
        .clk(clk),
        .mem_access_addr(ex_mem_alu_result), //[31:0]
        .mem_write_data(ex_mem_alu_in2_out), //[31:0] 
        .mem_write_en(ex_mem_mem_write),
        .mem_read_en(ex_mem_mem_read),
        .mem_read_data(mem_read_data)); //[31:0]         
        
        
        
        
        
        
        
        
        
///////////////////////////// IF/ID registers******************************************************
    pipe_reg_en #(.WIDTH(10)) IF_ID_pc_plus_4_reg (
        .clk(clk), 
        .reset(reset),
        .en(Data_Hazard), 
        .flush(IF_Flush),
        .d(pc_plus_4), //[WIDTH-1:0] 
        .q(if_id_pc_plus4)); //[WIDTH-1:0] 
        
    pipe_reg_en #(.WIDTH(32)) IF_ID_instr_reg ( 
        .clk(clk), 
        .reset(reset),
        .en(Data_Hazard), 
        .flush(IF_Flush),
        .d(instr), //[WIDTH-1:0] 
        .q(if_id_instr)); //[WIDTH-1:0]         
    
             
///////////////////////////// ID/EX registers ******************************************************
    pipe_reg #(.WIDTH(32)) ID_EX_if_id_instr_reg (
        .clk(clk), 
        .reset(reset),
        .d(if_id_instr), //[WIDTH-1:0] 
        .q(id_ex_instr)); //[WIDTH-1:0]
        
    pipe_reg #(.WIDTH(32)) ID_EX_reg1_reg (
        .clk(clk), 
        .reset(reset),
        .d(reg1), //[WIDTH-1:0] 
        .q(id_ex_reg1)); //[WIDTH-1:0]        

    pipe_reg #(.WIDTH(32)) ID_EX_reg2_reg (
        .clk(clk), 
        .reset(reset),
        .d(reg2), //[WIDTH-1:0] 
        .q(id_ex_reg2)); //[WIDTH-1:0]         
    
    pipe_reg #(.WIDTH(32)) ID_EX_imm_value_reg (
        .clk(clk), 
        .reset(reset),
        .d(imm_value), //[WIDTH-1:0] 
        .q(id_ex_imm_value)); //[WIDTH-1:0]    

    pipe_reg #(.WIDTH(5)) ID_EX_destination_reg ( 
        .clk(clk), 
        .reset(reset),
        .d(destination_reg), //[WIDTH-1:0] 
        .q(id_ex_destination_reg)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) ID_EX_mem_to_reg ( 
        .clk(clk), 
        .reset(reset),
        .d(mem_to_reg), //[WIDTH-1:0] 
        .q(id_ex_mem_to_reg)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(2)) ID_EX_alu_op_reg (
        .clk(clk), 
        .reset(reset),
        .d(alu_op), //[WIDTH-1:0] 
        .q(id_ex_alu_op)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) ID_EX_mem_read_reg (
        .clk(clk), 
        .reset(reset),
        .d(mem_read), //[WIDTH-1:0] 
        .q(id_ex_mem_read)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) ID_EX_mem_write_reg ( 
        .clk(clk), 
        .reset(reset),
        .d(mem_write), //[WIDTH-1:0] 
        .q(id_ex_mem_write)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) ID_EX_alu_src_reg (
        .clk(clk), 
        .reset(reset),
        .d(alu_src), //[WIDTH-1:0] 
        .q(id_ex_alu_src)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) ID_EX_reg_write_reg (
        .clk(clk), 
        .reset(reset),
        .d(reg_write), //[WIDTH-1:0] 
        .q(id_ex_reg_write)); //[WIDTH-1:0] 
     
///////////////////////////// EX/MEM registers******************************************************
    pipe_reg #(.WIDTH(32)) EX_MEM_ex_instr_reg (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_instr), //[WIDTH-1:0] 
        .q(ex_mem_instr)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(5)) EX_MEM_ex_destination_reg (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_destination_reg), //[WIDTH-1:0] 
        .q(ex_mem_destination_reg)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(32)) EX_MEM_alu_result_reg (
        .clk(clk), 
        .reset(reset),
        .d(alu_result), //[WIDTH-1:0] 
        .q(ex_mem_alu_result)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(32)) EX_MEM_alu_in2_out_reg (
        .clk(clk), 
        .reset(reset),
        .d(alu_in2_out), //[WIDTH-1:0] 
        .q(ex_mem_alu_in2_out)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) EX_MEM_ex_mem_to_reg (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_mem_to_reg), //[WIDTH-1:0] 
        .q(ex_mem_mem_to_reg)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) EX_MEM_ex_mem_read_reg (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_mem_read), //[WIDTH-1:0] 
        .q(ex_mem_mem_read)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) EX_MEM_ex_mem_write_reg (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_mem_write), //[WIDTH-1:0] 
        .q(ex_mem_mem_write)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) EX_MEM_ex_reg_write_reg (
        .clk(clk), 
        .reset(reset),
        .d(id_ex_reg_write), //[WIDTH-1:0] 
        .q(ex_mem_reg_write)); //[WIDTH-1:0] 
    

///////////////////////////// MEM/WB registers  ******************************************************
    pipe_reg #(.WIDTH(32)) MEM_WB_mem_alu_result_reg (
        .clk(clk), 
        .reset(reset),
        .d(ex_mem_alu_result), //[WIDTH-1:0] 
        .q(mem_wb_alu_result)); //[WIDTH-1:0] 
 
    pipe_reg #(.WIDTH(32)) MEM_WB_mem_read_data_reg (
        .clk(clk), 
        .reset(reset),
        .d(mem_read_data), //[WIDTH-1:0] 
        .q(mem_wb_mem_read_data)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) MEM_WB_mem_mem_to_reg (
        .clk(clk), 
        .reset(reset),
        .d(ex_mem_mem_to_reg), //[WIDTH-1:0] 
        .q(mem_wb_mem_to_reg)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(1)) MEM_WB_mem_reg_write_reg (
        .clk(clk), 
        .reset(reset),
        .d(ex_mem_reg_write), //[WIDTH-1:0] 
        .q(mem_wb_reg_write)); //[WIDTH-1:0] 

    pipe_reg #(.WIDTH(5)) MEM_WB_mem_destination_reg (
        .clk(clk), 
        .reset(reset),
        .d(ex_mem_destination_reg), //[WIDTH-1:0] 
        .q(mem_wb_destination_reg)); //[WIDTH-1:0] 
    
///////////////////////////// writeback ******************************************************
    mux2 #(.mux_width(32)) writeback_mux (
        .a(mem_wb_alu_result), // [mux_width-1:0]
        .b(mem_wb_mem_read_data), // [mux_width-1:0]
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data)); // [mux_width-1:0]
    
assign result = write_back_data;
    
    
    
endmodule
