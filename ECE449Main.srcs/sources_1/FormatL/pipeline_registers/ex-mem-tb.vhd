library ieee;
use ieee.std_logic_1164.all;

entity tb_ex_mem_register is
end entity;

architecture sim of tb_ex_mem_register is
    signal clock         : std_logic := '0';
    signal reset         : std_logic := '0';

    signal wb_data_in    : std_logic_vector(15 downto 0) := (others => '0');
    signal wb_dest_in    : std_logic_vector(2 downto 0)  := (others => '0');
    signal reg_write_in  : std_logic := '0';

    signal wb_data_out   : std_logic_vector(15 downto 0);
    signal wb_dest_out   : std_logic_vector(2 downto 0);
    signal reg_write_out : std_logic;

    constant T : time := 10 ns;
begin

    dut : entity work.ex_mem_register
        port map(
            clock         => clock,
            reset         => reset,
            wb_data_in    => wb_data_in,
            wb_dest_in    => wb_dest_in,
            reg_write_in  => reg_write_in,
            wb_data_out   => wb_data_out,
            wb_dest_out   => wb_dest_out,
            reg_write_out => reg_write_out
        );

    clock <= not clock after T/2;

    process
    begin
        ------------------------------------------------------------------
        -- 1. Reset behavior
        ------------------------------------------------------------------
        reset        <= '1';
        wb_data_in   <= x"9999";
        wb_dest_in   <= "101";
        reg_write_in <= '1';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert wb_data_out = x"0000" and
               wb_dest_out = "000" and
               reg_write_out = '0'
          report "EX/MEM: outputs not cleared on reset"
          severity error;

        ------------------------------------------------------------------
        -- 2. Latch behavior
        ------------------------------------------------------------------
        reset        <= '0';
        wb_data_in   <= x"1234";
        wb_dest_in   <= "010";
        reg_write_in <= '1';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert wb_data_out = x"1234" and
               wb_dest_out = "010" and
               reg_write_out = '1'
          report "EX/MEM: latch failed"
          severity error;

        ------------------------------------------------------------------
        -- 3. Update on next clock
        ------------------------------------------------------------------
        wb_data_in   <= x"AAAA";
        wb_dest_in   <= "111";
        reg_write_in <= '0';

        wait until rising_edge(clock);
        wait for 1 ns;

        assert wb_data_out = x"AAAA" and
               wb_dest_out = "111" and
               reg_write_out = '0'
          report "EX/MEM: update failed"
          severity error;

        report "tb_ex_mem_register PASSED" severity note;
        wait;
    end process;

end architecture;
