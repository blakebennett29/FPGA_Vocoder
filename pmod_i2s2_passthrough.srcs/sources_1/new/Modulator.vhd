----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2026 05:04:25 PM
-- Design Name: 
-- Module Name: Modulator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
-- Multiplies left/right signed inputs by envelope value when m_tvalid_in is high.
-- Uses sfixed for envelope and converts audio input to sfixed for multiply.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.ALL;

entity Modulator is
    Port (
        clk          : in  std_logic;
        reset        : in  std_logic;

        left_input_L1_H   : in  std_logic_vector(31 downto 0);
        right_input_L1_H  : in  std_logic_vector(31 downto 0);
        left_input_L1_L   : in std_logic_vector(31 downto 0);
        right_input_L1_L  : in std_logic_vector(31 downto 0);
        Env_fol_in        : in  sfixed(0 downto -18);
        m_tvalid_in       : in  std_logic;
        

        left_output_L1_H : out std_logic_vector(31 downto 0);
        right_output_L1_H : out std_logic_vector(31 downto 0);
        left_output_L1_L : out std_logic_vector(31 downto 0);
        right_output_L1_L : out std_logic_vector(31 downto 0)
    );
end Modulator;

architecture Behavioral of Modulator is

    type state_type is (IDLE, MODULATE, OUTPUT_STATE);
    signal current_state : state_type := IDLE;

    -- input converted to signed/fixed
    signal left_in_L1_H_s      : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal right_in_L1_H_s     : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal left_in_L1_L_s      : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal right_in_L1_L_s     : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    -- multiplication result width:
    -- left_in_s  = sfixed(31 downto 0)
    -- Env_fol_in = sfixed(0 downto -18)
    -- result     = sfixed(31 downto -18)
    signal left_mult_L1_H_s    : sfixed(31 downto -18) := to_sfixed(0, 0, -18);
    signal right_mult_L1_H_s   : sfixed(31 downto -18) := to_sfixed(0, 0, -18);
    signal left_mult_L1_L_s    : sfixed(31 downto -18) := to_sfixed(0, 0, -18);
    signal right_mult_L1_L_s   : sfixed(31 downto -18) := to_sfixed(0, 0, -18);
    
    -- resized back to output width
--    signal left_out_s     : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
--    signal right_out_s    : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal sfix_left_output_L1_H_s  : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal sfix_right_output_L1_H_s : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal sfix_left_output_L1_L_s  : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    signal sfix_right_output_L1_L_s : sfixed(31 downto 0) := to_sfixed(0, 0, -18);
    
    signal left_output_L1_H_s  : std_logic_vector(31 downto 0) := (others => '0') ;
    signal right_output_L1_H_s : std_logic_vector(31 downto 0) := (others => '0');
    signal left_output_L1_L_s  : std_logic_vector(31 downto 0) := (others => '0') ;
    signal right_output_L1_L_s : std_logic_vector(31 downto 0) := (others => '0');

begin

    ------------------------------------------------------------------------------
    -- Output assignments
    ------------------------------------------------------------------------------
    left_output_L1_H  <= left_output_L1_H_s;
    right_output_L1_H <= right_output_L1_H_s;
    
    left_output_L1_L <= left_output_L1_L_s;
    right_output_L1_L <= right_output_L1_L_s;
    

    ------------------------------------------------------------------------------
    -- Convert std_logic_vector inputs to sfixed
    ------------------------------------------------------------------------------
    left_in_L1_H_s  <= to_sfixed(signed(left_input_L1_H), 31, 0);
    right_in_L1_H_s <= to_sfixed(signed(right_input_L1_H), 31, 0);
    left_in_L1_L_s  <= to_sfixed(signed(left_input_L1_L), 31, 0);
    right_in_L1_L_s <= to_sfixed(signed(right_input_L1_L), 31, 0);

    ------------------------------------------------------------------------------
    -- State register + datapath registers
    ------------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state   <= IDLE;
                left_mult_L1_H_s     <= (others => '0');
                right_mult_L1_H_s    <= (others => '0');
                left_mult_L1_L_s      <= (others => '0');
                right_mult_L1_L_s     <= (others => '0');
                
                left_output_L1_H_s   <= (others => '0');
                right_output_L1_H_s  <= (others => '0');
                left_output_L1_L_s   <= (others => '0');
                right_output_L1_L_s  <= (others => '0');
                current_state <= IDLE;
            else
                case current_state is
                    when IDLE =>
                        if m_tvalid_in = '1' then
                            current_state <= MODULATE;
                        else
                            current_state <= IDLE;
                        end if;
                    when MODULATE =>
                        -- Multiply input by envelope
                        --high L1 modulation
                        left_mult_L1_H_s  <= left_in_L1_H_s * Env_fol_in;
                        right_mult_L1_H_s <= right_in_L1_H_s * Env_fol_in;
                        --Low L1 modulation
                        left_mult_L1_L_s  <= left_in_L1_L_s  * Env_fol_in;
                        right_in_L1_L_s   <= right_in_L1_L_s * Env_fol_in;
                        
                        current_state <= OUTPUT_STATE;
                    when OUTPUT_STATE =>
                        -- Resize back to 32-bit integer fixed-point
                        -- risize L1 high side
                        sfix_left_output_L1_H_s  <= resize(left_mult_L1_H_s, 31, 0);
                        sfix_right_output_L1_H_s <= resize(right_mult_L1_H_s, 31, 0);
                        --resize L1 Low side
                        sfix_left_output_L1_L_s  <= resize(left_mult_L1_L_s, 31, 0);
                        sfix_right_output_L1_L_s <= resize(right_in_L1_L_s, 31, 0);
                        
                        -- Convert back to std_logic_vector
                        left_output_L1_H_s  <= std_logic_vector(to_signed((sfix_left_output_L1_H_s), 32));
                        right_output_L1_H_s <= std_logic_vector(to_signed((sfix_right_output_L1_H_s), 32));
                        left_output_L1_L_s  <= std_logic_vector(to_signed((sfix_left_output_L1_L_s), 32));
                        right_output_L1_L_s <= std_logic_vector(to_signed((sfix_right_output_L1_L_s), 32));
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;