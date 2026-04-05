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

    StackView {
        id: stackView
        anchors.fill: parent
        anchors.bottomMargin: 0
        initialItem: simpleWelcomePage

        Component {
            id: simpleWelcomePage
            SimpleWelcome { objectName: "simpleWelcome" }
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
                stackView.push(homeModePage)
            }
        }
    }

    Connections {
        target: appController
        function onStateChanged() {
            pushPageForState(appController.state)
        }
    }

    function pushPageForState(state) {
        var current = stackView.currentItem ? stackView.currentItem.objectName : ""

        switch (state) {
            case AppController.Idle:
                if (current !== "homeModePicker" && current !== "simpleWelcome") {
                    stackView.pop(null)
                    stackView.push(homeModePage)
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
            if (appController.state === AppController.Scanning || appController.state === AppController.Processing) {
                appController.cancel()
            } else if (stackView.depth > 1) {
                stackView.pop()
            }
        }
    }

    SettingsDialog { id: settingsDialog }
}
