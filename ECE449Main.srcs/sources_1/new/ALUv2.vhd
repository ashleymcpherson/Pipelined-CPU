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
    instruction : in std_logic_vector(15 downto 0);
    --opcode : in std_logic_vector(6 downto 0);
    --shiftop : in std_logic_vector(3 downto 0);
    outside_input : in std_logic_vector(15 downto 0);
    output : out std_logic_vector(15 downto 0);
    z_flag : out std_logic;
    n_flag : out std_logic
);
end ALUv2;

architecture Behavioral of ALUv2 is
    signal outside_output : std_logic_vector(15 downto 0);
    
begin
    process(rb, rc, outside_input, instruction)
        variable opcode : std_logic_vector(6 downto 0) ;
        variable shiftop : std_logic_vector(3 downto 0) ;
        variable temp_s : signed(15 downto 0);
        variable mul_temp : signed(31 downto 0);
        variable result_s : signed(15 downto 0);
        
    
    begin
        z_flag <= '0';
        n_flag <= '0';
        opcode := instruction(15 downto 9);
        shiftop := instruction(3 downto 0);
        
        case opcode is
            when "0000001" => -- add
                temp_s := signed(rb) + signed(rc);
                result_s := (temp_s);
                
            when "0000010" => -- sub
                temp_s := signed(rb) - signed(rc); 
                result_s := (temp_s);
                
            when "0000011" => -- mul
                mul_temp := rb * rc;
                result_s := (mul_temp(15 downto 0));
            
            when "0000100" => -- nand
                result_s := (rb) nand (rc);
            
            when "0000101"=> -- shl
                result_s := signed(shift_left(unsigned(rb), to_integer(unsigned(shiftop))));
                
            when "0000110"=> -- shr
                result_s := signed(shift_right(unsigned(rb), to_integer(unsigned(shiftop))));
                
            when "0100000" => -- output
                outside_output <= std_logic_vector(rb);
                result_s := (rb);
                
            when "0100001" => -- input
                result_s := signed(outside_input);
                outside_output <= outside_input;
                
            when "0000111" => -- test
                result_s := (rb);
                
                if rb = to_signed(0, 16) then
                    z_flag <= '1';
                end if;
                
                if rb < to_signed(0, 16) then
                    n_flag <= '1';
                end if;
            
            
            when others => 
                result_s := (others => '0');
        end case;
        
--        if result_s = to_signed(0, 16) then
--            z_flag <= '1';
--        else
--            z_flag <= '0';
--        end if;
--        
--        if result_s < to_signed(0, 16) then
--            n_flag <= '1';
--        else
--            n_flag <= '0';
--        end if;      
        
        output <= std_logic_Vector(result_s);

    end process;

end Behavioral;
