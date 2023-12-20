`include "defines.vh"

module ram (  input clk,
              input write_enable,
              input [`ADDRESS_SIZE-1:0] write_address,
              input [`DATA_SIZE-1:0] write_data,
              input [`ADDRESS_SIZE-1:0] read_address,
              output logic [`DATA_SIZE-1:0] read_data
);

  logic [`DATA_SIZE-1:0] mem [longint];
  
  // Writes are performed in the next clock cycle
  always @(posedge clk) begin
    if (write_enable)
      mem[write_address] = write_data;
    else if((write_enable === 1'bx) | (write_enable === 1'bz))
      mem.delete();
  end
  
  // Reads are performed in the same clock cycle
  always @(read_address)
  begin
    read_data = 'hx;
    if((write_enable === 1'bx) | (write_enable === 1'bz))
      read_data = 'hx;
    else if(~write_enable && mem.exists(read_address))
      read_data = mem [read_address];
    else
      read_data = 'hx;
  end
  
  
  function void clearMem();
    mem.delete();
  endfunction
  
  function void loadMem(input string memFile);
    mem.delete();
    $display("INFO: Reading memory file: %s",memFile);
    if (memFile != "") begin
      $readmemh(memFile,mem);
      foreach(mem[i]) $display("%h",mem[i]);
    end
  endfunction

endmodule
