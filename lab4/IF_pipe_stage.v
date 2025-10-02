`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
    wire [9:0] branch_mux_out; //adjust width
    wire [9:0] jump_mux_out; //adjust width
    reg [9:0] pc_out; //adjust width
    
    
// write your code here
   mux2 #(.mux_width(10)) branch_mux (
        .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(branch_mux_out));
   
    mux2 #(.mux_width(10)) jump_mux (
        .a(branch_mux_out),
        .b(jump_address),
        .sel(jump),
        .y(jump_mux_out));
   
   instruction_mem instr_mem (
        .read_addr(pc_out),
        .data(instr));
        
   
   always @(posedge clk or posedge reset)
   begin
        if(reset) begin  
            pc_out <= 10'b0000000000;
        end
        else if (en) begin
            pc_out <= jump_mux_out;     
        end            
    end  
    
    assign pc_plus4 = pc_out +4;
   
   
endmodule
