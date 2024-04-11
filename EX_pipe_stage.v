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
    
    // Write your code here
wire[3:0] ALU_Control;
wire[31:0] ALU_input_1, ALU_input_2, imm_mux_result;
wire zero;
ALUControl alu_control
(
    .ALUOp(id_ex_alu_op),
    .Function(id_ex_instr[5:0]),
    .ALU_Control(ALU_Control));
mux4 #(.mux_width(32)) reg1_mux
(
    .a(reg1),
    .b(mem_wb_write_back_result),
    .c(ex_mem_alu_result),
    .d(32'b0),
    .sel(Forward_A),
    .y(ALU_input_1));
mux4 #(.mux_width(32)) reg2_mux
(
    .a(reg2),
    .b(mem_wb_write_back_result),
    .c(ex_mem_alu_result),
    .d(32'b0),
    .sel(Forward_B),
    .y(ALU_input_2));
mux2 #(.mux_width(32)) imm_mux
(
    .a(ALU_input_2),
    .b(id_ex_imm_value),
    .sel(id_ex_alu_src),
    .y(imm_mux_result));
ALU alu
(
    .a(ALU_input_1),
    .b(imm_mux_result),
    .alu_control(ALU_Control),
    .zero(zero),
    .alu_result(alu_result));
assign alu_in2_out = ALU_input_2;
endmodule
