LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.TEXTIO.ALL;

PACKAGE ProcessorPkg is
    CONSTANT c_WORD_SIZE : INTEGER := 8;
    CONSTANT c_ADDRESS_SIZE : INTEGER := 5;
    CONSTANT c_MEMORY_SIZE : INTEGER := 2**c_ADDRESS_SIZE;

    SUBTYPE t_Reg8 IS STD_LOGIC_VECTOR(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_UReg8 IS UNSIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    SUBTYPE t_SReg8 IS SIGNED(c_WORD_SIZE - 1 DOWNTO 0);
    
    CONSTANT c_PC_INIT_VALUE : t_Reg8 := x"02";

    TYPE t_Operation IS (
        op_ADD,
        op_SUB,
        op_AND,
        op_LOAD,
        op_STORE,
        op_JMP,
        op_JZ,
        op_HALT,
        op_INVALID
    );
    
    PURE FUNCTION f_DecodeInstruction(i_Instruction : t_Reg8) RETURN t_Operation;
END ProcessorPkg;

PACKAGE BODY ProcessorPkg IS
    PURE FUNCTION f_DecodeInstruction(i_Instruction : t_Reg8) RETURN t_Operation IS
        ALIAS a_OPCODE IS i_Instruction(7 DOWNTO 5);

        VARIABLE v_Operation : t_Operation := op_INVALID;
    BEGIN
        CASE a_OPCODE IS
            WHEN "000" =>
                v_Operation := op_ADD;
            WHEN "001" =>
                v_Operation := op_SUB;
            WHEN "010" =>
                v_Operation := op_AND;
            WHEN "011" =>
                v_Operation := op_LOAD;
            WHEN "100" =>
                v_Operation := op_STORE;
            WHEN "101" =>
                v_Operation := op_JMP;
            WHEN "110" =>
                v_Operation := op_JZ;
            WHEN "111" =>
                v_Operation := op_HALT;
            WHEN OTHERS =>
                v_Operation := op_INVALID;
        END CASE;
        RETURN v_Operation;
    END f_DecodeInstruction;   
END ProcessorPkg;
