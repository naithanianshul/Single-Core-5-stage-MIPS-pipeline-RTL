`include "defines.vh"

module fetch (	input clock,
				input reset_n,
                input id_stall_c,
                input ex_stall_c,
                input mem_stall_c,

                input branch_c,
                input [`ADDRESS_SIZE-1:0] branch_pc,
              
              	input EX_MEM_changePC_c,
                input [`ADDRESS_SIZE-1:0] EX_MEM_targetPC,


				input [`DATA_SIZE-1:0] im_read_data,
				output logic im_write_enable,
                output logic [`ADDRESS_SIZE-1:0] im_read_address,

                output logic [`ADDRESS_SIZE-1:0] IF_ID_nextPC,
                output logic [`DATA_SIZE-1:0] IF_ID_IR
);

  logic [`ADDRESS_SIZE-1:0] t_IF_ID_currentPC;
  logic [`ADDRESS_SIZE-1:0] t_IF_ID_nextPC;
  logic [`DATA_SIZE-1:0] t_IF_ID_IR;

  always@(posedge clock) begin
    if (!reset_n) begin
      IF_ID_nextPC <= 32'b0;
      IF_ID_IR <= 32'b0;
    end
    else if (id_stall_c || ex_stall_c || mem_stall_c) begin
      IF_ID_nextPC <= IF_ID_nextPC;
      IF_ID_IR <= IF_ID_IR;
    end
    else begin
      $display("Debug IF: IF_ID_currentPC = %h, IF_ID_IR_t = %h, IF_ID_nextPC = %h", IF_ID_nextPC, t_IF_ID_IR, t_IF_ID_nextPC);
      IF_ID_nextPC <= t_IF_ID_nextPC;
      IF_ID_IR <= t_IF_ID_IR;
    end
  end
  
  
  assign im_write_enable = 1'b0;
  always@(*) begin
    t_IF_ID_IR <= im_read_data;
    
    if (EX_MEM_changePC_c) begin
      t_IF_ID_currentPC = EX_MEM_targetPC;
      im_read_address <= EX_MEM_targetPC;
      $display("Debug IF: Jump to EX_MEM_targetPC = %h", EX_MEM_targetPC);
    end
    else begin
      t_IF_ID_currentPC = IF_ID_nextPC;
      im_read_address <= IF_ID_nextPC;
    end
    
    t_IF_ID_nextPC = t_IF_ID_currentPC + 3'b100;
    
  end
  
endmodule
