----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/22/2026 03:10:45 PM
-- Design Name: 
-- Module Name: BranchController - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BranchController is
    Port(
        clk : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        ra : in std_logic_vector(15 downto 0);
        flag_z : in std_logic;
        flag_n : in std_logic;
        cur_pc : in std_logic_vector(15 downto 0);
        
        pc_op : out std_logic_vector( 1 downto 0);
        set_pc : out std_logic_vector(15 downto 0);
        reset_prev : out std_logic;
        r7_wb_data : out std_logic_vector(15 downto 0);
        r7_wb_dest : out std_logic_vector(2 downto 0);
        wb_en : out std_logic
    );
end BranchController;

architecture Behavioral of BranchController is

begin

process(clk, flag_n, flag_z)
variable opcode : std_logic_vector(6 downto 0) := instruction(15 downto 9);
variable displ : std_logic_vector(8 downto 0) := instruction(8 downto 0);
variable disps : std_logic_vector( 5 downto 0) := instruction(5 downto 0);
begin
        
        
        case opcode is
            when "1000000" => --brr
                set_pc <= std_logic_vector(unsigned(cur_pc) + unsigned(displ));
                pc_op <= "10";
                wb_en <= '0';
            when "1000001" => --brr.n
                if flag_n = '1' then
                    set_pc <= std_logic_vector(unsigned(cur_pc) + unsigned(displ));
                    pc_op <= "10";
                elsif flag_n = '0' then
                    set_pc <= std_logic_vector(unsigned(cur_pc) + 1);
                    pc_op <= "01";
                end if;
                wb_en <= '0';
            when "1000010" => -- brr.z
                if flag_z = '1' then
                    set_pc <= std_logic_vector(unsigned(cur_pc) + unsigned(displ));
                    pc_op <= "10";
                elsif flag_z = '0' then
                    set_pc <= std_logic_vector(unsigned(cur_pc) + 1);
                    pc_op <= "01";
                end if;
                wb_en <= '0';
            when "1000011" => -- br
                set_pc <= std_logic_vector(unsigned(ra) + unsigned(disps));
                pc_op <= "10";
                wb_en <= '0';
            when "1000100" => -- br.n
                if flag_n = '1' then
                    set_pc <= std_logic_vector(unsigned(ra) + unsigned(disps));
                    pc_op <= "10";
                elsif flag_n = '0' then
                    set_pc <= std_logic_vector(unsigned(cur_pc) + 1);
                    pc_op <= "01";
                end if;  
                wb_en <= '0';             
            when "1000101" => -- br.z
                if flag_z = '1' then
                    set_pc <= std_logic_vector(unsigned(ra) + unsigned(displ));
                    pc_op <= "10";
                elsif flag_z = '0' then
                    set_pc <= std_logic_vector(unsigned(cur_pc) + 1);
                    pc_op <= "01";
                end if;
                wb_en <= '0';
            when "1000110" => -- br.sub
                set_pc <= std_logic_vector(unsigned(ra) + unsigned(displ));
                r7_wb_data <= std_logic_vector(unsigned(cur_pc) + 1);
                r7_wb_dest <= "111";
                wb_en <= '1';
                pc_op <= "10";
            when "1000111" =>
                set_pc <= ra;
                pc_op <= "10";
            when others =>
                pc_op <= "01";
        end case;


end process;
end Behavioral;
