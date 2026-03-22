library ieee;
use ieee.std_logic_1164.all;

entity tb_if_id_register is
end entity;

architecture simulate of tb_if_id_register is
    signal clock     : std_logic := '0';
    signal reset     : std_logic := '0';
    signal stall     : std_logic := '0';
    signal flush     : std_logic := '0';
    signal instr_in  : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_in     : std_logic_vector(15 downto 0) := (others => '0');
    signal instr_out : std_logic_vector(15 downto 0);
    signal pc_out    : std_logic_vector(15 downto 0);

    constant period : time := 10 ns;
begin

    dut : entity work.if_id_register
        port map(
            clock     => clock,
            reset     => reset,
            stall     => stall,
            flush     => flush,
            instr_in  => instr_in,
            pc_in     => pc_in,
            instr_out => instr_out,
            pc_out    => pc_out
        );

    clock <= not clock after period / 2;

    process
    begin
        -- Reset should clear outputs
        reset    <= '1';
        stall    <= '0';
        flush    <= '0';
        instr_in <= x"AAAA";
        pc_in    <= x"0011";
        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"0000" and pc_out = x"0000"
          report "IF/ID: outputs not cleared on reset"
          severity error;

        -- Normal latch
        reset    <= '0';
        instr_in <= x"1234";
        pc_in    <= x"0005";
        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"1234" and pc_out = x"0005"
          report "IF/ID: normal latch failed"
          severity error;

        -- Stall should hold old value
        stall    <= '1';
        instr_in <= x"BEEF";
        pc_in    <= x"0009";
        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"1234" and pc_out = x"0005"
          report "IF/ID: stall failed to hold value"
          severity error;

        -- Release stall, new values should latch
        stall    <= '0';
        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"BEEF" and pc_out = x"0009"
          report "IF/ID: value did not latch after stall released"
          severity error;

        -- Flush should clear outputs
        flush    <= '1';
        instr_in <= x"FFFF";
        pc_in    <= x"00AA";
        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"0000" and pc_out = x"0000"
          report "IF/ID: flush did not clear outputs"
          severity error;

        flush <= '0';

        report "tb_if_id_register PASSED" severity note;
        wait;
    end process;

end architecture;
