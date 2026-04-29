# Planejamento de testes do DRAM_CONTROLLER

---

## **dram_controller**

Os testes para a máquina de estados DRAM têm como objetivo garantir que a transição entre os corretamente funcionando, enviando os comandos corretos, esperando corretamente os timings e com as flags corretas ativadas.

## Testes por Simulação

### INIT
- [ ] Verificar que ready = 0
- [ ] Verificar que ignora comandos READ/WRITE
- [ ] Verificar envio de comandos de PRECHARGE
- [ ] Verificar tempo após PRECHARGE (tRP)
- [ ] Verificar envio de comandos de REFRESH
- [ ] Verificar tempo após REFRESH (tRFC)
- [ ] Verificar configuração do Mode Register
- [ ] Verificar transição para READY

### READY
- [ ] Verificar que ready = 1
- [ ] Verificar que req = 0
- [ ] Verificar envio de comandos de REFRESH
- [ ] Verificar espera de REFRESH antes de fazer comando READ/WRITE (req = 1)
- [ ] Verificar transição para READ, com req = 1, wEn = 0
- [ ] Verificar transição para WRITE, com req = 1, wEn = 1

### READ
- [ ] Verificar ready = 0
- [ ] Verificar que ignora novos comandos READ/WRITE
- [ ] Verificar ACTIVATE com endereço de linha correto
- [ ] Verificar tempo de espera tRCD
- [ ] Verificar READ com endereço de coluna correto
- [ ] Verificar leitura correta do dado
- [ ] Verificar espera de CAS Latency (CL = 3)
- [ ] Verificar envio de comando PRECHARGE
- [ ] Verificar tempo de espera tRP
- [ ] Verificar transição para READY

#### **WRITE**
- [ ] Verificar ready = 0
- [ ] Verificar que ignora novos comandos READ/WRITE
- [ ] Verificar ACTIVATE com endereço de linha correto
- [ ] Verificar tempo de espera tRCD
- [ ] Verificar WRITE com endereço de coluna correto
- [ ] Verificar escrita correta do dado
- [ ] Verificar espera tDPL
- [ ] Verificar envio de comando PRECHARGE
- [ ] Verificar tempo de espera tRP
- [ ] Verificar transição para READY

### REFRESH
- [ ] Verificar ready = 0
- [ ] Verificar que ignora comandos READ/WRITE
- [ ] Verificar envio do comando AUTO REFRESH
- [ ] Verificar tempo de espera tRC
- [ ] Verificar transição para READY

## **dram_iface**

Os testes para a interfa1ce DRAM têm como objetivo garantir que a máquina de estados de input esteja corretamente funcionando e esperando corretamente os timings.

## Testes por Simulação

### Leitura 
- [ ] Verificar mudança de estado para REQ_READ a partir da mudança de sinal em SW[9:4]
- [ ] Verificar definição de saída address conforme projeto no estado REQ_READ
- [ ] Verificar definição de saída wEn = 0 no estado REQ_READ
- [ ] Verificar definição de saída req = 1 no estado REQ_READ
- [ ] Verificar que estado muda de REQ_READ para WAIT_READ após definir req = 1
- [ ] Verificar que estado não sai de WAIT_READ enquanto ready != 1
- [ ] Verificar que estado sai de WAIT_READ para READY

### Escrita
- [ ] Verificar mudança de estado para REQ_WRITE a partir de sinal em KEY[3]
- [ ] Verificar definição de saída wEn = 1 no estado REQ_WRITE
- [ ] Verificar definição de saída req = 1 no estado REQ_WRITE
- [ ] Verificar que estado muda de REQ_WRITE para WAIT_WRITE após definir req = 1
- [ ] Verificar que estado não sai de WAIT_READ enquanto ready != 1
- [ ] Verificar que estado vai para REQ_READ após ready = 1
- [ ] Verificar que dado salvo condiz com dado escrito

## Testes na Placa
- [ ] Modificar SW[9:4] e verificar mudança nas saídas
- [ ] Pressionar KEY[3] e verificar leitura após escrita
- [ ] Alterar SW[9:4] para outro valor e voltar para o escrito previamente
