library ieee;
use ieee.std_logic_1164.all;

entity if_id_register is
port(
  clock : in  std_logic;
  reset : in  std_logic;
  instr_in : in  std_logic_vector(15 downto 0);   -- input 16 bit instruction from instruction memory
  instr_out : out std_logic_vector(15 downto 0)    -- outout 16 bit instruction to Decode stage
);
end entity;

architecture rtl of if_id_register is
  signal instr_if_id : std_logic_vector(15 downto 0);   -- for internal storage/internal register
begin

  process(clock)
  begin
    if rising_edge(clock) then            -- On the rising edge of the clock...
      if reset = '1' then                 -- If reset is active
        instr_if_id <= (others => '0');   -- clear the stored instruction (set all 16 bits to 0)
      else                                -- If reset is inactive
        instr_if_id <= instr_in;          -- copy input instruction into the internal register
      end if;
    end if;
  end process;

  instr_out <= instr_if_id;   -- output is whatever we stored last clock

end architecture;