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
entity I2S_out is
  Port (    clk : in std_logic;
            reset : in std_logic;
            locked : in std_logic;
            M_tdata_valid_in_R : in std_logic;
            M_tdata_valid_in_L : in std_logic;
            right_reg_shift : in std_logic_vector(23 downto 0);
            left_reg_shift : in std_logic_vector(23 downto 0);
            
            lrclk_rise_pulse_t : in std_logic := '0';
            lrclk_fall_pulse_t : in std_logic := '0';           
            sclk_fall_pulse_t : in std_logic := '0';
            t_sclk: in std_logic;
            t_mclk: in std_logic;
            t_lrclk: in std_logic;
            t_data: out std_logic
            );
end I2S_out;

architecture Behavioral of I2S_out is


signal mcnt : integer := 0;
signal scnt : integer :=0;
signal lrcnt : integer :=0;
signal mclk_ss : std_logic := '0';
signal sclk_ss : std_logic := '0';
signal lrclk_ss : std_logic :='0';
signal reset_s : std_logic := '0';
--blk memory signials

--shift register data
signal shift_Reg_load: std_logic_vector(31 downto 0) := (others => '0');
signal shift_cnt : integer := 0;
signal shift_cnt_out : integer := 0;
signal sclk_fall_pulse : std_logic := '0';
signal lrclk_fall_pulse_s : std_logic := '0';
signal lrclk_rise_pulse_s : std_logic := '0';

-- additional registers for reciver side
signal right_reg : std_logic_vector(31 downto 0) := (others =>'0');
signal left_reg : std_logic_vector(31 downto 0) := (others =>'0');

signal left_reg_shift_s : std_logic_vector(31 downto 0) := (others =>'0');--shift to output dac
signal right_reg_shift_s : std_logic_vector(31 downto 0) := (others =>'0');-- shift to ouput dac
-- state machine for l and R channel output
type LR_State is (Idle, Right, Left);
signal state, next_state : LR_State;

signal right_reg_shift_t : std_logic_vector(31 downto 0) := (others =>'0');
signal left_reg_shift_t : std_logic_vector(31 downto 0) := (others =>'0');
signal t_data_s : std_logic := '0';
signal sclk_rise_pulse : std_logic := '0';
signal test_register_shift_t : std_logic_vector(31 downto 0) := (others =>'0');
signal wait_first_bit : std_logic := '0';

-- sample holding buffers loaded from valid signals
signal left_buf  : std_logic_vector(31 downto 0) := (others => '0');
signal right_buf : std_logic_vector(31 downto 0) := (others => '0');
signal left_buf_lrclk  : std_logic_vector(31 downto 0) := (others => '0');
signal right_buf_lrclk : std_logic_vector(31 downto 0) := (others => '0');
signal sclk_fall_pulse_s : std_logic := '0';
begin

--transmitter clks (all counting off of source clk 100mhz)
    reset_s <= reset;
    mclk_ss <= t_mclk;
    sclk_ss <= t_sclk;
    lrclk_ss <= t_lrclk;
    t_data <= t_data_s;

    right_reg_shift_s <= right_reg_shift(23 downto 0) & (7 downto 0 => '0');
    left_reg_shift_s <= left_reg_shift(23 downto 0) & (7 downto 0 => '0');
    
    lrclk_rise_pulse_s <= lrclk_rise_pulse_t;
    lrclk_fall_pulse_s <= lrclk_fall_pulse_t;
    sclk_fall_pulse_s <= sclk_fall_pulse_t;
    process(clk)
        begin
           if reset_s = '1' then
                mcnt <= 0;
                scnt <= 0;
                lrcnt <= 0;
                right_reg_shift_t <= (others => '0');
                left_reg_shift_t <= (others => '0');
                sclk_fall_pulse <= '0';
--                mclk_ss  <= '0';
--                sclk_ss  <= '0';
--                lrclk_ss <= '0';
                shift_Reg_load <= (others => '0');
                shift_cnt <= 0;
                state <= Idle;
                next_state <= Idle;
            elsif rising_edge(clk) and (locked = '1') then 
                state <= next_state; -- continue if reset isn't high
                sclk_fall_pulse <= '0';
                --lrclk_fall_pulse_s <= '0';
                --lrclk_rise_pulse_s <= '0';
--            --------------------------------------------------------------------
--            --master clk generation
--                if mcnt >= 1 then   --creating that 25mhz clk (divide the clk by 4)
--                    mcnt <= 0;
--                    mclk_s <= not mclk_s; --toggle the clk
--                else
--                    mcnt <= mcnt + 1;
--                end if;
                ------------------------------------------------------------------
                --sclk generation
--                if scnt >= 3 then
--                    scnt <= 0;
                     -- detect the *falling* edge (about to go low 1 -> 0)
                    if sclk_ss = '1' then
                        sclk_fall_pulse <= '1';
                    end if;
                    if sclk_ss = '0' then
                        sclk_rise_pulse <= '1';
                    end if;
                    --sclk_s <= not sclk_s;
--                else
--                    scnt <= scnt + 1;
--                end if;
                ------------------------------------------------------------------
                --lrclk generation
--                if lrcnt >= 255 then
--                    lrcnt <= 0;
                    --not nessisary code------------
                    if lrclk_rise_pulse_s = '1' then   --lr edge detection "rising"
                        --lrclk_rise_pulse_s <= '1';
                        wait_first_bit <= '1';
                        shift_cnt <= 0;
                    end if;
                    if lrclk_fall_pulse_s = '1' then --"falling" edge detection
                       -- lrclk_fall_pulse_s <= '1';
                        wait_first_bit <= '1';
                        shift_cnt <= 0;
                    end if;
                    
                    --block above not nessassary -------------
                    --lrclk_s <= not lrclk_s;
                    
--                else
--                    lrcnt <= lrcnt + 1;
--                end if;
                ---------------------------------------------------------------------
                --Shift register logic
                   
--                    address <= address + 1;
--                    addra_s <= std_logic_vector(to_unsigned(address, 5));
--                    shift_Reg_load <= douta_s; --assine new sample to register
--                  if address >= 32 then  -- loop the block memory for output
--                        address <= 0;
--                    end if;
                     -- capture new filtered samples only when valid says they are good
                    if M_tdata_valid_in_L = '1' then
                        right_buf <= right_reg_shift_s;
                    end if;
        
                    if M_tdata_valid_in_R = '1' then
                        left_buf <= left_reg_shift_s;
                    end if;
                    if lrclk_rise_pulse_s = '1' then
                        left_buf_lrclk <= left_buf;
                        next_state <= Right;
                    end if;
                    if lrclk_fall_pulse_s = '1' then
                        right_buf_lrclk <= right_buf;
                        next_state <= Left;
                    end if;
                     --added for shift reg 
--                    if lrclk_ss = '1' then 
--                        --left_reg_output <= left_reg;
--                        right_reg_shift_t <= right_buf_lrclk;-- assinment to hold for an extra 32 sclk
--                    elsif lrclk_ss = '0' then
--                        --right_reg_output <= right_reg;
--                        left_reg_shift_t <= left_buf_lrclk; -- assinment to hold for an extra 32 sclk
--                    end if; -- why does else if also need a end if statment?
                    
                    --new code-------------------------------------------------------------
                    

                    case state is
                        when Idle =>
                            if lrclk_ss = '0' then
                                next_state <= Left;
                            else
                                next_state <= Right;
                            end if;
                            
                        when Left =>
                            -- shift LEFT data while lrclk = 0
                                if lrclk_ss = '0' then
                                    if sclk_fall_pulse_s = '1' then
                                        sclk_fall_pulse <= '0';
                            
                                        if wait_first_bit = '1' then
                                            wait_first_bit <= '0';   -- skip exactly one falling SCLK
                                        else
                                            t_data_s <= left_buf_lrclk(31 - shift_cnt);
                                            test_register_shift_t(31 - shift_cnt) <= left_buf_lrclk(31 - shift_cnt);
                                            shift_cnt <= shift_cnt + 1;
                                        end if;
                                    end if;
                                    next_state <= Left;
                                    sclk_fall_pulse <= '0';
                                    --lrclk_rise_pulse_s <= '0';
                                    --lrclk_fall_pulse_s <= '0';
                                else
                                    next_state <= Right;
                                    sclk_fall_pulse <= '0';
                                    --lrclk_rise_pulse_s <= '0';
                                    --lrclk_fall_pulse_s <= '0';
                                end if;
                        when Right =>
                            -- shift RIGHT data while lrclk = 1
                            if wait_first_bit = '1' then
                                wait_first_bit <= '0';
                            elsif lrclk_ss = '1' then
                                if sclk_fall_pulse_s = '1' then
                                    sclk_fall_pulse <= '0';
                                    t_data_s  <= right_buf_lrclk(31 - shift_cnt);
                                    test_register_shift_t(31 - shift_cnt) <= right_buf_lrclk(31 - shift_cnt);
                                    shift_cnt <= shift_cnt + 1;
                                end if;
                            --lrclk_fall_pulse_s <= '0';
                            elsif lrclk_ss = '0' then
                                next_state <= Left;
                                sclk_fall_pulse <= '0';
                                --lrclk_rise_pulse_s <= '0';
                                --lrclk_fall_pulse_s <= '0';
                            else
                                next_state <= idle;
                                sclk_fall_pulse <= '0';
                                --lrclk_rise_pulse_s <= '0';
                                --lrclk_fall_pulse_s <= '0';
                            end if;
                            
                            

                    end case;
                    -- end of new code -----------------------------------------------------------------------------
                --shift data bit's out (in is how I am looking at it while programing the dac)
--                if sclk_fall_pulse = '1' then 
--                    sclk_fall_pulse <= '0';
--                    --data <= shift_Reg_load(31 - shift_cnt);
--                    shift_cnt <= shift_cnt +1;
--                    --add data_in register to hold data
--                    if lrclk_ss = '0' then
--                        --this assniment needs the data coming from the computation(the current shift_Reg_load) and needs to shift it out to t_data the current (left_reg)
--                        --left_reg(31 - shift_cnt) <= shift_Reg_load(31 - shift_cnt);
                       
--                    elsif lrclk_ss = '1' then
--                        --right_reg(31 - shift_cnt) <= shift_Reg_load(31 - shift_cnt);
                        
--                    end if;
--                end if;     
                end if;
                

            --end if; -- idk where this was missed
    end process;
end Behavioral;