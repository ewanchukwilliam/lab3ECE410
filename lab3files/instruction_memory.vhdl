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
        -- Custom Test Program (little-endian)

        -- PC=0x00: lw x1, 4(x0)
        -- Load x1 from memory[4] = 0x00000024
        -- I-type: 000000000100_00000_010_00001_0000011 = 0x00402083
        0 => x"83", 1 => x"20", 2 => x"40", 3 => x"00",

        -- PC=0x04: lw x2, 8(x0)
        -- Load x2 from memory[8] = 0x00000043
        -- I-type: 000000001000_00000_010_00010_0000011 = 0x00802103
        4 => x"03", 5 => x"21", 6 => x"80", 7 => x"00",

        -- PC=0x08: add x3, x1, x2
        -- x3 = x1 + x2 = 0x24 + 0x43 = 0x67
        -- R-type: 0000000_00010_00001_000_00011_0110011 = 0x002081B3
        8 => x"B3", 9 => x"81", 10 => x"20", 11 => x"00",

        -- PC=0x0C: sw x3, 12(x0)
        -- Store x3 to memory[12] (overwrites 0xBABECAFE with 0x67)
        -- S-type: 0000000_00011_00000_010_01100_0100011 = 0x00302623
        12 => x"23", 13 => x"26", 14 => x"30", 15 => x"00",

        -- PC=0x10: lw x4, 12(x0)
        -- Load x4 from memory[12] = 0x67 (the value just stored)
        -- I-type: 000000001100_00000_010_00100_0000011 = 0x00C02203
        16 => x"03", 17 => x"22", 18 => x"C0", 19 => x"00",

        -- PC=0x14: beq x3, x4, 0
        -- Branch if x3 == x4 (they should be equal, both = 0x67)
        -- Offset = 0 means branch to same PC (effectively continue)
        -- B-type: 0_000000_00100_00011_000_0000_0_1100011 = 0x00418063
        20 => x"63", 21 => x"80", 22 => x"41", 23 => x"00",

        -- PC=0x18: add x5, x1, x2
        -- x5 = x1 + x2 = 0x24 + 0x43 = 0x67
        -- R-type: 0000000_00010_00001_000_00101_0110011 = 0x002082B3
        24 => x"B3", 25 => x"82", 26 => x"20", 27 => x"00",

        -- PC=0x1C: add x5, x2, x4
        -- x5 = x2 + x4 = 0x43 + 0x67 = 0xAA
        -- R-type: 0000000_00100_00010_000_00101_0110011 = 0x004102B3
        28 => x"B3", 29 => x"02", 30 => x"41", 31 => x"00",

        -- ========================================================================
        -- ORIGINAL BEQ TEST PROGRAM (commented out, uncomment to switch back)
        -- See beq.txt for expected outputs
        -- ========================================================================
        -- -- PC=0x00: lw x1, 0(x0) → x1 = 5
        -- 0 => x"83", 1 => x"20", 2 => x"00", 3 => x"00",
        --
        -- -- PC=0x04: lw x2, 4(x0) → x2 = 5
        -- 4 => x"03", 5 => x"21", 6 => x"40", 7 => x"00",
        --
        -- -- PC=0x08: beq x1, x2, 8 → BRANCH TAKEN (skip PC=0x0C)
        -- 8 => x"63", 9 => x"84", 10 => x"20", 11 => x"00",
        --
        -- -- PC=0x0C: lw x3, 8(x0) → SKIPPED (x3 stays 0)
        -- 12 => x"83", 13 => x"21", 14 => x"80", 15 => x"00",
        --
        -- -- PC=0x10: lw x4, 12(x0) → x4 = 10 (0xA)
        -- 16 => x"03", 17 => x"22", 18 => x"C0", 19 => x"00",
        --
        -- -- PC=0x14: lw x5, 16(x0) → x5 = 7
        -- 20 => x"83", 21 => x"22", 22 => x"00", 23 => x"01",
        --
        -- -- PC=0x18: beq x4, x5, 4 → BRANCH NOT TAKEN (x4≠x5)
        -- 24 => x"63", 25 => x"02", 26 => x"52", 27 => x"00",
        --
        -- -- PC=0x1C: lw x6, 20(x0) → x6 = 100 (0x64)
        -- 28 => x"03", 29 => x"23", 30 => x"40", 31 => x"01",

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
