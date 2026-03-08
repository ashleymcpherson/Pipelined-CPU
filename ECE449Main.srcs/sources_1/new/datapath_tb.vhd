library ieee;
use ieee.STD_LOGIC_1164.ALL;

entity datapath_tb is
end datapath_tb;

architecture simulate of datapath_tb is

    component datapath is
        Port (
            clk : in std_logic;
            reset : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    constant clk_period : time := 10 ns;

begin
    uut : datapath
    port map(
        clk => clk,
        reset => reset
    );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stimulus_process : process
    begin
        reset <= '1';       -- hold reset for active start
        wait for 30 ns;     
        reset <= '0';       -- release reset so PC begins fetching from ROM
        wait for 300 ns;    -- let pipeline run
        wait;
    end process;

end simulate;