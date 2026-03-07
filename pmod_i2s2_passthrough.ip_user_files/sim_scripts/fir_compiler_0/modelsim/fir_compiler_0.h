
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
// coefficients: 2398,-1735,-3480,0,3896,2169,-3327,-4449,1459,6209,1774,-6559,-5921,4628,9877,0,-12009,-6839,10624,14269,-4668,-19710,-5565,20282,18008,-13826,-28960,0,33910,18960,-28932,-38197,12295,51127,14233,-51199,-44924,34129,70831,0,-81778,-45510,69236,91300,-29411,-122662,-34329,124477,110426,-85108,-179901,0,218668,126041,-200250,-278639,95997,435973,136265,-572888,-626189,666078,2577947,3495564,2577947,666078,-626189,-572888,136265,435973,95997,-278639,-200250,126041,218668,0,-179901,-85108,110426,124477,-34329,-122662,-29411,91300,69236,-45510,-81778,0,70831,34129,-44924,-51199,14233,51127,12295,-38197,-28932,18960,33910,0,-28960,-13826,18008,20282,-5565,-19710,-4668,14269,10624,-6839,-12009,0,9877,4628,-5921,-6559,1774,6209,1459,-4449,-3327,2169,3896,0,-3480,-1735,2398
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

const double fir_compiler_0_coefficients[127] = {2398,-1735,-3480,0,3896,2169,-3327,-4449,1459,6209,1774,-6559,-5921,4628,9877,0,-12009,-6839,10624,14269,-4668,-19710,-5565,20282,18008,-13826,-28960,0,33910,18960,-28932,-38197,12295,51127,14233,-51199,-44924,34129,70831,0,-81778,-45510,69236,91300,-29411,-122662,-34329,124477,110426,-85108,-179901,0,218668,126041,-200250,-278639,95997,435973,136265,-572888,-626189,666078,2577947,3495564,2577947,666078,-626189,-572888,136265,435973,95997,-278639,-200250,126041,218668,0,-179901,-85108,110426,124477,-34329,-122662,-29411,91300,69236,-45510,-81778,0,70831,34129,-44924,-51199,14233,51127,12295,-38197,-28932,18960,33910,0,-28960,-13826,18008,20282,-5565,-19710,-4668,14269,10624,-6839,-12009,0,9877,4628,-5921,-6559,1774,6209,1459,-4449,-3327,2169,3896,0,-3480,-1735,2398};

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

