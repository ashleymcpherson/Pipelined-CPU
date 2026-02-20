----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2026 03:01:49 PM
-- Design Name: 
-- Module Name: ALUV1 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALUv1 is
Port ( 
    ra : in std_logic_vector(15 downto 0);
    rb : in std_logic_vector(15 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    --Cin : in std_logic_vector(1);
    output : out std_logic_vector(15 downto 0);
    Cout : out std_logic;
    flag : out std_logic_vector(3 downto 0);
);
end ALU-V1;

--Adder: kogge_stone_adder_nbit(ra=>A, rb=>B, Cin=> '0', Sum=>adder_sum, Cout=> Cout=>adder_cout);


architecture Behavioral of ALUv1 is

    --signal adder_sum : std_logic_vector(15 downto 0);
    --signal adder_cout : std_logic;
    signal temp : std_logic_vector(16 downto 0);
    signal overflow : std_logic;
    signal negative : std_logic;
    signal carry : std_logic;
    
begin
    
    case opcode is
        when "0000001" => temp <= ra + rb;
        when "0000010" => temp <= ra - rb;
        when "0000011" => temp <= ra * rb;
        when "0000100" => temp <= ra nand rb;
    end case

    

end Behavioral;
