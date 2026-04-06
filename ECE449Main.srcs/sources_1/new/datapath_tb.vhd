library ieee;
use ieee.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath_tb is
end datapath_tb;

architecture simulate of datapath_tb is

    component datapath is
        Port (
            clk : in std_logic;
            reset : in std_logic;
            outside_input : in std_logic_vector(15 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal outside_input : std_logic_vector(15 downto 0);

    constant clk_period : time := 10 ns;

begin
    uut : datapath
    port map(
        clk => clk,
        reset => reset,
        outside_input => outside_input
    );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    stimulus_process : process
        variable cycle : std_logic_vector(15 downto 0) := x"ffff";
    begin
        outside_input <= x"0000";
        
        --reset <= '1';       -- hold reset for active start
        --wait for 30 ns;     
        reset <= '0';       -- release reset so PC begins fetching from ROM
        --wait for 300 ns;    -- let pipeline run
        
        loop
            wait until rising_edge(clk);
            cycle := std_logic_vector(unsigned(cycle) + 1);
            
            case cycle is
                when x"010a" =>
                    outside_input <= x"FFFe";
                when x"010b" =>
                    outside_input <= x"0003";
                when x"010c" =>
                    outside_input <= x"0001";
                when x"010d" =>
                    outside_input <= x"0005";
                when x"010e" =>
                    outside_input <= x"0108";
                when x"010f" =>
                    outside_input <= x"0001";
                when x"0110" =>
                    outside_input <= x"0005";
                when x"0111" =>
                    outside_input <= x"0000";
                when others =>
                    outside_input <= x"0005";
            end case;
        end loop;
        
        
        wait;
    end process;

end simulate;