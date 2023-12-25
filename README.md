# Single Core 5-stage MIPS pipeline RTL
 RTL design of a single core 5-stage MIPS pipeline CPU implementation in Verilog

The project was built and run on https://www.edaplayground.com/x/hBBR

The Core CPU module assumes that the Instruction Memory and Data Memory are both Byte addressable and Reads/Writes can be performed in a single cycle

This processor supports the following instructions:
| Type | Instructions         |
|------|-----------------------|
| R    | add                   |
| I    | lui, ori, sw, lw, beq |
| J    | j                     |

This project also implements Data Forwarding to avoid pipeline stalls due to Read-After-Write (RAW) hazards
