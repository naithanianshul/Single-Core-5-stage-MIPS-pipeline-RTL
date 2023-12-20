`include "defines.vh"

module decode (	input clock,
				        input reset_n,
                input ex_stall_c,
                input mem_stall_c,
                
                input [`ADDRESS_SIZE-1:0] IF_ID_nextPC,
                input [`DATA_SIZE-1:0] IF_ID_IR,
                
                input EX_MEM_valid,
                input [4:0] EX_MEM_dest,
                input [`DATA_SIZE-1:0] EX_MEM_result,
                
                input MEM_WB_valid,
                input [4:0] MEM_WB_dest,
                input [`DATA_SIZE-1:0] MEM_WB_data,
				
               	input WB_WEenable,
                input [4:0] WB_dest,
                input [`DATA_SIZE-1:0] WB_value,
				
                output logic [`ADDRESS_SIZE-1:0] ID_EX_nextPC,
                output logic [`DATA_SIZE-1:0] ID_EX_A,
                output logic [`DATA_SIZE-1:0] ID_EX_B,
                output logic [`DATA_SIZE-1:0] ID_EX_imm,
                output logic [4:0] ID_EX_rd,	// 5 bits (from IR)
                output logic [4:0] ID_EX_rt,	// 5 bits (from IR)
                output logic [5:0] ID_EX_op,	// 6 bits (from IR)
                
                output logic id_stall_c
);

  // 2**5bits = 32 Architectural Registers of size 8 Byte (32 bits)
  logic [`DATA_SIZE-1:0] RF [32];
  
  integer i;
  
  always@(posedge clock) begin
    if (!reset_n) begin
      ID_EX_nextPC <= 32'b0;
      ID_EX_imm <= 32'b0;
      ID_EX_rd <= 5'b0;
      ID_EX_rt <= 5'b0;
      ID_EX_op <= 6'b0;
      ID_EX_A <= 32'b0;
      ID_EX_B <= 32'b0;
      for (i = 0; i < 32; i = i + 1) begin
        RF[i] = 32'b0;
      end
    end
    else if (ex_stall_c || mem_stall_c) begin
      if (WB_WEenable)
      	RF[WB_dest] <= WB_value;
      
      ID_EX_nextPC <= ID_EX_nextPC;
      ID_EX_imm <= ID_EX_imm;
      ID_EX_rd <= ID_EX_rd;
      ID_EX_rt <= ID_EX_rt;
      ID_EX_op <= ID_EX_op;
      ID_EX_A <= ID_EX_A;
      ID_EX_B <= ID_EX_B;
    end
    else begin
	  if (WB_WEenable)
      	RF[WB_dest] <= WB_value;
      
      ID_EX_nextPC <= ID_EX_nextPC;
	  ID_EX_imm <= `imm;
      ID_EX_rd <= `rd;
      ID_EX_rt <= `rt;
      if (`opcode == 6'b0)	ID_EX_op <= `funct;
      else	ID_EX_op <= `opcode;
      
      // --------------------------------------- //
      // Register File Bypass or Data Forwarding //
      // --------------------------------------- //
      
      // Forward from EX //
      if (EX_MEM_valid && `rs == EX_MEM_dest) begin
        ID_EX_A <= EX_MEM_result;
	    ID_EX_B <= RF[`rt];
      end
      else if (EX_MEM_valid && `rt == EX_MEM_dest) begin
        ID_EX_A <= RF[`rs];
	    ID_EX_B <= EX_MEM_result;
      end
      // Forward from MEM //
      else if (MEM_WB_valid && `rs == MEM_WB_dest) begin
        ID_EX_A <= MEM_WB_data;
	    ID_EX_B <= RF[`rt];
      end
      else if (MEM_WB_valid && `rt == MEM_WB_dest) begin
        ID_EX_A <= RF[`rs];
	    ID_EX_B <= MEM_WB_data;
      end
      // Forward from WB //
      else if (WB_WEenable && `rs == WB_dest) begin
        ID_EX_A <= WB_value;
	    ID_EX_B <= RF[`rt];
      end
      else if (WB_WEenable && `rt == WB_dest) begin
        ID_EX_A <= RF[`rs];
	    ID_EX_B <= WB_value;
      end
      // No RAW hazard //
      else begin
        ID_EX_A <= RF[`rs];
	    ID_EX_B <= RF[`rt];
      end
      
    end
  end
  
  // Stall ID if EX or MEM is stalled
  always @(*) begin
    if (ex_stall_c || mem_stall_c) id_stall_c = 1'b1;
    else id_stall_c = 1'b0;
  end
  
endmodule
