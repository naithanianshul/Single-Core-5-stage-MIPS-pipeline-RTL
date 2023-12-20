`include "defines.vh"

module memory ( input clock,
				        input reset_n,

                input [`DATA_SIZE-1:0] dm_read_data,
	              output                      dm_write_enable,
                output [`ADDRESS_SIZE-1:0]  dm_write_address,
                output [`DATA_SIZE-1:0]     dm_write_data,
                output [`ADDRESS_SIZE-1:0]  dm_read_address,
                
                input [`ADDRESS_SIZE-1:0] EX_MEM_targetPC,
                input [`DATA_SIZE-1:0] EX_MEM_result,
                input [`DATA_SIZE-1:0] EX_MEM_B,
                input [4:0] EX_MEM_dest,
                input [5:0] EX_MEM_op,

                output logic [`DATA_SIZE-1:0] MEM_WB_result,
                output logic [`DATA_SIZE-1:0] MEM_WB_data,
                output logic [4:0] MEM_WB_dest,
                output logic [5:0] MEM_WB_op,

                output logic MEM_WB_valid,
                output logic mem_stall_c
);
  
  always@(posedge clock) begin
    if (!reset_n) begin
        MEM_WB_result <= 32'b0;
        MEM_WB_data <= 32'b0;
        MEM_WB_dest <= 5'b0;
        MEM_WB_op <= 6'b0;
        MEM_WB_valid <= 1'b0;
        mem_stall_c <= 1'b0;
    end
    else begin
        MEM_WB_result <= EX_MEM_result;
        // Currently, this does not support 'lw' or 'sw' to the data memory
        MEM_WB_data <= 32'b0;
        MEM_WB_dest <= EX_MEM_dest;
        MEM_WB_op <= EX_MEM_op;
        // Currently, as long as the instruction is not a 'nop' then it is valid = 1
        // This is because currently we assume accessing Data Memory is single cycle access.
        mem_stall_c <= 1'b0;
        if (|{MEM_WB_op, MEM_WB_dest, MEM_WB_result}) MEM_WB_valid <= 1'b1;
        else MEM_WB_valid <= 1'b0;
    end
  end
  
endmodule
