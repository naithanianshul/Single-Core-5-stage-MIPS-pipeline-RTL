`include "defines.vh"
`include "ram.sv"
`include "cpu.sv"

module tb_top();
  
  integer i;

  logic reset_n;
  logic clk;
  
  logic                      im_write_enable;
  logic [`ADDRESS_SIZE-1:0]  im_write_address;
  logic [`DATA_SIZE-1:0]     im_write_data;
  logic [`ADDRESS_SIZE-1:0]  im_read_address;
  logic [`DATA_SIZE-1:0]      im_read_data;
  logic                      dm_write_enable;
  logic [`ADDRESS_SIZE-1:0]  dm_write_address;
  logic [`DATA_SIZE-1:0]     dm_write_data;
  logic [`ADDRESS_SIZE-1:0]  dm_read_address;
  logic [`DATA_SIZE-1:0]      dm_read_data;
  
  // Instruction Memory
  ram instruction_memory (
          .write_enable 		( im_write_enable ),
          .write_address		( im_write_address ),
          .write_data   		( im_write_data ),
          .read_address 		( im_read_address ),
          .read_data    		( im_read_data ),
          .clk          		( clk )
  );

  // Data Memory
  ram data_memory (
          .write_enable 		( dm_write_enable ),
          .write_address		( dm_write_address ),
          .write_data   		( dm_write_data ),
          .read_address 		( dm_read_address ),
          .read_data   			( dm_read_data ),
          .clk          		( clk )
  );
  
  // CPU Core
  cpu core (
      .clock				( clk ),
      .reset_n				( reset_n ),
      .im_write_enable		( im_write_enable ),
      .im_write_address     ( im_write_address ),
      .im_write_data        ( im_write_data ),
      .im_read_address      ( im_read_address ),
      .im_read_data         ( im_read_data ),
      .dm_write_enable      ( dm_write_enable ),
      .dm_write_address     ( dm_write_address ),
      .dm_write_data        ( dm_write_data ),
      .dm_read_address      ( dm_read_address ),
      .dm_read_data         ( dm_read_data )
  );
  
  task printPipelineData;
    input integer i;
    begin
      $display("Clock Cycle = %h",i);
      $display("IF: IR = %h", core.IF_ID_IR);
      $display("ID: ID_EX_A = %h, ID_EX_B = %h, ID_EX_imm = %h, ID_EX_rd = %h, ID_EX_rt = %h, ID_EX_op = %h", core.ID_EX_A, core.ID_EX_B, core.ID_EX_imm, core.ID_EX_rd, core.ID_EX_rt, core.ID_EX_op);
      $display("EX: EX_MEM_result = %h, EX_MEM_dest = %h, EX_MEM_B = %h, EX_MEM_op = %h, EX_MEM_valid = %h, ex_stall_c = %h", core.EX_MEM_result, core.EX_MEM_dest, core.EX_MEM_B, core.EX_MEM_op, core.EX_MEM_valid, core.ex_stall_c);
      $display("MEM: MEM_WB_result = %h, MEM_WB_data = %h, MEM_WB_dest = %h, MEM_WB_op = %h, MEM_WB_valid = %h, mem_stall_c = %h", core.MEM_WB_result, core.MEM_WB_data, core.MEM_WB_dest, core.MEM_WB_op, core.MEM_WB_valid, core.mem_stall_c);
      $display("WB: WB_dest = %h, WB_value = %h, WB_WEenable = %h", core.WB_dest, core.WB_value, core.WB_WEenable);
      $display("");
    end
  endtask
  
  task wait_n_clks;
    input integer i;
  begin
    repeat(i)
    begin
      wait(clk);
      wait(!clk);
    end
  end
  endtask
  
  initial begin
    $dumpfile("cpu.vcd");
    $dumpvars;
    
    clk = 1'b0;
    
    instruction_memory.loadMem($sformatf("program.dat"));
    
    reset_n = 1;
    wait_n_clks(10);
    reset_n = 0;
    wait_n_clks(10);
    reset_n = 1;
    
    for (i = 1; i < 14; i = i + 1) begin
      wait_n_clks(1);
      printPipelineData(i);
    end
    
    $finish();
  end
  
  always #5 clk = ~clk;
  
endmodule
