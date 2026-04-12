transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+INT_L_L1_fir_compiler  -L xpm -L xbip_utils_v3_0_13 -L axi_utils_v2_0_9 -L fir_compiler_v7_2_22 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.INT_L_L1_fir_compiler xil_defaultlib.glbl

do {INT_L_L1_fir_compiler.udo}

run 1000ns

endsim

quit -force
