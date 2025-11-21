------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : instruction_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB instruction memory (ROM) storing a simple RISC-V program.
--                Provides 32-bit instruction fetch based on byte address.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY instr_mem IS
    PORT (
        address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF instr_mem IS

    -- Byte-addressable ROM
    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    CONSTANT ROM : memory_data := (
        -- BEQ TEST using only LW, SW, ADD, BEQ
        -- (ADDI not implemented, so we use LW to get values)

        -- Instruction 0 @ PC=0x00: lw x1, 0(x0)
        -- Load x1 from memory address 0 (should load 0x00000005)
        -- I-type: imm=0x000, rs1=x0, funct3=010, rd=x1, opcode=0000011
        -- Binary: 000000000000_00000_010_00001_0000011 = 0x00002083
        0 => x"83", 1 => x"20", 2 => x"00", 3 => x"00",

        -- Instruction 1 @ PC=0x04: lw x2, 4(x0)
        -- Load x2 from memory address 4 (should load 0x00000005)
        -- I-type: imm=0x004, rs1=x0, funct3=010, rd=x2, opcode=0000011
        -- Binary: 000000000100_00000_010_00010_0000011 = 0x00402103
        4 => x"03", 5 => x"21", 6 => x"40", 7 => x"00",

        -- Instruction 2 @ PC=0x08: beq x1, x2, 8
        -- Branch forward 8 bytes if x1 == x2 (both should be 5)
        -- B-type: 0_000000_00010_00001_000_0100_0_1100011 = 0x00208463
        8 => x"63", 9 => x"84", 10 => x"20", 11 => x"00",

        -- Instruction 3 @ PC=0x0C: lw x3, 8(x0)
        -- Should be SKIPPED if branch works
        -- Load x3 = 99 from memory[8]
        -- I-type: 000000001000_00000_010_00011_0000011 = 0x00802183
        12 => x"83", 13 => x"21", 14 => x"80", 15 => x"00",

        -- Instruction 4 @ PC=0x10: lw x4, 12(x0)
        -- Branch target - Load x4 = 10 from memory[12]
        -- I-type: 000000001100_00000_010_00100_0000011 = 0x00C02203
        16 => x"03", 17 => x"22", 18 => x"C0", 19 => x"00",

        -- Instruction 5 @ PC=0x14: lw x5, 16(x0)
        -- Load x5 = 7 from memory[16]
        -- I-type: 000000010000_00000_010_00101_0000011 = 0x01002283
        20 => x"83", 21 => x"22", 22 => x"00", 23 => x"01",

        -- Instruction 6 @ PC=0x18: beq x4, x5, 4
        -- Should NOT branch (x4=10, x5=7)
        -- B-type: 0_000000_00101_00100_000_0010_0_1100011 = 0x00520263
        24 => x"63", 25 => x"02", 26 => x"52", 27 => x"00",

        -- Instruction 7 @ PC=0x1C: lw x6, 20(x0)
        -- Should execute - Load x6 = 100 from memory[20]
        -- I-type: 000000010100_00000_010_00110_0000011 = 0x01402303
        28 => x"03", 29 => x"23", 30 => x"40", 31 => x"01",

        OTHERS => (OTHERS => '0')
    );

    SIGNAL addr_int : INTEGER := 0;

BEGIN
    addr_int <= to_integer(unsigned(address(9 DOWNTO 0))); -- Address conversion fits 1 KB of ROM

    -- read 4 consecutive bytes form one 32-bit word
    data <= ROM(addr_int + 3) &
            ROM(addr_int + 2) &
            ROM(addr_int + 1) &
            ROM(addr_int);

END ARCHITECTURE rtl;
