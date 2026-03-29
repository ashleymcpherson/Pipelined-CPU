----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/09/2026 04:36:26 PM
-- Design Name: 
-- Module Name: ALUTest - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALUTest is
--  Port ( );
end ALUTest;

architecture simulate of ALUTest is

    
	signal A: signed(15 downto 0);
	signal B: signed(15 downto 0);
	signal opcode : std_logic_vector(6 downto 0);
	signal Cin: std_logic;

	signal Sum: std_logic_vector(15 downto 0);
	


begin


uut : entity work.ALUv2 port map(

    ra=>A, 
    rb=>B,
    --Cin=>Cin,
    output=>Sum, 
    opcode=>opcode
    
    );

process
begin

    opcode<="0000001";
    --for i in 255 to 0 loop
    A<= signed(to_unsigned(7, 16));
    B<= signed(to_unsigned(8, 16));
    wait for 1 ns;
    -- end loop
    A<= signed(to_signed(10, 16));
    B<= signed(to_signed(-10, 16));
    wait for 1 ns;

    opcode<="0000010";
    --for i in 255 to 0 loop
    A<= signed(to_signed(10, 16));
    B<= signed(to_signed(10, 16));
    wait for 1 ns;
    -- end loop
    -- end loop
    A<= to_signed(10, 16);
    B<= to_signed(-10, 16);
    wait for 1 ns;

    opcode<="0000011";
    
    A<= to_signed(10, 16);
    B<= to_signed(-10, 16);
    wait for 1 ns;
    
    A<= to_signed(10, 16);
    B<= to_signed(10, 16);
    wait for 1 ns;
    
    opcode<="0000100";
    
    A<= to_signed(10, 16);
    B<= to_signed(-10, 16);
    wait for 1 ns;
    
    A<= to_signed(10, 16);
    B<= to_signed(10, 16);
    wait for 1 ns;

end process;

end simulate;

