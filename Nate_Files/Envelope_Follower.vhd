----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2026 05:14:33 PM
-- Design Name: 
-- Module Name: Envelope_Follower - Behavioral
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
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;


entity Envelope_Follower is
    Port ( env_in : in STD_LOGIC_VECTOR (17 downto 0);
           env_start: in STD_LOGIC;
           env_clk : in STD_LOGIC;
           env_rst : in STD_LOGIC;
           env_out : out STD_LOGIC_VECTOR (16 downto 0));
end Envelope_Follower;

architecture Behavioral of Envelope_Follower is
signal env_input: STD_LOGIC_VECTOR(17 downto 0);
signal rectified: STD_LOGIC_VECTOR(17 downto 0);
signal rectified_fx : ufixed(17 downto 0);

signal feedback: STD_LOGIC_VECTOR(17 downto 0);
signal feedback_fx  : ufixed(17 downto 0);

signal term1: ufixed(17 downto -14);
signal term2: ufixed(17 downto -14);

signal output: STD_LOGIC_VECTOR(17 downto 0);
signal alpha : ufixed(0 downto -14);

signal state_cnt: integer := 0;

constant alpha_attack  : ufixed(0 downto -14):= to_ufixed(0.5, 0, -14);
constant alpha_release : ufixed(0 downto -14):= to_ufixed(0.9979, 0, -14);
constant output_hold: integer := 8;
constant one_fx : ufixed(0 downto -14) := to_ufixed(1.0,0,-14);

type IIR_State is (IDLE, SET_TERMS, MULTIPLY, SET_OUTPUT);
signal curr_state, next_state : IIR_State;

begin

process (curr_state,state_cnt, env_start) begin
    case curr_state is
        when IDLE =>
            if env_start = '1' then
                next_state <= SET_TERMS;
            else
                next_state <= IDLE;
            end if;
        when SET_TERMS =>
            if state_cnt <= 2 then
                next_state <= SET_TERMS;
            else
                next_state <= MULTIPLY;
            end if;
        when MULTIPLY =>
            if state_cnt <= 6 then
                next_state <= MULTIPLY;
            else
                next_state <= SET_OUTPUT;
            end if;
        when SET_OUTPUT =>
            if state_cnt <= output_hold then
                next_state <= SET_OUTPUT;
            else
                next_state <= IDLE;
            end if;            
        when others =>
            next_state <= IDLE;
    end case;
end process;

process(env_clk, env_rst)
begin   
    if rising_edge(env_clk) then
        curr_state <= next_state;
        if env_rst = '1' then
            env_input <= (others => '0');
            rectified <= (others => '0');
            feedback <= (others => '0');
            output <= (others => '0');
            state_cnt <= 0;
            term1 <= (others => '0');
            term2 <= (others => '0');
            alpha <= alpha_attack;
            curr_state <= IDLE;
        
        --Set Feedback term 
        elsif curr_state = IDLE then
            feedback <= output;
            feedback_fx <= to_ufixed(unsigned(feedback),17,0);
            env_input(17 downto 0) <= env_in;
            output <= output;          
            state_cnt <= 0;

        
        elsif curr_state = SET_TERMS then
            feedback <= feedback;
            feedback_fx  <= to_ufixed(unsigned(feedback), 17, 0);
            rectified <= std_logic_vector(abs(signed(env_input))); 
            rectified_fx <= to_ufixed(unsigned(rectified), 17, 0);
            state_cnt <= state_cnt + 1;
            
        --Set value through filter
        elsif curr_state = MULTIPLY then
            if rectified_fx > feedback_fx then
                alpha <= alpha_attack;
            else
                alpha <= alpha_release;
            end if;
            term1 <= resize((one_fx - alpha) * rectified_fx,17,-14);
            term2 <= resize(alpha * feedback_fx,17,-14);          
            state_cnt <= state_cnt + 1;
            
        elsif curr_state = SET_OUTPUT then
            output <= to_slv(resize(term1 + term2,17,0));
            state_cnt <= state_cnt + 1;
            
        else
            feedback <= output;
            env_input <= env_in;
            output <= output;
            rectified <= std_logic_vector(abs(signed(env_input)));  
            state_cnt <= 0;
        end if;
    end if;
end process;

env_out <= output(16 downto 0);

end Behavioral;
