// Pipeline's Data and Address sizes
`define ADDRESS_SIZE 32
`define DATA_SIZE    32


// Fields in Instruction Register (IR)
`define opcode IF_ID_IR[31:26]	// 6 bits
`define rs IF_ID_IR[25:21]		// 5 bits
`define rt IF_ID_IR[20:16]		// 5 bits
`define rd IF_ID_IR[15:11]		// 5 bits
`define shamt IF_ID_IR[10:6]	// 5 bits
`define funct IF_ID_IR[5:0]		// 6 bits
`define imm IF_ID_IR[15:0]		// 16 bits
`define address IF_ID_IR[25:0]	// 26 bits


// R type - funct
`define sll 6'd0
`define srl 6'd2
`define sra 6'd3
`define sllv 6'd4
`define srlv 6'd6
`define srav 6'd7
`define mult 6'd24
`define multu 6'd25
`define div 6'd26
`define divu 6'd27
`define add 6'd32
`define addu 6'd33
`define sub 6'd34
`define subu 6'd35
`define and_inst 6'd36
`define or_inst 6'd37
`define xor_inst 6'd38
`define nor_inst 6'd39
`define slt 6'd42
`define sltu 6'd43


// I type - opcode
`define beq 6'd4
`define bne 6'd5
`define blez 6'd6
`define bgtz 6'd7
`define addi 6'd8
`define addiu 6'd9
`define slti 6'd10
`define sltiu 6'd11
`define andi 6'd12
`define ori 6'd13
`define xori 6'd14
`define lui 6'd15
`define lw 6'd34
`define sw 6'd43


// J type - opcode
`define j_inst 6'd2
`define jal_inst 6'd3
