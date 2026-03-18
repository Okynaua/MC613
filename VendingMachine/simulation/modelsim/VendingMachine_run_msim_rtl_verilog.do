transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/c-ec2024/ra281174/MC613/MC613_Projetos/MC613/VendingMachine {/home/c-ec2024/ra281174/MC613/MC613_Projetos/MC613/VendingMachine/Register.v}
vlog -vlog01compat -work work +incdir+/home/c-ec2024/ra281174/MC613/MC613_Projetos/MC613/VendingMachine {/home/c-ec2024/ra281174/MC613/MC613_Projetos/MC613/VendingMachine/Accumulator.v}

vlog -vlog01compat -work work +incdir+/home/c-ec2024/ra281174/MC613/MC613_Projetos/MC613/VendingMachine {/home/c-ec2024/ra281174/MC613/MC613_Projetos/MC613/VendingMachine/Accumulator.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  Accumulator

add wave *
view structure
view signals
run -all
