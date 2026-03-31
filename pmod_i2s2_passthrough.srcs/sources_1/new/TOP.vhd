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

use IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.ALL;
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
            --=======================
            --PMod 1 on jA
            --========================
            r_sclk: out std_logic;
            r_mclk: out std_logic;
            r_lrclk: out std_logic;
            r_data: in std_logic; --in for actual use
            --r_data: out std_logic;
            
            t_sclk: out std_logic;
            t_mclk: out std_logic;
            t_lrclk: out std_logic;
            t_data: out std_logic;
            --======================
            --PMod 2 on JB (modulation input)
            --======================
            r2_sclk: out std_logic;
            r2_mclk: out std_logic;
            r2_lrclk: out std_logic;
            r2_data: in std_logic --in for actual use
            --r_data: out std_logic;
            
--            t2_sclk: out std_logic;
--            t2_mclk: out std_logic;
--            t2_lrclk: out std_logic;
--            t2_data: out std_logic;
            );
end TOP;

architecture Behavioral of TOP is
--data for ouput channel
    signal r_data_s  : std_logic := '0';
    signal t_data_s  : std_logic := '0';
    
    signal mclk_s    : std_logic := '0';
    signal sclk_s    : std_logic := '0';
    signal lrclk_s   : std_logic := '0';
    signal reset_s   : std_logic := '0';
--data for env fol channel
    signal r2_data_s : std_logic :='0';
    signal r2_sclk_s:  std_logic := '0';
    signal r2_mclk_s:  std_logic := '0';
    signal  r2_lrclk_s:  std_logic := '0';
    
    signal Env_fol_out_s : sfixed(0 downto -18);
component Data_line_output is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        
        Env_fol_in : in sfixed(0 downto -18);

        r_sclk   : out std_logic;
        r_mclk   : out std_logic;
        r_lrclk  : out std_logic;
        r_data   : in  std_logic;

        t_sclk   : out std_logic;
        t_mclk   : out std_logic;
        t_lrclk  : out std_logic;
        t_data   : out std_logic
    );
end component;

component Half_Data_line_Env_fol is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        
        Env_fol_out : out sfixed(0 downto -18);
        
        r_sclk   : out std_logic;
        r_mclk   : out std_logic;
        r_lrclk  : out std_logic;
        r_data   : in  std_logic;

        t_sclk   : out std_logic;
        t_mclk   : out std_logic;
        t_lrclk  : out std_logic;
        t_data   : out std_logic
    );
end component;

begin
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

r2_sclk <= sclk_s;
r2_mclk <= mclk_s;
r2_lrclk <= lrclk_s;
r2_data_s <= r2_data;

    U_Data_line_output : Data_line_output
        port map (
            clk      => clk,
            reset    => reset_s,
            
            Env_fol_in => Env_fol_out_s,

            r_sclk   => sclk_s,
            r_mclk   => mclk_s,
            r_lrclk  => lrclk_s,
            r_data   => r_data_s,

            t_sclk   => sclk_s,
            t_mclk   => mclk_s,
            t_lrclk  => lrclk_s,
            t_data   => t_data_s
        );

    U_Half_Data_line_Env_fol : Half_Data_line_Env_fol
        port map (
            clk      => clk,
            reset    => reset_s,

            Env_fol_out => Env_fol_out_s,
            r_sclk   => open,
            r_mclk   => open,
            r_lrclk  => open,
            r_data   => r2_data_s

--            t_sclk   => sclk_s,
--            t_mclk   => mclk_s,
--            t_lrclk  => lrclk_s,
--            t_data   => t_data_s
        );




end Behavioral;
