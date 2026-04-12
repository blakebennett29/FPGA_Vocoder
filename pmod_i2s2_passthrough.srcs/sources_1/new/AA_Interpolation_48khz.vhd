----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2026 05:12:02 PM
-- Design Name: 
-- Module Name: AA_Interpolation_48khz - Behavioral
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

entity AA_Interpolation_48khz is
  Port (        clk              : in  std_logic;
                reset            : in  std_logic;
        
                -- input samples
                data_in_left     : in  std_logic_vector(31 downto 0);
                data_in_right    : in  std_logic_vector(31 downto 0);
                left_valid_in    : in  std_logic; --remove
                right_valid_in   : in  std_logic; --remove
                m_tdata_valid_in : in std_logic;
                
                
                M_tdata_valid_out_R : out std_logic;
                M_tdata_valid_out_L : out std_logic;
                -- output samples
                data_out_left    : out std_logic_vector(23 downto 0);
                data_out_right   : out std_logic_vector(23 downto 0)
                );
end AA_Interpolation_48khz;

architecture Behavioral of AA_Interpolation_48khz is

-- signals for fir_compiler_0 port map and logic
signal    aclk_s :  STD_LOGIC := '0';
signal    s_axis_data_tvalid_s :  STD_LOGIC := '0';
signal    s_axis_data_tready_s :  STD_LOGIC := '1';
signal    s_axis_data_tdata_s :  STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
signal    m_axis_data_tvalid_s :  STD_LOGIC := '0';
signal    m_axis_data_tdata_s :  STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
signal    s_axis_data_tuser_s : std_logic_vector(0 downto 0) := "0";
signal    m_axis_data_tuser_s : std_logic_vector(0 downto 0) := "0";

signal    m_tdata_valid_in_s : std_logic := '0';
signal    left_valid_cnt : integer := 0;
signal    right_valid_cnt : integer := 0;

signal    out_data_L_s : std_logic_vector(23 downto 0) := (others => '0');
signal    out_data_R_s : std_logic_vector(23 downto 0) := (others => '0');

signal    data_in_left_s : std_logic_vector(31 downto 0) := (others => '0');
signal    data_in_right_s : std_logic_vector(31 downto 0) := (others => '0');

component fir_compiler_3 IS
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_data_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axis_data_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END component;

begin
AA_fir_up_sample_2: fir_compiler_3 port map (
    aclk               => clk,
    s_axis_data_tvalid  => s_axis_data_tvalid_s,
    s_axis_data_tready  => s_axis_data_tready_s,
    s_axis_data_tdata   => s_axis_data_tdata_s,
    m_axis_data_tvalid  => m_axis_data_tvalid_s,
    m_axis_data_tdata   => m_axis_data_tdata_s,
    s_axis_data_tuser => s_axis_data_tuser_s,
    m_axis_data_tuser => m_axis_data_tuser_s
);

m_tdata_valid_in_s <= m_tdata_valid_in;
data_out_left <= out_data_L_s;
data_out_right <= out_data_R_s;

data_in_right_s <= data_in_right;
data_in_left_s <= data_in_left;

process(clk)
        begin
            if rising_edge(clk) then
                -- if input channels are valid always valid for single channel every 511 aclk cycles
                -- default: no new input unless we successfully handshake
                --if s_axis_data_tvalid_s = '1' then
                  -- if we were holding a sample, only drop tvalid after handshake
                  --if s_axis_data_tready_s = '1' then
              if s_axis_data_tvalid_s = '1' then
                    if s_axis_data_tready_s = '1' then
                    --hold s_axis_data_tvalid_s high for two clk cycles
                        s_axis_data_tvalid_s <= '0';
                        if s_axis_data_tuser_s = "0" then
                            s_axis_data_tuser_s <= "1";
                            s_axis_data_tdata_s  <= data_in_left;
                        elsif s_axis_data_tuser_s = "1" then
                            s_axis_data_tdata_s  <= data_in_right;
                            s_axis_data_tuser_s <= "0";
                        end if;
                        --s_axis_data_tvalid_s <= '1';
                    elsif s_axis_data_tready_s = '0' then
                        s_axis_data_tvalid_s <= '0';
                    end if;
                  --end if;
              elsif s_axis_data_tvalid_s = '0' then
                    if m_tdata_valid_in_s = '1' then
                        s_axis_data_tvalid_s <= '1';
                    
                    end if;
              end if;
                -- load a new sample only if we're not currently holding one
--                if s_axis_data_tvalid_s = '1' then
----                    if m_tdata_valid_in_s = '1' then
--                        if m_tdata_valid_in_s = '1' then
--                            s_axis_data_tdata_s  <= data_in_left;
--                            s_axis_data_tuser_s  <= "1";  -- or "0", just be consistent
--                            s_axis_data_tvalid_s <= '1';
--                        elsif m_tdata_valid_in_s = '0' then
--                            s_axis_data_tdata_s  <= data_in_right;
--                            s_axis_data_tuser_s  <= "0";
--                            s_axis_data_tvalid_s <= '1';
--                        end if;
--  --                  end if;
--                end if;
                
                -- OUTPUT: use the OUTPUT tag (NOT s_axis tag)
                if (m_axis_data_tvalid_s = '1') and (m_axis_data_tuser_s = "1") then
                    out_data_l_s <= m_axis_data_tdata_s(23 downto 0);--data out
                    M_tdata_valid_out_L <= '1';
                else
                    M_tdata_valid_out_L <= '0';
                end if;
                if(m_axis_data_tvalid_s = '1') and (m_axis_data_tuser_s = "0") then
                    out_data_R_s <= m_axis_data_tdata_s(31 downto 8); --data out 24 downto 1
                    M_tdata_valid_out_R <= '1';
                else
                    M_tdata_valid_out_R <= '0';
                    
                end if;
                -- end of input channel check
            end if;
    end process;
end Behavioral;
