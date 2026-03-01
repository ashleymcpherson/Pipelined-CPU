library ieee;
use ieee.std_logic_1164.all;

entity tb_if_id_register is
end entity;

architecture simulate of tb_if_id_register is
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal instr_in : std_logic_vector(15 downto 0) := (others => '0');
    signal instr_out : std_logic_vector(15 downto 0);

    constant period : time := 10 ns;
begin

    dut : entity work.if_id_register
        port map(
            clock => clock,
            reset => reset,
            instr_in => instr_in,
            instr_out => instr_out
        );

    clock <= not clock after period / 2;

    process
    begin
        -- 1. Assert reset and apply some input (input shouldn't matter during reset)
    reset    <= '1';  -- Turn reset ON
    instr_in <= x"AAAA";
    wait until rising_edge(clock);
    wait for 1 ns;

    -- During reset, output should be cleared to 0
    assert instr_out = x"0000"
      report "IF/ID: instr_out not cleared on reset"
      severity error;

    -- 2. Deassert reset so the register should start latching inputs
    reset <= '0';  -- Turn reset OFF

    -- 3. Apply instruction 0x1234, expect it to appear at output after next rising edge
    instr_in <= x"1234";
    wait until rising_edge(clock);
    wait for 1 ns;

    -- Check output latched correctly
    assert instr_out = x"1234"
      report "IF/ID: instr_out should equal instr_in after clock"
      severity error;

    -- 4. Apply instruction 0xBEEF, expect output to update on next rising edge
    instr_in <= x"BEEF";
    wait until rising_edge(clock);
    wait for 1 ns;

    -- Check update worked
    assert instr_out = x"BEEF"
      report "IF/ID: instr_out should update each clock"
      severity error;

    -- 5. Reset again mid-run (should clear output again)
    reset    <= '1';
    instr_in <= x"FFFF";
    wait until rising_edge(clock);
    wait for 1 ns;

    -- Output should clear again
    assert instr_out = x"0000"
      report "IF/ID: instr_out not cleared on second reset"
      severity error;

    report "tb_if_id_register PASSED" severity note;
    wait;

  end process;

end architecture;
