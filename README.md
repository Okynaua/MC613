# MC613

A fazer:
- Máquina de Controle 

Módulos verificados na simulação:
- product2value
- iszero
- index2money
- bin2hex
- bin2decimal


Comando testbenches:
```
vlog file.v file_tb.v
vsim -voptargs=+acc=n work.file_tb
add wave -r *
run -all
```
