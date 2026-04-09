# EverFree - Checklist de Heurísticas de Usabilidade (Nielsen)

## Baseado nas 10 Heurísticas de Jakob Nielsen

---

## 1. VISIBILILIDADE DO STATUS DO SISTEMA

### O sistema deve sempre manter usuários informados sobre o que está acontecendo

#### Tela: ScanPage
- [x] Barra de progresso visível durante escaneamento
- [x] Contador de arquivos (X/Y arquivos)
- [x] Percentual de conclusão visível
- [x] ETA (tempo estimado) exibido
- [x] Nome do arquivo atual sendo processado
- [x] Animação pulsante indica atividade
- [x] Lista de arquivos encontrados atualiza em tempo real

#### Tela: ProcessPage
- [x] Grande percentual central (64px) visível
- [x] Barra de progresso animada
- [x] Arquivo atual exibido
- [x] Estatísticas: ETA, Throughput, Bytes liberados
- [x] Log de processamento (mesmo que placeholder)
- [x] Botão Cancelar sempre visível durante operação

#### Footer (Global)
- [x] Ponto pulsante durante operações ativas
- [x] Mensagem de status colorida (verde/vermelho/cinza)
- [x] Contador de arquivos durante scan/processamento
- [x] Percentual sempre atualizado

**Nota:** 10/10 ✅

---

## 2. CORRESPONDÊNCIA ENTRE SISTEMA E MUNDO REAL

### Falar na linguagem do usuário, não em termos técnicos

#### Termos Técnicos Usados
- [x] "Escaneando" → Compreensível ✅
- [x] "Economia estimada" → Claro ✅
- [x] "Arquivos" → Universal ✅
- [ ] "CRF" (em Advanced Mode) → Explicação necessária ⚠️
- [ ] "Codec H.265/VP9" → Usuário leigo pode não entender ⚠️
- [ ] "fit:1920x1080" → Sintaxe confusa ⚠️

#### Mensagens de Erro
- [x] "Erro ao acessar pasta" → Claro ✅
- [x] "Pastas ignoradas" → Entendível ✅
- [ ] Códigos de erro técnicos não devem aparecer ao usuário ⚠️

**Recomendação:**
- Adicionar tooltips explicativos para CRF, codecs
- Simplificar campo de redimensionamento com presets visuais
- Traduzir mensagens de erro técnicas para linguagem humana

**Nota:** 7/10 ⚠️

---

## 3. CONTROLE E LIBERDADE DO USUÁRIO

### Usuários devem poder desfazer ações e sair de situações indesejadas

#### Botões de Cancelar/Sair
- [x] ScanPage: Botão "✕ Cancelar" visível
- [x] ProcessPage: Botão "✕ Cancelar" visível
- [x] Global: Tecla ESC funciona para cancelar/voltar
- [x] SimpleWelcome: Botão "← Voltar" presente
- [x] AdvancedWelcome: Botão "← Voltar" no header
- [x] ReportPage: Botões "Nova Compressão" e "Fechar"

#### Navegação
- [x] StackView permite voltar (pop)
- [x] Reset() limpa estado completamente
- [x] Múltiplos caminhos para retornar ao início

**Nota:** 10/10 ✅

---

## 4. CONSISTÊNCIA E PADRONIZAÇÃO

### Seguir convenções e manter consistência em toda interface

#### Paleta de Cores (Material Design)
- [x] Cor primária: Verde (Material.Green) consistente
- [x] Cor de erro: Vermelho (Material.Red)
- [x] Cor de aviso: Laranja (Material.Orange)
- [x] Fundo: Cinza escuro (Grey.900/800) em tema escuro
- [x] Botões primários: Verde.Shade700
- [x] Botões secundários: Cinza/Shade600

#### Tipografia
- [x] Títulos: 20-24px, bold
- [x] Corpo: 13-15px
- [x] Labels secundárias: 11-12px, hintTextColor
- [x] Números grandes (stats): 26-64px, bold

#### Espaçamento
- [x] Margens de página: 20-32px
- [x] Spacing entre elementos: 8-20px
- [x] Cards: 10-14px radius

#### Componentes Reutilizáveis
- [x] BigButton.qml - Botões primários
- [x] SavingsBadge.qml - Exibição de economia
- [x] QualityStars.qml - Seleção de qualidade
- [x] CodecBadge.qml - Identificação de codec
- [x] FileListItem.qml - Itens de lista de arquivos

**Inconsistências Encontradas:**
- [ ] ProcessPage usa hardcoded strings ao invés de componentes reutilizáveis ⚠️
- [ ] Algumas páginas usam padding diferente (20 vs 30 vs 32px) ⚠️
- [ ] Nem todos os botões seguem BigButton.qml ⚠️

**Nota:** 7/10 ⚠️

---

## 5. PREVENÇÃO DE ERROS

### Melhor que boas mensagens de erro é prevenir que aconteçam

#### Validações Implementadas
- [x] addFolder() rejeita strings vazias
- [x] cloudLogin valida email/senha antes de enviar
- [x] FileDialog path parsing com URL decoding
- [x] Scan worker verifica espaço em disco
- [x] Botão desabilitado durante scan (enabled: state !== Scanning)
- [x] Folders duplicados não são adicionados

#### Confirmações
- [x] ConfirmDialog para operações destrutivas
- [x] Simple mode mostra preview antes de comprimir
- [x] Advanced mode permite selecionar arquivos específicos

#### Feedback Preventivo
- [x] Empty state em listas vazias
- [x] Placeholders em campos de texto
- [x] Tooltips explicativos em botões
- [ ] Warn se usuário tentar comprimir arquivos já comprimidos ⚠️
- [ ] Warn se espaço em disco for insuficiente ⚠️

**Nota:** 8/10 ✅

---

## 6. RECONHECER EM VEZ DE LEMBRAR

### Minimizar carga cognitiva do usuário

#### Informações Visíveis
- [x] Configurações atuais sempre visíveis (SettingsDialog)
- [x] Modo atual indicado (Simple/Advanced)
- [x] Progresso visível durante operações longas
- [x] Estatísticas de savings em cards visuais
- [x] Arquivos sendo processados listados em tempo real

#### Navegação
- [x] Título da página indica onde usuário está
- [x] Ícones indicam tipo de operação (🔍 scan, ⏳ process, ✅ complete)
- [x] Breadcrumbs implícito via StackView
- [ ] Indicador visual de modo atual no header ⚠️

**Nota:** 9/10 ✅

---

## 7. FLEXIBILIDADE E EFICIÊNCIA DE USO

### Atalhos para usuários experientes sem prejudicar novatos

#### Modo Simples (Novatos)
- [x] Um clique para escanear pastas padrão
- [x] Sem configurações complexas
- [x] Preview antes de comprimir
- [x] Mensagens em linguagem simples

#### Modo Avançado (Expert)
- [x] Controle total de codecs, qualidade, resolução
- [x] Seleção manual de arquivos
- [x] Configuração de threads
- [x] Busca recursiva toggle

#### Atalhos
- [x] ESC para cancelar/voltar
- [ ] Ctrl+S para salvar configurações ⚠️
- [ ] Ctrl+N para novo scan ⚠️
- [ ] Double-click para abrir pasta ⚠️

**Nota:** 7/10 ⚠️

---

## 8. DESIGN ESTÉTICO E MINIMALISTA

### Interfaces não devem conter informação irrelevante

#### Elementos na Tela
- [x] Home: Apenas logo, título e CTA principal
- [x] Scan: Progresso + lista de arquivos (nada mais)
- [x] Process: Big number + barra + stats essenciais
- [x] Report: Cards de stats + botões de ação

#### Ruído Visual
- [x] Sem informações desnecessárias durante operações
- [x] Cards só aparecem quando relevantes
- [x] Elementos escondidos quando não aplicáveis (visible: false)
- [ ] Codec card vazio no ReportPage (removido ✅)
- [ ] Log de processamento sem dados (placeholder adicionado ✅)

#### Hierarquia Visual
- [x] Números importantes em destaque (64px)
- [x] Labels secundárias menores e em hintTextColor
- [x] Botão primário destacado (highlighted: true)
- [x] Cores indicam importância (verde=bom, vermelho=erro)

**Nota:** 9/10 ✅

---

## 9. AJUDAR USUÁRIOS A RECONHECER, DIAGNOSTICAR E RECUPERAR DE ERROS

### Mensagens de erro devem ser claras e construtivas

#### Mensagens de Erro Implementadas
- [x] "Erro ao acessar pasta" → Indica problema específico
- [x] "X pasta(s) ignorada(s)" → Quantifica erro
- [x] Lista de pastas com erro acessível via botão
- [x] Botão "Limpar Erros" para resetar estado
- [ ] "Erro de compressão" genérico ⚠️
- [ ] Não indica como resolver o erro ⚠️

#### Diálogos de Erro
- [x] ErrorReportDialog para detalhes
- [x] ConfirmDialog para confirmações
- [x] Erros não bloqueiam fluxo principal (scan continua)

#### Recuperação
- [x] Botão "Nova Compressão" após erro
- [x] Estado resetado corretamente
- [x] Sem perda de dados silenciosa

**Recomendação:**
- Adicionar sugestões de resolução ("Verifique permissões da pasta")
- Mensagens de erro mais específicas por tipo de falha

**Nota:** 7/10 ⚠️

---

## 10. AJUDA E DOCUMENTAÇÃO

### Mesmo que melhor sem documentação, fornecê-la se necessário

#### Ajuda Inline
- [x] Tooltips em botões do header
- [x] Placeholders em campos de texto
- [x] Mensagens de empty state explicativas
- [x] Labels descritivos em todos os controles

#### Documentação Ausente
- [ ] Tutorial de primeiro uso (onboarding) ⚠️
- [ ] Help button com FAQ ⚠️
- [ ] Explicação de codecs e configurações ⚠️
- [ ] Link para documentação online ⚠️

**Recomendação:**
- Adicionar onboarding de 3 telas no primeiro uso
- Tooltip estendido em configurações avançadas
- Link para docs no footer

**Nota:** 5/10 ⚠️

---

## RESUMO FINAL

| Heurística | Nota | Status |
|------------|------|--------|
| 1. Visibilidade do Status | 10/10 | ✅ Excelente |
| 2. Correspondência com Mundo Real | 7/10 | ⚠️ Melhorar |
| 3. Controle e Liberdade | 10/10 | ✅ Excelente |
| 4. Consistência e Padronização | 7/10 | ⚠️ Melhorar |
| 5. Prevenção de Erros | 8/10 | ✅ Bom |
| 6. Reconhecer vs Lembrar | 9/10 | ✅ Excelente |
| 7. Flexibilidade e Eficiência | 7/10 | ⚠️ Melhorar |
| 8. Design Estético e Minimalista | 9/10 | ✅ Excelente |
| 9. Diagnóstico de Erros | 7/10 | ⚠️ Melhorar |
| 10. Ajuda e Documentação | 5/10 | ⚠️ Crítico |

### **MÉDIA GERAL: 7.9/10** ✅ Bom, com espaço para melhorias

---

## PRIORIDADES DE MELHORIA

### 🔴 Alta Prioridade
1. Adicionar onboarding/tutorial no primeiro uso
2. Melhorar mensagens de erro com sugestões de resolução
3. Adicionar tooltips explicativos em configurações avançadas

### 🟡 Média Prioridade
4. Padronizar padding/margins em todas as páginas
5. Adicionar atalhos de teclado (Ctrl+S, Ctrl+N)
6. Criar componente BigButton e usar em todas as telas
7. Adicionar indicador visual do modo atual no header

### 🟢 Baixa Prioridade
8. Adicionar double-click para abrir pasta
9. Warn se tentar comprimir arquivos já comprimidos
10. Link para documentação online no footer
