/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-14 21:48:55
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-18 18:53:01
 * @FilePath: /kun_riscv/rtl/reg_file.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module reg_file(
    input clk,
    input reset_n,
    input reg_we,
    input [`INST_RD_WIDTH  - 1: 0]reg_index,
    input [`REG_WIDTH - 1: 0]reg_data,
    input [`INST_RS1_WIDTH  - 1: 0]reg1_index,
    input [`INST_RS1_WIDTH  - 1: 0]reg2_index,
    output reg [`REG_WIDTH - 1: 0]reg1_data,
    output reg [`REG_WIDTH - 1: 0]reg2_data
);
    reg [`REG_WIDTH-1:0] reg_f [0:`REG_DATA_DEPTH-1];
    
    always @(*)
        if (reg1_index == `INST_RS1_WIDTH'b0)
            reg1_data = `REG_WIDTH'b0;
        else
            reg1_data = reg_f[reg1_index];
    
    always @(*)
        if (reg2_index == `INST_RS2_WIDTH'b0)
            reg2_data = `REG_WIDTH'b0;
        else
            reg2_data = reg_f[reg2_index];
    
    always @(posedge clk or negedge reset_n)
        if (reset_n && (reg_we) && (reg_index != `INST_RD_WIDTH'b0))
            reg_f[reg_index] = reg_data;

endmodule