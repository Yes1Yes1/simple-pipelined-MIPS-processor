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
wire reg_dst, temp_mem_to_reg, temp_mem_read, temp_mem_write, temp_alu_src, temp_reg_write, temp_branch; 
wire[1:0] temp_alu_op;
wire hazard_mux_sel;
wire[6:0] hazard_mux_result;
wire eq_test;
assign hazard_mux_sel = (~Data_Hazard) | Control_Hazard;
control control_unit
(
    .reset(reset),
    .opcode(instr[31:26]),
    .reg_dst(reg_dst),
    .mem_to_reg(temp_mem_to_reg),
    .alu_op(temp_alu_op),
    .mem_read(temp_mem_read),
    .mem_write(temp_mem_write),
    .alu_src(temp_alu_src),
    .reg_write(temp_reg_write),
    .branch(temp_branch),
    .jump(jump));
    
mux2 #(.mux_width(7)) hazard_mux
(
    .a({temp_mem_to_reg, temp_alu_op, temp_mem_read, temp_mem_write, temp_alu_src, temp_reg_write}),
    .b(7'b0),
    .sel(hazard_mux_sel),
    .y(hazard_mux_result));
assign mem_to_reg = hazard_mux_result[6];
assign alu_op = hazard_mux_result[5:4];
assign mem_read = hazard_mux_result[3];
assign mem_write = hazard_mux_result[2];
assign alu_src = hazard_mux_result[1];
assign reg_write = hazard_mux_result[0];

assign jump_address = instr[25:0] << 2;

sign_extend imm_extender
(
    .sign_ex_in(instr[15:0]),
    .sign_ex_out(imm_value));
assign branch_address = pc_plus4 + (imm_value << 2);

register_file reg_file
(
    .clk(clk),
    .reset(reset),
    .reg_write_en(mem_wb_reg_write),
    .reg_write_dest(mem_wb_write_reg_addr),
    .reg_write_data(mem_wb_write_back_data),
    .reg_read_addr_1(instr[25:21]),
    .reg_read_addr_2(instr[20:16]),
    .reg_read_data_1(reg1),
    .reg_read_data_2(reg2));
assign eq_test = ((reg1 ^ reg2)==32'd0) ? 1'b1 : 1'b0;
assign branch_taken = eq_test & temp_branch;

mux2 #(.mux_width(5)) dest_reg
(
    .a(instr[20:16]),
    .b(instr[15:11]),
    .sel(reg_dst),
    .y(destination_reg));
endmodule
