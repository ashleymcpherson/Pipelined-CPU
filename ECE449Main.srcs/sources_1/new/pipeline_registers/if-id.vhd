----------------------------------------------------------------------------------
-- Module Name: if_id.vhd - Behavioral
--
-- Description:
--   IF/ID Pipeline Register.
--
--   This module sits between the Instruction Fetch (IF) stage and
--   the Instruction Decode (ID) stage.
--
--   It stores:
--     - fetched instruction (instr_in)
--     - program counter value (pc_in)
--
--   Supports:
--     - Stall: holds current values (pipeline freeze)
--     - Flush: clears values (inserts bubble / NOP)
--     - Reset: clears pipeline register
--
--   Behavior:
--     - On rising edge of clock:
--          If reset OR flush ? clear outputs (insert bubble)
--          Else if not stalled ? latch new instruction and PC
--          Else ? hold previous values
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity if_id_register is
    port(
      clock : in  std_logic;
      reset : in  std_logic;
      stall : in  std_logic;
      flush : in  std_logic;
      instr_in : in  std_logic_vector(15 downto 0);
      pc_in : in  std_logic_vector(15 downto 0);
      instr_out : out std_logic_vector(15 downto 0);
      pc_out : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of if_id_register is
    -- Internal storage for pipeline register
    signal instr_if_id : std_logic_vector(15 downto 0);
    signal pc_if_id : std_logic_vector(15 downto 0);
    
begin

    -- Pipeline register process: handles, latching, stalling, and flushing of IF stage outputs
    process(clock)
    begin
        if rising_edge(clock) then
            -- Reset or flush: clear pipeline (insert bubble/NOP)
            if reset = '1' or flush = '1' then
                instr_if_id <= (others => '0');
                pc_if_id    <= (others => '0');
                
            -- Normal operation (no stall): latch new values
            elsif stall = '0' then
                instr_if_id <= instr_in;
                pc_if_id    <= pc_in;
            end if;
            
        end if;
    end process;

    -- Output assignments
    instr_out <= instr_if_id;
    pc_out <= pc_if_id;
    
end architecture;
