# Compilação
vlog bin2hex.v
vlog bin2hex_tb.v

# Simulação do testbench
vsim -voptargs=+acc=n work.bin2hex_tb

# Waveform
add wave -r *

# Rodar tudo
run -all