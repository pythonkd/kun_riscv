/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 22:00:12
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-18 21:29:09
 * @FilePath: /kun_riscv/rtl/decode_ctrl.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module decode(
    input [`INST_WIDTH - 1: 0]instruction,
    output reg mem_re,
    output reg zero,
    output reg branch,
    output reg [`INST_JUMP_WIDTH - 1 : 0]jump,
    output reg [`REG_WIDTH - 1: 0]imm,
    output reg [`INST_RS1_WIDTH  - 1: 0]reg_index,
    output reg [`INST_RS1_WIDTH  - 1: 0]reg1_index,
    output reg [`INST_RS1_WIDTH  - 1: 0]reg2_index,
    output reg [`ALU_OP_WIDTH - 1: 0]alu_op,
    output reg [`ALU_TYPE_WIDTH - 1: 0]alu_type,
    output reg [`ALU_OP_LENGTH_WIDTH - 1: 0]len,
    output reg instruction_decode_err
);
    wire [`INST_OPCODE_WIDTH - 1: 0]opcode = instruction[`INST_OPCODE_BASE + `INST_OPCODE_WIDTH - 1: `INST_OPCODE_BASE];
    wire [`INST_RD_WIDTH - 1: 0]rd = instruction[`INST_RD_BASE + `INST_RD_WIDTH - 1: `INST_RD_BASE];
    wire [`INST_FUNC3_WIDTH - 1: 0]func3 = instruction[`INST_FUNC3_BASE + `INST_FUNC3_WIDTH - 1: `INST_FUNC3_BASE];
    wire [`INST_RS1_WIDTH - 1: 0]rs1 = instruction[`INST_RS1_BASE + `INST_RS1_WIDTH - 1: `INST_RS1_BASE];
    wire [`INST_RS2_WIDTH - 1: 0]rs2 = instruction[`INST_RS2_BASE + `INST_RS2_WIDTH - 1: `INST_RS2_BASE];
    wire [`INST_FUNC7_WIDTH - 1: 0]func7 = instruction[`INST_FUNC7_BASE + `INST_FUNC7_WIDTH - 1: `INST_FUNC7_BASE];

    always @(*) begin
        mem_re = 1'b0;
        jump = `INST_JUMP_WIDTH'b0;
        reg_index = `INST_RD_WIDTH'b0;
        len = `ALU_OP_LENGTH_WIDTH'h2;
        instruction_decode_err = 0;
        zero = 1'b0;
        branch = 1'b0;
        case (opcode)
            `INST_OPCODE_R_TYPE: begin
                if ((func3 == `INST_FUNC3_WIDTH'b0) && (func7 == `INST_FUNC7_WIDTH'b0))
                    alu_op = `ALU_OP_ADD;
                else if ((func3 == `INST_FUNC3_WIDTH'b0) && (func7 == `INST_FUNC7_WIDTH'h20))
                    alu_op = `ALU_OP_SUB;
                else if (func3 == `INST_FUNC3_WIDTH'h1)
                    alu_op = `ALU_OP_SLL;
                else if (func3 == `INST_FUNC3_WIDTH'h2)
                    alu_op = `ALU_OP_SLT;
                else if (func3 == `INST_FUNC3_WIDTH'h3)
                    alu_op = `ALU_OP_SLTU;
                else if (func3 == `INST_FUNC3_WIDTH'h4)
                    alu_op = `ALU_OP_XOR;
                else if ((func3 == `INST_FUNC3_WIDTH'h5) && (func7 == `INST_FUNC7_WIDTH'h0))
                    alu_op = `ALU_OP_SRL;
                else if ((func3 == `INST_FUNC3_WIDTH'h5) && (func7 == `INST_FUNC7_WIDTH'h20))
                    alu_op = `ALU_OP_SRL_MSB;
                else if (func3 == `INST_FUNC3_WIDTH'h6)
                    alu_op = `ALU_OP_OR;
                else if (func3 == `INST_FUNC3_WIDTH'h7)
                    alu_op = `ALU_OP_AND;
                reg1_index = rs1;
                reg2_index = rs2;
                reg_index = rd;
                alu_type = `ALU_TYPE_REG_W_REG;
            end
            `INST_OPCODE_I_TYPE: begin
                if (func3 == `INST_FUNC3_WIDTH'b0)
                    alu_op = `ALU_OP_ADD;
                else if (func3 == `INST_FUNC3_WIDTH'h1)
                    alu_op = `ALU_OP_SLL;
                else if (func3 == `INST_FUNC3_WIDTH'h2)
                    alu_op = `ALU_OP_SLT;
                else if (func3 == `INST_FUNC3_WIDTH'h3)
                    alu_op = `ALU_OP_SLTU;
                else if (func3 == `INST_FUNC3_WIDTH'h4)
                    alu_op = `ALU_OP_XOR;
                else if ((func3 == `INST_FUNC3_WIDTH'h5) && (func7 == `INST_FUNC7_WIDTH'h0))
                    alu_op = `ALU_OP_SRL;
                else if ((func3 == `INST_FUNC3_WIDTH'h5) && (func7 == `INST_FUNC7_WIDTH'h20))
                    alu_op = `ALU_OP_SRL_MSB;
                else if (func3 == `INST_FUNC3_WIDTH'h6)
                    alu_op = `ALU_OP_OR;
                else if (func3 == `INST_FUNC3_WIDTH'h7)
                    alu_op = `ALU_OP_AND;
                reg1_index = rs1;
                reg_index = rd;
                alu_type = `ALU_TYPE_REG_IMM_W_REG;
                if ((func3 == `INST_FUNC3_WIDTH'h1) || (func3 == `INST_FUNC3_WIDTH'h5))
                    imm = {{(`REG_WIDTH-`INST_RS2_WIDTH){1'b0}}, rs2};
                else
                    imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
            end
            `INST_OPCODE_IL_TYPE: begin
                reg1_index = rs1;
                reg_index = rd;
                mem_re = 1'b1;
                alu_op = `ALU_OP_ADD;
                alu_type = `ALU_TYPE_REG_IMM_MEM_W_REG;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                if ((func3 == `INST_FUNC3_WIDTH'h0) || (func3 == `INST_FUNC3_WIDTH'h4))
                    len = `ALU_OP_LENGTH_WIDTH'h0;
                else if((func3 == `INST_FUNC3_WIDTH'h1) || (func3 == `INST_FUNC3_WIDTH'h5))
                    len = `ALU_OP_LENGTH_WIDTH'h1;
                if ((func3 == `INST_FUNC3_WIDTH'h4) || (func3 == `INST_FUNC3_WIDTH'h5))
                    zero = 1'b1;
            end
            `INST_OPCODE_S_TYPE: begin
                reg1_index = rs1;
                reg2_index = rs2;
                mem_re = 1'b1;
                if (func3 == `INST_FUNC3_WIDTH'h0)
                    len = `ALU_OP_LENGTH_WIDTH'h0;
                else if (func3 == `INST_FUNC3_WIDTH'h1)
                    len = `ALU_OP_LENGTH_WIDTH'h1;
                alu_type = `ALU_TYPE_REG_W_REG_IMM_MEM;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RD_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rd};
                alu_op = `ALU_OP_ADD;
            end
            `INST_OPCODE_B_TYPE: begin
                reg1_index = rs1;
                reg2_index = rs2;
                alu_type = `ALU_TYPE_IMM_W_PC;
                imm = {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                branch = 1'b1;
                case (func3)
                    `INST_FUNC3_WIDTH'd0: alu_op = `ALU_OP_BEQ;
                    `INST_FUNC3_WIDTH'd1: alu_op = `ALU_OP_BNE;
                    `INST_FUNC3_WIDTH'd4: alu_op = `ALU_OP_BLT;
                    `INST_FUNC3_WIDTH'd5: alu_op = `ALU_OP_BGE;
                    `INST_FUNC3_WIDTH'd6: alu_op = `ALU_OP_BLTU;
                    `INST_FUNC3_WIDTH'd7: alu_op = `ALU_OP_BGEU;
                endcase
            end
            `INST_OPCODE_JAL_TYPE: begin
                reg_index = rd;
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                alu_type = `ALU_TYPE_PC_W_REG;
                jump = `INST_JUMP_JAL;
                alu_op = `ALU_OP_ADD;
            end
            `INST_OPCODE_JALR_TYPE: begin
                reg1_index = rs1;
                reg_index = rd;
                imm = {{(`REG_WIDTH-`INST_FUNC7_WIDTH-`INST_RS2_WIDTH){func7[`INST_FUNC7_WIDTH - 1]}}, func7, rs2};
                alu_type = `ALU_TYPE_PC_W_REG;
                jump = `INST_JUMP_JALR;
                alu_op = `ALU_OP_ADD;
            end
            `INST_OPCODE_LUI_TYPE: begin
                alu_type = `ALU_TYPE_IMM_W_REG;
                imm = {instruction[31:12], {12{1'b0}}};
                reg_index = rd;
                alu_op = `ALU_OP_ADD;
            end
            `INST_OPCODE_AUIPC_TYPE: begin
                alu_type = `ALU_TYPE_PC_IMM_W_REG;
                imm = {instruction[31:12], {12{1'b0}}};
                reg_index = rd;
                alu_op = `ALU_OP_ADD;
            end
            default: instruction_decode_err = 1;
        endcase
    end


endmodule
