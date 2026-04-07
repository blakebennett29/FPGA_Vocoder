----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:
-- Design Name:
-- Module Name: tb_TOP
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
-- Top-level TB updated so data waits for LRCLK before sending each channel word.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_TOP is
end entity;

architecture sim of tb_TOP is

    --------------------------------------------------------------------------
    -- DUT signals
    --------------------------------------------------------------------------
    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';

    -- ADC 1 input side
    signal adc1_r_sclk  : std_logic;
    signal adc1_r_mclk  : std_logic;
    signal adc1_r_lrclk : std_logic;
    signal adc1_r_data  : std_logic := '0';

    -- ADC 2 input side
    signal adc2_r_sclk  : std_logic;
    signal adc2_r_mclk  : std_logic;
    signal adc2_r_lrclk : std_logic;
    signal adc2_r_data  : std_logic := '0';

    -- DAC outputs
    signal dac1_t_sclk  : std_logic;
    signal dac1_t_mclk  : std_logic;
    signal dac1_t_lrclk : std_logic;
    signal dac1_t_data  : std_logic;

    signal dac2_t_sclk  : std_logic;
    signal dac2_t_mclk  : std_logic;
    signal dac2_t_lrclk : std_logic;
    signal dac2_t_data  : std_logic;

    signal dac3_t_sclk  : std_logic;
    signal dac3_t_mclk  : std_logic;
    signal dac3_t_lrclk : std_logic;
    signal dac3_t_data  : std_logic;

    constant T_CLK : time := 10 ns;  -- 100 MHz

    --------------------------------------------------------------------------
    -- stimulus samples
    --------------------------------------------------------------------------
    constant ADC1_LEFT_ONCE  : std_logic_vector(23 downto 0) := x"aaaaaa";
    constant ADC1_RIGHT_ONCE : std_logic_vector(23 downto 0) := x"000000";

    constant ADC2_LEFT_ONCE  : std_logic_vector(23 downto 0) := x"aaaaaa";
    constant ADC2_RIGHT_ONCE : std_logic_vector(23 downto 0) := x"000000";

    constant ZERO24 : std_logic_vector(23 downto 0) := (others => '0');

begin

    --------------------------------------------------------------------------
    -- 100 MHz input clock
    --------------------------------------------------------------------------
    clk <= not clk after T_CLK/2;

    --------------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------------
    uut : entity work.TOP
        port map (
            clk          => clk,
            reset        => reset,

            adc1_r_sclk  => adc1_r_sclk,
            adc1_r_mclk  => adc1_r_mclk,
            adc1_r_lrclk => adc1_r_lrclk,
            adc1_r_data  => adc1_r_data,

            adc2_r_sclk  => adc2_r_sclk,
            adc2_r_mclk  => adc2_r_mclk,
            adc2_r_lrclk => adc2_r_lrclk,
            adc2_r_data  => adc2_r_data,

            dac1_t_sclk  => dac1_t_sclk,
            dac1_t_mclk  => dac1_t_mclk,
            dac1_t_lrclk => dac1_t_lrclk,
            dac1_t_data  => dac1_t_data,

            dac2_t_sclk  => dac2_t_sclk,
            dac2_t_mclk  => dac2_t_mclk,
            dac2_t_lrclk => dac2_t_lrclk,
            dac2_t_data  => dac2_t_data,

            dac3_t_sclk  => dac3_t_sclk,
            dac3_t_mclk  => dac3_t_mclk,
            dac3_t_lrclk => dac3_t_lrclk,
            dac3_t_data  => dac3_t_data
        );

    --------------------------------------------------------------------------
    -- reset / runtime
    --------------------------------------------------------------------------
    stim : process
    begin
        reset <= '1';
        wait for 200 ns;
        reset <= '0';

        wait for 20 ms;

        assert false report "Simulation finished." severity failure;
    end process;

    --------------------------------------------------------------------------
    -- ADC1 I2S stimulus
    --
    -- Wait for LRCLK before sending each word.
    -- Your receiver:
    --   lrclk='0' -> LEFT register shifting
    --   lrclk='1' -> RIGHT register shifting
    --
    -- TB drives on rising edge of SCLK so data is stable before falling edge.
    --------------------------------------------------------------------------
    adc1_driver : process

        procedure drive_slot(
            signal sclk      : in  std_logic;
            signal data_line : out std_logic;
            constant sample  : in  std_logic_vector(23 downto 0)
        ) is
        begin
            -- full 32-bit slot, MSB first
            -- bits [31:8] = sample, [7:0] = 0
            for i in 31 downto 0 loop
                wait until rising_edge(sclk);
                if i >= 8 then
                    data_line <= sample(i - 8);
                else
                    data_line <= '0';
                end if;
            end loop;
        end procedure;

    begin
        adc1_r_data <= '0';

        wait until reset = '0';

        -- let generated clocks settle
        wait for 5 us;

        -- wait until SCLK is running
        for i in 1 to 16 loop
            wait until rising_edge(adc1_r_sclk);
        end loop;

        ----------------------------------------------------------------------
        -- LEFT word: wait until LRCLK is low, then start on a fresh slot
        ----------------------------------------------------------------------
        wait until adc1_r_lrclk = '0';
        wait until rising_edge(adc1_r_sclk);
        drive_slot(adc1_r_sclk, adc1_r_data, ADC1_LEFT_ONCE);

        ----------------------------------------------------------------------
        -- RIGHT word: wait until LRCLK is high, then start on a fresh slot
        ----------------------------------------------------------------------
        wait until adc1_r_lrclk = '1';
        wait until rising_edge(adc1_r_sclk);
        drive_slot(adc1_r_sclk, adc1_r_data, ADC1_RIGHT_ONCE);

        ----------------------------------------------------------------------
        -- then zeros forever, aligned to LRCLK each time
        ----------------------------------------------------------------------
        loop
            wait until adc1_r_lrclk = '0';
            wait until rising_edge(adc1_r_sclk);
            drive_slot(adc1_r_sclk, adc1_r_data, ZERO24);

            wait until adc1_r_lrclk = '1';
            wait until rising_edge(adc1_r_sclk);
            drive_slot(adc1_r_sclk, adc1_r_data, ZERO24);
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- ADC2 I2S stimulus
    --------------------------------------------------------------------------
    adc2_driver : process

        procedure drive_slot(
            signal sclk      : in  std_logic;
            signal data_line : out std_logic;
            constant sample  : in  std_logic_vector(23 downto 0)
        ) is
        begin
            -- full 32-bit slot, MSB first
            -- bits [31:8] = sample, [7:0] = 0
            for i in 31 downto 0 loop
                wait until rising_edge(sclk);
                if i >= 8 then
                    data_line <= sample(i - 8);
                else
                    data_line <= '0';
                end if;
            end loop;
        end procedure;

    begin
        adc2_r_data <= '0';

        wait until reset = '0';

        -- let generated clocks settle
        wait for 5 us;

        -- wait until SCLK is running
        for i in 1 to 16 loop
            wait until rising_edge(adc2_r_sclk);
        end loop;

        ----------------------------------------------------------------------
        -- LEFT word
        ----------------------------------------------------------------------
        wait until adc2_r_lrclk = '0';
        wait until rising_edge(adc2_r_sclk);
        drive_slot(adc2_r_sclk, adc2_r_data, ADC2_LEFT_ONCE);

        ----------------------------------------------------------------------
        -- RIGHT word
        ----------------------------------------------------------------------
        wait until adc2_r_lrclk = '1';
        wait until rising_edge(adc2_r_sclk);
        drive_slot(adc2_r_sclk, adc2_r_data, ADC2_RIGHT_ONCE);

        ----------------------------------------------------------------------
        -- then zeros forever
        ----------------------------------------------------------------------
        loop
            wait until adc2_r_lrclk = '0';
            wait until rising_edge(adc2_r_sclk);
            drive_slot(adc2_r_sclk, adc2_r_data, ZERO24);

            wait until adc2_r_lrclk = '1';
            wait until rising_edge(adc2_r_sclk);
            drive_slot(adc2_r_sclk, adc2_r_data, ZERO24);
        end loop;
    end process;

end architecture;