library ieee;
use ieee.std_logic_1164.all;

entity if_id_register is
port(
  clock     : in  std_logic;
  reset     : in  std_logic;
  stall     : in  std_logic;
  flush     : in  std_logic;
  instr_in  : in  std_logic_vector(15 downto 0);
  pc_in     : in  std_logic_vector(15 downto 0);
  instr_out : out std_logic_vector(15 downto 0);
  pc_out    : out std_logic_vector(15 downto 0)
);
end entity;

architecture rtl of if_id_register is
  signal instr_if_id : std_logic_vector(15 downto 0);
  signal pc_if_id    : std_logic_vector(15 downto 0);
begin
  process(clock)
  begin
    if rising_edge(clock) then
      if reset = '1' or flush = '1' then
        instr_if_id <= (others => '0');
        pc_if_id    <= (others => '0');
      elsif stall = '0' then
        instr_if_id <= instr_in;
        pc_if_id    <= pc_in;
      end if;
    end if;
  end process;

  instr_out <= instr_if_id;
  pc_out    <= pc_if_id;
end architecture;
