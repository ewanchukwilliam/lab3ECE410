------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : data_memory.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : 1 KB data memory with 32-bit read/write interface.
--                Supports synchronous writes and asynchronous reads.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY data_mem IS
    PORT (
        address    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        write_en   : IN STD_LOGIC;
        clock      : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF data_mem IS

    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL RAM : memory_data := (
        4 => x"DEADBEEF",
        8 => x"CAFEBABE",
        OTHERS => (OTHERS => '0')
    );

BEGIN

    PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) AND write_en = '1' THEN
            RAM(to_integer(unsigned(address))) <= write_data;
        END IF;
    END PROCESS;

    data <= RAM(to_integer(unsigned(address)));

END behavioral;

ARCHITECTURE rtl OF data_mem IS

    TYPE memory_data IS ARRAY (0 TO 1023) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL RAM : memory_data := (
        -- Custom Test Data (little-endian)
        -- Address 0x0: 0x0AAAAAAA
        0 => x"AA", 1 => x"AA", 2 => x"AA", 3 => x"0A",
        -- Address 0x4: 0x00000024
        4 => x"24", 5 => x"00", 6 => x"00", 7 => x"00",
        -- Address 0x8: 0x00000043
        8 => x"43", 9 => x"00", 10 => x"00", 11 => x"00",
        -- Address 0xC: 0xBABECAFE
        12 => x"FE", 13 => x"CA", 14 => x"BE", 15 => x"BA",
        -- Address 0x10: 0x00000002
        16 => x"02", 17 => x"00", 18 => x"00", 19 => x"00",
        -- Address 0x14: 0xFFFFFFFF
        20 => x"FF", 21 => x"FF", 22 => x"FF", 23 => x"FF",
        -- Address 0x18: 0x00000000
        24 => x"00", 25 => x"00", 26 => x"00", 27 => x"00",
        -- Address 0x1C: 0xA3700A37
        28 => x"37", 29 => x"0A", 30 => x"70", 31 => x"A3",
        OTHERS => (OTHERS => '0')
    );

    SIGNAL addr_int : INTEGER := 0;

BEGIN

    -- Convert 32-bit address to integer
    addr_int <= to_integer(unsigned(address(9 DOWNTO 0))); -- 1 KB = 10-bit addressing

    -- Synchronous write
    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) THEN
            IF write_en = '1' THEN
                -- Write 32-bit word to memory in little-endian byte order
                RAM(addr_int + 0) <= write_data(7 DOWNTO 0);    -- LSB
                RAM(addr_int + 1) <= write_data(15 DOWNTO 8);
                RAM(addr_int + 2) <= write_data(23 DOWNTO 16);
                RAM(addr_int + 3) <= write_data(31 DOWNTO 24);  -- MSB
            END IF;
        END IF;
    END PROCESS;

    -- Combinational read
    -- Reconstruct 32-bit word from four bytes in little-endian order
    data <= RAM(addr_int + 3) & RAM(addr_int + 2) & RAM(addr_int + 1) & RAM(addr_int + 0);

END ARCHITECTURE rtl;
