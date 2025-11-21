------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_controller.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Single-cycle control unit for a simple RISC-V processor.
--                Decodes op_code, funct3, and funct7 fields to generate
--                ALU, memory, and register control signals.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY controller IS
    PORT (
        op_code    : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7_30    : IN STD_LOGIC;
        zero_flag : IN STD_LOGIC;
        alu_src   : OUT STD_LOGIC;
        mem_to_reg   : OUT STD_LOGIC;
        mem_write   : OUT STD_LOGIC;
        reg_write   : OUT STD_LOGIC;
        output_en   : OUT STD_LOGIC;
        pc_src    : OUT STD_LOGIC;  -- Branch control signal
        imm_src    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_op   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END controller;

ARCHITECTURE Behavioral OF controller IS
    -- "controls" is a compact control word encoding all the main control signals.
    -- Bit mapping (from MSB to LSB):
    --   [9]   - Selects ALU B operand source (0 = register, 1 = immediate)
    --   [8]   - Selects write-back data source (0 = ALU result, 1 = memory read)
    --   [7]   - Enables register file write
    --   [6]   - Enables data memory write
    --   [5:3] - Selects immediate format depending on the instruction type (I, S, etc.)
    --   [2:0] - ALU control operation code
    --
    -- Each instruction assigns a 10-bit pattern to "controls" that defines its
    -- full control behavior in a single line using the WITH-SELECT statement below.
    SIGNAL controls     : STD_LOGIC_VECTOR(9 DOWNTO 0);

    -- added for visibility in simulation
    TYPE instruction IS (LW, SW, ADD, BEQ, NOP);
    SIGNAL instr : instruction := NOP;
    SIGNAL aux          : STD_LOGIC_VECTOR(10 DOWNTO 0);

    -- Instruction opcodes. add new values for each instruction
    CONSTANT OPCODE_LW   : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0000011";
    CONSTANT OPCODE_SW   : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0100011";
    CONSTANT OPCODE_ADD  : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0110011";
    CONSTANT OPCODE_BRANCH : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1100011";

    -- Control signals per instruction
    -- Format: alu_src, mem_to_reg, reg_write, mem_write, imm_src[2:0], alu_op[2:0]
    CONSTANT CTRL_LW  : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1110010100";  -- LW: I-type, ALU add
    CONSTANT CTRL_SW  : STD_LOGIC_VECTOR(9 DOWNTO 0) := "1101011100";  -- SW: S-type, ALU add
    CONSTANT CTRL_ADD : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0010011100";  -- ADD: R-type
    CONSTANT CTRL_BEQ : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000101101";  -- BEQ: B-type, ALU sub
    CONSTANT CTRL_NOP : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0000000000";

BEGIN
    output_en <= '1';
    aux <= funct7_30 & funct3 & op_code;

    decode : PROCESS (op_code, funct3, funct7_30)
    BEGIN
        controls <= CTRL_NOP;

        CASE op_code IS
            WHEN OPCODE_LW =>
                instr <= LW;
                controls <= CTRL_LW;
            WHEN OPCODE_SW =>
                instr <= SW;
                controls <= CTRL_SW;
            WHEN OPCODE_ADD =>
                IF funct3 = "000" AND funct7_30 = '0' THEN
                    instr <= ADD;
                    controls <= CTRL_ADD;
                END IF;
            WHEN OPCODE_BRANCH =>
                IF funct3 = "000" THEN  -- BEQ has funct3 = 000
                    instr <= BEQ;
                    controls <= CTRL_BEQ;
                END IF;
            WHEN OTHERS =>
                instr <= NOP;
                controls <= CTRL_NOP;
        END CASE;
    END PROCESS;

    -- controller output assignments
    alu_src <= controls(9);
    mem_to_reg <= controls(8);
    reg_write <= controls(7);
    mem_write <= controls(6);
    imm_src  <= controls(5 DOWNTO 3);
    alu_op <= controls(2 DOWNTO 0);

    -- Branch control: take branch if BEQ instruction AND zero_flag is set
    pc_src <= '1' WHEN (instr = BEQ AND zero_flag = '1') ELSE '0';

END Behavioral;
