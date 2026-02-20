library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity PC is
port(
    clk : in std_logic;
    in_PC : in std_logic_vector(15 downto 0);
    Op_PC : in std_logic_vector(1 downto 0);
    out_PC : out std_logic_vector(15 downto 0)
);
end PC;

architecture Behavioral of PC is
    signal cur_PC : std_logic_vector(15 downto 0) := X"0000";
begin
process (clk)
begin

if rising_edge(clk) then
    case Op_PC is
        when "00" => 
        when "01" => cur_PC <= std_logic_vector(unsigned(cur_PC) + 1);
        when "10" => cur_PC <= in_PC;
        when "11" => cur_PC <= X"0000";
        when others =>
    end case;

end if;
end process;

out_PC <= cur_PC;

end Behavioral;


