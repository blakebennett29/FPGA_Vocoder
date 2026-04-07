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
library UNISIM;
use UNISIM.VComponents.all;

entity TOP is
  Port (    clk: in std_logic;
            reset: in std_logic;
              
            adc1_r_sclk: out std_logic;
            adc1_r_mclk: out std_logic;
            adc1_r_lrclk: out std_logic;
            adc1_r_data: in std_logic;
            
            adc2_r_sclk: out std_logic;
            adc2_r_mclk: out std_logic;
            adc2_r_lrclk: out std_logic;
            adc2_r_data: in std_logic; 
            
            dac1_t_sclk: out std_logic;
            dac1_t_mclk: out std_logic;
            dac1_t_lrclk: out std_logic;
            dac1_t_data: out std_logic;
            
            dac2_t_sclk: out std_logic;
            dac2_t_mclk: out std_logic;
            dac2_t_lrclk: out std_logic;
            dac2_t_data: out std_logic;
            
            dac3_t_sclk: out std_logic;
            dac3_t_mclk: out std_logic;
            dac3_t_lrclk: out std_logic;
            dac3_t_data: out std_logic
            );
end TOP;

architecture Behavioral of TOP is

-------------------------------------------------------------------
--   ____ ___  __  __ ____   ___  _   _ _____ _   _ _____ ____   --
--  / ___/ _ \|  \/  |  _ \ / _ \| \ | | ____| \ | |_   _/ ___|  --
-- | |  | | | | |\/| | |_) | | | |  \| |  _| |  \| | | | \___ \  -- 
-- | |__| |_| | |  | |  __/| |_| | |\  | |___| |\  | | |  ___) | --
--  \____\___/|_|  |_|_|    \___/|_| \_|_____|_| \_| |_| |____/  --
-------------------------------------------------------------------  
--===============================================================--                                                                                                                                                                                                        

component clk_wiz_0 is
  Port ( 
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );
end component clk_wiz_0;

component Data_line_output is
    Port (
        raw_clk : in std_logic;
        comp_clk      : in  std_logic;
        reset    : in  std_logic;
        
        Env_fol_in : in std_logic_vector(16 downto 0);
        in_valid : in std_logic;
        
        locked : in std_logic;
        r_sclk   : out std_logic;
        r_mclk   : out std_logic;
        r_lrclk  : out std_logic;
        r_data   : in  std_logic;
        --r_data : out std_logic;
        
        t_sclk   : out std_logic;
        t_mclk   : out std_logic;
        t_lrclk  : out std_logic;
        t_data   : out std_logic
    );
end component;

component Half_Data_line_Env_fol is
    Port (
        raw_clk : in std_logic;
        comp_clk      : in  std_logic;
        reset    : in  std_logic;
        locked : in std_logic;
        
        Env_fol_out : out std_logic_vector(16 downto 0);
        out_valid : out std_logic;
        
        r_sclk   : out std_logic;
        r_mclk   : out std_logic;
        r_lrclk  : out std_logic;
        r_data   : in  std_logic;
        --r_data : out std_logic;
        
        t_sclk   : out std_logic;
        t_mclk   : out std_logic;
        t_lrclk  : out std_logic;
        t_data   : out std_logic
    );
end component;

----------------------------------------------
--  ____ ___ ____ _   _    _    _     ____  --
-- / ___|_ _/ ___| \ | |  / \  | |   / ___| --
-- \___ \| | |  _|  \| | / _ \ | |   \___ \ --
--  ___) | | |_| | |\  |/ ___ \| |___ ___) |--
-- |____/___\____|_| \_/_/   \_\_____|____/ --
----------------------------------------------                                    
--===============================================================--
--MAIN CLK AND RST
-------------------------------------------------------------------
signal raw_clk_s : std_logic;
signal main_rst : std_logic := '0';
signal locked_s: std_logic := '0';
signal comp_clk_s: std_logic;
-------------------------------------------------------------------
--DATA SIGNALS
-------------------------------------------------------------------
type slv_array_r is array (0 to 1) of std_logic_vector(23 downto 0);
signal left_reg_shift_c  : slv_array_r;
signal right_reg_shift_c : slv_array_r;

-- Intermediate signals for DAC input selection
type slv_array_t is array (0 to 2) of std_logic_vector(23 downto 0);
signal dac_right_input : slv_array_t;
signal dac_left_input  : slv_array_t;

signal Env_fol_out_S : std_logic_vector(16 downto 0);
signal out_valid_s : std_logic := '0';
signal in_valid_s : std_logic := '0';
-------------------------------------------------------------------
-- ADC SIGNALS
-------------------------------------------------------------------
signal adc_sclk_s        : std_logic_vector(1 downto 0);
signal adc_mclk_s        : std_logic_vector(1 downto 0);
signal adc_lrclk_s       : std_logic_vector(1 downto 0);
signal adc_r_data_s      : std_logic_vector(1 downto 0);
signal adc_left_valid_s  : std_logic_vector(1 downto 0);
signal adc_right_valid_s : std_logic_vector(1 downto 0);
-------------------------------------------------------------------
-- DAC SIGNALS
-------------------------------------------------------------------
signal out_data_s : std_logic;

----------------------------------------------------------
--  ____   ___  ____ _____   __  __    _    ____  ____  --
-- |  _ \ / _ \|  _ \_   _| |  \/  |  / \  |  _ \/ ___| --
-- | |_) | | | | |_) || |   | |\/| | / _ \ | |_) \___ \ --
-- |  __/| |_| |  _ < | |   | |  | |/ ___ \|  __/ ___) |--
-- |_|    \___/|_| \_\|_|   |_|  |_/_/   \_\_|   |____/ --
----------------------------------------------------------    
--===============================================================--
begin 
----------  ==============  ----------                                             
----------  | TOP MODULE |  ----------
----------  ==============  ----------
main_rst <= reset;

adc1_r_sclk <= adc_sclk_s(0);
adc1_r_mclk <= adc_mclk_s(0);
adc1_r_lrclk <= adc_lrclk_s(0);
adc_r_data_s(0) <= adc1_r_data;

adc2_r_sclk <= adc_sclk_s(0);
adc2_r_mclk <= adc_mclk_s(0);
adc2_r_lrclk <= adc_lrclk_s(0);
adc_r_data_s(1) <= adc2_r_data;

--dac1_t_sclk <= adc_sclk_s(0);
--dac1_t_mclk <= adc_mclk_s(0);
--dac1_t_lrclk <= adc_lrclk_s(0);
--dac1_t_data <= out_data_s;

dac2_t_sclk <= adc_sclk_s(0);
dac2_t_mclk <= adc_mclk_s(0);
dac2_t_lrclk <= adc_lrclk_s(0);
dac2_t_data <= out_data_s;

--dac3_t_sclk <= adc_sclk_s(0);
--dac3_t_mclk <= adc_mclk_s(0);
--dac3_t_lrclk <= adc_lrclk_s(0);
--dac3_t_data <= out_data_s;

--out_valid_s <= out_valid;

--in_valid <= in_valid_s;
----------  ============= ----------                                           
----------  | CLOCKING  | ----------
----------  ============= ----------
-- Input clock buffer
clk_ibufg_inst : IBUFG
    port map (
        I => clk,
        O => raw_clk_s
    );

----------  ================= ----------                                           
----------  | ADC I2S BUSES | ----------
----------  ================= ----------

COMPUTATION_CLOCK: clk_wiz_0
  port map (
    clk_out1 => comp_clk_S,
    reset => main_rst,
    locked => locked_s,
    clk_in1 => raw_clk_s
  );
  
U_Data_line_output : Data_line_output
    port map (
        raw_clk  => raw_clk_s,
        comp_clk => comp_clk_s,
        reset    => main_rst,
        locked => locked_s,
        
        Env_fol_in => Env_fol_out_s,
        in_valid => in_valid_s,
        
        r_sclk   => adc_sclk_s(0),
        r_mclk   => adc_mclk_s(0),
        r_lrclk  => adc_lrclk_s(0),
        r_data   => adc_r_data_s(0),

--        t_sclk   => sclk_s,
--        t_mclk   => mclk_s,
--        t_lrclk  => lrclk_s,
        t_data   => out_data_s
    );

U_Half_Data_line_Env_fol : Half_Data_line_Env_fol
    port map (
        raw_clk => raw_clk_s,
        comp_clk => comp_clk_s,
        reset    => main_rst,
        locked => locked_s,
        
        Env_fol_out => Env_fol_out_s,
        out_valid => in_valid_s,
        
--        r_sclk   => adc_sclk_s(0),
--        r_mclk   => adc_mclk_s(0),
--        r_lrclk  => adc_lrclk_s(0),
        r_data   => adc_r_data_s(1)

--            t_sclk   => sclk_s,
--            t_mclk   => mclk_s,
--            t_lrclk  => lrclk_s,
--            t_data   => t_data_s
    );

end Behavioral;
