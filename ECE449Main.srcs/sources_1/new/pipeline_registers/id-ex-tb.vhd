library ieee;
use ieee.std_logic_1164.all;

entity tb_id_ex_register is
end entity;

architecture simulate of tb_id_ex_register is
    signal clock         : std_logic := '0';
    signal reset         : std_logic := '0';
    signal flush         : std_logic := '0';

    signal instr_in      : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_in         : std_logic_vector(15 downto 0) := (others => '0');
    signal ra_dest_in    : std_logic_vector(2 downto 0)  := (others => '0');
    signal rb_src_in     : std_logic_vector(2 downto 0)  := (others => '0');
    signal rc_src_in     : std_logic_vector(2 downto 0)  := (others => '0');
    signal rb_val_in     : std_logic_vector(15 downto 0) := (others => '0');
    signal rc_val_in     : std_logic_vector(15 downto 0) := (others => '0');
    signal reg_write_in  : std_logic := '0';

    signal instr_out     : std_logic_vector(15 downto 0);
    signal pc_out        : std_logic_vector(15 downto 0);
    signal ra_dest_out   : std_logic_vector(2 downto 0);
    signal rb_src_out    : std_logic_vector(2 downto 0);
    signal rc_src_out    : std_logic_vector(2 downto 0);
    signal rb_val_out    : std_logic_vector(15 downto 0);
    signal rc_val_out    : std_logic_vector(15 downto 0);
    signal reg_write_out : std_logic;

    constant T : time := 10 ns;
begin

    dut : entity work.id_ex_register
        port map(
            clock         => clock,
            reset         => reset,
            flush         => flush,
            instr_in      => instr_in,
            pc_in         => pc_in,
            ra_dest_in    => ra_dest_in,
            rb_src_in     => rb_src_in,
            rc_src_in     => rc_src_in,
            rb_val_in     => rb_val_in,
            rc_val_in     => rc_val_in,
            reg_write_in  => reg_write_in,
            instr_out     => instr_out,
            pc_out        => pc_out,
            ra_dest_out   => ra_dest_out,
            rb_src_out    => rb_src_out,
            rc_src_out    => rc_src_out,
            rb_val_out    => rb_val_out,
            rc_val_out    => rc_val_out,
            reg_write_out => reg_write_out
        );

    clock <= not clock after T/2;

    process
    begin
        ------------------------------------------------------------------
        -- 1. Reset clears everything
        ------------------------------------------------------------------
        reset        <= '1';
        flush        <= '0';
        instr_in     <= x"ABCD";
        pc_in        <= x"0008";
        ra_dest_in   <= "111";
        rb_src_in    <= "001";
        rc_src_in    <= "010";
        rb_val_in    <= x"1111";
        rc_val_in    <= x"2222";
        reg_write_in <= '1';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"0000" and
               pc_out = x"0000" and
               ra_dest_out = "000" and
               rb_src_out = "000" and
               rc_src_out = "000" and
               rb_val_out = x"0000" and
               rc_val_out = x"0000" and
               reg_write_out = '0'
          report "ID/EX: outputs not cleared on reset"
          severity error;

        ------------------------------------------------------------------
        -- 2. Normal latch
        ------------------------------------------------------------------
        reset        <= '0';
        instr_in     <= x"1234";
        pc_in        <= x"0003";
        ra_dest_in   <= "011";
        rb_src_in    <= "001";
        rc_src_in    <= "101";
        rb_val_in    <= x"ABCD";
        rc_val_in    <= x"0123";
        reg_write_in <= '1';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"1234" and
               pc_out = x"0003" and
               ra_dest_out = "011" and
               rb_src_out = "001" and
               rc_src_out = "101" and
               rb_val_out = x"ABCD" and
               rc_val_out = x"0123" and
               reg_write_out = '1'
          report "ID/EX: did not latch inputs correctly"
          severity error;

        ------------------------------------------------------------------
        -- 3. Update on next clock
        ------------------------------------------------------------------
        instr_in     <= x"F00D";
        pc_in        <= x"0004";
        ra_dest_in   <= "001";
        rb_src_in    <= "110";
        rc_src_in    <= "111";
        rb_val_in    <= x"DEAD";
        rc_val_in    <= x"BEEF";
        reg_write_in <= '0';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"F00D" and
               pc_out = x"0004" and
               ra_dest_out = "001" and
               rb_src_out = "110" and
               rc_src_out = "111" and
               rb_val_out = x"DEAD" and
               rc_val_out = x"BEEF" and
               reg_write_out = '0'
          report "ID/EX: update failed"
          severity error;

        ------------------------------------------------------------------
        -- 4. Flush should clear everything
        ------------------------------------------------------------------
        flush        <= '1';
        instr_in     <= x"9999";
        pc_in        <= x"0009";
        ra_dest_in   <= "101";
        rb_src_in    <= "010";
        rc_src_in    <= "011";
        rb_val_in    <= x"AAAA";
        rc_val_in    <= x"BBBB";
        reg_write_in <= '1';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert instr_out = x"0000" and
               pc_out = x"0000" and
               ra_dest_out = "000" and
               rb_src_out = "000" and
               rc_src_out = "000" and
               rb_val_out = x"0000" and
               rc_val_out = x"0000" and
               reg_write_out = '0'
          report "ID/EX: flush did not clear outputs"
          severity error;

        flush <= '0';

        report "tb_id_ex_register PASSED" severity note;
        wait;
    end process;

end architecture;
