----------------------------------------------------------------------------------
-- Top-level wrapper for the pipelined CPU (datapath)
--
-- Clock  : driven by STM32 via JC1 (K17)
-- Reset  : either button (rst_ex W19 OR rst_ld T17) resets the full pipeline
-- Inputs : 16 onboard switches -> io_in_port
-- Outputs: io_out_port -> 16 onboard LEDs
-- Note   : outside_input is a legacy port, tied to 0x0000
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (
        clk     : in  std_logic;                       -- STM32 clock via JC1
        rst_ex  : in  std_logic;                       -- button W19
        rst_ld  : in  std_logic;                       -- button T17
        sw      : in  std_logic_vector(15 downto 0);   -- onboard switches
        leds    : out std_logic_vector(15 downto 0);    -- onboard LEDs
        led_segments : out std_logic_vector(6 downto 0);
        led_digits   : out std_logic_vector(3 downto 0)
    );
end top;

architecture Behavioral of top is

    signal reset : std_logic;
    signal full_reset : std_logic;
    
    component datapath is
        Port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            full_reset    : in std_logic;
            outside_input : in  std_logic_vector(15 downto 0);
            io_in_port    : in  std_logic_vector(15 downto 0);
            io_out_port   : out std_logic_vector(15 downto 0);
            led_segments  : out std_logic_vector(6 downto 0);
            led_digits    : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    -- Either button triggers a full pipeline + PC reset
    reset <= rst_ex or rst_ld;
    full_reset <= rst_ex or rst_ld;

    cpu: datapath
        port map (
            clk           => clk,
            reset         => reset,
            full_reset    => full_reset,
            outside_input => x"0000",   -- legacy port, unused
            io_in_port    => sw,
            io_out_port   => leds,
            led_segments  => led_segments,
            led_digits    => led_digits
        );

end Behavioral;