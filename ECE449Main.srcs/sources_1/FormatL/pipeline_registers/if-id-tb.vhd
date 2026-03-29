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
        ------------------------------------------------------------------
        -- 1. Reset should clear both instruction and PC
        ------------------------------------------------------------------
        reset    <= '1';
        stall    <= '0';
        flush    <= '0';
        instr_in <= x"AAAA";
        pc_in    <= x"0005";

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"0000" and pc_out = x"0000"
          report "IF/ID: outputs not cleared on reset"
          severity error;

        ------------------------------------------------------------------
        -- 2. Normal latch
        ------------------------------------------------------------------
        reset    <= '0';
        instr_in <= x"1234";
        pc_in    <= x"0001";

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"1234" and pc_out = x"0001"
          report "IF/ID: normal latch failed"
          severity error;

        ------------------------------------------------------------------
        -- 3. Update again normally
        ------------------------------------------------------------------
        instr_in <= x"BEEF";
        pc_in    <= x"0002";

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"BEEF" and pc_out = x"0002"
          report "IF/ID: normal update failed"
          severity error;

        ------------------------------------------------------------------
        -- 4. Stall should hold old values
        ------------------------------------------------------------------
        stall    <= '1';
        instr_in <= x"9999";
        pc_in    <= x"0003";

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"BEEF" and pc_out = x"0002"
          report "IF/ID: stall did not hold previous values"
          severity error;

        ------------------------------------------------------------------
        -- 5. Release stall and latch new values
        ------------------------------------------------------------------
        stall    <= '0';
        instr_in <= x"7777";
        pc_in    <= x"0004";

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"7777" and pc_out = x"0004"
          report "IF/ID: release from stall failed"
          severity error;

        ------------------------------------------------------------------
        -- 6. Flush should clear outputs
        ------------------------------------------------------------------
        flush    <= '1';
        instr_in <= x"FFFF";
        pc_in    <= x"000A";

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
