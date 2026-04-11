----------------------------------------------------------------------------------
-- Module Name: id-ex.vhd - Behavioral
--
-- Description:
--   ID/EX Pipeline Register.
--
--   This module sits between the Instruction Decode (ID) stage and
--   the Execute (EX) stage.
--
--   It stores:
--     - instruction
--     - program counter
--     - destination register index
--     - source register indices
--     - source operand values
--     - register write enable
--
--   Supports:
--     - Flush: clears pipeline register (inserts bubble / NOP)
--     - Reset: clears pipeline register
--
--   Behavior:
--     - On rising edge of clock:
--         * If reset OR flush ? clear all stored values
--         * Else ? latch all ID-stage outputs into EX-stage registers
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity id_ex_register is
    port(
        clock         : in std_logic;
        reset         : in std_logic;
        flush         : in std_logic;

        instr_in      : in std_logic_vector(15 downto 0);
        pc_in         : in std_logic_vector(15 downto 0);
        ra_dest_in    : in std_logic_vector(2 downto 0);
        rb_src_in     : in std_logic_vector(2 downto 0);
        rc_src_in     : in std_logic_vector(2 downto 0);
        rb_val_in     : in std_logic_vector(15 downto 0);
        rc_val_in     : in std_logic_vector(15 downto 0);
        reg_write_in  : in std_logic;

        instr_out     : out std_logic_vector(15 downto 0);
        pc_out        : out std_logic_vector(15 downto 0);
        ra_dest_out   : out std_logic_vector(2 downto 0);
        rb_src_out    : out std_logic_vector(2 downto 0);
        rc_src_out    : out std_logic_vector(2 downto 0);
        rb_val_out    : out std_logic_vector(15 downto 0);
        rc_val_out    : out std_logic_vector(15 downto 0);
        reg_write_out : out std_logic
    );
end entity;

architecture rtl of id_ex_register is

    -- Internal pipeline storage registers
    signal instr_reg        : std_logic_vector(15 downto 0);
    signal pc_reg           : std_logic_vector(15 downto 0);
    signal ra_reg           : std_logic_vector(2 downto 0);
    signal rb_src_reg       : std_logic_vector(2 downto 0);
    signal rc_src_reg       : std_logic_vector(2 downto 0);
    signal rb_reg           : std_logic_vector(15 downto 0);
    signal rc_reg           : std_logic_vector(15 downto 0);
    signal write_enable_reg : std_logic;
    
begin
    
    -- Pipeline register process
    -- Transfers decoded values from ID stage into EX stage
    process(clock)
    begin
    
        if rising_edge(clock) then
        
            -- Reset or flush clears the pipeline register
            if reset = '1' or flush = '1' then
                instr_reg        <= (others => '0');
                pc_reg           <= (others => '0');
                ra_reg           <= (others => '0');
                rb_src_reg       <= (others => '0');
                rc_src_reg       <= (others => '0');
                rb_reg           <= (others => '0');
                rc_reg           <= (others => '0');
                write_enable_reg <= '0';
                
            -- Normal operation: latch all incoming ID-stage values
            else
                instr_reg        <= instr_in;
                pc_reg           <= pc_in;
                ra_reg           <= ra_dest_in;
                rb_src_reg       <= rb_src_in;
                rc_src_reg       <= rc_src_in;
                rb_reg           <= rb_val_in;
                rc_reg           <= rc_val_in;
                write_enable_reg <= reg_write_in;
            end if;
        end if;
    end process;
    
    -- Output assignments to EX stage
    instr_out     <= instr_reg;
    pc_out        <= pc_reg;
    ra_dest_out   <= ra_reg;
    rb_src_out    <= rb_src_reg;
    rc_src_out    <= rc_src_reg;
    rb_val_out    <= rb_reg;
    rc_val_out    <= rc_reg;
    reg_write_out <= write_enable_reg;
    
end architecture;