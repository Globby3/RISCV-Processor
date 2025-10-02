`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
    
    wire top_mux_sel;
    wire eq_tst_out; 
    wire branch;
    wire reg_dst; 
    wire [1:0] w_alu_op;
    wire w_mem_to_reg, w_mem_read, w_mem_write, w_alu_src, w_reg_write; 
    wire [31:0] sign_ext_out;
    
    
   control control (
    .reset(reset),
    .opcode(instr[31:26]),  
    .reg_dst(reg_dst), 
    .mem_to_reg(w_mem_to_reg), 
    .alu_op(w_alu_op),  
    .mem_read(w_mem_read),
    .mem_write(w_mem_write),
    .alu_src(w_alu_src),
    .reg_write(w_reg_write),
    .branch(branch),
    .jump(jump));    

   mux2 #(.mux_width(1)) top_mux1 ( 
        .a(w_mem_to_reg), // [mux_width-1:0] 
        .b(1'b0),// [mux_width-1:0] 
        .sel(top_mux_sel),
        .y(mem_to_reg)); // [mux_width-1:0] 
        
   mux2 #(.mux_width(2)) top_mux2 (
        .a(w_alu_op), // [mux_width-1:0] 
        .b(2'b00), // [mux_width-1:0] 
        .sel(top_mux_sel),
        .y(alu_op)); // [mux_width-1:0] 
        
   mux2 #(.mux_width(1)) top_mux3 (
        .a(w_mem_read),// [mux_width-1:0] 
        .b(1'b0), // [mux_width-1:0] 
        .sel(top_mux_sel),
        .y(mem_read)); // [mux_width-1:0] 
        
   mux2 #(.mux_width(1)) top_mux4 (
        .a(w_mem_write), // [mux_width-1:0] 
        .b(1'b0),
        .sel(top_mux_sel), // [mux_width-1:0] 
        .y(mem_write)); // [mux_width-1:0] 
        
   mux2 #(.mux_width(1)) top_mux5 (
        .a(w_alu_src), // [mux_width-1:0] 
        .b(1'b0), // [mux_width-1:0] 
        .sel(top_mux_sel),
        .y(alu_src)); // [mux_width-1:0] 
        
   mux2 #(.mux_width(1)) top_mux6 (
        .a(w_reg_write), // [mux_width-1:0] 
        .b(1'b0), // [mux_width-1:0] 
        .sel(top_mux_sel), 
        .y(reg_write)); // [mux_width-1:0]                                      
        
   register_file reg_file (
    .clk(clk),
    .reset(reset),
    .reg_write_en(mem_wb_reg_write),
    .reg_write_dest(mem_wb_write_reg_addr),
    .reg_write_data(mem_wb_write_back_data),
    .reg_read_addr_1(instr[25:21]), 
    .reg_read_addr_2(instr[20:16]),  
    .reg_read_data_1(reg1),  
    .reg_read_data_2(reg2));
    
    
   sign_extend sign_extend (
    .sign_ex_in(instr[15:0]),
    .sign_ex_out(sign_ext_out));
    
    mux2 #(.mux_width(5)) bot_mux (
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg));    
     
    assign eq_tst_out = ((reg1 ^ reg2) == 32'd0) ? 1'b1: 1'b0;
    assign branch_taken = eq_tst_out & branch;
    assign top_mux_sel = ~(Data_Hazard) || Control_Hazard;
    assign jump_address = instr[25:0] << 2;
    assign imm_value = sign_ext_out;
    assign branch_address = pc_plus4 + (sign_ext_out << 2);

       
endmodule
