transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/samue/Desktop/UNICAMP/2026/MC613/MC613/VendingMachine {C:/Users/samue/Desktop/UNICAMP/2026/MC613/MC613/VendingMachine/product2value.v}

vlog -vlog01compat -work work +incdir+C:/Users/samue/Desktop/UNICAMP/2026/MC613/MC613/VendingMachine/testbenches {C:/Users/samue/Desktop/UNICAMP/2026/MC613/MC613/VendingMachine/testbenches/bin2hex_tb.v}
vlog -vlog01compat -work work +incdir+C:/Users/samue/Desktop/UNICAMP/2026/MC613/MC613/VendingMachine {C:/Users/samue/Desktop/UNICAMP/2026/MC613/MC613/VendingMachine/bin2hex.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  bin2hex

add wave *
view structure
view signals
run -all
