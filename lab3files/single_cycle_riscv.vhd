------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_riscv.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Top-level RISC-V CPU combining single-cycle datapath and control logic.
--                Executes basic load, store, and arithmetic instructions.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY single_cycle_riscv IS
    PORT (
        clock     : IN STD_LOGIC;
        out_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE Structural OF single_cycle_riscv IS
    SIGNAL zero_flag                       : STD_LOGIC                     := '0';
    SIGNAL pc, pc_next                     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mem_write                         : STD_LOGIC;
    SIGNAL reg_write                         : STD_LOGIC;
    SIGNAL funct7_30                          : STD_LOGIC;
    SIGNAL alu_src, mem_to_reg, output_en, pc_src : STD_LOGIC;
    SIGNAL funct3                          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL imm_src                          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL alu_op                         : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL op_code                          : STD_LOGIC_VECTOR(6 DOWNTO 0);

BEGIN

    datapath : ENTITY work.lw_sw_datapath(structural)
        PORT MAP(
            clock       => clock,
            mem_write   => mem_write,    -- Signal 13: from controller
            reg_write   => reg_write,    -- Signal 10: from controller
            alu_src     => alu_src,      -- Signal 11: from controller
            mem_to_reg  => mem_to_reg,   -- Signal 14: from controller
            output_en   => output_en,    -- Signal 15: from controller
            pc_src      => pc_src,       -- Branch control: from controller
            imm_src     => imm_src,      -- Signal 8: from controller
            alu_op      => alu_op,       -- Signal 12: from controller
            op_code     => op_code,      -- Signal 1: to controller
            funct3      => funct3,       -- Signal 2: to controller
            funct7_30   => funct7_30,    -- Signal 3: to controller
            zero_flag   => zero_flag,    -- zero flag to controller
            out_data    => out_data
        );

    control_unit : ENTITY work.controller(behavioral)
        PORT MAP(
            op_code     => op_code,      -- Signal 1: from datapath
            funct3      => funct3,       -- Signal 2: from datapath
            funct7_30   => funct7_30,    -- Signal 3: from datapath
            zero_flag   => zero_flag,    -- zero flag from datapath
            alu_src     => alu_src,      -- Signal 11: to datapath
            mem_to_reg  => mem_to_reg,   -- Signal 14: to datapath
            mem_write   => mem_write,    -- Signal 13: to datapath
            reg_write   => reg_write,    -- Signal 10: to datapath
            output_en   => output_en,    -- Signal 15: to datapath
            pc_src      => pc_src,       -- Branch control: to datapath
            imm_src     => imm_src,      -- Signal 8: to datapath
            alu_op      => alu_op        -- Signal 12: to datapath
        );
END Structural;
