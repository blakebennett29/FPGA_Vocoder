// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (win64) Build 5076996 Wed May 22 18:37:14 MDT 2024
// Date        : Sat Apr  4 19:39:39 2026
// Host        : Blakes-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top fir_compiler_0 -prefix
//               fir_compiler_0_ fir_compiler_0_stub.v
// Design      : fir_compiler_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fir_compiler_v7_2_22,Vivado 2024.1" *)
module fir_compiler_0(aclk, s_axis_data_tvalid, s_axis_data_tready, 
  s_axis_data_tlast, s_axis_data_tuser, s_axis_data_tdata, m_axis_data_tvalid, 
  m_axis_data_tlast, m_axis_data_tuser, m_axis_data_tdata, event_s_data_tlast_missing, 
  event_s_data_tlast_unexpected, event_s_data_chanid_incorrect)
/* synthesis syn_black_box black_box_pad_pin="s_axis_data_tvalid,s_axis_data_tready,s_axis_data_tlast,s_axis_data_tuser[0:0],s_axis_data_tdata[31:0],m_axis_data_tvalid,m_axis_data_tlast,m_axis_data_tuser[0:0],m_axis_data_tdata[31:0],event_s_data_tlast_missing,event_s_data_tlast_unexpected,event_s_data_chanid_incorrect" */
/* synthesis syn_force_seq_prim="aclk" */;
  input aclk /* synthesis syn_isclock = 1 */;
  input s_axis_data_tvalid;
  output s_axis_data_tready;
  input s_axis_data_tlast;
  input [0:0]s_axis_data_tuser;
  input [31:0]s_axis_data_tdata;
  output m_axis_data_tvalid;
  output m_axis_data_tlast;
  output [0:0]m_axis_data_tuser;
  output [31:0]m_axis_data_tdata;
  output event_s_data_tlast_missing;
  output event_s_data_tlast_unexpected;
  output event_s_data_chanid_incorrect;
endmodule
