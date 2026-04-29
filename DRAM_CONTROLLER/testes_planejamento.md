# Planejamento de testes do DRAM_CONTROLLER

---

## **dram_controller**

Os testes para a máquina de estados DRAM têm como objetivo garantir que a transição entre os corretamente funcionando, enviando os comandos corretos, esperando corretamente os timings e com as flags corretas ativadas.

### *Simulação*

#### **INIT**
- [ ] Verificar que ready = 0
- [ ] Verificar que ignora comandos READ/WRITE
- [ ] Verificar envio de comandos de PRECHARGE
- [ ] Verificar tempo após PRECHARGE (tRP)
- [ ] Verificar envio de comandos de REFRESH
- [ ] Verificar tempo após REFRESH (tRFC)
- [ ] Verificar configuração do Mode Register
- [ ] Verificar transição para READY

#### **READY**
- [ ] Verificar que ready = 1
- [ ] Verificar que req = 0
- [ ] Verificar envio de comandos de REFRESH
- [ ] Verificar espera de REFRESH antes de fazer comando READ/WRITE (req = 1)
- [ ] Verificar transição para READ, com req = 1, wEn = 0
- [ ] Verificar transição para WRITE, com req = 1, wEn = 1

#### **READ**
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

#### **REFRESH**
- [ ] Verificar ready = 0
- [ ] Verificar que ignora comandos READ/WRITE
- [ ] Verificar envio do comando AUTO REFRESH
- [ ] Verificar tempo de espera tRC
- [ ] Verificar transição para READY
