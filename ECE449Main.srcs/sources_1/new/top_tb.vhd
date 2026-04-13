library ieee;
use ieee.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
end top_tb;

architecture simulate of top_tb is

    component top is
        Port (
            clk     : in  std_logic;
            rst_ex  : in  std_logic;
            rst_ld  : in  std_logic;
            sw      : in  std_logic_vector(15 downto 0);
            leds    : out std_logic_vector(15 downto 0)
        );
    end component;

    signal clk    : std_logic := '0';
    signal rst_ex : std_logic := '0';
    signal rst_ld : std_logic := '0';
    signal sw     : std_logic_vector(15 downto 0) := x"0000";
    signal leds   : std_logic_vector(15 downto 0);

    constant clk_period : time := 10 ns;

begin
    uut : top
    port map(
        clk    => clk,
        rst_ex => rst_ex,
        rst_ld => rst_ld,
        sw     => sw,
        leds   => leds
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
    begin
        -- Apply reset at startup (either button triggers full_reset in top)
        rst_ex <= '1';
        wait for 30 ns;
        rst_ex <= '0';

        -- Set switch input for first factorial test: N=5 (expect 5!=120=0x0078)
        sw <= x"0008";
        wait for 500 ns;

        -- Change input to N=4 (expect 4!=24=0x0018)
        sw <= x"0004";
        wait for 500 ns;

        -- Change input to N=7 (expect 7!=5040=0x13B0)
        sw <= x"0007";
        wait for 500 ns;

        -- Test overflow: N=9 (9!=362880, overflows 16-bit signed, expect LEDs=0x0000)
        sw <= x"0009";
        wait for 500 ns;

        -- Test edge case: N=2 (expect 2!=2=0x0002)
        sw <= x"0002";
        wait for 500 ns;

        wait;
    end process;

end simulate;
