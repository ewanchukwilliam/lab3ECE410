------------------------------------------------------------------------
-- University  : University of Alberta
-- Course      : ECE 410
-- Project     : Lab 3
-- File        : single_cycle_datapath.vhdl
-- Authors     : Antonio Alejandro Andara Lara
-- Date        : 23-Oct-2025
------------------------------------------------------------------------
-- Description  : Structural implementation of a single-cycle RISC-V datapath.
--                Includes PC, instruction fetch, decode, ALU, memory, and write-back.
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY lw_sw_datapath IS
    PORT (
        clock       : IN STD_LOGIC;
        mem_write     : IN STD_LOGIC;
        reg_write     : IN STD_LOGIC;
        alu_src     : IN STD_LOGIC;
        mem_to_reg     : IN STD_LOGIC;
        output_en     : IN STD_LOGIC;
        imm_src      : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        alu_op     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        op_code      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        funct3      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        funct7_30      : OUT STD_LOGIC;
        zero_flag   : OUT STD_LOGIC;
        out_data   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE structural OF lw_sw_datapath IS

    SIGNAL pc, pc_next                      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL instruction, imm_ext, alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rs1_data, rs2_data, rd_data      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_mux_o                     : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL alu_mux_o                        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN
    op_code   <= instruction(6 DOWNTO 0);
    funct3   <= instruction(14 DOWNTO 12);
    funct7_30   <= instruction(30);

------------------------------------------------------------------------
-- FETCH BLOCK
------------------------------------------------------------------------
    dp_pc : ENTITY work.program_counter(Behavioral)
        PORT MAP(
            clock   => clock,
            pc_out  => pc,
            pc_next => pc_next
        );

    dp_pc_adder : ENTITY work.pc_adder(structural)
        PORT MAP(
            pc_current => pc,
            pc_next    => pc_next
        );

    dp_instr_mem : ENTITY work.instr_mem(rtl)
        PORT MAP(
            address => pc,
            data    => instruction
        );

------------------------------------------------------------------------
-- DECODE BLOCK
------------------------------------------------------------------------
    dp_regfile : ENTITY work.register_file(behavioral)
        PORT MAP(
            clock    => clock,
            rs1_addr => rs1_addr,
            rs2_addr => rs2_addr,
            rd_addr  => rd_addr,
            rd_data  => result_mux_o,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            rd_we    => reg_write
        );

    -- TODO: Instantiate your immediate extension unit here.
    --       Connect it to the 'instruction(31 DOWNTO 7)' input,
    --       the 'imm_sel' control signal, and drive the 'imm_ext' output.

------------------------------------------------------------------------
-- EXECUTE & MEMORY BLOCK
------------------------------------------------------------------------
    dp_alu_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => rs2_data,
            in1   => imm_ext,
            out_y => alu_mux_o,
            sel   => alu_src
        );

    dp_alu : ENTITY work.alu(behavioral)
        PORT MAP(
            src_a     => rs1_data,
            src_b     => alu_mux_o,
            alu_ctrl  => alu_op,
            result    => alu_result,
            zero_flag => zero_flag
        );

    dp_data_mem : ENTITY work.data_mem(rtl)
        PORT MAP(
            clock      => clock,
            address    => alu_result,
            write_data => rs2_data,
            data       => rd_data,
            write_en   => mem_write
        );

------------------------------------------------------------------------
-- WRITE-BACK BLOCK
------------------------------------------------------------------------
    dp_result_src : ENTITY work.mux_2to1(behavioral)
        PORT MAP(
            in0   => alu_result,
            in1   => rd_data,
            out_y => result_mux_o,
            sel   => mem_to_reg
        );

    dp_tri_state_buffer: ENTITY work.tri_state_buffer(Behavioral)
        PORT MAP(
            output_en => output_en,
            buffer_input => result_mux_o,
            buffer_output=> out_data
        );

END structural;
