----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/09/2026 11:03:56 PM
-- Design Name: 
-- Module Name: DAC_Pmod - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity I2S_in is
  Port (    clk : in std_logic;
            reset : in std_logic;
            
            r_sclk: out std_logic;
            r_mclk: out std_logic;
            r_lrclk: out std_logic;
            r_data: in std_logic; --out for simulation
            
            
            left_reg_output : out std_logic_vector(23 downto 0);
            right_reg_output : out std_logic_vector(23 downto 0);
            left_valid : out std_logic;
            right_valid : out std_logic
            );
end I2S_in;

architecture Behavioral of I2S_in is
component blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END component;



signal mcnt : integer := 0;
signal scnt : integer :=0;
signal lrcnt : integer :=0;
signal mclk_s : std_logic := '0';
signal sclk_s : std_logic := '0';
signal lrclk_s : std_logic :='0';
signal reset_s : std_logic := '0';
--blk memory signials
signal ena_s : std_logic := '1';
signal wea_s : std_logic_vector(0 downto 0) := "0";
signal addra_s : std_logic_vector(4 downto 0) :="00000";
signal dina_s : std_logic_vector(31 downto 0) := x"00000000";
signal douta_s : std_logic_vector(31 downto 0) := (others => '0');
--shift register data
signal shift_Reg_load: std_logic_vector(31 downto 0) := (others => '0');
signal shift_cnt : integer := 0;
signal shift_cnt_out : integer := 0;
signal address : integer :=0;
signal sclk_fall_pulse : std_logic := '0';
signal lrclk_fall_pulse : std_logic := '0';
signal lrclk_rise_pulse : std_logic := '0';

-- additional registers for reciver side
signal right_reg : std_logic_vector(31 downto 0) := (others =>'0');
signal left_reg : std_logic_vector(31 downto 0) := (others =>'0');
signal right_reg_output_s : std_logic_vector(31 downto 0) := (others =>'0');--hold for sample period
signal left_reg_output_s : std_logic_vector(31 downto 0) := (others =>'0');--hold for sample period
signal left_reg_shift_c : std_logic_vector(23 downto 0) := (others =>'0');--shift to output dac
signal right_reg_shift_c : std_logic_vector(23 downto 0) := (others =>'0');-- shift to ouput dac
-- state machine for l and R channel output
type LR_State is (Idle, Right, Left);
signal state, next_state : LR_State;

signal left_valid_s : std_logic;
signal right_valid_s : std_logic;
begin

BM1 : blk_mem_gen_0 port map (
    clka => clk,
    ena => ena_s,
    wea => wea_s,
    addra => addra_s,
    dina => dina_s,
    douta => douta_s
    );
   

    
   --reciver clks
    r_mclk <= mclk_s;
    r_sclk <= sclk_s;
    r_lrclk <= lrclk_s;
    reset_s <= reset;
    --output registers left and right
    left_reg_output <= left_reg_output_s(30 downto 7);
    right_reg_output <= right_reg_output_s(30 downto 7);
    --assined for testing i2s out module with only i2s in at top module
    left_reg_shift_c <= left_reg_output_s(30 downto 7);
    right_reg_shift_c <= right_reg_output_s(30 downto 7);
    
    
    process(clk)
        begin
            if reset = '1' then
                mcnt <= 0;
                scnt <= 0;
                lrcnt <= 0;
                mclk_s  <= '0';
                sclk_s  <= '0';
                lrclk_s <= '0';
                reset_s <= '0';
                shift_Reg_load <= (others => '0');
                shift_cnt <= 0;
                state <= Idle;
                next_state <= Idle;
                left_valid_s <= '0';
                right_valid_s <= '0';
            elsif rising_edge(clk) then 
                state <= next_state; -- continue if reset isn't high
            --------------------------------------------------------------------
            --master clk generation
                if mcnt >= 1 then   --creating that 25mhz clk (divide the clk by 4)
                    mcnt <= 0;
                    mclk_s <= not mclk_s; --toggle the clk
                else
                    mcnt <= mcnt + 1;
                end if;
                --------------------------------------------------------------------
                --sclk generation
                if scnt >= 7 then
                    scnt <= 0;
                     -- detect the *falling* edge (about to go low 1 -> 0)
                    if sclk_s = '1' then
                        sclk_fall_pulse <= '1';
                    end if;
                    sclk_s <= not sclk_s;
                else
                    scnt <= scnt + 1;
                end if;
                --------------------------------------------------------------------
                --lrclk generation
                if lrcnt >= 511 then
                    lrcnt <= 0;
                    --not nessisary code------------
                    
                    if lrclk_s = '0' then   --lr edge detection "rising"
                        lrclk_rise_pulse <= '1';
                    end if;
                    if lrclk_s = '1' then --"falling" edge detection
                        lrclk_fall_pulse <= '1';
                    end if;
                    
                    --block above not nessassary -------------
                    lrclk_s <= not lrclk_s;
                else
                    lrcnt <= lrcnt + 1;
                end if;
                ---------------------------------------------------------------------
                --Shift register logic
                if reset = '1' then -- could probably move this with the other reset
                    shift_Reg_load <= (others => '0');
                    shift_cnt <= 0;
                    
                elsif shift_cnt >= 32 then 
                    ena_s <= '1';
                    shift_cnt <= 0;
                    --===========================================
                    -- comment out for actual use
                    --===========================================
                    address <= address + 1;
                    addra_s <= std_logic_vector(to_unsigned(address, 5));
                    shift_Reg_load <= douta_s; --assine new sample to register
                    if address >= 32 then  -- loop the block memory for output
                        address <= 0;
                    end if;
                    --===============
                    --end of comment(actual use)
                    --===============
                    
                    if lrclk_s = '1' then --shifting in right sample
                        left_reg_output_s <= left_reg;
                    end if;
                    
                    if lrclk_s = '0' then
                        right_reg_output_s <= right_reg;
                    end if;
                    -- added for fir samples 
                    
                    
                    
                    --new code-------------------------------------------------------------
                    
                else
--                    case state is
--                        when Idle =>
--                            if lrclk_s = '0' then
--                                next_state <= Right;
--                            else if lrclk_s = '1' then
--                                next_state <= left;
--                            end if;
--                            end if;
                            
--                        when Right =>
--                            if lrclk_s = '0' then
--                                if sclk_fall_pulse = '1' then 
--                                    sclk_fall_pulse <= '0';
--                                    r_data <= right_reg_shift(31 - shift_cnt);
--                                    shift_cnt <= shift_cnt +1;
--                                end if;
--                            end if;
--                            if lrclk_s = '1' then
--                                next_state <= Left;
--                            else
--                                next_state <= Right;
--                            end if;
--                        when Left =>
--                            if lrclk_s = '1' then
--                                if sclk_fall_pulse = '1' then 
--                                    sclk_fall_pulse <= '0';
--                                    r_data <= left_reg_shift(31 - shift_cnt);
--                                    shift_cnt <= shift_cnt +1;
--                                end if;
--                            end if;
--                            if lrclk_s = '0' then
--                                next_state <= Right;
--                            else
--                                next_state <= Left;
--                            end if;
                            
                            
                end if;
                --below changes lrclk rise pulse and fall to one system clk cycle
                if lrclk_rise_pulse = '1' then
                    lrclk_rise_pulse <='0';
                    right_valid <= '0';
                    left_valid <= '1';
                    
                    --right_reg_shift <= right_reg_output_s;-- assinment to hold for an extra 32 sclk
                elsif lrclk_fall_pulse = '1' then
                    left_valid <= '0';
                    right_valid <= '1';
                    lrclk_fall_pulse <='0';
                    --left_reg_shift <= left_reg_output_s; -- assinment to hold for an extra 32 sclk
                else
                    right_valid <= '0';
                    left_valid <= '0';
                end if; 
                
                
                
--                    end case;
                    -- end of new code -----------------------------------------------------------------------------
                --shift data bit's out (in is how I am looking at it while programing the dac)
                if sclk_fall_pulse = '1' then 
                    sclk_fall_pulse <= '0';
                    --r_data <= shift_Reg_load(31 - shift_cnt);--comment out for actual data
                    shift_cnt <= shift_cnt +1;
                    --add data_in register to hold data
                    if lrclk_s = '0' then
                        left_reg(31 - shift_cnt) <= r_data; -- shift_Reg_load(31 - shift_cnt); -- 
                    elsif lrclk_s = '1' then
                        right_reg(31 - shift_cnt) <= r_data; -- shift_Reg_load(31 - shift_cnt); --
                    else
                        null;
                    end if;
                end if;                                 
                --end if;
                
            end if;
            --end if; -- idk where this was missed
    end process;
    end behavioral;