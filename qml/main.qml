import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
import EverFree 1.0

ApplicationWindow {
    id: root
    width: 900
    height: 720
    minimumWidth: 700
    minimumHeight: 560
    visible: true
    title: qsTr("EverFree \u2014 Libere espa\u00e7o no seu disco")
    color: Material.color(Material.Grey, Material.Shade900)

    Material.theme: themeManager.darkMode ? Material.Dark : Material.Light
    Material.primary: Material.Green
    Material.accent: Material.Lime

    // ── Show onboarding on first use ──────────────────────────────────────
    Component.onCompleted: {
        if (!onboardingSettings.onboardingSeen) {
            onboardingTimer.start()
        }
    }

    Timer {
        id: onboardingTimer
        interval: 500
        onTriggered: onboardingDialog.open()
    }

    Settings {
        id: onboardingSettings
        category: "onboarding"
        property bool onboardingSeen: false
    }

    // ── Header ──────────────────────────────────────────────────────────────
    header: ToolBar {
        Material.background: Material.color(Material.Grey, Material.Shade800)
        Material.elevation: 4

        RowLayout {
            anchors.fill: parent
            spacing: 16

            Label {
                text: "\uD83C\uDF3F EverFree"
                font.pixelSize: 22
                font.bold: true
                color: Material.color(Material.Green, Material.Shade300)
                Layout.leftMargin: 20
            }

            // Mode indicator badge
            Rectangle {
                width: modeLabel.width + 16
                height: 28
                radius: 14
                color: appController.mode === AppController.Simple ?
                       Material.color(Material.Green, Material.Shade800) :
                       Material.color(Material.Blue, Material.Shade800)
                opacity: 0.9

                Label {
                    id: modeLabel
                    anchors.centerIn: parent
                    text: appController.mode === AppController.Simple ?
                          "\uD83D\uDD30 Modo Simples" : "\uD83C\uDF9B\uFE0F Modo Avan\u00e7ado"
                    font.pixelSize: 11
                    font.bold: true
                    color: Material.primaryTextColor
                }

                ToolTip.visible: parent.hovered
                ToolTip.text: appController.mode === AppController.Simple ?
                    "Modo simples: um clique e pronto! Mude nas configura\u00e7\u00f5es." :
                    "Modo avan\u00e7ado: controle total de codecs, qualidade e resolu\u00e7\u00e3o"
            }

            Item { Layout.fillWidth: true }

            RoundButton {
                text: themeManager.darkMode ? "\u2600\uFE0F" : "\uD83C\uDF19"
                font.pixelSize: 18
                flat: true
                Material.foreground: Material.foreground
                ToolTip.visible: hovered
                ToolTip.text: themeManager.darkMode ? qsTr("Modo Claro") : qsTr("Modo Escuro")
                onClicked: themeManager.toggleTheme()
            }

            RoundButton {
                text: "\u2699\uFE0F"
                font.pixelSize: 18
                flat: true
                Material.foreground: Material.foreground
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configura\u00e7\u00f5es")
                onClicked: settingsDialog.open()
            }
        }
    }

    // ── Footer melhorado ────────────────────────────────────────────────────
    footer: Rectangle {
        id: appFooter
        color: Material.color(Material.Grey, Material.Shade900)
        height: 44
        border.color: Material.color(Material.Grey, Material.Shade800)
        border.width: 1

        readonly property bool isActive:
            appController.state === AppController.Scanning ||
            appController.state === AppController.Processing

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            // Ponto pulsante durante operações ativas
            Rectangle {
                width: 8
                height: 8
                radius: 4
                visible: appFooter.isActive
                color: appController.state === AppController.Processing
                       ? Material.color(Material.Amber, Material.Shade400)
                       : Material.color(Material.Green, Material.Shade400)

                SequentialAnimation on opacity {
                    running: appFooter.isActive
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                }
            }

            // Mensagem principal
            Label {
                Layout.fillWidth: true
                text: appController.simpleStatus || qsTr("Pronto")
                font.pixelSize: 14
                color: {
                    if (appController.state === AppController.Error)
                        return Material.color(Material.Red, Material.Shade300)
                    if (appController.state === AppController.Complete)
                        return Material.color(Material.Green, Material.Shade300)
                    if (appFooter.isActive)
                        return Material.foreground
                    return "#999999"
                }
                elide: Text.ElideMiddle
            }

            // Contador de arquivos durante scan ou processamento
            Label {
                visible: (appController.state === AppController.Processing ||
                          appController.state === AppController.Scanning) &&
                         appController.progressModel.total > 0
                text: appController.progressModel.done + " / " +
                      appController.progressModel.total + " arquivos"
                font.pixelSize: 13
                color: Material.color(Material.Green, Material.Shade400)
                opacity: 0.85
            }

            // Percentual durante processamento ou scan
            Label {
                visible: (appController.state === AppController.Processing ||
                          appController.state === AppController.Scanning) &&
                         appController.progressModel.total > 0
                text: Math.round(appController.progressModel.percent) + "%"
                font.pixelSize: 13
                font.bold: true
                color: Material.color(Material.Amber, Material.Shade300)
            }
        }
    }

    // ── Conteúdo principal ──────────────────────────────────────────────────
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: simpleWelcomePage

        Component {
            id: simpleWelcomePage
            SimpleWelcome { objectName: "simpleWelcome" }
        }
        Component {
            id: advancedWelcomePage
            AdvancedWelcome { objectName: "advancedWelcome" }
        }
        Component {
            id: homeModePage
            HomeModePicker {
                objectName: "homeModePicker"
                simpleWelcomeComp: simpleWelcomePage
                advancedWelcomeComp: advancedWelcomePage
                scanPageComp: scanPage
                stackViewRef: stackView
            }
        }
        Component {
            id: scanPage
            ScanPage { objectName: "scanPage" }
        }
        Component {
            id: selectPage
            SelectPage { objectName: "selectPage" }
        }
        Component {
            id: processPage
            ProcessPage { objectName: "processPage" }
        }
        Component {
            id: reportPage
            ReportPage { objectName: "reportPage" }
        }
    }

    Timer {
        id: startupTimer
        interval: 50
        repeat: false
        running: true
        onTriggered: {
            if (appController.defaultMode === 2) {
                stackView.clear()
                stackView.push(advancedWelcomePage)
            }
        }
    }

    Connections {
        target: appController
        function onStateChanged() {
            pushPageForState(appController.state)
        }
        function onModeChanged() {
            updatePageForMode()
        }
    }

    function updatePageForMode() {
        var current = stackView.currentItem ? stackView.currentItem.objectName : ""
        if (current === "simpleWelcome" || current === "advancedWelcome") {
            if (appController.mode === AppController.Simple && current !== "simpleWelcome") {
                stackView.replace(current, simpleWelcomePage)
            } else if (appController.mode === AppController.Advanced && current !== "advancedWelcome") {
                stackView.replace(current, advancedWelcomePage)
            }
        }
    }

    function pushPageForState(state) {
        var current = stackView.currentItem ? stackView.currentItem.objectName : ""

        switch (state) {
            case AppController.Idle:
                // FIX T6: Use clear() + push to avoid accumulating duplicate pages
                if (current !== "simpleWelcome" && current !== "advancedWelcome" && current !== "homeModePicker") {
                    stackView.clear()
                    if (appController.defaultMode === 2) {
                        stackView.push(advancedWelcomePage)
                    } else {
                        stackView.push(simpleWelcomePage)
                    }
                }
                break
            case AppController.Scanning:
                if (current !== "scanPage") {
                    stackView.clear()
                    stackView.push(scanPage)
                }
                break
            case AppController.ScanComplete:
                if (appController.defaultMode === 2) {
                    if (current !== "selectPage") stackView.push(selectPage)
                } else {
                    if (current !== "processPage") stackView.push(processPage)
                }
                break
            case AppController.AwaitingConfirmation:
                if (current !== "scanPage") {
                    stackView.clear()
                    stackView.push(scanPage)
                }
                break
            case AppController.Processing:
                if (current !== "processPage") {
                    var pg = stackView.push(processPage)
                    if (pg && pg.objectName === "processPage") {
                        pg.stackViewRef = stackView
                    }
                }
                break
            case AppController.Complete:
            case AppController.Error:
                if (current !== "reportPage") stackView.push(reportPage)
                break
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (appController.state === AppController.Scanning ||
                appController.state === AppController.Processing) {
                appController.cancel()
            } else if (stackView.depth > 1) {
                stackView.pop()
            }
        }
    }

    // Power user keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+S"
        onActivated: {
            if (appController.state === AppController.Idle) {
                // Start scan with keyboard shortcut
                if (appController.defaultMode === 2) {
                    // Advanced mode - need to trigger from UI
                } else {
                    // Simple mode - auto start
                    appController.addDefaultUserFolders()
                    appController.startScan()
                }
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            // Reset to start
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
                appController.addDefaultUserFolders()
                appController.startScan()
            }
        }
    }

    SettingsDialog { id: settingsDialog }
    OnboardingDialog {
        id: onboardingDialog
        onAccepted: {
            onboardingSettings.onboardingSeen = true
        }
    }
}
