----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2026 02:25:59 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
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

entity datapath is
--  Port ( );
end datapath;



architecture Behavioral of datapath is
-- components are in order and should be able to be connected as such

component if_id_register is 
port(
    clock : in  std_logic;
    reset : in  std_logic;
    instr_in : in  std_logic_vector(15 downto 0);   -- input 16 bit instruction from instruction memory
    instr_out : out std_logic_vector(15 downto 0)    -- outout 16 bit instruction to Decode stage    
);
end component;

signal clk : std_logic;     
signal reset : std_logic;
signal instr_in : std_logic_vector(15 downto 0);
signal instr_out : std_logic_vector(15 downto 0);

component RegCtrl is
port(
    clk : in std_logic_vector;
    instruction : in std_logic_vector(15 downto 0);
    opcode : out std_logic_vector(6 downto 0);
    Ra : out std_logic_vector(2 downto 0); --out
    Rb : out std_logic_vector(2 downto 0); -- in 1
    Rc : out std_logic_vector(2 downto 0); -- in 2
    shiftOp : out std_logic_vector(3 downto 0) -- used for the A2 format
    );
end component;

component main_register is
port(
    rst : in std_logic; 
    clk: in std_logic;
    --read signals
    rd_index1: in std_logic_vector(2 downto 0); 
    rd_index2: in std_logic_vector(2 downto 0); 
    rd_data1: out std_logic_vector(15 downto 0); 
    rd_data2: out std_logic_vector(15 downto 0);
    --write back signals
    wr_index: in std_logic_vector(2 downto 0); 
    wr_data: in std_logic_vector(15 downto 0); 
    wr_enable: in std_logic
    );
end component;

component id_ex_register is
port(
    clk : in std_logic;
    reset : in std_logic; 
    
    opcode_in : in std_logic_vector(6 downto 0);
    ra_dest_in : in std_logic_vector(2 downto 0);
    rb_val_in : in std_logic_vector(15 downto 0);
    rc_val_in : in std_logic_vector(15 downto 0);
    reg_write_in : in std_logic;
    
    opcode_out : out std_logic_vector(6 downto 0);
    ra_dest_out : out std_logic_vector(2 downto 0);
    rb_val_out : out std_logic_vector(15 downto 0);
    rc_val_out : out std_logic_vector(15 downto 0);
    reg_write_out : out std_logic
    
    );
end component;

component ALU is
port(
    ra : in signed(15 downto 0); 
    rb : in signed(15 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    output : out std_logic_vector(15 downto 0)
    );
end component;

component ex_mem_register is
port(
    clock : in std_logic;
    reset : in std_logic;
    
    alu_result_in : in std_logic_vector(15 downto 0);
    ra_dest_in : in std_logic_vector(2 downto 0);
    reg_write_in : in std_logic;                        -- control signal
    
    alu_result_out : out std_logic_vector(15 downto 0);
    ra_dest_out : out std_logic_vector(2 downto 0);
    reg_write_out : out std_logic
    );
end component;

component mem_wb_register is
port(
            clock : in std_logic;
    reset: in std_logic;

    wb_data_in : in std_logic_vector(15 downto 0);
    ra_dest_in : in std_logic_vector(2 downto 0);
    reg_write_in : in std_logic;                        -- control signal

    wb_data_out : out std_logic_vector(15 downto 0);
    ra_dest_out : out std_logic_vector(2 downto 0);
    reg_write_out : out std_logic
    );
end component;




begin
--________________________-- define port maps for entities here

r1:if_id_register port map(clock=>clk,reset=>reset,instr_in=>instr_in, instr_out=>instr_out);




end Behavioral;
