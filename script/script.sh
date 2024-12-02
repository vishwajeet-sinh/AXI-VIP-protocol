#compilation
vlog +incdir+src axi.svh


#elaboration
vsim -novopt top -sv_lib C:/questasim64_10.6b/uvm-1.1d/win64/uvm_dpi +UVM_TIMEOUT=5000 +UVM_TESTNAME=axi_10_tx_test

#add wave or add log
#add wave sim:/top/vif/*
do wave.do


#simulation
run -all