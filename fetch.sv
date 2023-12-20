`include "defines.vh"

module fetch (	input clock,
				        input reset_n,
                input id_stall_c,
                input ex_stall_c,
                input mem_stall_c,

                input branch_c,
                input [`ADDRESS_SIZE-1:0] branch_pc,

				        input [`DATA_SIZE-1:0] im_read_data,
	              output logic im_write_enable,
                output logic [`ADDRESS_SIZE-1:0] im_read_address,

                output logic [`ADDRESS_SIZE-1:0] IF_ID_nextPC,
                output logic [`DATA_SIZE-1:0] IF_ID_IR
);
  
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
      IF_ID_nextPC <= IF_ID_nextPC + 1'b1;
      IF_ID_IR = im_read_data;
    end
  end  
  
  assign im_write_enable = 1'b0;
  assign im_read_address = IF_ID_nextPC;
  
endmodule
