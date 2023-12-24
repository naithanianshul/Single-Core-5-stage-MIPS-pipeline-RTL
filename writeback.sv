`include "defines.vh"

module writeback (input clock,
                  input reset_n,

                  input [`DATA_SIZE-1:0] MEM_WB_result,
                  input [`DATA_SIZE-1:0] MEM_WB_data,
                  input [4:0] MEM_WB_dest,
                  input [5:0] MEM_WB_op,
                  input [1:0] MEM_WB_instruc_type,
                  
                  output logic [4:0] WB_dest,
                  output logic [`DATA_SIZE-1:0] WB_value,
                  output logic WB_WEenable
);
  
  always@(posedge clock) begin
    if (!reset_n) begin
      WB_dest <= 5'b0;
      WB_value <= 32'b0;
      WB_WEenable <= 1'b0;
    end
    else begin
      WB_dest <= MEM_WB_dest;
      if ((MEM_WB_op == `lw) || (MEM_WB_op == `sw)) WB_value <= MEM_WB_data;
      else WB_value <= MEM_WB_result;
      // WB is valid only when the operation is not a 'nop'
      if (MEM_WB_instruc_type[1] == 1'b1) begin
        //$display("Debug WB: MEM_WB_instruc_type = %h, MEM_WB_op = %h", MEM_WB_instruc_type, MEM_WB_op);
        WB_WEenable <= 1'b1;
      end
      else WB_WEenable <= 1'b0;
    end
  end
  
endmodule
