# DRAM IFACE

Os testes para a interface DRAM têm como objetivo garantir que a máquina de estados de input esteja corretamente funcionando e esperando corretamente os timings.

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
- [ ] Verificar definição de saída req = 1 no estado REQ_READ
- [ ] Verificar que estado muda de REQ_WRITE para WAIT_WRITE após definir req = 1
- [ ] Verificar que estado não sai de WAIT_READ enquanto ready != 1
- [ ] Verificar que estado vai para REQ_READ após ready = 1
- [ ] Verificar que estado salvo condiz com estado escrito

## Testes na Placa

- [ ] Modificar SW[9:4] e verificar mudança nas saídas
- [ ] Pressionar KEY[3] e verificar leitura após escrita
- [ ] Alterar SW[9:4] para outro valor e voltar para o escrito previamente
