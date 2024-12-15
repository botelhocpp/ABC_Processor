LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ProcessorPkg.ALL;

ENTITY ControlUnit IS
PORT (    
    i_Instruction       : IN t_Reg8;
    i_Zero              : IN STD_LOGIC;
    i_Clk               : IN STD_LOGIC;
    i_Rst               : IN STD_LOGIC;
    o_Write_Enable      : OUT STD_LOGIC;
    o_Output_Enable     : OUT STD_LOGIC;
    o_Ac_Load           : OUT STD_LOGIC;
    o_Pc_Load           : OUT STD_LOGIC;
    o_Pc_Inc            : OUT STD_LOGIC;
    o_Ir_Load           : OUT STD_LOGIC;
    o_Address_Select    : OUT STD_LOGIC  
);
END ENTITY;

ARCHITECTURE RTL OF ControlUnit IS
    TYPE t_InstructionCycle IS (
        s_FETCH_INSTRUCTION,
        s_STORE_INSTRUCTION,
        s_FETCH_OPERAND,
        s_STORE_RESULT
    );
    SIGNAL r_Current_State : t_InstructionCycle := s_FETCH_INSTRUCTION;

    SIGNAL w_Operation : t_Operation := op_INVALID;
BEGIN
    w_Operation <= f_DecodeInstruction(i_Instruction);

    p_INSTRUCTION_CYCLE_NEXT_STATE:
    PROCESS(i_Rst, i_Clk)
    BEGIN
        IF(i_Rst = '1') THEN
            r_Current_State <= s_FETCH_INSTRUCTION;
        ELSIF(RISING_EDGE(i_Clk)) THEN
            CASE r_Current_State IS
                WHEN s_FETCH_INSTRUCTION =>
                    r_Current_State <= s_STORE_INSTRUCTION;

                WHEN s_STORE_INSTRUCTION =>
                    IF(
                        w_Operation = op_ADD OR w_Operation = op_SUB OR
                        w_Operation = op_AND OR w_Operation = op_LOAD
                    ) THEN
                        r_Current_State <= s_FETCH_OPERAND;
                    ELSE
                        r_Current_State <= s_STORE_RESULT;
                    END IF;
                    
                WHEN s_FETCH_OPERAND =>
                    r_Current_State <= s_STORE_RESULT;
                
                WHEN s_STORE_RESULT =>
                    r_Current_State <= s_FETCH_INSTRUCTION;
                
            END CASE;
        END IF;
    END PROCESS p_INSTRUCTION_CYCLE_NEXT_STATE;

    p_INSTRUCTION_CYCLE_GENERATE_SIGNALS:
    PROCESS(i_Zero, r_Current_State, i_Instruction, w_Operation)
    BEGIN
        -- Default values
        o_Write_Enable <= '0';
        o_Output_Enable <= '0';
        o_Ac_Load <= '0';
        o_Pc_Load <= '0';
        o_Pc_Inc <= '0';
        o_Ir_Load <= '0';
        o_Address_Select <= '0';  

        -- Set state specific signals
        CASE r_Current_State IS
            WHEN s_FETCH_INSTRUCTION =>
                o_Output_Enable <= '1';
                o_Pc_Inc <= '1';

            WHEN s_STORE_INSTRUCTION =>
                o_Output_Enable <= '1';
                o_Ir_Load <= '1';
            
            WHEN s_FETCH_OPERAND => 
                o_Output_Enable <= '1';
                o_Address_Select <= '1';   

            WHEN s_STORE_RESULT =>
                CASE w_Operation IS
                    WHEN op_ADD | op_SUB | op_AND | op_LOAD =>
                        o_Output_Enable <= '1';
                        o_Ac_Load <= '1';
                    WHEN op_STORE =>
                        o_Write_Enable <= '1';
                        o_Address_Select <= '1';  
                    WHEN op_JMP =>
                        o_Pc_Load <= '1';
                    WHEN op_JZ =>
                        IF(i_Zero = '1') THEN
                            o_Pc_Load <= '1';
                        END IF;
                    WHEN OTHERS =>
                END CASE;

        END CASE;
    END PROCESS p_INSTRUCTION_CYCLE_GENERATE_SIGNALS;
END ARCHITECTURE;
