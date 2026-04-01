# Testes por simulação:

## VGA
- [ ] Testar todas as cores
- [ ] Testar Sincronismo de HS
- [ ] Testar Sincronismo de VS
- [ ] Testar Mudança de VS após 640 HS
- [ ] Testar Reset do Counter_H após 640
- [ ] Testar Reset do Counter_V após 480
- [ ] Background sólido
- [ ] Baground Listras Horizontais
- [ ] Background Listras Verticais
- [ ] Testar Reset da VGA


## PPU
- [ ] Background tiles iguais
- [ ] Sprite em background alinhado e não alinhado com tile
- [ ] Sprite com parte fora da área
- [ ] Modificar a posição do sprite

### POS_BG
- [ ] Testar saída para posições dentro do tile
- [ ] Testar saída para posições na borda do tile
- [ ] Testar saída para posições fora do tile

### PPU_OAM
- [ ] Verificar saída de pixel com sprite
- [ ] Verificar saída de pixel sem sprite
- [ ] Adicionar sprite
- [ ] Remover sprite
- [ ] Mudar posição de sprite

### PPU_SPRITE
- [ ] Verificar saída de pixel com sprite
- [ ] Verificar saída de pixel sem sprite

### PPU_TILE
- [ ] Verificar saída de pixel em tile
- [ ] Verificar mudança de saída após mudança de background

### PPU_COMPOSITOR
- [ ] Verificar saída se não tiver sprite no pixel
- [ ] Verificar saída se tiver sprite no pixel
- [ ] Verificar saída quando video não estiver ativo

### PPU_COLOR
- [ ] Verificar a saída para cada cor do input

## Máquina de Estados:
- [ ] Verificar sinal de mudança de background
- [ ] Mover sprite
- [ ] x passou da posição máxima
- [ ] y passou da posição máxima


# Testes na placa:
- [ ] Verificar a impressão
- [ ] Mudar Background
- [ ] Mover Sprite
- [ ] Mover sprite até o fim da tela
- [ ] Resetar a tela depois de mudar o sprite
- [ ] Resetar a tela depois de mudar o background
