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
    shiftOp : out std_logic_vector(3 downto 0);
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
            when "0000001" | "0000010" | "0000011" | "0000100" => 
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '1';
            when "0001000" | "0001001"=>
                Ra <= instruction(8 downto 6);
                shiftOp <= instruction(3 downto 0);
                wb_enable <= '1';
            when others =>
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '0';
        end case;
    end Process;


end Behavioral;
