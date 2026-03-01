library ieee;
use ieee.std_logic_1164.all;

entity tb_id_ex_register is
end entity;

architecture simulate of tb_id_ex_register is
  signal clock : std_logic := '0';
  signal reset : std_logic := '0';

  signal opcode_in : std_logic_vector(6 downto 0)  := (others => '0'); 
  signal ra_dest_in : std_logic_vector(2 downto 0)  := (others => '0'); 
  signal rb_val_in : std_logic_vector(15 downto 0) := (others => '0'); 
  signal rc_val_in : std_logic_vector(15 downto 0) := (others => '0');
  signal reg_write_in : std_logic := '0';

  signal opcode_out : std_logic_vector(6 downto 0);
  signal ra_dest_out : std_logic_vector(2 downto 0);
  signal rb_val_out : std_logic_vector(15 downto 0);
  signal rc_val_out : std_logic_vector(15 downto 0);
  signal reg_write_out : std_logic;

  constant T : time := 10 ns;

begin

  dut : entity work.id_ex_register
    port map (
      clock => clock,
      reset => reset,
      opcode_in => opcode_in,
      ra_dest_in => ra_dest_in,
      rb_val_in => rb_val_in,
      rc_val_in => rc_val_in,
      reg_write_in => reg_write_in,
      opcode_out => opcode_out,
      ra_dest_out => ra_dest_out,
      rb_val_out => rb_val_out,
      rc_val_out => rc_val_out,
      reg_write_out => reg_write_out
    );

  clock <= not clock after T/2;

  process
  begin
    -- 1. Test reset clears everything
    reset <= '1';

    -- Drive non-zero values to prove reset overwrites them
    opcode_in <= "1010101";
    ra_dest_in <= "111";
    rb_val_in <= x"1111";
    rc_val_in <= x"2222";
    reg_write_in <= '1';

    wait until rising_edge(clock);
    wait for 1 ns;

    -- Check outputs cleared
    assert opcode_out = (others => '0') and
           ra_dest_out = (others => '0') and
           rb_val_out = x"0000" and
           rc_val_out = x"0000" and
           reg_write_out = '0'
      report "ID/EX: outputs not cleared on reset"
      severity error;

    -- 2. Release reset so it can latch inputs
    reset <= '0';

    -- Apply a set of values
    opcode_in <= "0001101";
    ra_dest_in <= "011";
    rb_val_in <= x"ABCD";
    rc_val_in <= x"0123";
    reg_write_in <= '1';

    wait until rising_edge(clock);
    wait for 1 ns;

    -- Check that each field latched correctly
    assert opcode_out = "0001101" and
           ra_dest_out = "011" and
           rb_val_out = x"ABCD" and
           rc_val_out = x"0123" and
           reg_write_out = '1'
      report "ID/EX: did not latch inputs correctly"
      severity error;

    -- Apply another set of values to ensure it updates each cycle
    opcode_in <= "1110001";
    ra_dest_in <= "001";
    rb_val_in <= x"DEAD";
    rc_val_in <= x"BEEF";
    reg_write_in <= '0';

    wait until rising_edge(clock);
    wait for 1 ns;

    -- Check update worked
    assert opcode_out = "1110001" and
           ra_dest_out = "001" and
           rb_val_out = x"DEAD" and
           rc_val_out = x"BEEF" and
           reg_write_out = '0'
      report "ID/EX: update failed"
      severity error;

    report "tb_id_ex_register PASSED" severity note;
    wait;
  end process;

end architecture;