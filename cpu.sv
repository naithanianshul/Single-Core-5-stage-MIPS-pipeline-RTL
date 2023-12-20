`include "defines.vh"
`include "fetch.sv"
`include "decode.sv"
`include "execute.sv"
`include "memory.sv"
`include "writeback.sv"

module cpu (input clock,
            input reset_n,

            input [`DATA_SIZE-1:0]      im_read_data,
            output                      im_write_enable,
            output [`ADDRESS_SIZE-1:0]  im_write_address,
            output [`DATA_SIZE-1:0]     im_write_data,
            output [`ADDRESS_SIZE-1:0]  im_read_address,

            input [`DATA_SIZE-1:0]      dm_read_data,
            output                      dm_write_enable,
            output [`ADDRESS_SIZE-1:0]  dm_write_address,
            output [`DATA_SIZE-1:0]     dm_write_data,
            output [`ADDRESS_SIZE-1:0]  dm_read_address
);

  logic id_stall_c;
  logic ex_stall_c;
  logic mem_stall_c;
  
  // Inputs for IF
  logic branch_c;
  logic [`ADDRESS_SIZE-1:0] branch_pc;
  logic [`ADDRESS_SIZE-1:0] IF_ID_nextPC;
  logic [`DATA_SIZE-1:0] IF_ID_IR;
  
  // Inputs for ID
  logic EX_MEM_valid;
  logic MEM_WB_valid;
  logic WB_WEenable;
  logic [4:0] EX_MEM_dest;
  logic [4:0] MEM_WB_dest;
  logic [4:0] WB_dest;
  logic [`DATA_SIZE-1:0] EX_MEM_result;
  logic [`DATA_SIZE-1:0] MEM_WB_data;
  logic [`DATA_SIZE-1:0] WB_value;

  // Inputs for EX
  logic [`ADDRESS_SIZE-1:0] ID_EX_nextPC;
  logic [`ADDRESS_SIZE-1:0] ID_EX_A;
  logic [`ADDRESS_SIZE-1:0] ID_EX_B;
  logic [`ADDRESS_SIZE-1:0] ID_EX_imm;
  logic [`ADDRESS_SIZE-1:0] ID_EX_rd;
  logic [`ADDRESS_SIZE-1:0] ID_EX_rt;
  logic [`ADDRESS_SIZE-1:0] ID_EX_op;

  // Inputs for MEM
  logic [5:0] EX_MEM_op;
  logic [`DATA_SIZE-1:0] EX_MEM_B;
  logic [`ADDRESS_SIZE-1:0] EX_MEM_targetPC;

  // Inputs for WB
  logic [`DATA_SIZE-1:0] MEM_WB_result;
  logic [5:0] MEM_WB_op;  
  
  // Instruction Fetch (IF) Stage
  fetch IF (  .clock(clock),
              .reset_n(reset_n),
              .id_stall_c(id_stall_c),
              .ex_stall_c(ex_stall_c),
              .mem_stall_c(mem_stall_c),

              .branch_c(branch_c),
              .branch_pc(branch_pc),

              .im_read_data(im_read_data),
              .im_write_enable(im_write_enable),
              .im_read_address(im_read_address),

              .IF_ID_nextPC(IF_ID_nextPC),
              .IF_ID_IR(IF_ID_IR)
  );
  
  // Instruction Decode (ID) Stage
  decode ID ( .clock(clock),
              .reset_n(reset_n),
              .ex_stall_c(ex_stall_c),
              .mem_stall_c(mem_stall_c),
              
              .IF_ID_nextPC(IF_ID_nextPC),
              .IF_ID_IR(IF_ID_IR),
              
              .EX_MEM_valid(EX_MEM_valid),
              .EX_MEM_dest(EX_MEM_dest),
              .EX_MEM_result(EX_MEM_result),
              
              .MEM_WB_valid(MEM_WB_valid),
              .MEM_WB_dest(MEM_WB_dest),
              .MEM_WB_data(MEM_WB_data),
              
              .WB_WEenable(WB_WEenable),
              .WB_dest(WB_dest),
              .WB_value(WB_value),
              
              .ID_EX_nextPC(ID_EX_nextPC),
              .ID_EX_A(ID_EX_A),
              .ID_EX_B(ID_EX_B),
              .ID_EX_imm(ID_EX_imm),
              .ID_EX_rd(ID_EX_rd),
              .ID_EX_rt(ID_EX_rt),
              .ID_EX_op(ID_EX_op),
              
              .id_stall_c(id_stall_c)
  );
  
  // Execute (EX) Stage
  execute EX (  .clock(clock),
                .reset_n(reset_n),
                .mem_stall_c(mem_stall_c),
                .ID_EX_nextPC(ID_EX_nextPC),
                .ID_EX_A(ID_EX_A),
                .ID_EX_B(ID_EX_B),
                .ID_EX_imm(ID_EX_imm),
                .ID_EX_rd(ID_EX_rd),
                .ID_EX_rt(ID_EX_rt),
                .ID_EX_op(ID_EX_op),
                .EX_MEM_valid(EX_MEM_valid),
                .EX_MEM_dest(EX_MEM_dest),
                .EX_MEM_result(EX_MEM_result),
                .EX_MEM_op(EX_MEM_op),
                .EX_MEM_B(EX_MEM_B),
                .EX_MEM_targetPC(EX_MEM_targetPC),
                .ex_stall_c(ex_stall_c)
  );

  // Memory (MEM) Stage
  memory MEM (  .clock(clock),
                .reset_n(reset_n),
                .dm_read_data(dm_read_data),
              	.dm_write_enable(dm_write_enable),
                .dm_write_address(dm_write_address),
                .dm_write_data(dm_write_data),
                .dm_read_address(dm_read_address),
                .EX_MEM_targetPC(EX_MEM_targetPC),
                .EX_MEM_result(EX_MEM_result),
                .EX_MEM_B(EX_MEM_B),
                .EX_MEM_dest(EX_MEM_dest),
                .EX_MEM_op(EX_MEM_op),
                .MEM_WB_result(MEM_WB_result),
                .MEM_WB_data(MEM_WB_data),
                .MEM_WB_dest(MEM_WB_dest),
                .MEM_WB_op(MEM_WB_op),
                .MEM_WB_valid(MEM_WB_valid),
                .mem_stall_c(mem_stall_c)
  );

  // Writeback (WB) Stage
  writeback WB (.clock(clock),
                .reset_n(reset_n),
                .MEM_WB_result(MEM_WB_result),
                .MEM_WB_data(MEM_WB_data),
                .MEM_WB_dest(MEM_WB_dest),
                .MEM_WB_op(MEM_WB_op),
                .WB_dest(WB_dest),
                .WB_value(WB_value),
                .WB_WEenable(WB_WEenable)
  );

endmodule
