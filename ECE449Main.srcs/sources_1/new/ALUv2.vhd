----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/08/2026 04:30:00 PM
-- Design Name: 
-- Module Name: ALUv2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_SIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALUv2 is
Port ( 
    rb : in signed(15 downto 0); 
    rc : in signed(15 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    shiftop : in std_logic_vector(3 downto 0);
    outside_input : in std_logic_vector(15 downto 0);
    output : out std_logic_vector(15 downto 0);
    z_flag : out std_logic;
    n_flag : out std_logic
);
end ALUv2;

architecture Behavioral of ALUv2 is
    signal outside_output : std_logic_vector(15 downto 0);
    
begin
    process(opcode, rb, rc, outside_input, shiftop)
        variable temp_s : signed(15 downto 0);
        variable mul_temp : signed(31 downto 0);
        
    
    begin
        z_flag <= '0';
        n_flag <= '0';
        
        
        case opcode is
            when "0000001" => -- add
                temp_s := signed(rb) + signed(rc);
                output <= std_logic_vector(temp_s);
                
            when "0000010" => -- sub
                temp_s := signed(rb) - signed(rc); --EROROROR HERE
                output <= std_logic_vector(temp_s);
                
            when "0000011" => -- mul
                mul_temp := rb * rc;
                output <= std_logic_vector(mul_temp(15 downto 0));
            
            when "0000100" => -- nand
                output <= std_logic_vector(rb) nand std_logic_vector(rc);
            
            when "0000101"=> -- shl
                output <= std_logic_vector(shift_left(unsigned(rb), to_integer(unsigned(shiftop))));
                
            when "0000110"=> -- shr
                output <= std_logic_vector(shift_right(unsigned(rb), to_integer(unsigned(shiftop))));
                
            when "0100000" => -- output
                outside_output <= std_logic_vector(rb);
                output <= std_logic_vector(rb);
                
            when "0100001" => -- input
                output <= outside_input;
                
            when "0000111" => -- test
                output <= std_logic_vector(rb);
                
                if rb = to_signed(0, 16) then
                    z_flag <= '1';
                end if;
                
                if rb < to_signed(0, 16) then
                    n_flag <= '1';
                end if;
                
            when others => 
                output <= (others => '0');
        end case;

    end process;

end Behavioral;
