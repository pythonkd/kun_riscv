/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-14 22:22:10
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-19 11:59:16
 * @FilePath: /kun_riscv/rtl/alu.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module alu(
    input [`REG_WIDTH - 1: 0]imm,
    input zero,
    input [`REG_WIDTH - 1: 0]pc,
    input [`REG_WIDTH - 1: 0]reg1_data,
    input [`REG_WIDTH - 1: 0]reg2_data,
    input [`ALU_OP_WIDTH - 1: 0]alu_op,
    input [`ALU_TYPE_WIDTH - 1: 0]alu_type,
    input [`ALU_OP_LENGTH_WIDTH - 1: 0]len,
    input [`REG_WIDTH - 1:0]mem_rd_data,
    output reg reg_we,
    output reg mem_we,
    output reg jump_en,
    output reg [`REG_WIDTH - 1: 0]reg_data,
    output reg [`REG_WIDTH - 1:0]mem_w_data,
    output reg [`REG_WIDTH - 1:0]mem_addr
);
    reg [`REG_WIDTH - 1: 0]alu_src1;
    reg [`REG_WIDTH - 1: 0]alu_src2;
    reg [`REG_WIDTH - 1: 0]alu_src;

    always @(*) begin
        reg_we = 1'b0;
        mem_we = 1'b0;
        jump_en = 1'b0;
        case (alu_type)
        `ALU_TYPE_REG_W_REG: begin
            alu_src1 = reg1_data;
            alu_src2 = reg2_data;
            reg_we = 1'b1;
        end
        `ALU_TYPE_REG_IMM_W_REG: begin
            alu_src1 = reg1_data;
            alu_src2 = imm;
            reg_we = 1'b1;
        end
        `ALU_TYPE_REG_IMM_MEM_W_REG: begin
            alu_src1 = mem_rd_data;
            alu_src2 = `REG_WIDTH'b0;
            mem_addr = reg1_data + imm;
            reg_we = 1'b1;
        end
        `ALU_TYPE_PC_W_REG: begin
            alu_src1 = pc;
            alu_src2 = `REG_WIDTH'h4;
            reg_we = 1'b1;
        end
        `ALU_TYPE_IMM_W_REG: begin
            alu_src1 = imm;
            reg_we = 1'b1;
        end
        `ALU_TYPE_PC_IMM_W_REG: begin
            alu_src1 = pc;
            alu_src2 = imm;
            reg_we = 1'b1;
        end
        `ALU_TYPE_IMM_W_PC: begin
            alu_src1 = reg1_data;
            alu_src2 = reg2_data;
        end
        default: begin
            alu_src2 = `REG_WIDTH'b0;
            alu_src1 = reg2_data;
            mem_we = 1'b1;
            mem_addr = reg1_data + imm;
        end
        endcase
        case (alu_op)
        `ALU_OP_ADD: alu_src = alu_src1 + alu_src2;
        `ALU_OP_SUB: alu_src = alu_src1 - alu_src2;
        `ALU_OP_XOR: alu_src = alu_src1 ^ alu_src2;
        `ALU_OP_OR: alu_src = alu_src1 | alu_src2;
        `ALU_OP_AND: alu_src = alu_src1 & alu_src2;
        `ALU_OP_SLL: alu_src = alu_src1 << alu_src2[4:0];
        `ALU_OP_SRL: alu_src = alu_src1 >> alu_src2[4:0];
        `ALU_OP_SLT: alu_src = $signed(alu_src1) < $signed(alu_src2) ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
        `ALU_OP_SLTU: alu_src = alu_src1 < alu_src2 ? `REG_WIDTH'b1 : `REG_WIDTH'b0;
        `ALU_OP_LUI: alu_src = alu_src1;
        `ALU_OP_AUI: alu_src = alu_src1 + alu_src2;
        `ALU_OP_SRL_MSB: alu_src = $signed(alu_src1) >>> alu_src2[4:0];
        `ALU_OP_BEQ: jump_en = alu_src1 == alu_src2;
        `ALU_OP_BNE: jump_en = alu_src1 != alu_src2;
        `ALU_OP_BLT: jump_en = $signed(alu_src1) < $signed(alu_src2);
        `ALU_OP_BGE: jump_en = $signed(alu_src1) >= $signed(alu_src2);
        `ALU_OP_BLTU: jump_en = alu_src1 < alu_src2;
        `ALU_OP_BGEU: jump_en = alu_src1 >= alu_src2;
        endcase
        if (reg_we) begin
            case(len)
                `ALU_OP_LENGTH_WIDTH'b00: reg_data = zero ? {{(`REG_WIDTH - 8){1'b0}}, alu_src[7: 0]}: {{(`REG_WIDTH - 8){alu_src[7]}}, alu_src[7: 0]};
                `ALU_OP_LENGTH_WIDTH'b01: reg_data = zero ? {{(`REG_WIDTH - 16){1'b0}}, alu_src[15: 0]}: {{(`REG_WIDTH - 16){alu_src[15]}}, alu_src[15: 0]};
                `ALU_OP_LENGTH_WIDTH'b10: reg_data = alu_src[31: 0];
            endcase
        end
        else if (mem_we) begin
            case(len)
                `ALU_OP_LENGTH_WIDTH'b00: mem_w_data = {mem_rd_data[`REG_WIDTH-1: 8], alu_src[7: 0]};
                `ALU_OP_LENGTH_WIDTH'b01: mem_w_data = {mem_rd_data[`REG_WIDTH-1: 16], alu_src[15: 0]};
                `ALU_OP_LENGTH_WIDTH'b10: mem_w_data = alu_src[31: 0];
            endcase
        end
    end

endmodule
