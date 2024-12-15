LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY InputOutputModule IS
PORT (
    i_Address       : IN STD_LOGIC_VECTOR(c_ADDRESS_SIZE - 1 DOWNTO 0);
    i_Write_Enable  : IN STD_LOGIC;
    i_Output_Enable : IN STD_LOGIC;
    i_Clk           : IN STD_LOGIC;
    i_Rst           : IN STD_LOGIC;
    i_Buttons       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    o_Leds          : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    io_Data         : INOUT t_Reg8
);
END ENTITY;

ARCHITECTURE RTL OF InputOutputModule IS 
    CONSTANT c_BUTTONS_ADDRESS : INTEGER := 30;
    CONSTANT c_LEDS_ADDRESS : INTEGER := 31;
    
    TYPE t_IORegisterArray IS ARRAY (0 TO 31) OF t_Reg8; 
    SIGNAL r_IO_Registers : t_IORegisterArray := (OTHERS => (OTHERS => '0'));

    SIGNAL r_Leds : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL r_Data_Out : t_Reg8 := (OTHERS => '0');
    
    SIGNAL w_Address : INTEGER RANGE 0 TO 31 := 0;
BEGIN 
    o_Leds <= r_Leds;
    io_Data <= r_Data_Out WHEN (i_Output_Enable = '1') ELSE (OTHERS => 'Z');
    
    w_Address <= TO_INTEGER(UNSIGNED(i_Address));

    p_REGISTERS_READ_WRITE_CONTROL:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_IO_Registers <= (
                (OTHERS => (OTHERS => '0'))
            );
            r_Data_Out <= (OTHERS => '0');
        ELSIF(RISING_EDGE(i_Clk)) THEN
            r_IO_Registers(c_BUTTONS_ADDRESS)(3 DOWNTO 0) <= i_Buttons;
            
            IF(w_Address < 16) THEN
                IF(
                    i_Write_Enable = '1' AND 
                    w_Address /= c_BUTTONS_ADDRESS
                ) THEN
                    r_IO_Registers(w_Address) <= io_Data;
                END IF;
                
                r_Data_Out <= r_IO_Registers(w_Address);
            END IF;
        END IF;
    END PROCESS p_REGISTERS_READ_WRITE_CONTROL;

    p_DEVICES_CONTROL:
    PROCESS(i_Clk)
    BEGIN
        IF(RISING_EDGE(i_Clk)) THEN
            r_Leds <= r_IO_Registers(c_LEDS_ADDRESS)(3 DOWNTO 0);
        END IF;
    END PROCESS p_DEVICES_CONTROL;
END ARCHITECTURE;