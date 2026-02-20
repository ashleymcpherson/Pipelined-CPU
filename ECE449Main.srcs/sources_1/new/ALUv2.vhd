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
    ra : in signed(15 downto 0); 
    rb : in signed(15 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    --Cin : in std_logic_vector(1);
    output : out std_logic_vector(15 downto 0)
    --Cout : out std_logic;
    --flag : out std_logic_vector(3 downto 0)
);
end ALUv2;

architecture Behavioral of ALUv2 is
    --signal temp : std_logic_vector(15 downto 0);
    signal result_int : std_logic_vector(15 downto 0);
    signal carry : std_logic;
    signal overflow : std_logic;
    
    --signal overflow : std_logic;
    --signal negative : std_logic;
    --signal carry : std_logic;
    
begin
    process(opcode, ra, rb)
        variable temp_u : signed(16 downto 0);
        variable temp_s : signed(15 downto 0);
        variable mul_temp : signed(31 downto 0);
        
    
    begin
        result_int <= (others => '0');
        carry <= '0';
        overflow <= '0';
        
        
        case opcode is
            when "0000001" => 
                --temp_u := ('0' & unsigned(ra)) + ('0' & unsigned(rb));
                --temp_u := ('1' & unsigned(ra)) + ('1' & unsigned(rb));
                --result_int <= std_logic_vector(temp_u(15 downto 0));
                --carry <= temp_u(16);
                
                temp_s := signed(ra) + signed(rb);
                --temp_u := unsigned(ra) + unsigned(rb);
                --if (ra(15) = rb(15)) and (temp_s(15) /= ra(15)) then
                 --   overflow <= '1';
                --else
                   -- overflow <= '0';
                --end if;
            
                output <= std_logic_vector(temp_s);
                
            when "0000010" => 
                temp_s := ra - rb; --EROROROR HERE
                output <= std_logic_vector(temp_s);
                --temp_u := ('0' & unsigned(ra)) - ('0' & unsigned(rb));
                --result_int <= std_logic_vector(temp_u(15 downto 0));
                --carry <= temp_u(16);
                
                --temp_s := signed(ra) - signed(rb);
                --if (ra(15) = rb(15)) and (temp_s(15) /= ra(15)) then
                --    overflow <= '1';
                --else
                --    overflow <= '0';
                --end if;
            
            when "0000011" => 
                mul_temp := ra * rb;
                output <= std_logic_vector(mul_temp(15 downto 0));
            
            when "0000100" =>
                output <= std_logic_vector(ra) nand std_logic_vector(rb);
            
            when "0000101"=>
                    
            when others => 
                output <= (others => '0');
        end case;
            --output <= result_int;
    end process;

end Behavioral;
