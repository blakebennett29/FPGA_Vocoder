vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xbip_utils_v3_0_13
vlib modelsim_lib/msim/axi_utils_v2_0_9
vlib modelsim_lib/msim/fir_compiler_v7_2_22
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xbip_utils_v3_0_13 modelsim_lib/msim/xbip_utils_v3_0_13
vmap axi_utils_v2_0_9 modelsim_lib/msim/axi_utils_v2_0_9
vmap fir_compiler_v7_2_22 modelsim_lib/msim/fir_compiler_v7_2_22
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv \
"E:/School/3610_digital_systems/Vivado/2024.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"E:/School/3610_digital_systems/Vivado/2024.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_13  -93  \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_9  -93  \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work fir_compiler_v7_2_22  -93  \
"../../../ipstatic/hdl/fir_compiler_v7_2_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../../pmod_i2s2_passthrough.gen/sources_1/ip/INT_L_L1_fir_compiler/sim/INT_L_L1_fir_compiler.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

