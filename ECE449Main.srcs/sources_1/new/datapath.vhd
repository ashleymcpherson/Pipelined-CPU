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
signal pc_in : std_logic_vector(15 downto 0) := (others => '0');
signal pc_op : std_logic_vector(1 downto 0) := "01"; -- for set to 01 to make PC increment
signal enable : std_logic := '1';
signal stall_pipe : std_logic := '0';
signal flush_ifid : std_logic := '0';
signal flush_idex : std_logic := '0';

component PC is
port(
    clk : in std_logic;
    in_PC : in std_logic_vector(15 downto 0);
    Op_PC : in std_logic_vector(1 downto 0);
    out_PC : out std_logic_vector(15 downto 0)
    );
end component;

signal pc_address : std_logic_vector(15 downto 0);

component blk_mem_gen_0 is
port(
        clka  : in std_logic;
        ena   : in std_logic;
        addra : in std_logic_vector(9 downto 0);
        douta : out std_logic_vector(15 downto 0)
    );
end component;

signal instr_in : std_logic_vector(15 downto 0);

component if_id_register is 
port(
    clock : in  std_logic;
    reset : in  std_logic;
    stall : in std_logic;
    flush : in std_logic;
    instr_in : in  std_logic_vector(15 downto 0);   -- input 16 bit instruction from instruction memory
    instr_out : out std_logic_vector(15 downto 0);    -- outout 16 bit instruction to Decode stage    
    pc_in : in std_logic_vector(15 downto 0);
    pc_out : out std_logic_vector(15 downto 0)
);
end component;

signal instr_out : std_logic_vector(15 downto 0);
signal pc_id : std_logic_vector(15 downto 0);


component RegCtrl is
port(
    clk : in std_logic;
    instruction : in std_logic_vector(15 downto 0);
    opcode : out std_logic_vector(6 downto 0);
    Ra : out std_logic_vector(2 downto 0); --out
    Rb : out std_logic_vector(2 downto 0); -- in 1
    Rc : out std_logic_vector(2 downto 0); -- in 2
    shiftOp : out std_logic_vector(3 downto 0); -- used for the A2 format
    wb_enable : out std_logic;
    branchOut : out std_logic_vector(8 downto 0);
    forwarding_control : out std_logic_vector(1 downto 0)
    );
end component;

signal Ra : std_logic_vector(2 downto 0); -- pass by
signal Rb : std_logic_vector(2 downto 0); --index 1
signal Rc : std_logic_vector(2 downto 0); -- index 2
signal opcode_id : std_logic_vector(6 downto 0);--pass by
signal shiftop_id : std_logic_vector(3 downto 0); --passby
signal wb_enable_id : std_logic;
signal branch_data_id : std_logic_vector(8 downto 0);
signal forwarding_control : std_logic_vector(1 downto 0);

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
signal read_index1 : std_logic_vector(2 downto 0);

component BranchController is
port(
    clk : in std_logic;
    instruction : in std_logic_vector(15 downto 0);
    ra : in std_logic_vector(15 downto 0);
    flag_z : in std_logic;
    flag_n : in std_logic;
    cur_pc : in std_logic_vector(15 downto 0);
    
    pc_op : out std_logic_vector(1 downto 0);
    set_pc : out std_logic_vector(15 downto 0);
    reset_prev : out std_logic;
    r7_wb_data : out std_logic_vector(15 downto 0);
    r7_wb_dest : out std_logic_vector(2 downto 0);
    wb_en : out std_logic
    );
end component; 

signal branch_pc_op : std_logic_vector(1 downto 0);
signal branch_set_pc : std_logic_vector(15 downto 0);
signal branch_reset_prev : std_logic;
signal r7_wb_data : std_logic_vector(15 downto 0);
signal r7_wb_dest : std_logic_vector(2 downto 0);
signal branch_wb_en : std_logic;

component id_ex_register is
port(
    clock : in std_logic;
    reset : in std_logic; 
    flush : in std_logic;
    
    instr_in : in std_logic_vector(15 downto 0);
    pc_in : in std_logic_vector(15 downto 0);
    ra_dest_in : in std_logic_vector(2 downto 0);
    rb_val_in : in std_logic_vector(15 downto 0);
    rb_src_in : in std_logic_vector(2 downto 0);
    rc_val_in : in std_logic_vector(15 downto 0);
    rc_src_in : in std_logic_vector(2 downto 0);
    reg_write_in : in std_logic;

    instr_out : out std_logic_vector(15 downto 0);
    pc_out : out std_logic_vector(15 downto 0);
    ra_dest_out : out std_logic_vector(2 downto 0);
    rb_val_out : out std_logic_vector(15 downto 0);
    rb_src_out : out std_logic_vector(2 downto 0);
    rc_val_out : out std_logic_vector(15 downto 0);
    rc_src_out : out std_logic_vector(2 downto 0);
    reg_write_out : out std_logic    
    );
end component;

signal instr_ex : std_logic_vector(15 downto 0);
signal pc_ex : std_logic_vector(15 downto 0);
signal ra_dest_ex : std_logic_vector(2 downto 0);
signal rb_src_ex : std_logic_vector(2 downto 0);
signal rc_src_ex : std_logic_vector(2 downto 0);
signal rb_ex : std_logic_vector(15 downto 0);
signal rc_ex : std_logic_vector(15 downto 0);
signal reg_wr_ex : std_logic;

signal opcode_ex : std_logic_vector(6 downto 0);
signal shiftop_ex : std_logic_vector(3 downto 0);

signal fwd_a : std_logic_vector(15 downto 0);
signal fwd_b : std_logic_vector(15 downto 0);

component ALUv2 is
port(
    rb : in signed(15 downto 0); 
    rc : in signed(15 downto 0);
    instruction : in std_logic_vector(15 downto 0);
    outside_input : in std_logic_vector(15 downto 0);
    output : out std_logic_vector(15 downto 0);
    str_loc : out std_logic_vector(15 downto 0);
    mem_ctrl : out std_logic;
    z_flag : out std_logic;
    n_flag : out std_logic
    );
end component;

signal alu_out : std_logic_vector(15 downto 0);
signal z_flag_ex : std_logic;
signal n_flag_ex : std_logic;

signal z_reg : std_logic := '0';
signal n_reg: std_logic := '0';

component ex_mem_register is
port(
    clock : in std_logic;
    reset : in std_logic;
    
    wb_data_in : in std_logic_vector(15 downto 0);
    wb_dest_in : in std_logic_vector(2 downto 0);
    reg_write_in : in std_logic;  
    mem_ctrl_in   : in std_logic;     
    mem_addr_in   : in std_logic_vector(15 downto 0);               
    
    wb_data_out : out std_logic_vector(15 downto 0);
    wb_dest_out : out std_logic_vector(2 downto 0);
    reg_write_out : out std_logic;
    mem_ctrl_out   : out std_logic;
    mem_addr_out  : out std_logic_vector(15 downto 0)
    );
end component;

signal wb_data_mem : std_logic_vector(15 downto 0);
signal wb_dest_mem : std_logic_vector(2 downto 0);
signal reg_wr_mem :std_logic;


component blk_mem_gen_1 is
port(
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    
    );
end component;

component mem_wb_register is
port(
    clock : in std_logic;
    reset: in std_logic;

    wb_data_in : in std_logic_vector(15 downto 0);
    wb_dest_in : in std_logic_vector(2 downto 0);
    reg_write_in : in std_logic; 
    mem_ctrl_in : in std_logic;                       -- control signal

    wb_data_out : out std_logic_vector(15 downto 0);
    wb_dest_out : out std_logic_vector(2 downto 0);
    reg_write_out : out std_logic;
    mem_ctrl_out : out std_logic
    );
end component;

signal wb_data_wb : std_logic_vector(15 downto 0);
signal wb_dest_wb : std_logic_vector(2 downto 0);
signal wb_enable_pipe : std_logic;

signal reg_wb_output : std_logic_vector(15 downto 0);
signal wb_reg_dest : std_logic_vector(2 downto 0);
signal wb_enable : std_logic;

signal rb_data_sub : std_logic_Vector(15 downto 0);
signal ra_dest_sub : std_logic_vector(2 downto 0);


signal rb_val_id    : std_logic_vector(15 downto 0);
signal rc_val_id    : std_logic_vector(15 downto 0);
signal ra_dest_id   : std_logic_vector(2 downto 0);
signal reg_write_id : std_logic;


signal mem_mem_ctrl : std_logic;
signal ex_mem_ctrl : std_logic;
signal ex_location : std_logic_Vector(15 downto 0);
signal mem_location : std_logic_Vector(15 downto 0);

signal mem_enb : std_logic;
--signal addrb : std_logic_vector(15 downto 0);
signal dinb : std_logic_vector(15 downto 0);
signal doutb : std_logic_vector(15 downto 0);

signal wb_data_direct_mem : std_logic_vector(15 downto 0);


signal mem_wenb : std_logic_vector(0 downto 0);
signal wb_mem_ctrl : std_logic;


signal dump : std_logic_vector(15 downto 0);
--signal flush_count : std_logic_vector(1 downto 0) := "11";


signal bc_ra_val : std_logic_vector(15 downto 0);


signal flush_count : unsigned(1 downto 0) := (others => '0');

begin

enable <= '1';
stall_pipe <= '0';



-- multiplexer for the first read port of the register file
    process(instr_out, Ra, Rb)
    begin
        case instr_out(15 downto 9) is
            when "1000011" | "1000100" | "1000101" | "1000110" | "1000111" =>
                read_index1 <= Ra;
            when others =>
                read_index1 <= Rb;
        end case;
    end process;

-- branch controller
    bc1: BranchController
    port map(
        clk => clk,
        instruction => instr_out,
        ra => bc_ra_val,
        --ra => rb_val_id,
        flag_z => z_flag_ex,
        flag_n => n_flag_ex,
        cur_pc => pc_id,
        pc_op => branch_pc_op,
        set_pc => branch_set_pc,
        reset_prev => branch_reset_prev,
        r7_wb_data => r7_wb_data,
        r7_wb_dest => r7_wb_dest,
        wb_en => branch_wb_en
    );

    pc_op <= branch_pc_op;
    pc_in <= branch_set_pc;
    
    
    process(clk)
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    flush_count <= (others => '0');
                elsif branch_pc_op = "10" then
                    flush_count <= "10";
                elsif flush_count /= 0 then
                    flush_count <= flush_count - 1;
                end if;
            end if;
        end process;
    
    flush_ifid <= '1' when flush_count = "10" else '0';
    flush_idex <= '1' when flush_count /= 0 else '0';
    
--    flush_ifid <= '1' when branch_pc_op = "10" else '0';
--    flush_idex <= '1' when branch_pc_op = "10" and instr_out(15 downto 9) /= "1000110" else '0';


    --flush_ifid <= '1' when branch_pc_op = "10" else '0';
    --flush_idex <= '0';

    --flush_ifid <= '1' when branch_pc_op = "10" else '0';
   -- flush_ifid <= '1' when flush_count = "11" else when flush_count = "10" else when flush_count = "01"
    --flush_idex <= '1' when branch_pc_op = "10" else '0';
--process(clk, branch_pc_op)
--variable flush_count : std_logic_vector(1 downto 0);
--begin
--    if (rising_edge(clk)) then
--        if branch_pc_op = "10" then
--            flush_count := "01";
--        --flush_count := "11" when branch_pc_op = "10" ;
--        end if;
        
--        if flush_count = "11" or flush_count = "10" or flush_count = "01" then
--            flush_ifid <= '1';
--            flush_count := std_logic_vector(unsigned(flush_count) - 1);
--       else
--            flush_ifid <= '0';
--        end if;
           
--    end if;

--end process;
    -- forwarding
    fwd_a <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = rb_src_ex and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = rb_src_ex and wb_dest_wb /= "000") else
             rb_ex;

    fwd_b <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = rc_src_ex and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = rc_src_ex and wb_dest_wb /= "000") else
             rc_ex;

    -- final writeback
    reg_wb_output <=  doutb when wb_mem_ctrl = '1' else wb_data_wb; --v when branch_wb_en = '1' else
    wb_reg_dest   <=  wb_dest_wb; --r7_wb_dest when branch_wb_en = '1' else
    wb_enable     <=  wb_enable_pipe; -- branch_wb_en when branch_wb_en = '1' else

    rb_data_sub <= r7_wb_data when (branch_wb_en = '1') else 
                    rb_data;
    ra_dest_sub <= "111" when( branch_wb_en = '1') else Ra;
             
             
--    rb_val_id <= r7_wb_data when (branch_wb_en = '1') else
--             wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = read_index1 and wb_dest_mem /= "000") else
--             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 and wb_dest_wb /= "000") else
--             rb_data;
    
--    rc_val_id <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = Rc and wb_dest_mem /= "000") else
--             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = Rc and wb_dest_wb /= "000") else
--             rc_data;
    ra_dest_id   <= Ra;
    reg_write_id <= wb_enable_id;
    
    bc_ra_val <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = read_index1 and wb_dest_mem /= "000") else
                 wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 and wb_dest_wb /= "000") else
                 rb_data;
    
    
    rb_val_id <= r7_wb_data when (branch_wb_en = '1') else
             wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = read_index1 and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = read_index1 and wb_dest_wb /= "000") else
             rb_data;
    
    rc_val_id <= wb_data_mem when (reg_wr_mem = '1' and wb_dest_mem = Rc and wb_dest_mem /= "000") else
             wb_data_wb  when (wb_enable_pipe = '1' and wb_dest_wb = Rc and wb_dest_wb /= "000") else
             rc_data;
    
    

    --mem access logic



mem_wenb <= "1" when reg_wr_mem = '0'  and mem_mem_ctrl = '1' else "0";
mem_enb <= mem_mem_ctrl;
dinb <= wb_data_mem;    
--signal mem_enb : std_logic;
--signal addrb : std_logic_vector(15 downto 0);
--signal dinb : std_logic_vector(15 downto 0);
--signal doutb : std_logic_vector(15 downto 0);

--signal wb_data_direct_mem : std_logic_vector(15 downto 0);

--signal ex_mem_ctrl : std_logic;
--signal mem_wenb : std_logic;
    
      

    -- flag registers
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if reset = '1' then
--                z_reg <= '0';
--                n_reg <= '0';
--            else
--                z_reg <= z_flag_ex;
--                n_reg <= n_flag_ex;
--            end if;
--        end if;
--    end process;

-- define port maps for entities here they should be mostly sequential
pc1: PC
port map(
    clk=>clk,
    in_PC=>pc_in,
    Op_PC=>pc_op,
    out_pc=>pc_address
);

--rom1: rom_128B port map(clock=>clk, reset=>reset, enable=>enable, address=>pc_address, data_out=>instr_in);
rom1: blk_mem_gen_0 
port map(
    clka=>clk,
    ena=>enable,
    addra=>pc_address(9 downto 0),
    douta=>instr_in
);

pr1: if_id_register
port map(
    clock=>clk,
    reset=>reset,
    stall=>stall_pipe,
    flush=>flush_ifid,
    instr_in=>instr_in, 
    instr_out=>instr_out,
    pc_in => pc_address,
    pc_out => pc_id
);

regc: RegCtrl
port map(
    clk=>clk,
    instruction=>instr_out,
    Ra=>Ra,
    Rb=>Rb,
    Rc=>Rc,
    opcode=>opcode_id,
    shiftOp=>shiftop_id,
    wb_enable=>wb_enable_id,
    branchOut=>branch_data_id,
    forwarding_control=>forwarding_control
);

mreg: register_file
port map(
    rst=>reset,
    clk=>clk,
    rd_index1=>read_index1,
    rd_index2=>Rc,
    wr_index=>wb_reg_dest,
    wr_data=>reg_wb_output,
    wr_enable=>wb_enable,
    rd_data1=>rb_data,
    rd_data2=>rc_data
 );
 
pr2: id_ex_register
port map(
    clock=>clk,
    reset=>reset,
    flush=>flush_idex,
    instr_in=>instr_out,
    pc_in=>pc_id,
    ra_dest_in   => ra_dest_id,
    rb_val_in    => rb_val_id,
    rc_val_in    => rc_val_id,
    reg_write_in => reg_write_id,
    
    
    rb_src_in=>read_index1,
    --rc_val_in=>rc_data,
    rc_src_in=>RC,
    --reg_write_in=>wb_enable_id,
    instr_out=>instr_ex,
    ra_dest_out=>ra_dest_ex,
    rb_val_out=>rb_ex,
    rb_src_out=>rb_src_ex,
    rc_val_out=>rc_ex,
    rc_src_out=>rc_src_ex,
    reg_write_out=>reg_wr_ex,
    pc_out=>pc_ex
);

al: ALUv2
port map(
    rb=>signed(fwd_a),
    rc=>signed(fwd_b),
    instruction=>instr_ex,
    output=>alu_out,
    outside_input=>outside_input,
    str_loc=>ex_location,
    mem_ctrl=>ex_mem_ctrl,
    z_flag=>z_flag_ex,
    n_flag=>n_flag_ex
);

pr3: ex_mem_register
port map(
    clock=>clk,
    reset=>reset,
    wb_data_in=>alu_out,
    wb_dest_in=>ra_dest_ex,
    reg_write_in=>reg_wr_ex,
    wb_data_out=>wb_data_mem,
    wb_dest_out=>wb_dest_mem,
    reg_write_out=>reg_wr_mem,
    mem_ctrl_in=>ex_mem_ctrl,
    mem_ctrl_out=>mem_mem_ctrl,
    mem_addr_in=>ex_location,
    mem_addr_out=>mem_location
);
ram: blk_mem_gen_1
port map(
addrb=>mem_location(9 downto 0),
clkb=>clk,
dinb=>dinb,
enb=>'1',
doutb=>doutb,
web=>mem_wenb,

clka=>clk,
wea=>"0",
addra=>"0000000000",
dina=>x"0000",
douta=>dump

);
-- putlogic here if we need differ write back
pr4: mem_wb_register
port map(
    clock=>clk,
    reset=>reset,
    wb_data_in=>wb_data_mem,
    wb_dest_in=>wb_dest_mem,
    reg_write_in=>reg_wr_mem,
    wb_data_out=>wb_data_wb,
    wb_dest_out=>wb_dest_wb,
    reg_write_out=>wb_enable_pipe,
    mem_ctrl_in=>mem_mem_ctrl,
    mem_ctrl_out=>wb_mem_ctrl
    
);

end Behavioral;
