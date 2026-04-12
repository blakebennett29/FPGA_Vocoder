----------------------------------------------------------------------------------
-- Testbench for I2S_out
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_I2S_out is
end tb_I2S_out;

architecture Behavioral of tb_I2S_out is

    --------------------------------------------------------------------------
    -- DUT component
    --------------------------------------------------------------------------
    component I2S_out is
      Port (
            clk : in std_logic;
            reset : in std_logic;
            locked : in std_logic;
            M_tdata_valid_in_R : in std_logic;
            M_tdata_valid_in_L : in std_logic;
            right_reg_shift : in std_logic_vector(23 downto 0);
            left_reg_shift  : in std_logic_vector(23 downto 0);

            lrclk_rise_pulse_t : in std_logic;
            lrclk_fall_pulse_t : in std_logic;
            sclk_fall_pulse_t  : in std_logic;

            t_sclk  : in std_logic;
            t_mclk  : in std_logic;
            t_lrclk : in std_logic;
            t_data  : out std_logic
      );
    end component;

    --------------------------------------------------------------------------
    -- Signals
    --------------------------------------------------------------------------
    signal clk                : std_logic := '0';
    signal reset              : std_logic := '1';
    signal locked             : std_logic := '0';

    signal M_tdata_valid_in_R : std_logic := '0';
    signal M_tdata_valid_in_L : std_logic := '0';

    signal right_reg_shift    : std_logic_vector(23 downto 0) := (others => '0');
    signal left_reg_shift     : std_logic_vector(23 downto 0) := (others => '0');

    signal lrclk_rise_pulse_t : std_logic := '0';
    signal lrclk_fall_pulse_t : std_logic := '0';
    signal sclk_fall_pulse_t  : std_logic := '0';

    signal t_sclk             : std_logic := '0';
    signal t_mclk             : std_logic := '0';
    signal t_lrclk            : std_logic := '0';
    signal t_data             : std_logic;

    constant CLK_PERIOD  : time := 10 ns;   -- 100 MHz
    constant MCLK_PERIOD : time := 40 ns;   -- 25 MHz
    constant SCLK_PERIOD : time := 80 ns;   -- 12.5 MHz

begin

    --------------------------------------------------------------------------
    -- DUT instantiation
    --------------------------------------------------------------------------
    uut: I2S_out
        port map (
            clk                => clk,
            reset              => reset,
            locked             => locked,
            M_tdata_valid_in_R => M_tdata_valid_in_R,
            M_tdata_valid_in_L => M_tdata_valid_in_L,
            right_reg_shift    => right_reg_shift,
            left_reg_shift     => left_reg_shift,
            lrclk_rise_pulse_t => lrclk_rise_pulse_t,
            lrclk_fall_pulse_t => lrclk_fall_pulse_t,
            sclk_fall_pulse_t  => sclk_fall_pulse_t,
            t_sclk             => t_sclk,
            t_mclk             => t_mclk,
            t_lrclk            => t_lrclk,
            t_data             => t_data
        );

    --------------------------------------------------------------------------
    -- Main clock
    --------------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- MCLK generation
    --------------------------------------------------------------------------
    mclk_process : process
    begin
        while true loop
            t_mclk <= '0';
            wait for MCLK_PERIOD/2;
            t_mclk <= '1';
            wait for MCLK_PERIOD/2;
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- SCLK generation
    --------------------------------------------------------------------------
    sclk_process : process
    begin
        while true loop
            t_sclk <= '0';
            wait for SCLK_PERIOD/2;
            t_sclk <= '1';
            wait for SCLK_PERIOD/2;
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- LRCLK generation
    -- 32 SCLKs low, then 32 SCLKs high
    --------------------------------------------------------------------------
    lrclk_process : process
    begin
        while true loop
            t_lrclk <= '0';
            wait for 32 * SCLK_PERIOD;
            t_lrclk <= '1';
            wait for 32 * SCLK_PERIOD;
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- Generate 1-clk pulses from LRCLK and SCLK edges
    --------------------------------------------------------------------------
    pulse_process : process(clk)
        variable lrclk_d : std_logic := '0';
        variable sclk_d  : std_logic := '0';
    begin
        if rising_edge(clk) then
            lrclk_rise_pulse_t <= '0';
            lrclk_fall_pulse_t <= '0';
            sclk_fall_pulse_t  <= '0';

            -- LRCLK edge pulses
            if lrclk_d = '0' and t_lrclk = '1' then
                lrclk_rise_pulse_t <= '1';
            elsif lrclk_d = '1' and t_lrclk = '0' then
                lrclk_fall_pulse_t <= '1';
            end if;

            -- SCLK falling-edge pulse
            if sclk_d = '1' and t_sclk = '0' then
                sclk_fall_pulse_t <= '1';
            end if;

            lrclk_d := t_lrclk;
            sclk_d  := t_sclk;
        end if;
    end process;

    --------------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------------
    stim_proc : process
    begin
        reset  <= '1';
        locked <= '0';
        wait for 200 ns;

        reset  <= '0';
        locked <= '1';
        wait for 200 ns;

        ----------------------------------------------------------------------
        -- first stereo pair
        ----------------------------------------------------------------------
        left_reg_shift  <= x"AAAAAA";
        right_reg_shift <= x"123456";

        M_tdata_valid_in_L <= '1';
        M_tdata_valid_in_R <= '1';
        wait for CLK_PERIOD;
        M_tdata_valid_in_L <= '0';
        M_tdata_valid_in_R <= '0';

        wait for 8 us;

        ----------------------------------------------------------------------
        -- second stereo pair
        ----------------------------------------------------------------------
        left_reg_shift  <= x"FEDCBA";
        right_reg_shift <= x"654321";

        M_tdata_valid_in_L <= '1';
        M_tdata_valid_in_R <= '1';
        wait for CLK_PERIOD;
        M_tdata_valid_in_L <= '0';
        M_tdata_valid_in_R <= '0';

        wait for 8 us;

        ----------------------------------------------------------------------
        -- third stereo pair
        ----------------------------------------------------------------------
        left_reg_shift  <= x"800001";
        right_reg_shift <= x"7FFFFF";

        M_tdata_valid_in_L <= '1';
        M_tdata_valid_in_R <= '1';
        wait for CLK_PERIOD;
        M_tdata_valid_in_L <= '0';
        M_tdata_valid_in_R <= '0';

        wait for 10 us;

        report "Simulation finished." severity note;
        wait;
    end process;

end Behavioral;