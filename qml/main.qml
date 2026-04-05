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

            // Theme toggle
            RoundButton {
                text: themeManager.darkMode ? "\u2600\uFE0F" : "\uD83C\uDF19"
                font.pixelSize: 18
                flat: true
                Material.foreground: Material.foreground
                ToolTip.visible: hovered
                ToolTip.text: themeManager.darkMode ? qsTr("Modo Claro") : qsTr("Modo Escuro")
                onClicked: themeManager.toggleTheme()
            }

            // Settings button
            RoundButton {
                text: "\u2699\uFE0F"
                font.pixelSize: 18
                flat: true
                Material.foreground: Material.foreground
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Configura\u00e7\u00f5es")
                // onClicked: settingsDialog.open()
            }
        }
    }

    footer: ToolBar {
        Material.background: Material.color(Material.Grey, Material.Shade800)
        Material.elevation: 2

        Label {
            anchors.centerIn: parent
            text: appController.simpleStatus
            font.pixelSize: 12
            color: Material.hintTextColor
            elide: Text.ElideMiddle
            padding: 8
        }
    }

    // StackView como elemento principal
    StackView {
        id: stackView
        anchors.fill: parent
        anchors.bottomMargin: 0
        initialItem: pagesComponent
    }

    // Navigation state controller
    Connections {
        target: appController

        function onStateChanged() {
            pushPageForState(appController.state)
        }

        function onSimpleStatusChanged() {
            // status bar updates automatically via binding
        }
    }

    function pushPageForState(state) {
        switch (state) {
            case AppController.Idle:
                if (stackView.currentItem && stackView.currentItem.objectName !== "homeModePicker") {
                    stackView.pop(null)
                    stackView.push(homeModePicker)
                }
                break
            case AppController.ModeSelected:
                if (stackView.currentItem && stackView.currentItem.objectName !== "modePicker") {
                    // Stay on current page
                }
                break
            case AppController.Scanning:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "scanPage") {
                    stackView.push(scanPageComponent)
                }
                break
            case AppController.ScanComplete:
                if (appController.mode === AppController.Simple) {
                    // Simple mode: auto-advance to processing
                    if (!stackView.currentItem || stackView.currentItem.objectName !== "processPage") {
                        stackView.push(processPageComponent)
                    }
                } else {
                    if (!stackView.currentItem || stackView.currentItem.objectName !== "selectPage") {
                        stackView.push(selectPageComponent)
                    }
                }
                break
            case AppController.Selecting:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "selectPage") {
                    stackView.push(selectPageComponent)
                }
                break
            case AppController.Processing:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "processPage") {
                    stackView.push(processPageComponent)
                }
                break
            case AppController.Complete:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "reportPage") {
                    stackView.push(reportPageComponent)
                }
                break
            case AppController.Error:
                if (!stackView.currentItem || stackView.currentItem.objectName !== "reportPage") {
                    stackView.push(reportPageComponent)
                }
                break
        }
    }

    // Home Mode Picker (initial page)
    Component {
        id: pagesComponent
        HomeModePicker { id: homeModePicker; objectName: "homeModePicker" }
    }

    Component {
        id: scanPageComponent
        ScanPage { id: scanPage; objectName: "scanPage" }
    }

    Component {
        id: selectPageComponent
        SelectPage { id: selectPage; objectName: "selectPage" }
    }

    Component {
        id: processPageComponent
        ProcessPage { id: processPage; objectName: "processPage" }
    }

    Component {
        id: reportPageComponent
        ReportPage { id: reportPage; objectName: "reportPage" }
    }

    // Keyboard shortcuts
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
}
