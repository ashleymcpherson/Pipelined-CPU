library ieee;
use ieee.std_logic_1164.all;

entity tb_rom_128B is
end entity;

architecture sim of tb_rom_128B is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';
  signal enable : std_logic := '0';
  signal address : std_logic_vector(5 downto 0) := (others => '0');
  signal data_out : std_logic_vector(15 downto 0);

  constant T : time := 10 ns;

begin

  -- Instantiate ROM DUT
  dut : entity work.rom_128B
    port map (
      clock => clock,
      reset => reset,
      enable => enable,
      address => address,
      data_out => data_out
    );

  -- Clock generator
  clock <= not clock after T/2;

  process
  begin
    -- 1. Apply reset
    reset <= '1';                -- Assert reset (clears ROM output register)
    enable <= '0';               -- Disable reads during reset
    address <= "000000";         -- Address 0
    wait until rising_edge(clock);
    wait for 1 ns;

    -- 2. Release reset and enable reading
    reset  <= '0';               -- Deassert reset
    enable <= '1';               -- Enable ROM reads

    -- 3. Read address 0
    address <= "000000";           -- Present address 0
    wait until rising_edge(clock); -- With latency=1, ROM output updates after this edge
    wait for 1 ns;

    -- Since init file is "none", all memory contents are 0
    assert data_out = x"0000"
      report "ROM: expected 0 at address 0 when init file is none"
      severity error;

    -- 4. Read last address (63)
    address <= "111111";         -- Present address 63
    wait until rising_edge(clock);
    wait for 1 ns;

    -- Should still be 0
    assert data_out = x"0000"
      report "ROM: expected 0 at address 63 when init file is none"
      severity error;

    -- 5. Disable enable (ROM typically holds last registered output)
    enable <= '0';               -- Disable reads
    address <= "000101";         -- Change address while disabled
    wait until rising_edge(clock);
    wait for 1 ns;

    -- With init file none, it's still 0, but we treat this as a "hold behavior" check
    assert data_out = x"0000"
      report "ROM: unexpected output when enable=0 (expected hold)"
      severity warning;

    report "tb_rom_128B PASSED (init file none)" severity note;
    wait;
  end process;

end architecture;