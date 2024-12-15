LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Processor IS
PORT ( 
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    o_Write_Enable  : OUT STD_LOGIC;
    o_Output_Enable : OUT STD_LOGIC;
    o_Address       : OUT STD_LOGIC_VECTOR(c_ADDRESS_SIZE - 1 DOWNTO 0);
    io_Data         : INOUT t_Reg8
);
END ENTITY;

ARCHITECTURE RTL OF Processor IS
    SIGNAL w_Alu_Bus        : t_Reg8 := (OTHERS => '0');
    SIGNAL w_Ac_Data        : t_Reg8 := (OTHERS => '0');
    SIGNAL w_Pc_Data        : STD_LOGIC_VECTOR(c_ADDRESS_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL w_Instruction    : t_Reg8 := (OTHERS => '0');
    
    ALIAS a_Opcode IS w_Instruction(7 DOWNTO 5);
    ALIAS a_Address IS w_Instruction(4 DOWNTO 0);

    SIGNAL w_Zero           : STD_LOGIC := '0';
    SIGNAL w_Write_Enable   : STD_LOGIC := '0';
    SIGNAL w_Output_Enable  : STD_LOGIC := '0';
    SIGNAL w_Ac_Load        : STD_LOGIC := '0';
    SIGNAL w_Pc_Load        : STD_LOGIC := '0';
    SIGNAL w_Pc_Inc         : STD_LOGIC := '0';
    SIGNAL w_Ir_Load        : STD_LOGIC := '0';
    SIGNAL w_Address_Select : STD_LOGIC := '0';  
BEGIN
    e_AC_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D     => w_Alu_Bus,
        i_Load  => w_Ac_Load,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Q     => w_Ac_Data
    );
    e_ALU: ENTITY WORK.ArithmeticLogicUnit
    PORT MAP(
        i_Op_A      => w_Ac_Data,
        i_Op_B      => io_Data,
        i_Sel       => a_Opcode,
        o_Zero      => w_Zero,
        o_Result    => w_Alu_Bus
    );
    e_IR_REGISTER: ENTITY WORK.GenericRegister
    PORT MAP (
        i_D     => io_Data,
        i_Load  => w_Ir_Load,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Q     => w_Instruction
    );
    e_PC_REGISTER: ENTITY WORK.Counter
    GENERIC MAP ( g_SIZE => c_ADDRESS_SIZE )
    PORT MAP (
        i_D     => a_Address,
        i_Load  => w_Pc_Load,
        i_Inc   => w_Pc_Inc,
        i_Clk   => i_Clk,
        i_Rst   => i_Rst,
        o_Q     => w_Pc_Data
    );
    e_CONTROL_UNIT: ENTITY WORK.ControlUnit
    PORT MAP(
        i_Instruction       => w_Instruction, 
        i_Zero              => w_Zero, 
        i_Clk               => i_Clk,
        i_Rst               => i_Rst,
        o_Write_Enable      => w_Write_Enable,
        o_Output_Enable     => w_Output_Enable,
        o_Ac_Load           => w_Ac_Load,
        o_Pc_Load           => w_Pc_Load,
        o_Pc_Inc            => w_Pc_Inc,
        o_Ir_Load           => w_Ir_Load,
        o_Address_Select    => w_Address_Select  
    );

    -- Redirect to Output
    o_Write_Enable <= w_Write_Enable;
    o_Output_Enable <= w_Output_Enable; 

    -- Multiplexers
    o_Address <= a_Address WHEN (w_Address_Select = '1') ELSE w_Pc_Data;
    
    -- Write to Memory Tristate Buffer
    io_Data <= w_Alu_Bus WHEN (w_Write_Enable = '1') ELSE (OTHERS => 'Z');
END ARCHITECTURE;
