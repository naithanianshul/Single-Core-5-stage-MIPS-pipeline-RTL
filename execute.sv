`include "defines.vh"

module execute (input clock,
				input reset_n,
                input mem_stall_c,
                
                input MEM_WB_valid,
                input [4:0] MEM_WB_dest,
                input [`DATA_SIZE-1:0] MEM_WB_result,
				
               	input WB_WEenable,
                input [4:0] WB_dest,
                input [`DATA_SIZE-1:0] WB_value,
				
                input [`ADDRESS_SIZE-1:0] ID_EX_nextPC,
                input [`DATA_SIZE-1:0] ID_EX_A,
                input [`DATA_SIZE-1:0] ID_EX_B,
                input [15:0] ID_EX_imm,
                input [4:0] ID_EX_rs,	// 5 bits (from IR)
                input [4:0] ID_EX_rt,	// 5 bits (from IR)
                input [4:0] ID_EX_rd,	// 5 bits (from IR)
                input [5:0] ID_EX_op,	// 6 bits (from IR)
                input [1:0] ID_EX_instruc_type,
                
                output logic EX_MEM_changePC_c,
                output logic [`ADDRESS_SIZE-1:0] EX_MEM_targetPC,
                output logic [`DATA_SIZE-1:0] EX_MEM_result,
                output logic [`DATA_SIZE-1:0] EX_MEM_B,
                output logic [4:0] EX_MEM_dest,
                output logic [5:0] EX_MEM_op,
                output logic [1:0] EX_MEM_instruc_type,
                
                output logic EX_MEM_valid,
                output logic ex_stall_c
);
  
  logic [`DATA_SIZE-1:0] t_A;
  logic [`DATA_SIZE-1:0] t_B;
  
  logic valid_rs;
  logic valid_rt;
  logic valid_rd;
  assign valid_rs = (ID_EX_instruc_type[1] == 1'b1);
  assign valid_rt = (ID_EX_instruc_type[1] == 1'b1);
  assign valid_rd = (ID_EX_instruc_type == 2'b11);
  
  logic t_EX_MEM_valid;
  assign t_EX_MEM_valid = (ID_EX_instruc_type != 2'b00);
  
  always@(posedge clock) begin
    if (~reset_n | EX_MEM_changePC_c) begin
	  EX_MEM_dest <= 5'b0;
      EX_MEM_result <= 32'b0;
      EX_MEM_op <= 6'b0;
      EX_MEM_B <= 32'b0;
      EX_MEM_instruc_type <= 2'b0;
      EX_MEM_changePC_c <= 1'b0;
      EX_MEM_targetPC <= 32'b0;
      EX_MEM_valid <= 1'b0;
    end
    else if (mem_stall_c) begin
	  EX_MEM_dest <= EX_MEM_dest;
      EX_MEM_result <= EX_MEM_result;
      EX_MEM_op <= EX_MEM_op;
      EX_MEM_B <= EX_MEM_B;
      EX_MEM_instruc_type <= EX_MEM_instruc_type;
      EX_MEM_changePC_c <= EX_MEM_changePC_c;
      EX_MEM_targetPC <= EX_MEM_targetPC;
      EX_MEM_valid <= EX_MEM_valid;
    end
    else begin
      if (valid_rd) EX_MEM_dest <= ID_EX_rd;
      else EX_MEM_dest <= ID_EX_rt;
      
      EX_MEM_changePC_c <= 1'b0;
      // ALU Instruc Ops
      case (ID_EX_op)
        `lui: begin
          EX_MEM_result <= {ID_EX_imm, 16'b0};
          EX_MEM_targetPC <= ID_EX_nextPC;
        end

        `ori: begin
          EX_MEM_result <= t_A | {16'b0, ID_EX_imm};
          EX_MEM_targetPC <= ID_EX_nextPC;
        end

        `add: begin
          EX_MEM_result <= t_A + t_B;
          EX_MEM_targetPC <= ID_EX_nextPC;
        end
        
        `lw: begin
          EX_MEM_result <= t_A + { {16{ID_EX_imm[15]}}, ID_EX_imm };
          EX_MEM_targetPC <= ID_EX_nextPC;
        end
        
        `sw: begin
          EX_MEM_result <= t_A + { {16{ID_EX_imm[15]}}, ID_EX_imm };
          EX_MEM_targetPC <= ID_EX_nextPC;
        end

        `j_inst: begin
          EX_MEM_result <= 32'b0;
          EX_MEM_changePC_c <= 1'b1;
          EX_MEM_targetPC <= {ID_EX_nextPC[31:28], {ID_EX_rs,ID_EX_rt,ID_EX_imm}, 2'b00};
          $display("Debug EX: Jump to EX_MEM_targetPC = %h", {ID_EX_nextPC[31:28], {ID_EX_rs,ID_EX_rt,ID_EX_imm}, 2'b00});
        end
        
        `beq: begin
          EX_MEM_result <= 32'b0;
          $display("Debug EX: beq - ID_EX_A = %h, ID_EX_B = %h", t_A, t_B);
          if (t_A == t_B) begin
          	EX_MEM_changePC_c <= 1'b1;
            EX_MEM_targetPC <= ID_EX_nextPC + { {14{ID_EX_imm[15]}}, ID_EX_imm, 2'b00 };
            $display("Debug EX: Jump to EX_MEM_targetPC = %h based on ID_EX_nextPC = %h and ID_EX_imm = %h", ID_EX_nextPC + { {14{ID_EX_imm[15]}}, ID_EX_imm, 2'b00 }, ID_EX_nextPC, ID_EX_imm);
          end
          else begin
            EX_MEM_changePC_c <= 1'b0;
          	EX_MEM_targetPC <= ID_EX_nextPC;
          end
        end

        default: begin
          EX_MEM_result <= 32'b0;
          EX_MEM_targetPC <= ID_EX_nextPC;
        end
      endcase
      
      EX_MEM_op <= ID_EX_op;
      EX_MEM_B <= t_B;
      EX_MEM_instruc_type <= ID_EX_instruc_type;
      EX_MEM_valid <= t_EX_MEM_valid;
      //$display("Debug EX: ID_EX_instruc_type = %h, t_EX_MEM_valid = %h", ID_EX_instruc_type, t_EX_MEM_valid);
    end
  end
  
  
  always @(*) begin
    // Stall EX if MEM is stalled
    // In future where 'div' is also supported,
	// stall EX for all multi-cycle operations
    if (mem_stall_c) ex_stall_c <= 1'b1;
    else ex_stall_c <= 1'b0;
    
    // --------------------------------------- //
    // Register File Bypass or Data Forwarding //
    // --------------------------------------- //

    t_A <= ID_EX_A;
    //$display("Debug EX: valid_rs = %h, ID_EX_instruc_type = %h, ID_EX_op = %h", valid_rt, ID_EX_instruc_type, ID_EX_op);
    if (valid_rs) begin
      // Value t_A -- Register `rs
      // Forward from EX //
      if (EX_MEM_valid && ID_EX_rs == EX_MEM_dest) begin
        t_A <= EX_MEM_result;
        $display("Debug EX: Data forwarded to ID_EX_A (rs = %h) from EX_MEM_result = %h", ID_EX_rs, EX_MEM_dest);
      end
      // Forward from MEM //
      else if (MEM_WB_valid && ID_EX_rs == MEM_WB_dest) begin
        t_A <= MEM_WB_result;
        $display("Debug EX: Data forwarded to ID_EX_A (rs = %h) from MEM_WB_result = %h", ID_EX_rs, MEM_WB_result);
      end
      // Forward from WB //
      else if (WB_WEenable && ID_EX_rs == WB_dest) begin
        t_A <= WB_value;
        $display("Debug EX: Data forwarded to ID_EX_A (rs = %h) from WB_value = %h", ID_EX_rs, WB_value);
      end
    end

    t_B <= ID_EX_B;
    //$display("Debug EX: valid_rt = %h, ID_EX_instruc_type = %h, ID_EX_op = %h", valid_rt, ID_EX_instruc_type, ID_EX_op);
    if (valid_rt) begin
      // Value t_B -- Register `rt
      // Forward from EX //
      if (EX_MEM_valid && ID_EX_rt == EX_MEM_dest) begin
        t_B <= EX_MEM_result;
        $display("Debug EX: Data forwarded to ID_EX_B (rt = %h) from EX_MEM_result = %h", ID_EX_rt, EX_MEM_result);
      end
      // Forward from MEM //
      else if (MEM_WB_valid && ID_EX_rt == MEM_WB_dest) begin
        t_B <= MEM_WB_result;
        $display("Debug EX: Data forwarded to ID_EX_B (rt = %h) from MEM_WB_result = %h", ID_EX_rt, MEM_WB_result);
      end
      // Forward from WB //
      else if (WB_WEenable && ID_EX_rt == WB_dest) begin
        t_B <= WB_value;
        $display("Debug EX: Data forwarded to ID_EX_B (rt = %h) from WB_value = %h", ID_EX_rt, WB_value);
      end
    end 
    // --------------------------------------- //
    //                    END                  //
    // --------------------------------------- //
      
    
  end
  
endmodule
