# 🌿 EverFree

> **Libere espaço no seu disco — automaticamente.**

EverFree é uma aplicação desktop moderna e bonita que usa o poder do **batchpress** para comprimir todas as suas imagens e vídeos, liberando gigabytes de espaço — sem você precisar tomar decisão nenhuma.

---

## ✨ O que o usuário vê

### Modo Simples (Leigo)
1. **Abre o EverFree**
2. Clica em **"🔍 Escanear Meu Computador"**
3. Pronto. O app escaneia, comprime e mostra quanto espaço foi liberado.

**Zero configurações. Zero perguntas. Funciona.**

### Modo Avançado
- Escolha pastas específicas
- Controle codec, CRF, resize, qualidade, threads
- Selecione arquivos individualmente
- Veja projeções de economia antes de comprimir
- Relatório detalhado por pasta e codec

---

## 🎯 Funcionalidades

| Recurso | Descrição |
|---------|-----------|
| **🟢 Modo Simples** | Um clique, zero decisões. Escaneia pastas pessoais automaticamente. |
| **🔵 Modo Avançado** | Controle total: pastas, codecs, qualidade, threads. |
| **📊 Scan Inteligente** | Mostra economia estimada antes de tocar em qualquer arquivo. |
| **🎨 Interface Moderna** | Qt6 Quick Controls 2, Material Design dark, animações suaves. |
| **📁 Multi-pasta** | Adicione quantas pastas quiser. Busca recursiva em subpastas. |
| **🔇 Pastas Ignoradas** | Pastas sem permissão são silenciosamente ignoradas (com log discreto). |
| **🖼️ Imagens** | WebP, JPEG, PNG, BMP — redimensiona e comprime em paralelo. |
| **🎬 Vídeos** | H.265, H.264, VP9 — auto-seleção do melhor codec. |
| **🔍 Detecção de Duplicatas** | Hash SHA-256 identifica arquivos idênticos. |
| **🌍 Multi-idioma** | Pronto para PT/EN (textos em português por padrão). |
| **🌙 Dark/Light Mode** | Toggle com um clique. |
| **📊 Relatório Visual** | Gráficos de barras comparando tamanho original vs final. |

---

## 🖥️ Screenshots (Conceito)

### Home — Escolha o Modo
```
┌──────────────────────────────────────────┐
│  🌿 EverFree                        🌙 ⚙ │
├──────────────────────────────────────────┤
│                                          │
│     Bem-vindo ao EverFree                │
│     Libere espaço no seu disco           │
│                                          │
│   ┌─────────────┐  ┌─────────────┐       │
│   │  ⚡         │  │  🔧         │       │
│   │  Modo       │  │  Modo       │       │
│   │  Simples    │  │  Avançado   │       │
│   │             │  │             │       │
│   │ Um clique,  │  │ Controle    │       │
│   │ zero decis. │  │ total       │       │
│   └─────────────┘  └─────────────┘       │
│                                          │
├──────────────────────────────────────────┤
│  Ready — escaneie seu computador         │
└──────────────────────────────────────────┘
```

### Modo Simples — Um Clique
```
┌──────────────────────────────────────────┐
│  🌿 EverFree                        🌙 ⚙ │
├──────────────────────────────────────────┤
│                                          │
│        🖥️                                │
│                                          │
│  Vamos liberar espaço do seu computador  │
│                                          │
│     ┌──────────────────────────┐         │
│     │  🔍 Escanear Meu PC      │         │
│     └──────────────────────────┘         │
│                                          │
│  Pastas pessoais serão escaneadas        │
│  automaticamente.                        │
│                                          │
├──────────────────────────────────────────┤
│  Ready — escaneie com um clique          │
└──────────────────────────────────────────┘
```

### Scan — Progresso
```
┌──────────────────────────────────────────┐
│  🌿 EverFree                        🌙 ⚙ │
├──────────────────────────────────────────┤
│                                          │
│  Escaneando arquivos...                  │
│  ████████████████░░░░  64%               │
│                                          │
│  foto_ferias.jpg  →  WebP q85 (92% ↓)   │
│  video_aniversario.mp4 → H.265 (58% ↓)  │
│  ...                                     │
│                                          │
│  Encontrados 1,247 arquivos              │
│  Economia estimada: 67%                  │
│                                          │
├──────────────────────────────────────────┤
│  Escaneando: 800/1247 (ETA: 2m 15s)     │
└──────────────────────────────────────────┘
```

### Relatório Final
```
┌──────────────────────────────────────────┐
│  🌿 EverFree                        🌙 ⚙ │
├──────────────────────────────────────────┤
│                                          │
│         ✅ Concluído!                    │
│                                          │
│  Original: ████████████████████ 48.3 GB  │
│  Depois:   ████████░░░░░░░░░░ 16.1 GB   │
│                                          │
│  📁 1,247 arquivos processados           │
│  💾 32.2 GB liberados                    │
│  📊 67% de economia                      │
│                                          │
│  Codecs usados: H.265 (842), WebP (405) │
│                                          │
│  [Nova Compressão]  [Ver Detalhes]       │
│                                          │
├──────────────────────────────────────────┤
│  ✅ 32.2 GB liberados em 1,247 arquivos │
└──────────────────────────────────────────┘
```

---

## 📋 Pré-requisitos

### Build
- **CMake** 3.16+
- **Qt6** com módulos: Core, Gui, Widgets, Qml, Quick, QuickControls2, Charts
- **FFmpeg** dev libraries (libavcodec, libavformat, libavutil, libswscale, libswresample)
- **libwebp** dev (opcional, para WebP)
- **C++17** compiler (GCC 9+, Clang 10+, MSVC 2019+)

### Runtime
- Qt6 runtime
- FFmpeg runtime (normalmente já instalado)

---

## 🚀 Build

### 1. Clone o repositório

```bash
cd ~/Dvl/projetos/
# EverFree já está aqui
```

### 2. Instale dependências

**Linux (Ubuntu/Debian):**
```bash
sudo apt install cmake qt6-base-dev qt6-declarative-dev \
    qt6-quickcontrols2-dev libavcodec-dev libavformat-dev \
    libavutil-dev libswscale-dev libswresample-dev libwebp-dev
```

### 3. Configure e compile

```bash
cd ~/Dvl/projetos/EverFree
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

### 4. Execute

```bash
./build/EverFree
```

---

## 📁 Estrutura do Projeto

```
EverFree/
├── CMakeLists.txt                 # Build principal
├── README.md                      # Este arquivo
├── src/
│   ├── main.cpp                   # Entry point
│   ├── AppController.cpp/.hpp     # Cérebro C++ (liga core → QML)
│   ├── SimpleMode.cpp/.hpp        # Modo leigo (auto-config)
│   ├── AdvancedMode.cpp/.hpp      # Modo avançado (controle total)
│   ├── workers/
│   │   ├── ScanWorker.cpp/.hpp    # Scan em background thread
│   │   ├── ProcessWorker.cpp/.hpp # Processamento de imagens
│   │   └── VideoProcessWorker.hpp # Processamento de vídeos
│   ├── models/
│   │   ├── FileItemModel.cpp/.hpp # Model de arquivos para QML
│   │   ├── ScanReportModel.cpp/.hpp # Model de relatório
│   │   └── ProgressModel.cpp/.hpp   # Model de progresso
│   └── utils/
│       ├── FileUtils.cpp/.hpp     # Helpers: formatBytes, ETA
│       └── ThemeManager.cpp/.hpp  # Dark/Light theme
├── qml/
│   ├── main.qml                   # Window principal + StackView
│   ├── pages/
│   │   ├── HomeModePicker.qml     # Escolha: Simples ou Avançado
│   │   ├── SimpleWelcome.qml      # Modo leigo: "Escanear Meu PC"
│   │   ├── AdvancedWelcome.qml    # Modo avançado: escolha pastas
│   │   ├── ScanPage.qml           # Scan com progresso
│   │   ├── SelectPage.qml         # Seleção de arquivos
│   │   ├── ProcessPage.qml        # Compressão em tempo real
│   │   └── ReportPage.qml         # Relatório final com gráficos
│   ├── components/
│   │   ├── SavingsBadge.qml       # Badge de economia (%)
│   │   ├── CodecBadge.qml         # Badge de codec (H.265, WebP)
│   │   ├── QualityStars.qml       # Estrelas de qualidade ★★★★☆
│   │   ├── FileListItem.qml       # Delegate de arquivo na lista
│   │   ├── BigButton.qml          # Botão grande (modo simples)
│   │   ├── FolderCard.qml         # Card de pasta
│   │   ├── StatusBar.qml          # Barra de status
│   │   └── SavingsChart.qml       # Gráfico original vs depois
│   └── dialogs/
│       ├── SettingsDialog.qml     # Configurações avançadas
│       ├── ErrorReportDialog.qml  # Pastas ignoradas
│       └── ConfirmDialog.qml      # Confirmação genérica
└── resources/
    └── icon.svg                   # Ícone do app
```

---

## 🎮 Usando o EverFree

### Modo Simples

1. **Abra o EverFree**
2. Clique em **"Modo Simples"**
3. Clique em **"🔍 Escanear Meu Computador"**
4. Aguarde — o app faz tudo sozinho
5. Veja o relatório: quanto espaço foi liberado!

**Pastas escaneadas automaticamente:**
- Pictures / Imagens
- Videos / Vídeos
- Desktop / Área de Trabalho
- Documents / Documentos
- Downloads

**Pastas sem permissão?** Ignoradas silenciosamente. Sem erros, sem popups.

### Modo Avançado

1. **Abra o EverFree**
2. Clique em **"Modo Avançado"**
3. Adicione pastas manualmente ou use "Adicionar Pastas do Usuário"
4. Configure: codec, CRF, resize, qualidade, threads
5. Clique em **"Escanear"**
6. Veja a projeção de economia
7. Selecione quais arquivos comprimir (ou selecione todos)
8. Clique em **"Processar"**
9. Veja o relatório detalhado

---

## ⚙️ Configurações Avançadas

### Imagens
| Config | Opções | Default |
|--------|--------|---------|
| Formato | same, webp, jpg, png, bmp | same |
| Qualidade | 1-100 | 90 |
| Resize | fit:1920x1080, 50%, 1920x1080, "" | fit:1920x1080 |

### Vídeos
| Config | Opções | Default |
|--------|--------|---------|
| Codec | auto, h265, h264, vp9 | auto |
| CRF | -1 (auto), 0-51 | -1 |
| Resolução máx | original, 4k, 1080p, 720p, 480p | 1080p |

### Geral
| Config | Opções | Default |
|--------|--------|---------|
| Threads | 0-64 | 0 (auto) |
| Recursivo | sim, não | sim |
| Dedup | sim, não | sim |

---

## 🔧 Arquitetura

```
┌─────────────────────────────────────────────┐
│                  QML UI                      │
│  (Material Design, animações, StackView)    │
└───────────────┬─────────────────────────────┘
                │ binds to
┌───────────────▼─────────────────────────────┐
│            AppController (C++)               │
│  - Mode management (Simple/Advanced)        │
│  - State machine (Idle→Scan→Process→Done)   │
│  - Worker orchestration                     │
└───┬──────────────┬──────────────┬───────────┘
    │              │              │
┌───▼──────┐ ┌────▼──────┐ ┌────▼──────────┐
│ScanWorker│ │ProcessWrk │ │VideoProcessWrk│
│  (QThread)│ │ (QThread) │ │  (QThread)    │
└───┬──────┘ └────┬──────┘ └────┬──────────┘
    │              │              │
    └──────────────┴──────────────┘
                   │ calls
┌──────────────────▼──────────────────────────┐
│         batchpress core library             │
│  - scan_files()                             │
│  - process_files()                          │
│  - process_video_files()                    │
│  - run_batch() / run_video_batch()          │
└─────────────────────────────────────────────┘
```

---

## 🐛 Troubleshooting

### "batchpress not found"
```bash
# Verifique se o batchpress está no path relativo correto
ls ~/Dvl/projetos/GitHub/batchpress/core/include/batchpress/types.hpp

# Ou passe o path explicitamente:
cmake -B build -DBATCHPRESS_DIR=/path/to/batchpress
```

### "Qt6 not found"
```bash
# Aponte para sua instalação Qt6
cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt6
```

### "FFmpeg not found"
```bash
# Linux
sudo apt install libavcodec-dev libavformat-dev libavutil-dev \
    libswscale-dev libswresample-dev
```

### "WebP not found"
```bash
# Linux (WebP é opcional — sem ele, fallback para PNG)
sudo apt install libwebp-dev
```

### App não abre
```bash
# Rode do terminal para ver logs
./build/EverFree

# Verifique dependências
ldd ./build/EverFree | grep "not found"
```

---

## 📄 Licença

MIT © [Marco Antônio Bueno da Silva](mailto:bueno.marco@gmail.com)

---

## 🙏 Créditos

- **batchpress** — Core library de compressão paralela
- **Qt6** — Framework UI
- **FFmpeg** — Codec de vídeo
- **libwebp** — Codec WebP
- **stb** — Load/resize/save de imagens

---

Feito com ❤️ para **nunca mais você se preocupar com espaço em disco**.
