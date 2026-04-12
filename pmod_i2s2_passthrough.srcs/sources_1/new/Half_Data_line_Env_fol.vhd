----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2026 05:53:21 PM
-- Design Name: 
-- Module Name: Half_Data_line_Env_fol - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Half_Data_line_Env_fol is
  Port (    --raw_clk: in std_logic;
            comp_clk: in std_logic;
            reset: in std_logic;
            locked : in std_logic;
            
            Env_fol_out_L_L : out std_logic_vector(16 downto 0);
            Env_fol_out_H_L : out std_logic_vector(16 downto 0);
            Env_fol_out_L_R : out std_logic_vector(16 downto 0);
            Env_fol_out_H_R : out std_logic_vector(16 downto 0);
            out_valid_h : out std_logic;
            out_valid_L : out std_logic;
            
--            r_sclk: out std_logic;
--            r_mclk: out std_logic;
--            r_lrclk: out std_logic;
            r_data: in std_logic --in for actual use
            --r_data: out std_logic;
            
--            t_sclk: out std_logic;
--            t_mclk: out std_logic;
--            t_lrclk: out std_logic;
--            t_data: out std_logic
            );
end Half_Data_line_Env_fol;

architecture Behavioral of Half_Data_line_Env_fol is
signal r_data_s : std_logic := '0';
signal t_data_s : std_logic := '0';
signal mclk_s : std_logic := '0';
signal sclk_s : std_logic := '0';
signal lrclk_s : std_logic :='0';
signal reset_s : std_logic := '0';
-- additional registers for reciver side
signal left_reg_shift_c : std_logic_vector(23 downto 0) := (others =>'0');--shift to output dac
signal right_reg_shift_c : std_logic_vector(23 downto 0) := (others =>'0');-- shift to ouput dac
-- ============================================================
-- ADDED (_s) signals for FIR + I2S valid/data routing
-- ============================================================
signal fir_left_valid_in_s  : std_logic := '1';
signal fir_right_valid_in_s : std_logic := '1';
-- assined from fir to output port

signal left_valid_s : std_logic := '0';
signal right_valid_s : std_logic := '0';

signal m_tdata_valid_s :  std_logic := '0';
--data out for diffrent levels to see on output only use one set at a time
signal fir_out_data_right_s : std_logic_vector(31 downto 0) := (others =>'0');
signal fir_out_data_left_s : std_logic_vector(31 downto 0) := (others =>'0');
signal fir_out_data_right_2_s : std_logic_vector(31 downto 0) := (others =>'0');
signal fir_out_data_left_2_s : std_logic_vector(31 downto 0) := (others =>'0');

--Level 1
--high
signal H_L1_output_left_s : std_logic_vector(31 downto 0) := (others =>'0');
signal H_L1_output_right_s : std_logic_vector(31 downto 0) := (others =>'0');
--low
signal L_L1_output_left_s : std_logic_vector(31 downto 0) := (others =>'0');
signal L_L1_output_right_s : std_logic_vector(31 downto 0) := (others =>'0');
--signials for testing
signal L_L1_test_left_s : std_logic_vector(23 downto 0) := (others => '0');
signal L_L1_test_right_s : std_logic_vector(23 downto 0) := (others => '0');
--data out for interpolation AA
-- internal signals
signal interpolate_aa_data_out_left_s   : std_logic_vector(23 downto 0) := (others =>'0');
signal interpolate_aa_data_out_right_s  : std_logic_vector(23 downto 0) := (others =>'0');
--data out for interpolation level 1
signal interpolate_l1_data_out_left_s     : std_logic_vector(31 downto 0) := (others =>'0');
signal interpolate_l1_data_out_right_s    : std_logic_vector(31 downto 0) := (others =>'0');

signal m_tdata_valid_out_L1_s            : std_logic := '0';
signal m_tdata_valid_in_AA              : std_logic := '0';
signal m_tdata_valid_in_AA_1            : std_logic := '0';
signal m_tdata_valid_in_AA_2            : std_logic := '0';
signal m_tdata_valid_s_int_aa_s : std_logic := '0';

signal m_tdata_valid_out_H1_s : std_logic := '0';
signal m_tdata_valid_out_int_aa_s : std_logic := '0';

signal Env_fol_out_s : std_logic_vector(16 downto 0); -- needs
signal env_out_s : std_logic_vector(16 downto 0) := (others => '0');
signal out_valid_L_s : std_logic := '0';
signal out_valid_H_s : std_logic := '0';
signal Env_fol_out_L_s : std_logic_vector(16 downto 0) := (others => '0');
signal Env_fol_out_H_s : std_logic_vector(16 downto 0) := (others => '0');
signal Env_fol_out_L_R_s : std_logic_vector(16 downto 0) := (others => '0');
signal Env_fol_out_H_R_s : std_logic_vector(16 downto 0) := (others => '0');

signal out_valid_L_R_s : std_logic := '0';
signal out_valid_H_R_s : std_logic := '0';
signal locked_s : std_logic :='0';

signal lrclk_rise_pulse_s : std_logic := '0';
signal lrclk_fall_pulse_s : std_logic := '0';
component I2S_in is
  Port (    --clk : in std_logic;
            comp_clk : in std_logic;
            reset : in std_logic;
            locked : in std_logic;
            
            lrclk_rise_pulse_t : out std_logic;
            lrclk_fall_pulse_t : out std_logic;
            
            r_sclk: out std_logic;
            r_mclk: out std_logic;
            r_lrclk: out std_logic;
            r_data: in std_logic;
            --r_data: out std_logic;--out for simulation
            
            left_valid : out std_logic;
            right_valid : out std_logic;
            left_reg_output : out std_logic_vector(23 downto 0);
            right_reg_output : out std_logic_vector(23 downto 0)
            );
end component;



component AA_filter_1 is
  Port (        clk : in std_logic;
                reset : in std_logic;
                left_valid_in : in std_logic;
                right_valid_in : in std_logic;
                left_reg_input : in std_logic_vector(23 downto 0);
                right_reg_input : in std_logic_vector(23 downto 0);
        
                out_data_left : out std_logic_vector(31 downto 0);
                out_data_right : out std_logic_vector(31 downto 0);
                m_tdata_valid_out: out std_logic
                );
end component;


-- second of 2 AA filters
component AA_filter_2 is
  Port (    clk : in std_logic;
            reset : in std_logic;
            left_valid_in : in std_logic;
            right_valid_in : in std_logic;
            m_tdata_valid_in: in std_logic;
            input_left : in std_logic_vector(31 downto 0);
            input_right : in std_logic_vector(31 downto 0);
            
            m_tdata_valid_out : out std_logic;
            out_data_left : out std_logic_vector(31 downto 0);
            out_data_right : out std_logic_vector(31 downto 0)
            );
end component;

--level 1 of tree 2 filters
component Level_1 is
  Port (
           clk : in std_logic;
           L1_input_left  : in std_logic_vector(31 downto 0);
           L1_input_right : in std_logic_vector(31 downto 0);
           left_valid_in : in std_logic;
           right_valid_in : in std_logic;
           m_tdata_valid_in : in std_logic;
           
           m_tdata_valid_out_H1 : out std_logic;
           m_tdata_valid_out_L1 : out std_logic;
           --High output
           H_L1_output_left : out std_logic_vector(31 downto 0);
           H_L1_output_right : out std_logic_vector(31 downto 0);
           --low output
           L_L1_output_left : out std_logic_vector(31 downto 0);
           L_L1_output_right : out std_logic_vector(31 downto 0)
           );
end component;

component Envlope_Follower_control_Logic is
    Port (  env_in : in std_logic_vector(17 downto 0);
            env_start: in STD_LOGIC;
            env_clk : in STD_LOGIC;
            env_rst : in STD_LOGIC;
            env_out : out std_logic_vector(16 downto 0);
            out_valid : out std_logic
             );
end component;


--component I2S_out is
--  Port (    clk : in std_logic;
--            reset : in std_logic;
--            right_reg_shift : in std_logic_vector(23 downto 0);
--            left_reg_shift : in std_logic_vector(23 downto 0);
            
--            t_sclk: in std_logic;
--            t_mclk: in std_logic;
--            t_lrclk: in std_logic;
--            t_data: out std_logic
--            );
--end component;
begin
-- assnments make these avalible to see on top level module
reset_s <= reset;
--r_sclk  <= sclk_s;
--r_mclk  <= mclk_s;
--r_lrclk <= lrclk_s;

--t_sclk  <= sclk_s;
--t_mclk  <= mclk_s;
--t_lrclk <= lrclk_s;
r_data_s <= r_data; --actual use
--r_data <= r_data_s; --simulation
--t_data <= t_data_s;
--assinments for modulator
Env_fol_out_L_L <= Env_fol_out_L_s; --  H_L1_output_left_s(23 downto 7);--Env_fol_out_L_s;
Env_fol_out_H_L <= Env_fol_out_H_s;   --L_L1_output_left_s(23 downto 7);
Env_fol_out_L_R <= Env_fol_out_L_R_s;
Env_fol_out_H_R <= Env_fol_out_H_R_s;

--    <= out_valid_L_R_s;
--    <= out_valid_H_R_s;
out_valid_l <= out_valid_L_s;
out_valid_h <= out_valid_H_s;
locked_s <= locked;
--assinments for I2S_in

----assinments for I2S_out
----left_reg_shift_c <= left_reg_output;
----right_reg_shift_c <= right_reg_output;
--I2s_o : I2S_out port map (
--    clk => clk,
--    reset => reset,
    
--    right_reg_shift => left_reg_shift_c, --for right out data  --right_reg_shift_c,
--    --passthrough_signal --left_reg_shift_c,
--    --AA_filter_signal  --fir_out_data_left_s,
--    left_reg_shift => interpolate_aa_data_out_left_s, --fir_out_data_left_s(44 downto 21), --L_L1_test_left_s,-- , --fir_out_data_left_s,   --for left out data  -- right_reg_shift_c,-- --
    
--    t_sclk => sclk_s,
--    t_mclk => mclk_s,
--    t_lrclk => lrclk_s,
--    t_data => t_data_s
--    );
I2s_i : I2S_in port map (
    --clk => raw_clk,--assined to top clk
    comp_clk => comp_clk,
    reset => reset, --assined to top reset
    locked => locked_s,
    
    r_sclk => sclk_s,
    r_mclk => mclk_s,
    r_lrclk => lrclk_s,
    r_data => r_data_s, --update in I2S in to take serial data in instead of blk_mem
    left_valid => left_valid_s,
    right_valid => right_valid_s,
    
    left_reg_output => left_reg_shift_c, --maps to FIR core inputs
    right_reg_output => right_reg_shift_c
);

AA_1: AA_filter_1 Port map (
                clk => comp_clk,
                reset => reset_s,
                left_valid_in => left_valid_s,
                right_valid_in => right_valid_s,
                left_reg_input => left_reg_shift_c,
                right_reg_input => right_reg_shift_c,
        
                out_data_left => fir_out_data_left_s,
                out_data_right => fir_out_data_right_s,
                m_tdata_valid_out => m_tdata_valid_in_AA_1
            );

--AA filter
AA_2: AA_filter_2 port map(
    clk             => comp_clk,
    reset => reset,
    left_valid_in   => left_valid_s,
    right_valid_in  => right_valid_s,
    M_tdata_valid_in => m_tdata_valid_in_AA_1,
    input_left  => fir_out_data_left_s,--this is an input to the fir core  -- data in fir core
    input_right => fir_out_data_right_s,--this is an input to the fir core
    
    m_tdata_valid_out => m_tdata_valid_in_AA_2,
    out_data_left => fir_out_data_left_2_s,
    out_data_right => fir_out_data_right_2_s
);
L1: Level_1 port map(  
           clk => comp_clk,
           L1_input_left => fir_out_data_left_2_s, -- in from AA_filter_2
           L1_input_right => fir_out_data_right_2_s, --in from AA_filter_2
           left_valid_in => left_valid_s, -- this is still valid for 96khz not anything downsampled
           right_valid_in => right_valid_s, --this is still valid for 96khz not anything downsampled
           m_tdata_valid_in => m_tdata_valid_in_AA_2,
           m_tdata_valid_out_H1 => m_tdata_valid_out_H1_s,
           m_tdata_valid_out_L1 => m_tdata_valid_out_L1_s,

           --High output
           H_L1_output_left => H_L1_output_left_s,
           H_L1_output_right => H_L1_output_right_s,
           --low output
           L_L1_output_left =>  L_L1_output_left_s, --L_L1_test_left_s, --
           L_L1_output_right => L_L1_output_right_s --L_L1_test_right_s --
           );
           
--==================
--EV follower passthrough test
--====================
EV_L_L_1: Envlope_Follower_control_Logic Port map(
            env_in => L_L1_output_left_s(26 downto 9),
            env_start => m_tdata_valid_out_L1_s,
            env_clk => comp_clk,
            env_rst => reset,
            env_out => Env_fol_out_L_s,
            out_valid => out_valid_L_s
             );

--==================
--EV follower passthrough test
--====================
EV_H_L_1: Envlope_Follower_control_Logic Port map(
            env_in => H_L1_output_left_s(26 downto 9),
            env_start => m_tdata_valid_out_H1_s,
            env_clk => comp_clk,
            env_rst => reset,
            env_out => Env_fol_out_H_s,
            out_valid => out_valid_H_s
             );
----==================
----EV follower passthrough test
----====================
--EV_L_R_1: Envlope_Follower_control_Logic Port map(
--            env_in => L_L1_output_right_s(26 downto 9),
--            env_start => m_tdata_valid_out_L1_s,
--            env_clk => comp_clk,
--            env_rst => reset,
--            env_out => Env_fol_out_L_R_s,
--            out_valid => out_valid_L_R_s
--             );

----==================
----EV follower passthrough test
----====================
--EV_H_R_1: Envlope_Follower_control_Logic Port map(
--            env_in => H_L1_output_right_s(26 downto 9),
--            env_start => m_tdata_valid_out_H1_s,
--            env_clk => comp_clk,
--            env_rst => reset,
--            env_out => Env_fol_out_H_R_s,
--            out_valid => out_valid_H_R_s
--             );          
         
end Behavioral;
