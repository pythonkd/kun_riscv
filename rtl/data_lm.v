/*
 * @Author: pythonkd 1181878670@qq.com
 * @Date: 2026-07-12 17:45:31
 * @LastEditors: pythonkd 1181878670@qq.com
 * @LastEditTime: 2026-07-18 18:48:51
 * @FilePath: /kun_riscv/rtl/data_lm.v
 * @Description: 
 * 
 * Copyright (c) 2026 by  kunpeng.zhao, All Rights Reserved. 
 */

module d_lm(
   input clk,
   input [`REG_WIDTH - 1:0]mem_addr,
   input [`REG_WIDTH - 1:0]mem_w_data,
   input mem_re,
   input mem_we,
   output reg [`REG_WIDTH - 1:0]mem_rd_data,
   output data_err

);
 
   reg [`REG_WIDTH-1: 0]local_mem[0:`DATA_MEM_DEPTH-1];
   
   assign data_err = mem_addr[`DATA_MEM_WIDTH+1:2] > (`DATA_MEM_DEPTH - 1) ? 1 : 0;

   always @(posedge clk)
      if (!data_err & mem_we)
         local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]] <= mem_w_data;

   always @(*)
      if (data_err | !mem_re)
         mem_rd_data = `REG_WIDTH'b0;
      else
         mem_rd_data = local_mem[mem_addr[`DATA_MEM_WIDTH+1:2]];

endmodule
