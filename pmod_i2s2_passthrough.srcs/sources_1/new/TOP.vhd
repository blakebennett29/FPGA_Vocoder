----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2026 03:21:23 PM
-- Design Name: 
-- Module Name: TOP - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
  Port (    clk: in std_logic;
            reset: in std_logic;
              
            r_sclk: out std_logic;
            r_mclk: out std_logic;
            r_lrclk: out std_logic;
            --r_data: in std_logic; --in for actual use
            r_data: in std_logic;
            
            t_sclk: out std_logic;
            t_mclk: out std_logic;
            t_lrclk: out std_logic;
            t_data: out std_logic
            );
end TOP;

architecture Behavioral of TOP is
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
signal fir_out_data_right_s : std_logic_vector(23 downto 0);
signal fir_out_data_left_s : std_logic_vector(23 downto 0);
signal left_valid_s : std_logic := '0';
signal right_valid_s : std_logic := '0';


component I2S_in is
  Port (    clk : in std_logic;
            reset : in std_logic;
            
            r_sclk: out std_logic;
            r_mclk: out std_logic;
            r_lrclk: out std_logic;
            --r_data: in std_logic;
            r_data: in std_logic;--out for simulation
            
            left_valid : out std_logic;
            right_valid : out std_logic;
            left_reg_output : out std_logic_vector(23 downto 0);
            right_reg_output : out std_logic_vector(23 downto 0)
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

component FIR is
  Port (    clk : in std_logic;
            left_valid_in : in std_logic;
            right_valid_in : in std_logic;
            left_reg_input : in std_logic_vector(23 downto 0);
            right_reg_input : in std_logic_vector(23 downto 0);
            
            out_data_left : out std_logic_vector(23 downto 0);
            out_data_right : out std_logic_vector(23 downto 0)
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
--assinments for I2S_in

--assinments for I2S_out
--left_reg_shift_c <= left_reg_output;
--right_reg_shift_c <= right_reg_output;
I2s_o : I2S_out port map (
    clk => clk,
    reset => reset_s,
    right_reg_shift => left_reg_shift_c, --for right out data  --right_reg_shift_c,
    left_reg_shift => fir_out_data_left_s,  --left_reg_shift_c, --for left out data  
    
    t_sclk => sclk_s,
    t_mclk => mclk_s,
    t_lrclk => lrclk_s,
    t_data => t_data_s
    );
I2s_i : I2S_in port map (
    clk => clk,--assined to top clk
    reset => reset, --assined to top reset
    
    r_sclk => sclk_s,
    r_mclk => mclk_s,
    r_lrclk => lrclk_s,
    r_data => r_data_s, --update in I2S in to take serial data in instead of blk_mem
    left_valid => left_valid_s,
    right_valid => right_valid_s,
    
    left_reg_output => left_reg_shift_c, --maps to FIR core inputs
    right_reg_output => right_reg_shift_c
);

FIR_0: FIR port map(
    clk             => clk,
    left_valid_in   => left_valid_s,
    right_valid_in  => right_valid_s,
    left_reg_input  => left_reg_shift_c,--this is an input to the fir core  -- data in fir core
    right_reg_input => right_reg_shift_c,--this is an input to the fir core

    out_data_left => fir_out_data_left_s,
    out_data_right => fir_out_data_right_s
);
end Behavioral;
