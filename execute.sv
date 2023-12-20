`include "defines.vh"

module execute (input clock,
				        input reset_n,
                input mem_stall_c,
				
                input [`ADDRESS_SIZE-1:0] ID_EX_nextPC,
                input [`DATA_SIZE-1:0] ID_EX_A,
                input [`DATA_SIZE-1:0] ID_EX_B,
                input [`DATA_SIZE-1:0] ID_EX_imm,
                input [4:0] ID_EX_rd,	// 5 bits (from IR)
                input [4:0] ID_EX_rt,	// 5 bits (from IR)
                input [5:0] ID_EX_op,	// 6 bits (from IR)
                
                output logic [`ADDRESS_SIZE-1:0] EX_MEM_targetPC,
                output logic [`DATA_SIZE-1:0] EX_MEM_result,
                output logic [`DATA_SIZE-1:0] EX_MEM_B,
                output logic [4:0] EX_MEM_dest,
                output logic [5:0] EX_MEM_op,
                
                output logic EX_MEM_valid,
                output logic ex_stall_c
);
  
  always@(posedge clock) begin
    if (!reset_n) begin
      EX_MEM_valid <= 1'b0;
	  EX_MEM_dest <= 5'b0;
      EX_MEM_result <= 32'b0;
      EX_MEM_op <= 6'b0;
      EX_MEM_B <= 32'b0;
      EX_MEM_targetPC <= 32'b0;
    end
    else if (mem_stall_c) begin
      EX_MEM_valid <= EX_MEM_valid;
	  EX_MEM_dest <= EX_MEM_dest;
      EX_MEM_result <= EX_MEM_result;
      EX_MEM_op <= EX_MEM_op;
      EX_MEM_B <= EX_MEM_B;
      EX_MEM_targetPC <= EX_MEM_targetPC;
    end
    else begin
      EX_MEM_op <= ID_EX_op;
      EX_MEM_B <= ID_EX_B;
      if (ID_EX_op == 6'b0) EX_MEM_dest <= ID_EX_rd;
      else EX_MEM_dest <= ID_EX_rt;

      // ALU Instruc Ops
      case (ID_EX_op)
        `add: begin
            EX_MEM_result <= ID_EX_A + ID_EX_B;
            EX_MEM_valid <= 1'b1;
            EX_MEM_targetPC <= ID_EX_nextPC;
        end
        `lui: begin
            EX_MEM_result <= ID_EX_imm;
            EX_MEM_valid <= 1'b1;
            EX_MEM_targetPC <= ID_EX_nextPC;
        end
        `beq, `bne: begin
            EX_MEM_result <= 32'b0;
            EX_MEM_valid <= 1'b0;
            EX_MEM_targetPC <= ID_EX_nextPC + ID_EX_imm;
        end
    	default: begin
            EX_MEM_result <= 32'b0;
            EX_MEM_valid <= 1'b0;
            EX_MEM_targetPC <= ID_EX_nextPC;
        end
      endcase
      
    end
  end
  
  // Stall EX if MEM is stalled
  // In future where 'div' is also supported,
  // stall EX for all multi-cycle operations
  always @(*) begin
    if (mem_stall_c) ex_stall_c = 1'b1;
    else ex_stall_c = 1'b0;
  end
  
endmodule
