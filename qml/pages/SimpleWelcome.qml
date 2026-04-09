import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "simpleWelcome"

    background: Rectangle {
        color: Material.color(Material.Grey, Material.Shade900)
    }

    // Botão Voltar ancorado ao topo
    Button {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 8
        anchors.leftMargin: 12
        text: qsTr("\u2190 Voltar")
        flat: true
        Material.foreground: Material.hintTextColor
        font.pixelSize: 14
        onClicked: {
            appController.reset()
            if (StackView.view) StackView.view.pop()
        }
    }

    // Card centralizado com leve offset para compensar o botão Voltar
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
        width: Math.min(520, parent.width - 64)
        height: 360
        color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
        radius: 14

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 0

            Label {
                text: "\uD83D\uDCBB"
                font.pixelSize: 64
                Layout.alignment: Qt.AlignHCenter
            }

            Item { height: 18 }

            Label {
                text: qsTr("Vamos liberar espa\u00e7o do seu computador")
                font.pixelSize: 20
                font.bold: true
                color: Material.foreground
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            Item { height: 10 }

            Label {
                text: qsTr("Pastas pessoais ser\u00e3o escaneadas automaticamente.\nPastas sem acesso ser\u00e3o ignoradas.")
                font.pixelSize: 13
                color: Material.hintTextColor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            Item { Layout.fillHeight: true }

            Button {
                id: scanButton
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                enabled: appController.state !== AppController.Scanning

                contentItem: Label {
                    text: {
                        if (appController.state === AppController.Scanning)
                            return "\u23F3 Escaneando..."
                        if (appController.state === AppController.ScanComplete ||
                            appController.state === AppController.AwaitingConfirmation)
                            return "\u2705 Escaneamento Conclu\u00eddo"
                        return "\uD83D\uDD0D Escanear Meu Computador"
                    }
                    font.pixelSize: 17
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 14
                    color: {
                        if (!scanButton.enabled)
                            return Material.color(Material.Green, Material.Shade800)
                        if (scanButton.pressed)
                            return Material.color(Material.Green, Material.Shade900)
                        if (scanButton.hovered)
                            return Material.color(Material.Green, Material.Shade600)
                        return Material.color(Material.Green, Material.Shade700)
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                onClicked: {
                    appController.addDefaultUserFolders()
                    appController.startScan()
                }
            }
        }
    }
}
