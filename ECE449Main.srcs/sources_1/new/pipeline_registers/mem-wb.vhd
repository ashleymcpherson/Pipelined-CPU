----------------------------------------------------------------------------------
-- Module Name: MEM_WB.vhd - Behavioral
--
-- Description:
--   MEM/WB Pipeline Register.
--
--   This module sits between the Memory (MEM) stage and
--   the Write-Back (WB) stage.
--
--   It stores:
--     - write-back data
--     - destination register index
--     - register write enable
--     - memory control signal
--
--   Supports:
--     - Reset: clears selected stored values
--
--   Behavior:
--     - On rising edge of clock:
--          If reset ? clears internal registers currently handled in this design
--          Else ? latches MEM-stage outputs into WB-stage registers
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mem_wb_register is
    port(
        clock : in std_logic;
        reset : in std_logic;

        wb_data_in : in std_logic_vector(15 downto 0);
        wb_dest_in : in std_logic_vector(2 downto 0);
        reg_write_in : in std_logic;
        mem_ctrl_in : in std_logic;

        wb_data_out : out std_logic_vector(15 downto 0);
        wb_dest_out : out std_logic_vector(2 downto 0);
        reg_write_out : out std_logic;
        mem_ctrl_out : out std_logic
    );
end entity;

architecture rtl of mem_wb_register is
    
    -- Internal pipeline storage registers
    signal data_reg : std_logic_vector(15 downto 0);
    signal dest_reg : std_logic_vector(2 downto 0);
    signal write_enable_reg : std_logic;
    signal mem_ctrl_reg : std_logic;
    
begin

    -- Pipeline register process
    -- Transfers MEM-stage results into WB-stage registers
    process(clock)
    begin
    
        if rising_edge(clock) then
            
            -- Reset currently clears only selected registers
            if reset = '1' then
                data_reg <= (others => '0');
                dest_reg <= (others => '0');
                write_enable_reg <= '0';
                
            -- Normal operation: latch MEM-stage outputs
            else
                data_reg <= wb_data_in;
                dest_reg <= wb_dest_in;
                write_enable_reg <= reg_write_in;
                mem_ctrl_reg <= mem_ctrl_in;
            end if;
            
        end if;
    end process;

    -- Output assignments to WB-stage
    wb_data_out <= data_reg;
    wb_dest_out <= dest_reg;
    reg_write_out <= write_enable_reg;
    mem_ctrl_out <= mem_ctrl_reg;
    
end architecture;
