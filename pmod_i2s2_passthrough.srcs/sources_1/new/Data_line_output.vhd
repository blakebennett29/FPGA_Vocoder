----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2026 05:53:21 PM
-- Design Name: 
-- Module Name: Data_line_output - Behavioral
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

entity Data_line_output is
  Port (    raw_clk: in std_logic;
            comp_clk: in std_logic;
            reset: in std_logic;
            
            Env_fol_in : in std_logic_vector(16 downto 0);
            in_valid : in std_logic;
            
            locked : in std_logic;
            r_sclk: out std_logic;
            r_mclk: out std_logic;
            r_lrclk: out std_logic;
            r_data: in std_logic; --in for actual use
            --r_data: out std_logic;
            
            t_sclk: out std_logic;
            t_mclk: out std_logic;
            t_lrclk: out std_logic;
            t_data: out std_logic
            );
end Data_line_output;

architecture Behavioral of Data_line_output is

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
signal interpolate_aa_data_out_left_s   : std_logic_vector(31 downto 0) := (others =>'0');
signal interpolate_aa_data_out_right_s  : std_logic_vector(31 downto 0) := (others =>'0');
signal interpolate_aa_2_data_out_left_s : std_logic_vector(23 downto 0) := (others =>'0');
signal interpolate_aa_2_data_out_right_s : std_logic_vector(23 downto 0) := (others =>'0');
--data out for interpolation level 1
signal interpolate_l1_data_out_left_s     : std_logic_vector(31 downto 0) := (others =>'0');
signal interpolate_l1_data_out_right_s    : std_logic_vector(31 downto 0) := (others =>'0');

signal m_tdata_valid_out_L1_s            : std_logic := '0';
signal m_tdata_valid_in_AA_2              : std_logic := '0';
signal m_tdata_valid_in_AA_1              : std_logic := '0';
signal m_tdata_valid_s_int_aa_s : std_logic := '0';

signal m_tdata_valid_out_H1_s : std_logic := '0';
signal m_tdata_valid_out_int_aa_s : std_logic := '0';
signal m_tdata_valid_out_int_aa_2_s : std_logic := '0';
-- Modulator signail's
signal H_L1_output_left_M_s : std_logic_vector(31 downto 0);
signal H_L1_output_right_M_s : std_logic_vector(31 downto 0);
signal L_L1_output_right_M_s : std_logic_vector(31 downto 0);
signal L_L1_output_left_M_s : std_logic_vector(31 downto 0);

signal Env_fol_value_in_s : std_logic_vector(16 downto 0);
--Envlope Follower passthrough signials
signal env_in_s : std_logic_vector(17 downto 0) := (others => '0');
signal env_start_s : std_logic := '0';
signal env_clk_s : std_logic := '0';
signal env_rst_s : std_logic := '0';
signal env_out_s : std_logic_vector(16 downto 0) := (others => '0');
signal in_valid_s : std_logic := '0';
signal Mod_valid_out_s : std_logic := '0';
signal locked_s : std_logic := '0';

--component Envlope_Follower_control_Logic is
--    Port (  env_in : in std_logic_vector(17 downto 0);
--            env_start: in STD_LOGIC;
--            env_clk : in STD_LOGIC;
--            env_rst : in STD_LOGIC;
--            env_out : out std_logic_vector(17 downto 0)
--             );
--end component;

component I2S_in is
  Port (    clk : in std_logic;
            comp_clk : in std_logic;
            reset : in std_logic;
            locked : in std_logic;
            
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
  Port (            clk : in std_logic;
                    reset : in std_logic;
                    left_valid_in : in std_logic;
                    right_valid_in : in std_logic;
                    m_tdata_valid_in: in std_logic;
                    input_left : in std_logic_vector(31 downto 0);
                    input_right : in std_logic_vector(31 downto 0);
            
                    out_data_left : out std_logic_vector(31 downto 0);
                    out_data_right : out std_logic_vector(31 downto 0);
                    m_tdata_valid_out: out std_logic
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

component Modulator is
    Port (
        clk          : in  std_logic;
        reset        : in  std_logic;

        left_input_L1_H   : in  std_logic_vector(31 downto 0);
        right_input_L1_H  : in  std_logic_vector(31 downto 0);
        left_input_L1_L   : in std_logic_vector(31 downto 0);
        right_input_L1_L  : in std_logic_vector(31 downto 0);
        Env_fol_in   : in  std_logic_vector(16 downto 0);
        in_valid     : in std_logic;
        m_tvalid_in  : in  std_logic;
        
        Mod_valid_out : out std_logic;
        left_output_L1_H : out std_logic_vector(31 downto 0);
        right_output_L1_H : out std_logic_vector(31 downto 0);
        left_output_L1_L : out std_logic_vector(31 downto 0);
        right_output_L1_L : out std_logic_vector(31 downto 0)
    );
end component;



component INTERPOLATE_L1 is
 Port (
        clk              : in  std_logic;
        reset            : in  std_logic;

        -- input samples
        H_data_in_left     : in  std_logic_vector(31 downto 0);
        H_data_in_right    : in  std_logic_vector(31 downto 0);
        L_data_in_left     : in  std_logic_vector(31 downto 0);
        L_data_in_right    : in  std_logic_vector(31 downto 0);
        left_valid_in    : in  std_logic;
        right_valid_in   : in  std_logic;
        m_tdata_valid_in_L1 : in std_logic;
        m_tdata_valid_in_H1 : in std_logic;
        
        m_tdata_valid_out_int_aa : out std_logic;
        -- output samples
        data_out_left    : out std_logic_vector(31 downto 0);
        data_out_right   : out std_logic_vector(31 downto 0) );
end component;

component INTERPOLATE_AA is
  Port (
        clk              : in  std_logic;
        reset            : in  std_logic;

        -- input samples
        data_in_left     : in  std_logic_vector(31 downto 0);
        data_in_right    : in  std_logic_vector(31 downto 0);
        left_valid_in    : in  std_logic;
        right_valid_in   : in  std_logic;
        m_tdata_valid_in : in  std_logic;
        
        m_tdata_valid_out : out std_logic;
        -- output samples
        data_out_left    : out std_logic_vector(31 downto 0);
        data_out_right   : out std_logic_vector(31 downto 0)
        );
end component;

component AA_Interpolation_48khz is
  Port (        clk              : in  std_logic;
                reset            : in  std_logic;
        
                -- input samples
                data_in_left     : in  std_logic_vector(31 downto 0);
                data_in_right    : in  std_logic_vector(31 downto 0);
                left_valid_in    : in  std_logic; --remove
                right_valid_in   : in  std_logic; --remove
                m_tdata_valid_in : in std_logic;
        
                -- output samples
                data_out_left    : out std_logic_vector(23 downto 0);
                data_out_right   : out std_logic_vector(23 downto 0)
                );
end component;

component I2S_out is
  Port (    clk : in std_logic;
            reset : in std_logic;
            right_reg_shift : in std_logic_vector(23 downto 0);
            left_reg_shift : in std_logic_vector(23 downto 0);
            
            t_sclk: in std_logic;
            t_mclk: in std_logic;
            t_lrclk: in std_logic;
            t_data: out std_logic
            );
end component;

begin
-- assnments make these avalible to see on top level module
reset_s <= reset;
r_sclk  <= sclk_s;
r_mclk  <= mclk_s;
r_lrclk <= lrclk_s;

t_sclk  <= sclk_s;
t_mclk  <= mclk_s;
t_lrclk <= lrclk_s;
r_data_s <= r_data; --actual use
--r_data <= r_data_s; --simulation
t_data <= t_data_s;
in_valid_s <= in_valid;

locked_s <= locked;
--assinments for Modulator
Env_fol_value_in_s <= Env_fol_in;
--assinments for I2S_in


I2s_i : I2S_in port map (
    clk => raw_clk,--assined to top clk
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

MOD_u: Modulator Port map (
        clk   => comp_clk,       
        reset => reset_s,      
        --input data
        left_input_L1_H => H_L1_output_left_s,
        right_input_L1_H => H_L1_output_right_s,
        left_input_L1_L => L_L1_output_left_s,
        right_input_L1_L => L_L1_output_right_s,
        --modulator and valid signials
        Env_fol_in =>  Env_fol_value_in_s,
        in_valid => in_valid_s,
        m_tvalid_in => m_tdata_valid_out_H1_s,
        
        Mod_valid_out => Mod_valid_out_s,
        --output data
        left_output_L1_H => H_L1_output_left_M_s,
        right_output_L1_H => H_L1_output_right_M_s,
        left_output_L1_L => L_L1_output_left_M_s,
        right_output_L1_L => L_L1_output_right_M_s
         
    );




U_INTERPOLATE_L1 : INTERPOLATE_L1
    port map (
        clk            => comp_clk,
        reset          => reset,
        
        H_data_in_left   => H_L1_output_left_s, --H_L1_output_left_M_s, --
        H_data_in_right  => H_L1_output_right_s, --H_L1_output_right_M_s, --
        
        L_data_in_left   => L_L1_output_left_s, --L_L1_output_left_M_s, --
        L_data_in_right  => L_L1_output_right_s, --L_L1_output_right_M_s, --
        
        left_valid_in    => left_valid_s,
        right_valid_in   => right_valid_s,
        m_tdata_valid_in_L1 => Mod_valid_out_s,     --m_tdata_valid_out_L1_s, 
        m_tdata_valid_in_H1 => Mod_valid_out_s,     --m_tdata_valid_out_H1_s,
        
        m_tdata_valid_out_int_aa => m_tdata_valid_out_int_aa_s,
        data_out_left    => interpolate_l1_data_out_left_s,
        data_out_right   => interpolate_l1_data_out_right_s
    );
    
U_INTERPOLATE_AA : INTERPOLATE_AA
port map (
    clk            => comp_clk,
    reset          => reset,

    data_in_left   => interpolate_l1_data_out_left_s, --data from AA filter
    data_in_right  => interpolate_l1_data_out_right_s, --data from AA filter
    left_valid_in  => left_valid_s,
    right_valid_in => right_valid_s,
    
    m_tdata_valid_in => m_tdata_valid_out_int_aa_s,
    
    m_tdata_valid_out => m_tdata_valid_out_int_aa_2_s,
    data_out_left  => interpolate_aa_data_out_left_s,
    data_out_right => interpolate_aa_data_out_right_s
); 

U_INTERPOLATE_AA_2 : AA_interpolation_48khz
port map (
    clk            => comp_clk,
    reset          => reset,

    data_in_left   => interpolate_aa_data_out_left_s, --data from AA filter
    data_in_right  => interpolate_aa_data_out_right_s, --data from AA filter
    left_valid_in  => left_valid_s,
    right_valid_in => right_valid_s,
    
    m_tdata_valid_in => m_tdata_valid_out_int_aa_2_s,
    
    
    data_out_left  => interpolate_aa_2_data_out_left_s,
    data_out_right => interpolate_aa_2_data_out_right_s
); 
--assinments for I2S_out
--left_reg_shift_c <= left_reg_output;
--right_reg_shift_c <= right_reg_output;
I2s_o : I2S_out port map (
    clk => comp_clk,
    reset => reset,
    
    right_reg_shift => interpolate_aa_2_data_out_right_s, --for right out data  --right_reg_shift_c,
    --passthrough_signal --left_reg_shift_c,
    --AA_filter_signal  --fir_out_data_left_s,
    left_reg_shift => interpolate_aa_2_data_out_left_s,--interpolate_aa_2_data_out_left_s, --env_out_s(17 downto 0) & "000000",--interpolate_aa_data_out_left_s, --fir_out_data_left_s(44 downto 21), --L_L1_test_left_s,-- , --fir_out_data_left_s,   --for left out data  -- right_reg_shift_c,-- --
    
    t_sclk => sclk_s,
    t_mclk => mclk_s,
    t_lrclk => lrclk_s,
    t_data => t_data_s
    );


end Behavioral;
