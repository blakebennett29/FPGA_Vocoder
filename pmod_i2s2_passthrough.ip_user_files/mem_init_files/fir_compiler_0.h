
//------------------------------------------------------------------------------
// (c) Copyright 2023 Advanced Micro Devices. All rights reserved.
//
// This file contains confidential and proprietary information
// of AMD, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//------------------------------------------------------------------------------ 
//
// C Model configuration for the "fir_compiler_0" instance.
//
//------------------------------------------------------------------------------
//
// coefficients: 3389,-3004,1800,0,-2016,3755,-4703,4447,-2818,0,3425,-6556,8370,-8013,5110,0,-6213,11841,-15018,14262,-9014,0,10747,-20273,25456,-23937,14984,0,-17545,32825,-40897,38180,-23742,0,27484,-51175,63503,-59087,36648,0,-42312,78790,-97871,91259,-56792,0,66289,-124420,156096,-147345,93081,0,-113140,218211,-283068,282609,-185368,0,263124,-572629,885164,-1153158,1333840,-1397593,1333840,-1153158,885164,-572629,263124,0,-185368,282609,-283068,218211,-113140,0,93081,-147345,156096,-124420,66289,0,-56792,91259,-97871,78790,-42312,0,36648,-59087,63503,-51175,27484,0,-23742,38180,-40897,32825,-17545,0,14984,-23937,25456,-20273,10747,0,-9014,14262,-15018,11841,-6213,0,5110,-8013,8370,-6556,3425,0,-2818,4447,-4703,3755,-2016,0,1800,-3004,3389
// chanpats: 173
// name: fir_compiler_0
// filter_type: 0
// rate_change: 0
// interp_rate: 1
// decim_rate: 1
// zero_pack_factor: 1
// coeff_padding: 0
// num_coeffs: 127
// coeff_sets: 1
// reloadable: 0
// is_halfband: 0
// quantization: 0
// coeff_width: 24
// coeff_fract_width: 0
// chan_seq: 0
// num_channels: 2
// num_paths: 1
// data_width: 24
// data_fract_width: 0
// output_rounding_mode: 5
// output_width: 32
// output_fract_width: 0
// config_method: 0

const double fir_compiler_0_coefficients[127] = {3389,-3004,1800,0,-2016,3755,-4703,4447,-2818,0,3425,-6556,8370,-8013,5110,0,-6213,11841,-15018,14262,-9014,0,10747,-20273,25456,-23937,14984,0,-17545,32825,-40897,38180,-23742,0,27484,-51175,63503,-59087,36648,0,-42312,78790,-97871,91259,-56792,0,66289,-124420,156096,-147345,93081,0,-113140,218211,-283068,282609,-185368,0,263124,-572629,885164,-1153158,1333840,-1397593,1333840,-1153158,885164,-572629,263124,0,-185368,282609,-283068,218211,-113140,0,93081,-147345,156096,-124420,66289,0,-56792,91259,-97871,78790,-42312,0,36648,-59087,63503,-51175,27484,0,-23742,38180,-40897,32825,-17545,0,14984,-23937,25456,-20273,10747,0,-9014,14262,-15018,11841,-6213,0,5110,-8013,8370,-6556,3425,0,-2818,4447,-4703,3755,-2016,0,1800,-3004,3389};

const xip_fir_v7_2_pattern fir_compiler_0_chanpats[1] = {P_BASIC};

static xip_fir_v7_2_config gen_fir_compiler_0_config() {
  xip_fir_v7_2_config config;
  config.name                = "fir_compiler_0";
  config.filter_type         = 0;
  config.rate_change         = XIP_FIR_INTEGER_RATE;
  config.interp_rate         = 1;
  config.decim_rate          = 1;
  config.zero_pack_factor    = 1;
  config.coeff               = &fir_compiler_0_coefficients[0];
  config.coeff_padding       = 0;
  config.num_coeffs          = 127;
  config.coeff_sets          = 1;
  config.reloadable          = 0;
  config.is_halfband         = 0;
  config.quantization        = XIP_FIR_INTEGER_COEFF;
  config.coeff_width         = 24;
  config.coeff_fract_width   = 0;
  config.chan_seq            = XIP_FIR_BASIC_CHAN_SEQ;
  config.num_channels        = 2;
  config.init_pattern        = fir_compiler_0_chanpats[0];
  config.num_paths           = 1;
  config.data_width          = 24;
  config.data_fract_width    = 0;
  config.output_rounding_mode= XIP_FIR_CONVERGENT_ODD;
  config.output_width        = 32;
  config.output_fract_width  = 0,
  config.config_method       = XIP_FIR_CONFIG_SINGLE;
  return config;
}

const xip_fir_v7_2_config fir_compiler_0_config = gen_fir_compiler_0_config();

