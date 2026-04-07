import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
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

            // Contador de arquivos durante scan
            Label {
                visible: appController.state === AppController.Scanning &&
                         appController.progressModel.total > 0
                text: appController.progressModel.done + " / " +
                      appController.progressModel.total + " arquivos"
                font.pixelSize: 13
                color: Material.color(Material.Green, Material.Shade400)
                opacity: 0.85
            }

            // Percentual durante processamento
            Label {
                visible: appController.state === AppController.Processing &&
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
            HomeModePicker { objectName: "homeModePicker" }
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
                if (current !== "homeModePicker" && current !== "simpleWelcome" && current !== "advancedWelcome") {
                    stackView.pop(null)
                    if (appController.mode === AppController.Advanced) {
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
                if (appController.mode === AppController.Simple) {
                    if (current !== "processPage") stackView.push(processPage)
                } else {
                    if (current !== "selectPage") stackView.push(selectPage)
                }
                break
            case AppController.AwaitingConfirmation:
                if (current !== "scanPage") {
                    stackView.clear()
                    stackView.push(scanPage)
                }
                break
            case AppController.Selecting:
                if (current !== "selectPage") stackView.push(selectPage)
                break
            case AppController.Processing:
                if (current !== "processPage") stackView.push(processPage)
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

    SettingsDialog { id: settingsDialog }
}
