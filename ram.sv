`include "defines.vh"

module ram (  input clk,
              input write_enable,
              input [`ADDRESS_SIZE-1:0] write_address,
              input [`DATA_SIZE-1:0] write_data,
              input [`ADDRESS_SIZE-1:0] read_address,
              output logic [`DATA_SIZE-1:0] read_data
);

  logic [7:0] mem [longint];
  
  // Writes are performed in the next clock cycle
  always @(posedge clk) begin
    if((write_enable === 1'bx) | (write_enable === 1'bz))
      mem.delete();
    else if (write_enable == 1'b1) begin
      mem[{write_address[31:2], 2'b00}] = write_data[31:24];
      mem[{write_address[31:2], 2'b01}] = write_data[23:16];
      mem[{write_address[31:2], 2'b10}] = write_data[15:8];
      mem[{write_address[31:2], 2'b11}] = write_data[7:0];
      //$display("Debug RAM: write_data = %h and write_address = %h", write_data, write_address);
    end
  end
  
  // Reads are performed in the same clock cycle
  always @(read_address)
  begin
    read_data = 'hx;
    if((write_enable === 1'bx) | (write_enable === 1'bz))
      read_data = 'hx;
    else if(write_enable == 1'b0 && mem.exists(read_address)) begin
      read_data = getWord(read_address);
      //$display("Debug RAM: read_data = %h and read_address = %h", getWord(read_address), read_address);
    end
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
      //foreach(mem[i]) $display("Debug RAM: %h",mem[i]);
    end
  endfunction
  
  function [31:0] getWord(input [`ADDRESS_SIZE-1:0] address);
    //$display("Debug RAM: address = %h and data = %h", address, {mem[address], mem[address+2'b01], mem[address+2'b10], mem[address+2'b11]});
    return {mem[{address[31:2], 2'b00}], mem[{address[31:2], 2'b01}], mem[{address[31:2], 2'b10}], mem[{address[31:2], 2'b11}]};
  endfunction

endmodule
