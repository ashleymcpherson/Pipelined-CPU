library ieee;
use ieee.std_logic_1164.all;

entity tb_ex_mem_register is
end entity;

architecture sim of tb_ex_mem_register is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';

  signal alu_result_in : std_logic_vector(15 downto 0) := (others => '0');
  signal ra_dest_in : std_logic_vector(2 downto 0)  := (others => '0'); 
  signal reg_write_in : std_logic := '0';

  signal alu_result_out : std_logic_vector(15 downto 0);
  signal ra_dest_out : std_logic_vector(2 downto 0);
  signal reg_write_out : std_logic;

  constant T : time := 10 ns;

begin

  dut : entity work.ex_mem_register
    port map (
      clock => clock,
      reset => reset,
      alu_result_in => alu_result_in,
      ra_dest_in => ra_dest_in,
      reg_write_in => reg_write_in,
      alu_result_out => alu_result_out,
      ra_dest_out => ra_dest_out,
      reg_write_out => reg_write_out
    );

  clock <= not clock after T/2;

  process
  begin

    -- Test 1. Reset test behaviour
    reset <= '1';  -- Turn reset ON
    alu_result_in <= x"9999";
    ra_dest_in <= "101";
    reg_write_in <= '1';

    wait until rising_edge(clock);
    wait for 1 ns;

    -- During reset, all output should be zero
    assert alu_result_out = x"0000" and
           ra_dest_out = "000" and
           reg_write_out = '0'
      report "EX/MEM: outputs not cleared on reset"
      severity error;

    -- Test 2. Latch test behaviour
    reset <= '0';  -- Turn reset OFF

    alu_result_in <= x"1234";  -- New ALU result
    ra_dest_in <= "010";
    reg_write_in <= '1';       -- Enable write

    wait until rising_edge(clock);
    wait for 1 ns;

    -- Outputs should match inputs after rising edge
    assert alu_result_out = x"1234" and
           ra_dest_out = "010" and
           reg_write_out = '1'
      report "EX/MEM: latch failed"
      severity error;

    -- Test 3. Update on next clock test
    alu_result_in <= x"AAAA";  -- Change ALU result
    ra_dest_in <= "111";
    reg_write_in <= '0';       -- Disable write

    wait until rising_edge(clock);  -- Next rising edge should latch these
    wait for 1 ns;

    -- Check that outputs updated correctly
    assert alu_result_out = x"AAAA" and
           ra_dest_out = "111" and
           reg_write_out = '0'
      report "EX/MEM: update failed"
      severity error;


    report "tb_ex_mem_register PASSED" severity note;
    wait;
  end process;

end architecture;