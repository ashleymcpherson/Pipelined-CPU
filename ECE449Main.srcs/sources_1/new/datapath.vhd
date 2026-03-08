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
  Port (
        clk : in std_logic;
        reset : in std_logic;
        outside_input : in std_logic_vector(15 downto 0)
  );
end datapath;

architecture Behavioral of datapath is
-- components are in order and should be able to be connected as such
signal pc_op: std_logic_vector(1 downto 0) := "01"; -- for set to 01 to make PC increment
signal enable : std_logic := '1';

component PC is
port(
    clk : in std_logic;
    in_PC : in std_logic_vector(15 downto 0);
    Op_PC : in std_logic_vector(1 downto 0);
    out_PC : out std_logic_vector(15 downto 0)
    );
end component;

signal pc_address : std_logic_vector(15 downto 0);
-- signal enable : std_logic;


--component rom_128B is
--port(
--    clock : in std_logic;
--  --  reset : in std_logic;
--    enable : in std_logic;
--    address : in std_logic_vector(5 downto 0);
--    data_out : out std_logic_vector(15 downto 0)
--    );
--end component;

component blk_mem_gen_0 is
port(
        clka  : in std_logic;
        ena   : in std_logic;
        addra : in std_logic_vector(8 downto 0);
        douta : out std_logic_vector(15 downto 0)
    );
end component;


signal instr_in : std_logic_vector(15 downto 0);

component if_id_register is 
port(
    clock : in  std_logic;
    reset : in  std_logic;
    instr_in : in  std_logic_vector(15 downto 0);   -- input 16 bit instruction from instruction memory
    instr_out : out std_logic_vector(15 downto 0)    -- outout 16 bit instruction to Decode stage    
);
end component;

    

signal instr_out : std_logic_vector(15 downto 0);


component RegCtrl is
port(
    clk : in std_logic;
    instruction : in std_logic_vector(15 downto 0);
    opcode : out std_logic_vector(6 downto 0);
    Ra : out std_logic_vector(2 downto 0); --out
    Rb : out std_logic_vector(2 downto 0); -- in 1
    Rc : out std_logic_vector(2 downto 0); -- in 2
    shiftOp : out std_logic_vector(3 downto 0); -- used for the A2 format
    wb_enable : out std_logic
    );
end component;

signal Ra : std_logic_vector(2 downto 0); -- pass by
signal Rb : std_logic_vector(2 downto 0); --index 1
signal Rc : std_logic_vector(2 downto 0); -- index 2
signal opcode_id : std_logic_vector(6 downto 0);--pass by
signal shiftop_id : std_logic_vector(3 downto 0); --passby
signal wb_enable_id : std_logic;

component register_file is
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

signal rb_data : std_logic_vector(15 downto 0);
signal rc_data : std_logic_vector(15 downto 0);

component id_ex_register is
port(
    clock : in std_logic;
    reset : in std_logic; 
    
    opcode_in : in std_logic_vector(6 downto 0);
    ra_dest_in : in std_logic_vector(2 downto 0);
    rb_val_in : in std_logic_vector(15 downto 0);
    rc_val_in : in std_logic_vector(15 downto 0);
    reg_write_in : in std_logic;
    shiftop_in : in std_logic_vector(3 downto 0);
    
    opcode_out : out std_logic_vector(6 downto 0);
    ra_dest_out : out std_logic_vector(2 downto 0);
    rb_val_out : out std_logic_vector(15 downto 0);
    rc_val_out : out std_logic_vector(15 downto 0);
    reg_write_out : out std_logic;
    shiftop_out : out std_logic_vector(3 downto 0)
    
    );
end component;

signal opcode_alu : std_logic_vector(6 downto 0);
signal rb_alu : std_logic_vector(15 downto 0);
signal rc_alu : std_logic_vector(15 downto 0);
signal shiftop_alu : std_logic_vector(3 downto 0);
--pass by values
signal reg_wr_ex : std_logic;
signal reg_wb_ex :std_logic_vector(2 downto 0);

component ALUv2 is
port(
    rb : in signed(15 downto 0); 
    rc : in signed(15 downto 0);
    opcode : in std_logic_vector(6 downto 0);
    output : out std_logic_vector(15 downto 0);
    shiftop : in std_logic_vector(3 downto 0);
    outside_input : in std_logic_vector(15 downto 0)
    );
end component;

signal alu_out : std_logic_vector(15 downto 0);

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

signal alu_out_mem : std_logic_vector(15 downto 0);

signal reg_wr_mem : std_logic;
signal reg_wb_mem :std_logic_vector(2 downto 0);

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

signal reg_wb_output : std_logic_vector(15 downto 0);
signal wb_reg_dest : std_logic_vector(2 downto 0);
signal wb_enable : std_logic;


begin

pc_op <= "01";
enable <= '1';

--________________________-- define port maps for entities here they should be mostly sequential
pc1: PC port map(clk=>clk, in_PC=>X"0000", op_PC=>pc_op, out_pc=>pc_address);
--rom1: rom_128B port map(clock=>clk, reset=>reset, enable=>enable, address=>pc_address, data_out=>instr_in);
rom1: blk_mem_gen_0 port map(clka=>clk, ena=>enable, addra=>pc_address(8 downto 0), douta=>instr_in);
pr1: if_id_register port map(clock=>clk,reset=>reset,instr_in=>instr_in, instr_out=>instr_out);
regc: RegCtrl port map(clk=>clk, instruction=>instr_out, Ra=>Ra, Rb=>Rb, Rc=>Rc, opcode=>opcode_id, shiftOp=>shiftop_id, wb_enable=>wb_enable_id);
mreg: register_file port map(rst=>reset, clk=>clk, rd_index1=>Rb, rd_index2=>Rc,wr_index=>wb_reg_dest, wr_data=>reg_wb_output,wr_enable=>wb_enable, rd_data1=>rb_data, rd_data2=>rc_data);
pr2: id_ex_register port map(clock=>clk, reset=>reset, opcode_in=>opcode_id, ra_dest_in=>Ra, rb_val_in=>rb_data, rc_val_in=>rc_data, reg_write_in=>wb_enable_id, opcode_out=>opcode_alu, ra_dest_out=>reg_wb_ex, rb_val_out=>rb_alu, rc_val_out=>rc_alu, reg_write_out=>reg_wr_ex, shiftop_in=>shiftop_id, shiftop_out=>shiftop_alu);
al: ALUv2 port map(rb=>signed(rb_alu), rc=>signed(rc_alu), opcode=>opcode_alu, output=>alu_out, shiftop=>shiftop_alu, outside_input=>outside_input);
pr3: ex_mem_register port map(clock=>clk, reset=>reset, alu_result_in=>alu_out, ra_dest_in=>reg_wb_ex, reg_write_in=>reg_wr_ex, alu_result_out=>alu_out_mem, ra_dest_out=>reg_wb_mem, reg_write_out=>reg_wr_mem);
-- putlogic here if we need differ write back
pr4: mem_wb_register port map(clock=>clk, reset=>reset, wb_data_in=>alu_out_mem, ra_dest_in=>reg_wb_mem, reg_write_in=>reg_wr_mem, wb_data_out=>reg_wb_output, ra_dest_out=>wb_reg_dest, reg_write_out=>wb_enable);

end Behavioral;