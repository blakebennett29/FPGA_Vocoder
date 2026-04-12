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
        
        Env_fol_in_H_L_1   : in  std_logic_vector(16 downto 0);
        Env_fol_in_L_L_1   : in  std_logic_vector(16 downto 0);
        Env_fol_in_L_R : in  std_logic_vector(16 downto 0);
        Env_fol_in_H_R : in  std_logic_vector(16 downto 0);
       -- in_valid_h          : in std_logic;
        in_valid_l          : in std_logic;
        m_tvalid_in       : in  std_logic;
        
        Mod_valid_out    : out std_logic;
        left_output_L1_H : out std_logic_vector(31 downto 0);
        right_output_L1_H : out std_logic_vector(31 downto 0);
        left_output_L1_L : out std_logic_vector(31 downto 0);
        right_output_L1_L : out std_logic_vector(31 downto 0)
    );
end Modulator;

architecture Behavioral of Modulator is

    type state_type is (IDLE, MODULATE, OUTPUT_STATE, assign_output);
    signal current_state : state_type := IDLE;
    signal reset_s : std_logic := '0';
    signal Env_fol_in_L_L_1_s : ufixed(0 downto -17) := to_ufixed(0, 0, -17);
    signal Env_fol_in_H_L_1_s : ufixed(0 downto -17) := to_ufixed(0, 0, -17);
    signal in_valid_h_s : std_logic := '0';
    signal in_valid_l_s : std_logic := '0';
    signal Mod_valid_out_s : std_logic := '0';
    -- input converted to signed/fixed
    signal left_in_L1_H_s      : sfixed(31 downto 0) := (others => '0');
    signal right_in_L1_H_s     : sfixed(31 downto 0) := (others => '0');
    signal left_in_L1_L_s      : sfixed(31 downto 0) := (others => '0');
    signal right_in_L1_L_s     : sfixed(31 downto 0) := (others => '0');

    -- multiplication result width:
    -- left_in_s  = ufixed(31 downto 0)
    -- Env_fol_in = ufixed(0 downto -18)
    -- result     = ufixed(31 downto -18)
    signal left_mult_L1_H_s    : sfixed(31 downto -17) := (others => '0');
    signal right_mult_L1_H_s   : sfixed(31 downto -17) := (others => '0');
    signal left_mult_L1_L_s    : sfixed(31 downto -17) := (others => '0');
    signal right_mult_L1_L_s   : sfixed(31 downto -17) := (others => '0');
    
    -- resized back to output width
--    signal left_out_s     : ufixed(31 downto 0) := (others => '0');
--    signal right_out_s    : ufixed(31 downto 0) := (others => '0');
    signal sfix_left_output_L1_H_s  : sfixed(31 downto 0) := (others => '0');
    signal sfix_right_output_L1_H_s : sfixed(31 downto 0) := (others => '0');
    signal sfix_left_output_L1_L_s  : sfixed(31 downto 0) := (others => '0');
    signal sfix_right_output_L1_L_s : sfixed(31 downto 0) := (others => '0');
    
    signal left_output_L1_H_s  : std_logic_vector(31 downto 0) := (others => '0') ;
    signal right_output_L1_H_s : std_logic_vector(31 downto 0) := (others => '0');
    signal left_output_L1_L_s  : std_logic_vector(31 downto 0) := (others => '0') ;
    signal right_output_L1_L_s : std_logic_vector(31 downto 0) := (others => '0');
    Constant Test_gain : sfixed(0 downto -17) := to_sfixed(0.9999, 0, -17);
   
   signal Env_fol_in_L_R_1_s : ufixed(0 downto -17) := to_ufixed(0, 0, -17);
   signal Env_fol_in_H_R_1_s : ufixed(0 downto -17) := to_ufixed(0, 0, -17);
begin
    reset_s <= reset;
    ------------------------------------------------------------------------------
    -- Output assignments
    ------------------------------------------------------------------------------
    left_output_L1_H  <= left_output_L1_H_s;
    right_output_L1_H <= right_output_L1_H_s;
    
    left_output_L1_L <= left_output_L1_L_s;
    right_output_L1_L <= right_output_L1_L_s;
    
    --------------------------------------------
    --assinment for std_logic_vector to ufixed
    --------------------------------------------
    
    Env_fol_in_L_L_1_s <= to_ufixed( "0" & Env_fol_in_L_L_1, 0, -17);
    Env_fol_in_H_L_1_s <= to_ufixed( "0" & Env_fol_in_H_L_1, 0, -17);
    Env_fol_in_L_R_1_s <= to_ufixed( "0" & Env_fol_in_L_R, 0, -17);
    Env_fol_in_H_R_1_s <= to_ufixed( "0" & Env_fol_in_H_R, 0, -17);
    --in_valid_h_s <= in_valid_h;
    in_valid_l_s <= in_valid_l;
    ------------------------------------------------------------------------------
    -- Convert std_logic_vector inputs to ufixed
    ------------------------------------------------------------------------------
    left_in_L1_H_s  <= to_sfixed(signed(left_input_L1_H), 31, 0);
    right_in_L1_H_s <= to_sfixed(signed(right_input_L1_H), 31, 0);
    left_in_L1_L_s  <= to_sfixed(signed(left_input_L1_L), 31, 0);
    right_in_L1_L_s <= to_sfixed(signed(right_input_L1_L), 31, 0);

    Mod_valid_out <= Mod_valid_out_s;
    ------------------------------------------------------------------------------
    -- State register + datapath registers
    ------------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_s = '1' then
                current_state   <= IDLE;
                left_mult_L1_H_s     <= (others => '0');
                right_mult_L1_H_s    <= (others => '0');
                left_mult_L1_L_s      <= (others => '0');
                right_mult_L1_L_s     <= (others => '0');
                
                sfix_left_output_L1_H_s <= (others => '0');
                sfix_right_output_L1_H_s <= (others => '0');
                sfix_left_output_L1_L_s <= (others => '0');
                sfix_right_output_L1_L_s <= (others => '0');
                
                left_output_L1_H_s   <= (others => '0');
                right_output_L1_H_s  <= (others => '0');
                left_output_L1_L_s   <= (others => '0');
                right_output_L1_L_s  <= (others => '0');
                current_state <= IDLE;
            else
                case current_state is
                    when IDLE =>
                        Mod_valid_out_s     <= '0';
                        if in_valid_l_s = '1' then  --m_tvalid_in = '1' then   -- -- m_tvalid_in = '1' then--
                            current_state <= MODULATE;
                        else
                            current_state <= IDLE;
                        end if;
                    when MODULATE =>
                        -- Multiply input by envelope
                        --high L1 modulation
                        left_mult_L1_H_s  <= resize(left_in_L1_H_s  * Test_gain,31,-17);--to_sfixed(Env_fol_in_H_L_1_s), 31, -17);   --Env_fol_in_H_L_1_s    --to_sfixed(signed('0' & Env_fol_in_s), -1, -18), 31, 0);
                        right_mult_L1_H_s <= resize(right_in_L1_H_s * Test_gain,31,-17);--to_sfixed(Env_fol_in_H_R_1_s), 31, -17);-- * to_sfixed((signed("00" & Env_fol_in_H_L_1_s) sll 1), 0, -18), 31, 0);  --Env_fol_in_H_L_1_s
                        
                        --Low L1 modulation
                        left_mult_L1_L_s  <= resize(left_in_L1_L_s  * Test_gain,31,-17);--to_sfixed(Env_fol_in_L_L_1_s), 31, -17);    --left_mult_L1_L_s  <= resize(left_in_L1_L_s  * to_sfixed((signed("00" & Env_fol_in_L_L_1_s) sll 1), 0, -18), 31 , 0); --Env_fol_in_L_L_1_s    --to_sfixed(signed('0' & Env_fol_in_s), -1, -18), 31, 0);
                        right_mult_L1_L_s   <= resize(right_in_L1_L_s * Test_gain,31,-17);--to_sfixed(Env_fol_in_L_R_1_s), 31, -17);    -- * to_sfixed((signed("00" & Env_fol_in_L_L_1_s) sll 1), 0, -18), 31 , 0); --Env_fol_in_L_L_1_s  --to_sfixed(signed('0' & Env_fol_in_s), -1, -18), 31, 0);
                        
                        current_state <= OUTPUT_STATE;
                    when OUTPUT_STATE =>
                        -- Resize back to 32-bit integer fixed-point
                        -- risize L1 high side
                        sfix_left_output_L1_H_s  <= resize(left_mult_L1_H_s, 31, 0);
                        sfix_right_output_L1_H_s <= resize(right_mult_L1_H_s, 31, 0);
                        --resize L1 Low side
                        sfix_left_output_L1_L_s  <= resize(left_mult_L1_L_s, 31, 0);
                        sfix_right_output_L1_L_s <= resize(right_mult_L1_L_s, 31, 0);
                        current_state <= assign_output;
                    when assign_output =>
                        -- Convert back to std_logic_vector
                        left_output_L1_H_s  <= std_logic_vector(to_signed((sfix_left_output_L1_H_s), 32));
                        right_output_L1_H_s <= std_logic_vector(to_signed((sfix_right_output_L1_H_s), 32));
                        left_output_L1_L_s  <= std_logic_vector(to_signed((sfix_left_output_L1_L_s), 32));
                        right_output_L1_L_s <= std_logic_vector(to_signed((sfix_right_output_L1_L_s), 32));
                        Mod_valid_out_s     <= '1';
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
     
end Behavioral;