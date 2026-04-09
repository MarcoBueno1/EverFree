# EverFree - Roteiro de Testes de Usabilidade Manual

## Instruções

1. Execute cada cenário na ordem apresentada
2. Para cada teste, marque: ✅ PASS, ❌ FAIL, ⚠️ PARCIAL
3. Anote observações e problemas encontrados
4. Tempo estimado: 30-45 minutos

---

## 👤 PERFIL DE TESTE: USUÁRIO LEIGO (Modo Simples)

### Cenário 1: Primeiro Uso - Modo Simples

**Objetivo:** Verificar se um usuário sem conhecimento técnico consegue usar o app

| Passo | Ação Esperada | Resultado | Observações |
|-------|---------------|-----------|-------------|
| 1. Abrir o aplicativo | Tela inicial aparece em < 2 segundos | ⬜ | |
| 2. Identificar modo de uso | Deve estar claro que é "Modo Simples" | ⬜ | |
| 3. Ler mensagem de boas-vindas | Texto compreensível, sem jargão técnico | ⬜ | |
| 4. Localizar botão principal | Botão "Escanear Meu Computador" visível e claro | ⬜ | |
| 5. Clicar no botão de escanear | Feedback imediato (spinner/loading) | ⬜ | |
| 6. Aguardar escaneamento | Progresso visível, ETA, arquivos aparecendo | ⬜ | |
| 7. Ver preview de resultados | Cards de stats claros, economia visível | ⬜ | |
| 8. Confirmar compressão | Botão "Confirmar e Comprimir" destacado | ⬜ | |
| 9. Aguardar processamento | Barra de progresso, %, stats em tempo real | ⬜ | |
| 10. Ver relatório final | Tamanho original → final, economia total | ⬜ | |
| 11. Voltar ao início | Botão "Nova Compressão" funciona | ⬜ | |

**Avaliação Geral do Cenário:**
- [ ] Intuitivo (não precisei pensar)
- [ ] Claro (entendi o que estava acontecendo)
- [ ] Eficiente (fluiu sem obstáculos)
- [ ] Agradável (visual bonito, cores coerentes)

**Problemas Encontrados:**
```
1. 
2. 
3. 
```

**Nota (1-10):** ___

---

### Cenário 2: Cancelamento de Operação

**Objetivo:** Verificar se usuário pode cancelar sem perder dados

| Passo | Ação Esperada | Resultado | Observações |
|-------|---------------|-----------|-------------|
| 1. Iniciar escaneamento | Progresso começa | ⬜ | |
| 2. Clicar "Cancelar" | Operação para em < 2 segundos | ⬜ | |
| 3. Ver feedback | Mensagem "Operação cancelada" | ⬜ | |
| 4. Voltar ao início | Tela inicial aparece | ⬜ | |
| 5. Verificar dados | Nenhuma perda de arquivos/configs | ⬜ | |
| 6. Pressionar ESC durante processo | Mesmo comportamento de cancelar | ⬜ | |

**Avaliação:**
- [ ] Cancelamento é claro e imediato
- [ ] Sem perda de dados
- [ ] Feedback adequado

**Problemas Encontrados:**
```
1. 
```

**Nota (1-10):** ___

---

## 👨‍💻 PERFIL DE TESTE: USUÁRIO AVANÇADO (Modo Avançado)

### Cenário 3: Configuração de Modo Avançado

**Objetivo:** Verificar controle total para usuários experientes

| Passo | Ação Esperada | Resultado | Observações |
|-------|---------------|-----------|-------------|
| 1. Mudar para Modo Avançado | Via SettingsDialog ou tela inicial | ⬜ | |
| 2. Adicionar pastas | "Adicionar Pasta" abre diálogo | ⬜ | |
| 3. Ver pastas selecionadas | Lista aparece com paths completos | ⬜ | |
| 4. Remover pasta | Botão ✕ funciona | ⬜ | |
| 5. Toggle recursiva | Checkbox habilita/desabilita | ⬜ | |
| 6. Abrir SettingsDialog | Todas opções visíveis | ⬜ | |
| 7. Mudar formato de imagem | same → WebP → JPEG | ⬜ | |
| 8. Ajustar qualidade (slider) | Valor atualizado em tempo real | ⬜ | |
| 9. Mudar codec de vídeo | auto → H.265 → H.264 → VP9 | ⬜ | |
| 10. Ajustar CRF | Slider de -1 (Auto) a 51 | ⬜ | |
| 11. Mudar resolução máx | original → 4K → 1080p → 720p | ⬜ | |
| 12. Salvar configurações | Settings fecha, settings persistem | ⬜ | |
| 13. Reabrir app | Configurações mantidas | ⬜ | |

**Avaliação:**
- [ ] Todas opções são claras
- [ ] Valores padrão são razoáveis
- [ ] Slider tem feedback visual
- [ ] Configurações persistem corretamente

**Problemas Encontrados:**
```
1. 
2. 
```

**Nota (1-10):** ___

---

### Cenário 4: Seleção Manual de Arquivos

**Objetivo:** Verificar se pode selecionar arquivos específicos

| Passo | Ação Esperada | Resultado | Observações |
|-------|---------------|-----------|-------------|
| 1. Completar scan | Lista de arquivos aparece | ⬜ | |
| 2. Ver lista de arquivos | Nome, tamanho, economia estimada | ⬜ | |
| 3. Selecionar/deselecionar | Checkboxes funcionam | ⬜ | |
| 4. Ver contagem | "X arquivos selecionados" | ⬜ | |
| 5. Iniciar processamento | Só arquivos selecionados processados | ⬜ | |
| 6. Ver progresso | Stats atualizam corretamente | ⬜ | |

**Avaliação:**
- [ ] Seleção é intuitiva
- [ ] Visual de lista é claro
- [ ] Economia estimada é útil

**Problemas Encontrados:**
```
1. 
```

**Nota (1-10):** ___

---

## 🎨 AVALIAÇÃO VISUAL GLOBAL

### Cores e Contraste

| Elemento | Avaliação | Observações |
|----------|-----------|-------------|
| Tema Escuro | ⬜ Bom ⬜ Ruim | |
| Tema Claro | ⬜ Bom ⬜ Ruim | |
| Toggle tema (header) | ⬜ Funciona ⬜ Bug | |
| Verde primário | ⬜ Agradável ⬜ Ruim | |
| Vermelho de erro | ⬜ Visível ⬜ Não | |
| Laranja de aviso | ⬜ Visível ⬜ Não | |
| Contraste texto/fundo | ⬜ Bom ⬜ Ruim | |

**Teste de Daltonismo:**
- [ ] Conseguir diferenciar status apenas por cor?
- [ ] Ícones ajudam na distinção?

### Tipografia

| Elemento | Avaliação | Observações |
|----------|-----------|-------------|
| Tamanho de títulos | ⬜ Bom ⬜ Pequeno ⬜ Grande | |
| Corpo de texto | ⬜ Legível ⬜ Ruim | |
| Labels pequenos | ⬜ Legíveis ⬜ Não | |
| Números grandes | ⬜ Impactantes ⬜ Ruim | |
| Hierarquia visual | ⬜ Clara ⬜ Confusa | |

### Espaçamento e Layout

| Elemento | Avaliação | Observações |
|----------|-----------|-------------|
| Margens | ⬜ Adequadas ⬜ Apertado | |
| Espaçamento entre elementos | ⬜ Bom ⬜ Ruim | |
| Cards e containers | ⬜ Claros ⬜ Confusos | |
| Alinhamento | ⬜ Consistente ⬜ Não | |
| Responsividade (redimensionar janela) | ⬜ Funciona ⬜ Quebra | |

### Animações

| Elemento | Avaliação | Observações |
|----------|-----------|-------------|
| Transições de página | ⬜ Suaves ⬜ Lentas ⬜ Rápidas | |
| Animação de progresso | ⬜ Fluida ⬜ Travando | |
| Fade-in de itens | ⬜ Elegante ⬜ Desnecessário | |
| Ponto pulsante | ⬜ Útil ⬜ Distração | |
| Performance geral | ⬜ 60fps ⬜ Travers | |

---

## 🔧 FUNCIONALIDADES ESPECÍFICAS

### Dialog de Configurações

| Teste | Resultado | Observações |
|-------|-----------|-------------|
| Abrir (⚙️ no header) | ⬜ | |
| Scroll funciona | ⬜ | |
| Todos campos visíveis | ⬜ | |
| Salvar funciona | ⬜ | |
| Cancelar funciona | ⬜ | |
| Valores persistem | ⬜ | |

### Tela de Relatório

| Teste | Resultado | Observações |
|-------|-----------|-------------|
| Cards de stats claros | ⬜ | |
| Barra visual útil | ⬜ | |
| "Ver Detalhes" funciona | ⬜ | |
| "Nova Compressão" reseta | ⬜ | |
| Pastas ignoradas acessíveis | ⬜ | |

### Footer

| Teste | Resultado | Observações |
|-------|-----------|-------------|
| Mensagem de status | ⬜ | |
| Contador de arquivos | ⬜ | |
| Percentual correto | ⬜ | |
| Ponto pulsante | ⬜ | |

---

## 📊 MÉTRICAS DE USABILIDADE

### Tempo de Tarefas (opcional, com cronômetro)

| Tarefa | Tempo | Avaliação |
|--------|-------|-----------|
| Primeiro scan completo | ___s | ⬜ Rápido (<30s) ⬜ Médio ⬜ Lento (>2min) |
| Mudar configuração | ___s | ⬜ Rápido (<5s) ⬜ Médio ⬜ Lento |
| Cancelar operação | ___s | ⬜ Imediato (<2s) ⬜ Médio ⬜ Lento |
| Encontrar configurações | ___s | ⬜ Imediato ⬜ Demorou ⬜ Não encontrei |

### Escala de Satisfação (após todos testes)

**De 1 a 10, quanto você recomendaria este app para:**

| Público | Nota | Justificativa |
|---------|------|---------------|
| Usuário leigo | ___/10 | |
| Usuário avançado | ___/10 | |
| Profissional de TI | ___/10 | |

**O que mais te agradou:**
```
1. 
2. 
3. 
```

**O que mais precisa melhorar:**
```
1. 
2. 
3. 
```

---

## ✅ CHECKLIST FINAL

### Funcional (tem e funciona?)

- [x] Escaneamento de pastas
- [x] Compressão de imagens
- [x] Compressão de vídeos
- [x] Modo simples
- [x] Modo avançado
- [x] Cancelamento
- [x] Relatório de economia
- [x] Toggle de tema
- [x] Configurações persistentes
- [x] Múltiplas pastas
- [ ] Cloud backup (se implementado)
- [ ] Rollback/restauração (se implementado)

### Visual (está bonito e coerente?)

- [ ] Cores são agradáveis e consistentes
- [ ] Tipografia é legível em todos os tamanhos
- [ ] Espaçamento é adequado
- [ ] Animações são suaves
- [ ] Layout não quebra ao redimensionar
- [ ] Emojis/ícones são apropriados
- [ ] Dark mode e light mode funcionam

### Acessibilidade (todos podem usar?)

- [ ] Contraste é adequado (WCAG AA)
- [ ] Touch targets >= 48x48px
- [ ] Leitores de tela funcionariam
- [ ] Daltonismo considerado
- [ ] Navegação por teclado possível

---

## 📝 RESUMO EXECUTIVO

**Data do Teste:** ___/___/______

**Testador:** _________________

**Total de Testes:** ___

**Passaram:** ___ (___%)

**Falharam:** ___ (___%)

**Nota Geral de Usabilidade:** ___/10

**Decisão:**
- [ ] ✅ Aprovado para produção
- [ ] ⚠️ Aprovado com ressalmas (listar abaixo)
- [ ] ❌ Reprovado (precisa de melhorias críticas)

**Ações Requeridas:**
```
1. 
2. 
3. 
```

**Próxima Revisão:** ___/___/______
