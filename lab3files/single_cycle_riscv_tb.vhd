LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_riscv_tb IS
END ENTITY;

ARCHITECTURE tb OF single_cycle_riscv_tb IS

    -- DUT port signals
    SIGNAL clock            : STD_LOGIC                     := '0';
    SIGNAL out_data         : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    -- Exposed internal signals for waveform viewing
    SIGNAL pc               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL branch_target    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL instruction      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rs1_data         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rs2_data         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_result       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL imm_ext          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL zero_flag        : STD_LOGIC;
    SIGNAL pc_src           : STD_LOGIC;
    SIGNAL alu_op           : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

    -- DUT instance with debug outputs
    DUT : ENTITY work.single_cycle_riscv(Structural)
        PORT MAP(
            clock               => clock,
            out_data            => out_data,
            debug_pc            => pc,
            debug_instruction   => instruction,
            debug_pc_src        => pc_src,
            debug_zero_flag     => zero_flag,
            debug_branch_target => branch_target,
            debug_rs1_data      => rs1_data,
            debug_rs2_data      => rs2_data,
            debug_alu_result    => alu_result,
            debug_imm_ext       => imm_ext,
            debug_alu_op        => alu_op
        );

    clk_process : PROCESS
    BEGIN
        FOR i IN 0 TO 9 LOOP
            clock <= '0';
            WAIT FOR 1 ns;
            clock <= '1';
            WAIT FOR 1 ns;
        END LOOP;
        WAIT;
    END PROCESS;

END ARCHITECTURE;
