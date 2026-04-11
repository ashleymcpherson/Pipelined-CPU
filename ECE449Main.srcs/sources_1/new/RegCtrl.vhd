----------------------------------------------------------------------------------
-- Module Name: RegCtrl.vhd - Behavioral

-- Description: 
--   Register Control Unit.
--   Decodes instruction fields and determines:
--     - source registers (Ra, Rb, Rc)
--     - destination register (implicit via instruction)
--     - write enable signal
--     - branch displacement output
--
--   Also groups instructions by format (A, B1, B2, etc.)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RegCtrl is
    Port (
        clk : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        opcode : out std_logic_vector(6 downto 0);
        Ra : out std_logic_vector(2 downto 0);
        Rb : out std_logic_vector(2 downto 0);
        Rc : out std_logic_vector(2 downto 0);
        shiftOp : out std_logic_vector(3 downto 0);
        branchOut : out std_logic_vector(8 downto 0);
        wb_enable : out std_logic;
        forwarding_control : out std_logic_vector(1 downto 0)
    );
end RegCtrl;

architecture Behavioral of RegCtrl is
begin

    process(instruction)
    begin
        -- Always expose the opcode field directly
        opcode <= instruction(15 downto 9);
        
        -- Default assignments to avoid latches and undefined ('U') values
        Ra <= instruction(8 downto 6);
        Rb <= instruction(5 downto 3);
        Rc <= instruction(2 downto 0);
        shiftOp <= X"0";
        branchOut <= instruction(8 downto 0);
        wb_enable <= '0';
        forwarding_control <= "00";
        
        
        case instruction(15 downto 9) is
        
            -- Non-writeback instruction in standard 3-register format
            when "0000000" =>
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '0';
                
            -- Regular ALU instructions (ADD, SUB, MUL, NAND, etc)
            when "0000001" | "0000010" | "0000011" | "0000100" =>
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '1';
                
            -- Shift instructions
            when "0000101" | "0000110"=>
                -- Destination register is also used as the source operand
                Ra <= instruction(8 downto 6);
                Rb <= instruction(8 downto 6);
                Rc <= instruction(2 downto 0);
                shiftOp <= instruction(3 downto 0);
                wb_enable <= '1';
                
            -- OUT
            when "0100000" =>
                -- Put the register value to be output on the B line
                Rb <= instruction(8 downto 6);
                Rc <= instruction(2 downto 0);  -- dummy assignment
                Ra <= instruction(5 downto 3);  -- dummy assignment
                wb_enable <= '0';
                
            -- IN
            when "0100001" => 
                -- Writes external input value into the destination register path
                wb_enable <= '1';
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);  -- unused/kept valid
                Rc <= instruction(2 downto 0);
                
            -- TEST
            when "0000111" =>  
                -- Reads Ra and updates flags, but does not write-back
                Ra <= instruction(8 downto 6);
                Rb <= instruction(8 downto 6);       -- TEST reads Ra
                Rc <= instruction(2 downto 0);
                wb_enable <= '0';
            
            -- Format B1: BRR, BRR.N, BRR.Z, BRR.Overflow
            when "1000000" | "1000001" | "1000010" | "1001000" =>
                -- Uses 9-bit branch displacement
                branchOut <= instruction(8 downto 0);
                Ra <= "111";    -- dummy assignment to prevent floating
                Rb <= "111";    -- dummy assignment to prevent floating
                Rc <= "111";    -- dummy assignment to prevent floating
                wb_enable <= '0';

            -- Format B2: BR, BR.N, BR.Z
            when "1000011" | "1000100" | "1000101" =>
                -- Uses register-based target plus displacement
                Ra <= instruction(8 downto 6);
                Rb <= instruction(8 downto 6);
                branchOut <= instruction(8 downto 0);
                wb_enable <= '0';
            
            -- Absolute branch/jump instruction
            when "1000111" =>   -- 71
                Ra <= "111";
                Rb <= "000";    -- dummy assignment
                Rc <= "000";    -- dummy assignment
                wb_enable <= '0';
                
            -- BR.SUB
            when "1000110" =>
                -- Uses Ra and displacement and enables write-back for return address
                Ra <= instruction(8 downto 6);
                rb <= instruction(8 downto 6);
                rc <= instruction(2 downto 0);
                wb_enable <= '1';
                
            -- LOAD
            when "0010000" =>
                Ra <= instruction(8 downto 6);  -- destination register
                Rb <= instruction(5 downto 3);  -- register containing memory address
                wb_enable <= '1';
            
            -- STORE
            when "0010001" =>
                Rb <= instruction(5 downto 3);  -- data to store
                Rc <= instruction(8 downto 6);  -- register containing memory address
                wb_enable <= '0';
            
            -- LOADIMM
            when "0010010" =>
                -- Always targets R7
                Ra <= "111"; 
                Rb <= "111";
                Rc <= "111";
                wb_enable <= '1';
            
            -- MOV
            when "0010011" =>
                -- Move source register into destination register
                Ra <= instruction(8 downto 6);  -- destination register
                Rb <= instruction(5 downto 3);  -- source register
                wb_enable <= '1';
            
            -- Safe default behaviour for unknown/unused opcodes
            when others =>
                Ra <= instruction(8 downto 6);
                Rb <= instruction(5 downto 3);
                Rc <= instruction(2 downto 0);
                wb_enable <= '0';
                
        end case;
    end process;

end Behavioral;
