LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY single_cycle_riscv_tb IS
END ENTITY;

ARCHITECTURE tb OF single_cycle_riscv_tb IS

    -- DUT port signals
    SIGNAL clock            : STD_LOGIC                     := '0';
    SIGNAL out_data         : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

BEGIN

    -- DUT instance
    -- To view internal signals in simulation, add them from the Objects window
    -- or use hierarchical paths like: DUT/datapath/pc, DUT/datapath/instruction, etc.
    DUT : ENTITY work.single_cycle_riscv(Structural)
        PORT MAP(
            clock    => clock,
            out_data => out_data
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
