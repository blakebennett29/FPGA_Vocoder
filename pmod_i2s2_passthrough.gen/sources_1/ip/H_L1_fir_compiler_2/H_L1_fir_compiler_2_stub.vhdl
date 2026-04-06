-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
-- Date        : Mon Mar 30 16:23:43 2026
-- Host        : Blakes-PC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top H_L1_fir_compiler_2 -prefix
--               H_L1_fir_compiler_2_ H_L1_fir_compiler_2_stub.vhdl
-- Design      : H_L1_fir_compiler_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity H_L1_fir_compiler_2 is
  Port ( 
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    event_s_data_chanid_incorrect : out STD_LOGIC
  );

end H_L1_fir_compiler_2;

architecture stub of H_L1_fir_compiler_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "aclk,s_axis_data_tvalid,s_axis_data_tready,s_axis_data_tuser[0:0],s_axis_data_tdata[31:0],m_axis_data_tvalid,m_axis_data_tuser[0:0],m_axis_data_tdata[31:0],event_s_data_chanid_incorrect";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fir_compiler_v7_2_22,Vivado 2024.1";
begin
end;
