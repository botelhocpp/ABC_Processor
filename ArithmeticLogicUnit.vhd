LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ArithmeticLogicUnit IS
PORT(
    i_Op_A      : IN t_Reg8;
    i_Op_B      : IN t_Reg8;
    i_Sel       : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    o_Zero      : OUT STD_LOGIC;
    o_Result    : OUT t_Reg8
);
END ENTITY;

ARCHITECTURE RTL OF ArithmeticLogicUnit IS
    CONSTANT c_ZERO : t_UReg8 := (OTHERS => '0');
    
    SIGNAL w_Result : t_UReg8 := (OTHERS => '0');
    SIGNAL w_Op_A : t_UReg8 := (OTHERS => '0');
    SIGNAL w_Op_B : t_UReg8 := (OTHERS => '0');
BEGIN
    w_Op_A <= RESIZE(t_UReg8(i_Op_A), w_Op_A'LENGTH);
    w_Op_B <= RESIZE(t_UReg8(i_Op_B), w_Op_A'LENGTH);

    WITH i_Sel SELECT
        w_Result <= (w_Op_A + w_Op_B)   WHEN "000",
                    (w_Op_A - w_Op_B)   WHEN "001",
                    (w_Op_A AND w_Op_B) WHEN "010",
                    (w_Op_A)            WHEN "011",
                    (w_Op_B)            WHEN OTHERS;

    o_Result <= t_Reg8(w_Result);

	o_Zero <= '1' WHEN (w_Result = c_ZERO) ELSE '0';
END ARCHITECTURE;
