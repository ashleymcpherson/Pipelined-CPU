library ieee;
use ieee.std_logic_1164.all;

entity tb_mem_wb_register is
end entity;

architecture simulate of tb_mem_wb_register is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';

  signal wb_data_in : std_logic_vector(15 downto 0) := (others => '0'); -- data to write back
  signal ra_dest_in : std_logic_vector(2 downto 0)  := (others => '0'); -- destination reg
  signal reg_write_in : std_logic := '0';                                   -- write enable

  signal wb_data_out : std_logic_vector(15 downto 0);
  signal ra_dest_out : std_logic_vector(2 downto 0);
  signal reg_write_out : std_logic;

  constant T : time := 10 ns;

begin

  dut : entity work.mem_wb_register
    port map (
      clock => clock,
      reset => reset,
      wb_data_in => wb_data_in,
      ra_dest_in => ra_dest_in,
      reg_write_in => reg_write_in,
      wb_data_out => wb_data_out,
      ra_dest_out => ra_dest_out,
      reg_write_out => reg_write_out
    );

  clock <= not clock after T/2;

  stimulus : process
  begin
    -- Reset test
    reset <= '1';
    wb_data_in <= x"FEED";
    ra_dest_in <= "001";
    reg_write_in <= '1';

    wait until rising_edge(clock);
    wait for 1 ns;

    assert wb_data_out = x"0000" and
           ra_dest_out = "000" and
           reg_write_out = '0'
      report "MEM/WB: outputs not cleared on reset"
      severity error;

    reset <= '0';

    -- Latch test
    wb_data_in <= x"CAFE";
    ra_dest_in <= "110";
    reg_write_in <= '1';

    wait until rising_edge(clock);
    wait for 1 ns;

    assert wb_data_out = x"CAFE" and
           ra_dest_out = "110" and
           reg_write_out = '1'
      report "MEM/WB: latch failed"
      severity error;

    -- Update test (write enable changes too)
    wb_data_in <= x"0001";
    ra_dest_in <= "010";
    reg_write_in <= '0';

    wait until rising_edge(clock);
    wait for 1 ns;

    assert wb_data_out = x"0001" and
           ra_dest_out = "010" and
           reg_write_out = '0'
      report "MEM/WB: update failed"
      severity error;

    report "tb_mem_wb_register PASSED" severity note;
    wait;
  end process;

end architecture;