`include "defines.vh"

// Fields in Instruction Register (IR)
`define opcode IF_ID_IR[31:26]	// 6 bits
`define rs IF_ID_IR[25:21]		// 5 bits
`define rt IF_ID_IR[20:16]		// 5 bits
`define rd IF_ID_IR[15:11]		// 5 bits
`define shamt IF_ID_IR[10:6]	// 5 bits
`define funct IF_ID_IR[5:0]		// 6 bits
`define imm IF_ID_IR[15:0]		// 16 bits
`define address IF_ID_IR[25:0]	// 26 bits

module decode (	input clock,
				input reset_n,
                input ex_stall_c,
                input mem_stall_c,
               
                input WB_WEenable,
                input [4:0] WB_dest,
                input [`DATA_SIZE-1:0] WB_value,
                
                input [`ADDRESS_SIZE-1:0] IF_ID_nextPC,
                input [`DATA_SIZE-1:0] IF_ID_IR,
                
                output logic [`ADDRESS_SIZE-1:0] ID_EX_nextPC,
                output logic [`DATA_SIZE-1:0] ID_EX_A,
                output logic [`DATA_SIZE-1:0] ID_EX_B,
                output logic [15:0] ID_EX_imm,
                output logic [4:0] ID_EX_rs,	// 5 bits (from IR)
                output logic [4:0] ID_EX_rt,	// 5 bits (from IR)
                output logic [4:0] ID_EX_rd,	// 5 bits (from IR)
                output logic [5:0] ID_EX_op,	// 6 bits (from IR)
                output logic [1:0] ID_EX_instruc_type,
                
                output logic id_stall_c
);
  
  logic [`DATA_SIZE-1:0] t_ID_EX_A;
  logic [`DATA_SIZE-1:0] t_ID_EX_B;
  logic [5:0] t_ID_EX_op;
  logic [1:0] t_ID_EX_instruc_type;

  // 2**5bits = 32 Architectural Registers of size 8 Byte (32 bits)
  logic [`DATA_SIZE-1:0] RF [32];
  
  integer i;
  
  always@(posedge clock) begin
    if (!reset_n) begin
      /*for (i = 0; i < 32; i = i + 1) begin
        RF[i] = 32'b0;
      end*/
      
      ID_EX_nextPC <= 32'b0;

      ID_EX_A <= 32'b0;
      ID_EX_B <= 32'b0;
      ID_EX_imm <= 32'b0;

      ID_EX_rs <= 5'b0;
      ID_EX_rt <= 5'b0;
      ID_EX_rd <= 5'b0;
      ID_EX_op <= 6'b0;
      ID_EX_instruc_type <= 2'b00;
    end
    else if (ex_stall_c || mem_stall_c) begin
      if (WB_WEenable) begin
      	RF[WB_dest] <= WB_value;
        $display("Debug ID: Pipeline stallled but WB result is written back WB_dest = %h, WB_value = %h", WB_dest, WB_value);
      end
      
      ID_EX_nextPC <= ID_EX_nextPC;
      
      ID_EX_A <= ID_EX_A;
      ID_EX_B <= ID_EX_B;
      ID_EX_imm <= ID_EX_imm;
      
      ID_EX_rs <= ID_EX_rs;
      ID_EX_rt <= ID_EX_rt;
      ID_EX_rd <= ID_EX_rd;
      ID_EX_op <= ID_EX_op;
      ID_EX_instruc_type <= ID_EX_instruc_type;
      
    end
    else begin
      if (WB_WEenable) begin
      	RF[WB_dest] <= WB_value;
        $display("Debug ID: WB result is written back WB_dest = %h, WB_value = %h", WB_dest, WB_value);
      end
      
      ID_EX_nextPC <= ID_EX_nextPC;
      
	  ID_EX_A <= t_ID_EX_A;
      ID_EX_B <= t_ID_EX_B;
      ID_EX_imm <= `imm;
      
      ID_EX_rs <= `rs;
      ID_EX_rt <= `rt;
      ID_EX_rd <= `rd;
      ID_EX_op <= t_ID_EX_op;
      ID_EX_instruc_type <= t_ID_EX_instruc_type;
    end
  end
  
  always @(*) begin
    // id_stall //
    if (ex_stall_c || mem_stall_c) id_stall_c <= 1'b1;
    else id_stall_c <= 1'b0;
    
    // A and B //
    if (WB_WEenable && WB_dest == `rs) begin
      $display("Debug ID: WB result is forwarded to 'A' WB_dest = %h, WB_value = %h", WB_dest, WB_value);
      t_ID_EX_A <= WB_value;
    end
    else t_ID_EX_A <= RF[`rs];
    if (WB_WEenable && WB_dest == `rt) begin
      $display("Debug ID: WB result is forwarded to 'B' WB_dest = %h, WB_value = %h", WB_dest, WB_value);
      t_ID_EX_B <= WB_value;
    end
    else t_ID_EX_B <= RF[`rt];
    
    // op and instruc_type //
    // R type instruction - 11
    if (|`opcode == 1'b0 && |IF_ID_IR[25:0] == 1'b1) begin
      t_ID_EX_op <= `funct;
      t_ID_EX_instruc_type <= 2'b11;
      $display("Debug ID: R type instruction");
    end
    // I type instruction - 10
    else if (|IF_ID_IR[31:28] == 1'b1) begin
      t_ID_EX_op <= `opcode;
      t_ID_EX_instruc_type <= 2'b10;
      $display("Debug ID: I type instruction, opcode = %b", IF_ID_IR[31:26]);
    end
    // J type instruction - 01
    else if (|IF_ID_IR[31:28] == 1'b0 && IF_ID_IR[27] == 1'b1) begin
      t_ID_EX_op <= `opcode;
      t_ID_EX_instruc_type <= 2'b01;
      $display("Debug ID: J type instruction");
    end
    // NOP - 00
    else begin
      t_ID_EX_op <= `opcode;
      t_ID_EX_instruc_type <= 2'b00;
      $display("Debug ID: NOP instruction");
    end
  end
  
endmodule
