`include "defines.vh"

module memory ( input clock,
				input reset_n,

                input [`DATA_SIZE-1:0] dm_read_data,
				output logic                      dm_write_enable,
                output logic [`ADDRESS_SIZE-1:0]  dm_write_address,
                output logic [`DATA_SIZE-1:0]     dm_write_data,
                output logic [`ADDRESS_SIZE-1:0]  dm_read_address,
                
                input [`ADDRESS_SIZE-1:0] EX_MEM_targetPC,
                input [`DATA_SIZE-1:0] EX_MEM_result,
                input [`DATA_SIZE-1:0] EX_MEM_B,
                input [4:0] EX_MEM_dest,
                input [5:0] EX_MEM_op,
                input [1:0] EX_MEM_instruc_type,

                output logic [`DATA_SIZE-1:0] MEM_WB_result,
                output logic [`DATA_SIZE-1:0] MEM_WB_data,
                output logic [4:0] MEM_WB_dest,
                output logic [5:0] MEM_WB_op,
                output logic [1:0] MEM_WB_instruc_type,

                output logic MEM_WB_valid,
                output logic mem_stall_c
);
  
  logic [`DATA_SIZE-1:0] t_MEM_WB_data;
  
  always@(posedge clock) begin
    if (!reset_n) begin
      MEM_WB_result <= 32'b0;
      MEM_WB_data <= 32'b0;
      MEM_WB_dest <= 5'b0;
      MEM_WB_op <= 6'b0;
      MEM_WB_instruc_type <= 2'b0;
      MEM_WB_valid <= 1'b0;
      mem_stall_c <= 1'b0;
    end
    else begin
      MEM_WB_result <= EX_MEM_result;
      MEM_WB_data <= t_MEM_WB_data;
      MEM_WB_dest <= EX_MEM_dest;
      MEM_WB_op <= EX_MEM_op;
      MEM_WB_instruc_type <= EX_MEM_instruc_type;
      // The instruction is valid if it is a R or I type instruction
      if (EX_MEM_instruc_type[1] == 1'b1) MEM_WB_valid <= 1'b1;
      else MEM_WB_valid <= 1'b0;
      mem_stall_c <= 1'b0;
    end
  end
  
  always@(*) begin
    dm_write_enable <= 1'b0;
    // MEM Instruc Ops
    case (EX_MEM_op)
      `lw: begin
        dm_read_address <= EX_MEM_result;
        dm_write_address <= 32'b0;
        dm_write_data <= 32'b0;
        t_MEM_WB_data <= dm_read_data;
        $display("Debug MEM: Read from Data Memory dm_read_address = %h, MEM_WB_data = %h", EX_MEM_result, dm_read_data);
      end

      `sw: begin
        dm_write_enable <= 1'b1;
        dm_write_address <= EX_MEM_result;
        dm_write_data <= EX_MEM_B;
        dm_read_address <= 32'b0;
        t_MEM_WB_data <= 32'b0;
        $display("Debug MEM: Write to Data Memory dm_write_address = %h, dm_write_data = %h", EX_MEM_result, EX_MEM_B);
      end

      default: begin
        t_MEM_WB_data <= 32'b0;
        dm_write_address <= 32'b0;
      end
    endcase
  end
  
endmodule
