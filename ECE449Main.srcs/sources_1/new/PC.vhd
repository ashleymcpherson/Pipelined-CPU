----------------------------------------------------------------------------------
-- Module Name: PC.vhd - Behavioral

-- Description: 
--  Program Counter register.
--  Updates the current PC on the rising edge of the clock based on Op_PC.
----------------------------------------------------------------------------------

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
    -- Holds the current program counter value
    signal cur_PC : std_logic_vector(15 downto 0) := X"0000";
begin

    process(clk)
    begin
    
        if rising_edge(clk) then
            case Op_PC is
            
                -- Op_PC = "00"
                when "00" => 
                    -- Hold current PC value
                    
                -- Op_PC = "01"
                when "01" =>
                    -- Normal sequential execution: advance to the next instruction (increment PC by 1)
                    cur_PC <= std_logic_vector(unsigned(cur_PC) + 1);
                    
                -- Op_PC = "10"
                when "10" =>
                    -- Branch/jump: load PC with the target address from in_PC
                    cur_PC <= in_PC;
                    
                -- Op_PC = "11"
                when "11" => 
                    -- Reset PC to address 0x0000
                    cur_PC <= X"0000";
                   
                -- Safety case
                when others =>
                
            end case;
        end if;
    
    end process;

    -- Continuously drive the current PC value to the output
    out_PC <= cur_PC;

end Behavioral;


