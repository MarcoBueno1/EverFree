import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

ApplicationWindow {
    id: root
    width: 900
    height: 700
    minimumWidth: 700
    minimumHeight: 500
    visible: true
    title: qsTr("EverFree \u2014 Libere espa\u00e7o no seu disco")
    color: Material.color(Material.Grey, Material.Shade900)

    Material.theme: themeManager.darkMode ? Material.Dark : Material.Light
    Material.primary: Material.Green
    Material.accent: Material.Lime

    // ---- Page Component definitions ----
    Component {
        id: homeModeComponent
        HomeModePicker {
            objectName: "homeModePicker"
            simpleWelcomeComp: simpleWelcomeComp
            scanPageComp: scanPageComp
            stackViewRef: stackView
        }
    }

    Component {
        id: simpleWelcomeComp
        SimpleWelcome {
            objectName: "simpleWelcome"
            scanPageComp: scanPageComp
            stackViewRef: stackView
        }
    }

    Component {
        id: scanPageComp
        ScanPage { objectName: "scanPage" }
    }

    Component {
        id: selectPageComp
        SelectPage { objectName: "selectPage" }
    }

    Component {
        id: processPageComp
        ProcessPage { objectName: "processPage" }
    }

    Component {
        id: reportPageComp
        ReportPage { objectName: "reportPage" }
    }

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
                font.weight: Font.Bold
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

    footer: Rectangle {
        color: Material.color(Material.Grey, Material.Shade900)
        height: 28

        Label {
            anchors.centerIn: parent
            text: appController.simpleStatus || qsTr("Pronto")
            font.pixelSize: 11
            color: "#aaaaaa"
            elide: Text.ElideMiddle
        }
    }

    // StackView — starts with SimpleWelcome (default mode)
    StackView {
        id: stackView
        anchors.fill: parent
        anchors.bottomMargin: 0
        initialItem: simpleWelcomeComp
    }

    // On startup, check if we should show mode picker instead (advanced mode)
    Timer {
        id: startupTimer
        interval: 50
        repeat: false
        running: true
        onTriggered: {
            if (appController.defaultMode === 2) {
                stackView.clear()
                stackView.push(homeModeComponent)
            }
        }
    }

    // Navigation state controller
    Connections {
        target: appController

        function onStateChanged() {
            pushPageForState(appController.state)
        }
    }

    function pushPageForState(state) {
        switch (state) {
            case AppController.Idle:
                if (stackView.currentItem && stackView.currentItem.objectName !== "homeModePicker"
                    && stackView.currentItem.objectName !== "simpleWelcome") {
                    stackView.pop(null)
                    stackView.push(homeModeComponent)
                }
                break
            case AppController.ModeSelected:
                break
            case AppController.Scanning:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "scanPage") {
                    stackView.clear()
                    stackView.push(scanPageComp)
                }
                break
            case AppController.ScanComplete:
                if (appController.mode === AppController.Simple) {
                    if (!stackView.currentItem || stackView.currentItem.objectName !== "processPage") {
                        stackView.push(processPageComp)
                    }
                } else {
                    if (!stackView.currentItem || stackView.currentItem.objectName !== "selectPage") {
                        stackView.push(selectPageComp)
                    }
                }
                break
            case AppController.Selecting:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "selectPage") {
                    stackView.push(selectPageComp)
                }
                break
            case AppController.Processing:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "processPage") {
                    stackView.push(processPageComp)
                }
                break
            case AppController.Complete:
            case AppController.Error:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "reportPage") {
                    stackView.push(reportPageComp)
                }
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

    SettingsDialog {
        id: settingsDialog
    }
}
