----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2026 03:10:19 PM
-- Design Name: 
-- Module Name: RegCtrl - Behavioral
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

entity RegCtrl is
Port ( 
    clk : in std_logic;
    instruction : in std_logic_vector(15 downto 0);
    opcode : out std_logic_vector(6 downto 0);
    Ra : out std_logic_vector(2 downto 0);
    Rb : out std_logic_vector(2 downto 0);
    Rc : out std_logic_vector(2 downto 0);
    shiftOp : out std_logic_vector(3 downto 0) := X"0";
    branchOut : out std_logic_vector(8 downto 0);
    wb_enable : out std_logic
    );
end RegCtrl;

architecture Behavioral of RegCtrl is

begin

    Process(clk)
    begin
        
        opcode <= instruction(15 downto 9);
        
        case instruction(15 downto 9) is
            when "0000000" =>
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '0';
            when "0000001" | "0000010" | "0000011" | "0000100" => --regular instructions
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '1';
            when "0000101" | "0000110"=> --shift instructions
                Ra <= instruction(8 downto 6);
                Rb <= instruction(8 downto 6);
                Rc <= instruction(2 downto 0);
                shiftOp <= instruction(3 downto 0);
                wb_enable <= '1';
            when "0100000" =>
                Rb <= instruction(8 downto 6); --put the value for output on B line
                Rc <= instruction(2 downto 0); -- dummys to ensure no floaints
                Ra <= instruction(5 downto 3); -- ''
                wb_enable <= '0';
            when "0100001" => 
                wb_enable <= '1';
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3); --unsured just to prevent floatings
                Rc <= instruction(2 downto 0);
            when "1000000" | "1000001" | "1000010" => -- format B1
                branchOut <= instruction(8 downto 0);
                
                Ra <= "111"; --unsured just to prevent floatings
                Rb <= "111"; --unsured just to prevent floatings
                Rc <= "111"; --unsured just to prevent floatings
                wb_enable <= '0';

            
            when "1000011" | "1000100" | "1000101" | "1000110" => -- format B2
                Ra <= instruction(8 downto 6);
                branchOut <= instruction(8 downto 0);
                wb_enable <= '0';
            
            when "1000111" => --71
                Ra <= "111";
                wb_enable <= '1';
            
            when others =>
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '0';
        end case;
    end Process;


end Behavioral;
