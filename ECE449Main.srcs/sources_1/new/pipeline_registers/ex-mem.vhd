----------------------------------------------------------------------------------
-- Module Name: EX_MEM.vhd - Behavioral
--
-- Description:
--   EX/MEM Pipeline Register.
--
--   This module sits between the Execute (EX) stage and
--   the Memory (MEM) stage.
--
--   It stores:
--     - write-back data
--     - destination register index
--     - register write enable
--     - memory control signal
--     - memory address
--
--   Supports:
--     - Reset: clears selected stored values
--
--   Behavior:
--     - On rising edge of clock:
--         * If reset ? clears internal registers currently handled in this design
--         * Else ? latches EX-stage outputs into MEM-stage registers
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ex_mem_register is
    port(
        clock : in std_logic;
        reset : in std_logic;

        wb_data_in : in std_logic_vector(15 downto 0);
        wb_dest_in : in std_logic_vector(2 downto 0);
        reg_write_in : in std_logic;
        mem_ctrl_in : in std_logic;
        mem_addr_in : in std_logic_vector(15 downto 0);
        
        wb_data_out : out std_logic_vector(15 downto 0);
        wb_dest_out : out std_logic_vector(2 downto 0);
        reg_write_out : out std_logic;
        mem_ctrl_out : out std_logic;
        mem_addr_out : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of ex_mem_register is
    
    -- Internal pipeline storage registers
    signal data_reg         : std_logic_vector(15 downto 0);
    signal dest_reg         : std_logic_vector(2 downto 0);
    signal write_enable_reg : std_logic;
    signal mem_ctrl_reg     : std_logic;
    signal mem_addr_reg     : std_logic_vector(15 downto 0);
    
begin

    -- Pipeline register process
    -- Transfers EX-stage results into MEM-stage registers
    process(clock)
    begin
        if rising_edge(clock) then
        
            -- Reset currently clears only selected registers
            if reset = '1' then
                data_reg <= (others => '0');
                dest_reg <= (others => '0');
                write_enable_reg <= '0';
                
            -- Normal operation: latch EX-stage outputs
            else
                data_reg <= wb_data_in;
                dest_reg <= wb_dest_in;
                write_enable_reg <= reg_write_in;
                mem_ctrl_reg <= mem_ctrl_in;
                mem_addr_reg <= mem_addr_in;
            end if;
            
        end if;
    end process;

    -- Output assignments to MEM-stage
    wb_data_out <= data_reg;
    wb_dest_out <= dest_reg;
    reg_write_out <= write_enable_reg;
    mem_ctrl_out <= mem_ctrl_reg;
    mem_addr_out <= mem_addr_reg;
    
end architecture;
