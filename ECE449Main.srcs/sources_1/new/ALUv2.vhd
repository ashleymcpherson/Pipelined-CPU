----------------------------------------------------------------------------------
-- Module Name: ALUv2.vhd - Behavioral
--
-- Description:
--   Arithmetic Logic Unit (ALU) for the datapath.
--
--   Performs arithmetic, logic, shift, I/O, memory, and control operations.
--
--   Inputs:
--     - rb, rc: source operands
--     - instruction: full instruction for opcode decoding
--     - outside_input: external input for IN instruction
--
--   Outputs:
--     - output: ALU result
--     - z_flag: set if result is zero
--     - n_flag: set if result is negative
--     - v_flag: set if overflow occurs (used for BRR.Overflow)
--     - mem_ctrl: enables memory operations
--     - str_loc: memory address for LOAD/STORE
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUv2 is
    port ( 
        rb : in signed(15 downto 0); 
        rc : in signed(15 downto 0);
        instruction : in std_logic_vector(15 downto 0);
        outside_input : in std_logic_vector(15 downto 0);
        
        output : out std_logic_vector(15 downto 0);
        z_flag : out std_logic;
        n_flag : out std_logic;
        v_flag : out std_logic;
        
        str_loc : out std_logic_vector(15 downto 0);
        mem_ctrl : out std_logic
    );
end ALUv2;

architecture Behavioral of ALUv2 is

    -- NOTE: currently not used externally
    signal outside_output : std_logic_vector(15 downto 0);
    
begin

    -- Main ALU process
    process(rb, rc, outside_input, instruction)
        
        -- Decoded fields
        variable opcode : std_logic_vector(6 downto 0);
        variable shiftop : std_logic_vector(3 downto 0);
        variable imm : std_logic_vector(7 downto 0);
        
        -- Intermediate results
        variable temp_s : signed(15 downto 0);
        variable mul_temp : signed(31 downto 0);
        variable result_s : signed(15 downto 0);
            
    begin
    
        -- Default values (important to avoid latches)
        z_flag <= '0';
        n_flag <= '0';
        v_flag <= '0';
        mem_ctrl <= '0';
        str_loc <= x"0000";
        
        opcode := instruction(15 downto 9);
        shiftop := instruction(3 downto 0);
        imm := (instruction(7 downto 0));
        
        case opcode is
        
            -- ADD
            when "0000001" =>
                temp_s := signed(rb) + signed(rc);
                result_s := temp_s;
                
            -- SUB 
            when "0000010" =>
                temp_s := signed(rb) - signed(rc); 
                result_s := temp_s;
                
            -- MUL
            when "0000011" =>
                mul_temp := rb * rc;
                result_s := mul_temp(15 downto 0);
                
                -- Overflow detection (for BRR.Overflow)
                if (mul_temp > to_signed(32767, 32)) or 
                   (mul_temp < to_signed(-32768, 32)) then
                    v_flag <= '1';
                end if;
                
            -- NAND
            when "0000100" =>
                result_s := signed(std_logic_vector(rb) nand std_logic_vector(rc));
            
            -- SHL
            when "0000101"=>
                result_s := signed(shift_left(unsigned(rb), to_integer(unsigned(shiftop))));
                
            -- SHR
            when "0000110"=>
                result_s := signed(shift_right(unsigned(rb), to_integer(unsigned(shiftop))));
                
            -- OUT
            when "0100000" =>
                outside_output <= std_logic_vector(rb);
                result_s := (rb);
                
            -- IN
            when "0100001" =>
                result_s := signed(outside_input);
                outside_output <= outside_input;
                
            -- BR.SUB pass through
            when "1000110" =>
                result_s := rb;  
                
            -- TEST   
            when "0000111" =>
                result_s := (rb);
                
                if rb = to_signed(0, 16) then
                    z_flag <= '1';
                end if;
                
                if rb < to_signed(0, 16) then
                    n_flag <= '1';
                end if;
            
            -- LOAD
            when "0010000" => 
                -- Pass address through for memory stage
                mem_ctrl <= '1';
                result_s := rc;
                str_loc <= std_logic_vector(rb);
                
            -- STORE
            when "0010001" =>
            -- Pass address through
                mem_ctrl <= '1';
                result_s := rb;
                str_loc <= std_logic_vector(rc);
            
            -- MOV
            when "0010011" =>
                -- Pass Rb value to Ra
                result_s := rb;
            
            -- LOADIMM
            when "0010010" => -- LOADIMM: handled in a separate merge step (see below)
                result_s := rb;
                
                -- Upper/lower byte control
                if instruction(8) = '1' then
                   result_s(15 downto 8) := signed(imm);
                else
                   result_s(7 downto 0) := signed(imm); 
                end if;
            
            when others => 
                result_s := (others => '0');
                
        end case;   
        
        -- Final ALU output
        output <= std_logic_vector(result_s);

    end process;

end Behavioral;
