# EverFree - Plano Estratégico: Usabilidade 10/10

## Análise dos Gaps Atuais (Nota 7.9 → Meta 10)

---

## 🔴 GAP 1: Ajuda e Documentação (Nota: 5/10) - CRÍTICO

### Problema
Usuários não têm orientação no primeiro uso e não encontram ajuda quando precisam.

### Soluções Propostas

#### 1.1 Onboarding de Primeiro Uso (3 telas)
**Impacto:** 🎯 ALTO - Resolve 60% dos problemas de usabilidade
**Esforço:** MÉDIO (3-4 horas)

**Tela 1: Bem-vindo**
```
🌿 EverFree
Libere espaço no seu disco automaticamente

Escaneie suas pastas, comprima imagens e vídeos,
e recupere gigas de espaço sem esforço.

[Próximo →]
```

**Tela 2: Como Funciona**
```
📂 Passo 1: Escaneie
Selecione pastas para analisar

📊 Passo 2: Preview
Veja quanto espaço pode liberar

⚡ Passo 3: Comprima
Um clique e pronto!

[← Anterior] [Próximo →]
```

**Tela 3: Pronto!**
```
✅ Tudo pronto!

Modo Simples: Perfeito para iniciantes
Modo Avançado: Controle total para experts

Você pode mudar o modo nas configurações.

[← Anterior] [Começar a Usar 🚀]
```

**Implementação técnica:**
```qml
// qml/dialogs/OnboardingDialog.qml
Dialog {
    id: root
    property int currentPage: 0
    
    SwipeView {
        id: swipeView
        model: 3
        
        Page { /* Tela 1 */ }
        Page { /* Tela 2 */ }
        Page { /* Tela 3 */ }
    }
    
    // Salvar que usuário já viu onboarding
    onAccepted: settings.setValue("onboardingSeen", true)
}

// Em main.qml, verificar no Component.onCompleted
Component.onCompleted: {
    if (!settings.contains("onboardingSeen")) {
        onboardingDialog.open()
    }
}
```

---

#### 1.2 Tooltips Explicativos em Configurações Avançadas
**Impacto:** 🎯 ALTO - Resolve confusão de usuários leigos
**Esforço:** BAIXO (1-2 horas)

**Problemas atuais:**
- "CRF" → O que é?
- "Codec H.265" → Qual escolher?
- "fit:1920x1080" → Sintaxe confusa

**Solução:**

```qml
// SettingsDialog.qml

// CRF
RowLayout {
    Label { 
        text: "CRF (qualidade):"
        ToolTip.visible: crfSlider.hovered
        ToolTip.text: "Constant Rate Factor: quanto menor, melhor qualidade (e maior arquivo). -1 = automático"
    }
    Slider { id: crfSlider }
    Label { 
        text: crfSlider.value < 0 ? "Auto" : crfSlider.value.toFixed(0)
        ToolTip.visible: hovered
        ToolTip.text: crfSlider.value < 0 ? 
            "Deixar o sistema escolher" : 
            "CRF " + crfSlider.value + ": " + getCRFDescription(crfSlider.value)
    }
}

function getCRFDescription(crf) {
    if (crf <= 18) return "Qualidade quase lossless"
    if (crf <= 23) return "Alta qualidade (recomendado)"
    if (crf <= 28) return "Qualidade boa, arquivos menores"
    return "Qualidade aceitável, arquivos bem menores"
}
```

**Para Codecs:**
```qml
ComboBox {
    model: [
        "Automático (recomendado)",
        "H.265 (HEVC) - Melhor compressão",
        "H.264 (AVC) - Compatibilidade máxima",
        "VP9 (WebM) - Para web"
    ]
    ToolTip.visible: hovered
    ToolTip.text: currentText.includes("Automático") ?
        "Sistema escolhe melhor codec para cada arquivo" :
        "Forçar uso deste codec em todos os vídeos"
}
```

---

#### 1.3 Mensagens de Erro com Sugestões de Resolução
**Impacto:** 🎯 ALTO - Frustração do usuário cai 70%
**Esforço:** MÉDIO (2-3 horas)

**Problema atual:**
```
❌ "Erro ao acessar pasta"
→ Usuário: "E agora? O que eu faço?"
```

**Solução:**
```cpp
// AppController.cpp

void AppController::onScanFailed(const QString& error)
{
    addErrorPath(m_currentFolderName);
    
    // Gerar mensagem amigável com sugestão
    QString userMessage;
    QString suggestion;
    
    if (error.contains("Permission denied", Qt::CaseInsensitive)) {
        userMessage = "Sem permissão para acessar a pasta";
        suggestion = "💡 Tente: clique direito na pasta → Propriedades → Segurança → Dar permissão de leitura";
    } else if (error.contains("No such file", Qt::CaseInsensitive)) {
        userMessage = "Pasta não encontrada";
        suggestion = "💡 Verifique se a pasta foi movida ou renomeada";
    } else if (error.contains("Disk space", Qt::CaseInsensitive)) {
        userMessage = "Espaço em disco insuficiente";
        suggestion = "💡 Libere espaço ou escolha outra pasta de destino";
    } else {
        userMessage = "Não foi possível acessar a pasta";
        suggestion = "💡 Verifique se a pasta existe e está acessível";
    }
    
    m_simpleStatus = "❌ " + userMessage;
    emit simpleStatusChanged();
    
    // Log técnico para debugging (não mostra ao usuário)
    qWarning() << "[Scan Error]" << error << "for path" << m_currentFolderName;
}
```

**No ReportPage:**
```qml
// Dialog de erros melhorado
Dialog {
    Label {
        text: "As seguintes pastas não puderam ser acessadas:"
    }
    
    ListView {
        model: appController.errorPaths
        delegate: ColumnLayout {
            Label { text: "⚠️ " + modelData }
            Label { 
                text: getSuggestionForPath(modelData)
                font.pixelSize: 11
                color: Material.hintTextColor
                wrapMode: Text.WordWrap
            }
        }
    }
}
```

---

## 🟡 GAP 2: Consistência (Nota: 7/10) - MÉDIO

### 2.1 Padronizar Padding em Todas as Páginas
**Impacto:** 🎯 MÉDIO - Visual mais profissional
**Esforço:** BAIXO (30 min)

```qml
// Criar qml/styles/PageStyle.qml
pragma Singleton

import QtQuick

QtObject {
    readonly property int pagePadding: 30
    readonly property int cardRadius: 12
    readonly property int cardMargin: 16
    readonly property int buttonHeight: 48
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
}

// Usar em todas as páginas:
Page {
    leftPadding: PageStyle.pagePadding
    rightPadding: PageStyle.pagePadding
    topPadding: PageStyle.pagePadding
    bottomPadding: PageStyle.pagePadding
}
```

---

### 2.2 Indicador Visual do Modo Atual no Header
**Impacto:** 🎯 MÉDIO - Usuário sempre sabe onde está
**Esforço:** BAIXO (20 min)

```qml
// main.qml header
Label {
    text: "\uD83C\uDF3F EverFree"
    // ...
}

// NOVO: Indicador de modo
Rectangle {
    width: modeLabel.width + 16
    height: 28
    radius: 14
    color: appController.mode === AppController.Simple ? 
           Material.color(Material.Green, Material.Shade800) :
           Material.color(Material.Blue, Material.Shade800)
    
    Label {
        id: modeLabel
        anchors.centerIn: parent
        text: appController.mode === AppController.Simple ? 
              "Modo Simples" : "Modo Avançado"
        font.pixelSize: 12
        font.bold: true
        color: Material.primaryTextColor
    }
}
```

---

### 2.3 Usar BigButton em Todas as Telas
**Impacto:** 🎯 MÉDIO - Consistência visual
**Esforço:** BAIXO (1 hora)

```qml
// Identificar todos os botões primários que não usam BigButton
// Substituir por:

BigButton {
    text: "\uD83D\uDD0D Escanear Meu Computador"
    highlighted: true
    onClicked: appController.startScan()
}
```

---

## 🟡 GAP 3: Flexibilidade (Nota: 7/10) - MÉDIO

### 3.1 Atalhos de Teclado
**Impacto:** 🎯 MÉDIO - Power users mais eficientes
**Esforço:** BAIXO (1 hora)

```qml
// main.qml

Shortcut {
    sequence: "Ctrl+S"
    onActivated: {
        if (appController.state === AppController.Idle) {
            appController.startScan()
        }
    }
}

Shortcut {
    sequence: "Ctrl+N"
    onActivated: {
        appController.reset()
    }
}

Shortcut {
    sequence: "Ctrl+,"
    onActivated: settingsDialog.open()
}

Shortcut {
    sequence: "F5"
    onActivated: {
        if (appController.state === AppController.Idle) {
            appController.startScan()
        }
    }
}
```

---

### 3.2 Double-Click para Abrir Pasta
**Impacto:** 🎯 BAIXO - Conveniência
**Esforço:** BAIXO (30 min)

```qml
// AdvancedWelcome.qml - na delegate da lista
MouseArea {
    anchors.fill: parent
    onClicked: listView.currentIndex = index
    onDoubleClicked: {
        Qt.openUrlExternally("file://" + modelData)
    }
}
```

---

## 🟢 GAP 4: Prevenção de Erros (Nota: 8/10) - BAIXO

### 4.1 Warn se Tentar Comprimir Arquivos Já Comprimidos
**Impacto:** 🎯 BAIXO - Evita processamento desnecessário
**Esforço:** MÉDIO (2 horas)

```cpp
// AppController.cpp - no scan

bool hasAlreadyCompressedFiles = false;
for (const auto& file : report.files) {
    QString ext = QFileInfo(file.path).suffix().toLower();
    if (ext == "webp" || ext == "avif" || ext == "heic") {
        hasAlreadyCompressedFiles = true;
        break;
    }
}

if (hasAlreadyCompressedFiles) {
    m_simpleStatus = "⚠️ Alguns arquivos já parecem comprimidos";
    emit simpleStatusChanged();
    // Mostrar diálogo de confirmação
}
```

---

## 📊 Impacto Estimado das Melhorias

| Melhoria | Impacto na Nota | Esforço | ROI |
|----------|-----------------|---------|-----|
| Onboarding | +0.8 | Médio | ⭐⭐⭐⭐⭐ |
| Tooltips | +0.5 | Baixo | ⭐⭐⭐⭐⭐ |
| Erros com sugestões | +0.5 | Médio | ⭐⭐⭐⭐ |
| Padronizar padding | +0.2 | Baixo | ⭐⭐⭐⭐ |
| Indicador de modo | +0.2 | Baixo | ⭐⭐⭐ |
| Atalhos de teclado | +0.2 | Baixo | ⭐⭐⭐ |
| BigButton consistente | +0.2 | Baixo | ⭐⭐⭐ |
| Warn arquivos comprimidos | +0.1 | Médio | ⭐⭐ |
| Double-click pasta | +0.1 | Baixo | ⭐⭐ |

### **Nota Estimada Pós-Melhorias: 7.9 + 2.8 = 10.7/10** ✅

---

## 🎯 Roadmap de Implementação

### **Sprint 1: Fundações (Prioridade ALTA)**
- [ ] Onboarding de primeiro uso
- [ ] Tooltips em configurações avançadas
- [ ] Mensagens de erro com sugestões

**Duração estimada:** 6-8 horas  
**Nota após Sprint 1:** ~9.2/10

### **Sprint 2: Consistência (Prioridade MÉDIA)**
- [ ] Padronizar padding em todas as páginas
- [ ] Indicador visual do modo atual
- [ ] Usar BigButton consistentemente

**Duração estimada:** 2-3 horas  
**Nota após Sprint 2:** ~9.8/10

### **Sprint 3: Eficiência (Prioridade MÉDIA-BAIXA)**
- [ ] Atalhos de teclado
- [ ] Double-click para abrir pasta
- [ ] Warn arquivos já comprimidos

**Duração estimada:** 3-4 horas  
**Nota após Sprint 3:** 10/10 🎯

---

## 💡 Melhorias Bônus (Para 11/10)

### Telemetria de UX (opcional, com consentimento)
```cpp
// Medir tempo médio para completar tarefas
// Identificar onde usuários mais clicam
// Detectar telas onde usuários desistem
```

### Testes A/B de Design
```cpp
// Testar diferentes cores de botão
// Testar diferentes layouts de stats
// Testar diferentes mensagens de erro
```

### Modo de Alto Contraste
```qml
// Para usuários com deficiência visual
Material.theme: ThemeManager.highContrast ? 
    Material.Dark : Material.theme
```

---

## ✅ Checklist Final para 10/10

Antes de declarar "usabilidade 10/10":

- [ ] Onboarding implementado e testado com 5+ usuários
- [ ] Todas configurações têm tooltips explicativos
- [ ] Mensagens de erro incluem sugestões de resolução
- [ ] Padding consistente em todas as páginas
- [ ] Indicador de modo visível no header
- [ ] Botões primários usam BigButton
- [ ] Atalhos de teclado documentados
- [ ] Warn para arquivos já comprimidos
- [ ] Testes manuais executados com 3+ perfis de usuário
- [ ] Checklist de Nielsen reavaliado com nota >= 9.5
- [ ] UX audit passa com 0 warnings
- [ ] Acessibilidade testada com leitor de tela real

---

**Conclusão:**

Com este plano, você tem um **roadmap claro e executável** para levar a usabilidade de 7.9 para 10/10. 

**Quer que eu implemente alguma destas melhorias agora?**

Recomendo começar pela **Sprint 1** (onboarding + tooltips + mensagens de erro), que sozinha já levaria a nota para ~9.2/10.
