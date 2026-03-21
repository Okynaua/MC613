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
vlog product2value.v product2value_tb.v
vsim -voptargs=+acc=n work.product2value_tb
run -all
