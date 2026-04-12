onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib INT_L_L1_fir_compiler_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {INT_L_L1_fir_compiler.udo}

run 1000ns

quit -force
