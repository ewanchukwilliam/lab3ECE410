------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : extension_unit.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Immediate field extender for RISC-V instruction formats.
--                Supports I, S, B, U, and J-type immediate extraction.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY extension_unit IS
    PORT (
        din  : IN STD_LOGIC_VECTOR(31 DOWNTO 7);   -- Instruction bits [31:7]
        ctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);    -- Format selector
        dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)   -- Extended immediate
    );
END ENTITY;

ARCHITECTURE behavioral OF extension_unit IS
BEGIN

    PROCESS (din, ctrl)
        VARIABLE imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    BEGIN
        -- Default to zero
        imm := (OTHERS => '0');

        CASE ctrl IS
            -- I-type: imm[11:0] = inst[31:20]
            WHEN "010" =>
                imm(11 DOWNTO 0) := din(31 DOWNTO 20);
                -- Sign extend from bit 11
                IF din(31) = '1' THEN
                    imm(31 DOWNTO 12) := (OTHERS => '1');
                END IF;

            -- U-type: imm[31:12] = inst[31:12], imm[11:0] = 0
            WHEN "011" =>
                imm(31 DOWNTO 12) := din(31 DOWNTO 12);
                imm(11 DOWNTO 0) := (OTHERS => '0');

            -- S-type: imm[11:5] = inst[31:25], imm[4:0] = inst[11:7]
            WHEN "100" =>
                imm(11 DOWNTO 5) := din(31 DOWNTO 25);
                imm(4 DOWNTO 0) := din(11 DOWNTO 7);
                -- Sign extend from bit 11
                IF din(31) = '1' THEN
                    imm(31 DOWNTO 12) := (OTHERS => '1');
                END IF;

            -- B-type: imm[12] = inst[31], imm[10:5] = inst[30:25],
            --         imm[4:1] = inst[11:8], imm[11] = inst[7], imm[0] = 0
            WHEN "101" =>
                imm(12) := din(31);
                imm(11) := din(7);
                imm(10 DOWNTO 5) := din(30 DOWNTO 25);
                imm(4 DOWNTO 1) := din(11 DOWNTO 8);
                imm(0) := '0';
                -- Sign extend from bit 12
                IF din(31) = '1' THEN
                    imm(31 DOWNTO 13) := (OTHERS => '1');
                END IF;

            -- J-type: imm[20] = inst[31], imm[10:1] = inst[30:21],
            --         imm[11] = inst[20], imm[19:12] = inst[19:12], imm[0] = 0
            WHEN "110" =>
                imm(20) := din(31);
                imm(19 DOWNTO 12) := din(19 DOWNTO 12);
                imm(11) := din(20);
                imm(10 DOWNTO 1) := din(30 DOWNTO 21);
                imm(0) := '0';
                -- Sign extend from bit 20
                IF din(31) = '1' THEN
                    imm(31 DOWNTO 21) := (OTHERS => '1');
                END IF;

            WHEN OTHERS =>
                imm := (OTHERS => '0');
        END CASE;

        dout <= imm;
    END PROCESS;

END behavioral;
