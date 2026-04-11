----------------------------------------------------------------------------------
-- Module Name: BranchController - Behavioral

-- Description: 
--  Handles branch and jump instructions by:
--      1) decoding the branch opcode
--      2) checking the relevant condition flag when needed
--      3) computing the next PC target
--      4) optionally writing the return address into R7 for BR.SUB
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BranchController is
    Port(
        clk : in std_logic;
        instruction : in std_logic_vector(15 downto 0);
        ra : in std_logic_vector(15 downto 0);
        flag_z : in std_logic;
        flag_n : in std_logic;
        flag_v : in std_logic;
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

    process(instruction, flag_n, flag_z, flag_v, ra, cur_pc)
        variable opcode : std_logic_vector(6 downto 0);
        variable displ : std_logic_vector(8 downto 0);
        variable disps : std_logic_vector( 5 downto 0);
        
        -- Sign-extended branch displacements
        variable displ_x2 : std_logic_vector(15 downto 0);
        variable disps_x2 : std_logic_vector(15 downto 0);

    begin
        -- Extract opcode and displacements fields from the instruction
        opcode := instruction(15 downto 9);
        displ  := instruction(8 downto 0);
        disps  := instruction(5 downto 0); 
        
        -- Sign-extend the immediate fields so they can be added to 16-bit addresses
        displ_x2 := std_logic_vector((resize(signed(displ), 16)));
        disps_x2 := std_logic_vector((resize(signed(disps), 16)));    
        
        -- Default outputs:
        -- pc_op = "01" means continue normally / increment PC
        -- These defaults are overridden only when a branch/jump is taken 
        pc_op <= "01";
        set_pc <= (others => '0');
        wb_en <= '0';
        r7_wb_data <= (others => '0');
        r7_wb_dest <= (others => '0');
        reset_prev <= '0';
        
        case opcode is
        
            -- BRR:
            when "1000000" =>
                --  Unconditional relative branch using 9-bit displacement
                set_pc <= std_logic_vector(signed(cur_pc) + signed(displ_x2) -1  );
                pc_op <= "10";
                wb_en <= '0';
                
                
            -- BRR.N:
            when "1000001" =>
                -- Relative branch if negative flag is set
                if flag_n = '1' then
                    set_pc <= std_logic_vector(signed(cur_pc) + signed(displ_x2));
                    pc_op <= "10";
                
                -- Fall through to normal PC increment
                elsif flag_n = '0' then
                    pc_op <= "01";
                end if;
                wb_en <= '0';
                
                
            -- BRR.Z: 
            when "1000010" =>
                -- Relative branch if zero flag is set
                if flag_z = '1' then
                    set_pc <= std_logic_vector(signed(cur_pc) + signed(displ_x2)-1);
                    pc_op <= "10";
                    
                -- Fall through to normal PC increment
                elsif flag_z = '0' then
                    pc_op <= "01";
                end if;
                wb_en <= '0';
                
                
            -- BRR.Overflow:
            when "1001000" =>
                -- Relative branch if overflag flag is set
                -- Used after operations like MUL when the 16-bit signed range is exceeded
                if flag_v = '1' then
                    set_pc <= std_logic_vector(signed(cur_pc) + signed(displ_x2) - 1);
                    pc_op <= "10";
                    
                -- Fall through to normal PC increment
                elsif flag_v = '0' then 
                    pc_op <= "01";
                end if;
                wb_en <= '0';
                
                
            -- BR:
            when "1000011" =>
                -- Unconditional register-based branch
                -- target = RA + signed 6-bit displacement + 1
                set_pc <= std_logic_vector(signed(ra) + signed(disps_x2) + 1);
                pc_op <= "10";
                wb_en <= '0';
           
                
            -- BR.N:
            when "1000100" =>
                -- Register-based branch if negative flag is set
                if flag_n = '1' then
                    set_pc <= std_logic_vector(signed(ra) + signed(disps_x2) + 1);
                    pc_op <= "10";
                    
                -- Fall through to normal PC increment
                elsif flag_n = '0' then
                    pc_op <= "01";
                end if;  
                wb_en <= '0';
                 
                 
            -- BR.Z            
            when "1000101" =>
                -- Register-based branch if zero flag is set
                if flag_z = '1' then
                    set_pc <= std_logic_vector(signed(ra) + signed(disps_x2));
                    pc_op <= "10";
                
                -- Fall through to normal PC increment
                elsif flag_z = '0' then
                    pc_op <= "01";
                end if;
                wb_en <= '0';
                
                
            -- BR.SUB
            when "1000110" =>
                -- Jumpp to target and save return address in R7 
                set_pc <= std_logic_vector(signed(ra) + signed(disps_x2));
                r7_wb_data <= std_logic_vector(signed(cur_pc) + 1);
                r7_wb_dest <= "111";
                wb_en <= '1';
                pc_op <= "10";
                
                
            -- Jump to address stored in a register
            when "1000111" =>
                set_pc <= ra;
                pc_op <= "10";
                
            
            -- Non-branch instruction
            when others =>
                -- Continue normal sequential execution
                pc_op <= "01";
                
        end case;
    end process;
    
end Behavioral;
