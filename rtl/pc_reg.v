/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 16:38:32
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-18 22:17:56
 * @FilePath: /kun_riscv/rtl/pc_reg.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */


module pc_reg(
    input clk,
    input reset_n,
    input [`CPU_ERR_WIDTH - 1: 0]cpu_err,
    input [`REG_WIDTH - 1:0]nx_pc,
    output reg [`REG_WIDTH - 1: 0]pc,
    output reg stop
);
    wire err_occur = |cpu_err;

    // assign stop = !reset_n;
    always @(posedge clk or negedge reset_n)
        if (!reset_n)
            stop <= 1'b1;
        else
            stop <= 1'b0;
    
    always @(posedge clk or negedge reset_n)
        if (!reset_n)
            pc <= `REG_WIDTH'b0;
        else
            pc <= nx_pc;
    
endmodule