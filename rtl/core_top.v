/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:12:15
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-18 22:43:50
 * @FilePath: /kun_riscv/rtl/core_top.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module core_top (
    input clk,
    input reset_n
);

    wire stop;
    wire branch;
    wire reg_we;
    wire mem_re;
    wire mem_we;
    wire jump_en;
    wire zero;
    wire data_err;
    wire instruction_err;
    wire instruction_decode_err;
    wire [`REG_WIDTH - 1:0]mem_rd_data;
    wire [`REG_WIDTH - 1:0]mem_addr;
    wire [`REG_WIDTH - 1:0]mem_w_data;
    wire [`ALU_OP_LENGTH_WIDTH - 1: 0]len;
    wire [`ALU_TYPE_WIDTH - 1: 0]alu_type;
    wire [`ALU_OP_WIDTH - 1: 0]alu_op;
    wire [`INST_RD_WIDTH  - 1: 0]rd_index;
    wire [`REG_WIDTH - 1: 0]rd_data;
    wire [`INST_JUMP_WIDTH - 1: 0]jump;
    wire [`REG_WIDTH - 1: 0]cur_pc;
    wire [`REG_WIDTH - 1: 0]nx_pc;
    wire [`INST_WIDTH-1: 0]instruction;
    wire [`CPU_ERR_WIDTH-1: 0]cpu_err;
    wire [`REG_WIDTH - 1: 0]imm;
    wire [`INST_RS1_WIDTH  - 1: 0]rs1_index;
    wire [`INST_RS1_WIDTH  - 1: 0]rs2_index;
    wire [`REG_WIDTH - 1: 0]rs1_data;
    wire [`REG_WIDTH - 1: 0]rs2_data;

    assign cpu_err = {{(`CPU_ERR_WIDTH - 3){1'b0}}, instruction_decode_err, data_err, instruction_err};
    pc_reg u_pc_reg(
        //input
        .clk(clk),
        .reset_n(reset_n),
        .nx_pc(nx_pc),
        .cpu_err(cpu_err),
        //output
        .pc(cur_pc),
        .stop(stop)
    );

    pc_mux u_pc_mux(
        // input
        .stop(stop),
        .pc(cur_pc),
        .branch(branch),
        .imm(imm),
        .rs1_data(rs1_data),
        .jump(jump),
        .jump_en(jump_en),
        //output
        .nx_pc(nx_pc)
    );
    
    i_lm u_ilm(
        //input
        .pc(cur_pc),
        //output
        .instruction(instruction),
        .instruction_err(instruction_err)
    );

    d_lm u_dlm(
        //input
        .clk(clk),
        .mem_addr(mem_addr),
        .mem_w_data(mem_w_data),
        .mem_re(mem_re),
        .mem_we(mem_we),
        //output
        .mem_rd_data(mem_rd_data),
        .data_err(data_err)
    );

    reg_file u_reg_file(
        //input
        .clk(clk),
        .reset_n(reset_n),
        .reg_we(reg_we),
        .reg_index(rd_index),
        .reg_data(rd_data),
        .reg1_index(rs1_index),
        .reg2_index(rs2_index),
        //output
        .reg1_data(rs1_data),
        .reg2_data(rs2_data)
    );

    decode u_decode(
        //input
        .instruction(instruction),
        //output
        .mem_re(mem_re),
        .zero(zero),
        .branch(branch),        
        .jump(jump),
        .imm(imm),
        .reg_index(rd_index),
        .reg1_index(rs1_index),
        .reg2_index(rs2_index),
        .alu_op(alu_op),
        .alu_type(alu_type),
        .len(len),
        .instruction_decode_err(instruction_decode_err)
    );

    alu u_alu(
        //input
        .imm(imm),
        .pc(cur_pc),
        .zero(zero),
        .reg1_data(rs1_data),
        .reg2_data(rs2_data),
        .alu_op(alu_op),
        .alu_type(alu_type),
        .len(len),
        .mem_rd_data(mem_rd_data),
        //output
        .reg_we(reg_we),
        .mem_we(mem_we),
        .jump_en(jump_en),
        .reg_data(rd_data),
        .mem_w_data(mem_w_data),
        .mem_addr(mem_addr)
    );
   

endmodule