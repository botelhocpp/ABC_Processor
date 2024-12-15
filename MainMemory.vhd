LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY MainMemory IS
GENERIC ( g_SIZE : INTEGER := c_ADDRESS_SIZE );
PORT (
    i_Address       : IN STD_LOGIC_VECTOR(g_SIZE - 1 DOWNTO 0);
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    io_Data         : INOUT t_Reg8
);
END ENTITY;

ARCHITECTURE RTL OF MainMemory IS    
    TYPE t_MemoryArray IS ARRAY (0 TO 2**g_SIZE - 1) OF t_Reg8;

    SIGNAL r_Contents : t_MemoryArray := (
        00 => "01110110", -- LOAD 22
        01 => "00001111", -- ADD 15
        02 => "10010110", -- STORE 22

        03 => "01100001", -- LOAD 1
        04 => "00010101", -- ADD 21
        05 => "10000001", -- STORE 1

        06 => "01110100", -- LOAD 20
        07 => "00110101", -- SUB 21
        08 => "10010100", -- STORE 20

        09 => "11001011", -- JZ 11
        10 => "10100000", -- JMP 0
        11 => "11100000", -- HALT

        15 => x"01", -- array[0]
        16 => x"02", -- array[1]
        17 => x"03", -- array[2]
        18 => x"04", -- array[3]
        19 => x"05", -- array[4]
        20 => x"05", -- iterations
        21 => x"01", -- constant_1
        22 => x"00", -- array_sum

        OTHERS => (OTHERS => '0')
    );
    
    SIGNAL r_Data_Out : t_Reg8 := (OTHERS => '0');
    SIGNAL w_Address : INTEGER RANGE r_Contents'RANGE := 0;
BEGIN 
    w_Address <= TO_INTEGER(UNSIGNED(i_Address));
    io_Data <= r_Data_Out;

    p_MEMORY_READ_WRITE_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            IF(i_Write_Enable = '1') THEN
                r_Contents(w_Address) <= io_Data;
            END IF;

            IF(i_Output_Enable = '1') THEN
                r_Data_Out <= r_Contents(w_Address);
            ELSE
                r_Data_Out <= (OTHERS => 'Z');
            END IF;
        END IF;
    END PROCESS p_MEMORY_READ_WRITE_CONTROL;
END ARCHITECTURE;
