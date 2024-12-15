LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY Counter IS
GENERIC ( g_SIZE : INTEGER := c_ADDRESS_SIZE );
PORT (
    i_D : IN STD_LOGIC_VECTOR(g_SIZE - 1 DOWNTO 0);
    i_Load : IN STD_LOGIC;
    i_Inc : IN STD_LOGIC;
    i_Clk : IN STD_LOGIC;
    i_Rst : IN STD_LOGIC;
    o_Q : OUT STD_LOGIC_VECTOR(g_SIZE - 1 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE RTL OF Counter IS
    SIGNAL r_Q : STD_LOGIC_VECTOR(g_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN    
    o_Q <= r_Q;

    p_LOAD_REGISTER:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Q <= (OTHERS => '0');
        ELSIF(RISING_EDGE(i_Clk)) THEN
            IF(i_Load = '1') THEN
                r_Q <= i_D;
            ELSIF(i_Inc = '1') THEN
                r_Q <= STD_LOGIC_VECTOR(UNSIGNED(r_Q) + 1);
            END IF;
        END IF;
    END PROCESS p_LOAD_REGISTER;
END ARCHITECTURE;