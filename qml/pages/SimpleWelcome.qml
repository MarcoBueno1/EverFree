import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "simpleWelcome"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 0

        // Back button
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: qsTr("\u2190 Voltar")
                flat: true
                Material.foreground: Material.hintTextColor
                font.pixelSize: 14
                onClicked: {
                    appController.reset()
                    if (StackView.view) StackView.view.pop()
                }
            }

            Item { Layout.fillWidth: true }
        }

        Item { Layout.preferredHeight: 20 }

        // Main content card
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(560, root.width - 80)
            Layout.preferredHeight: 380
            color: Material.color(Material.Grey, Material.Shade800)
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 36
                spacing: 24

                Label {
                    text: "\uD83D\uDCBB"
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("Vamos liberar espa\u00e7o do seu computador")
                    font.pixelSize: 22
                    font.bold: true
                    color: Material.foreground
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("Pastas pessoais ser\u00e3o escaneadas automaticamente.\nPastas sem acesso ser\u00e3o ignoradas.")
                    font.pixelSize: 13
                    color: Material.hintTextColor
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Item { Layout.fillHeight: true }

                // Scan button
                Button {
                    id: scanButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 60
                    highlighted: true
                    enabled: !scanning
                    Material.background: Material.color(Material.Green, Material.Shade700)
                    Material.foreground: Material.primaryTextColor

                    property bool scanning: false

                    contentItem: Label {
                        text: scanButton.scanning
                            ? "\u23F3 Escaneando..."
                            : "\uD83D\uDD0D Escanear Meu Computador"
                        font.pixelSize: 20
                        font.bold: true
                        color: parent.Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 16
                        color: scanButton.scanning
                            ? Material.color(Material.Green, Material.Shade800)
                            : parent.pressed
                                ? Material.color(Material.Green, Material.Shade900)
                                : parent.hovered
                                    ? Material.color(Material.Green, Material.Shade600)
                                    : Material.color(Material.Green, Material.Shade700)
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    onClicked: {
                        scanButton.scanning = true
                        appController.addDefaultUserFolders()
                        appController.startScan()
                    }
                }

                Item { Layout.fillHeight: true; Layout.preferredHeight: 10 }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
