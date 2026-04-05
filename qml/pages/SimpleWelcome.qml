import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "simpleWelcome"
    leftPadding: 40
    rightPadding: 40
    topPadding: 30
    bottomPadding: 30

    // Back button
    header: ToolBar {
        Material.background: "transparent"
        Material.elevation: 0

        Button {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("\u2190 Voltar")
            flat: true
            Material.foreground: Material.hintTextColor
            font.pixelSize: 14
            onClicked: {
                appController.reset()
                StackView.view.pop()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item { Layout.fillHeight: true; Layout.preferredHeight: 30 }

        // Central card
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.min(560, root.width - 80)
            Layout.preferredHeight: 380
            Material.background: Material.color(Material.Grey, Material.Shade800)
            Material.elevation: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 36
                spacing: 24

                // Big icon
                Label {
                    text: "\uD83D\uDCBB"
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("Vamos liberar espa\u00e7o do seu computador")
                    font.pixelSize: 22
                    font.bold: true
                    font.weight: Font.Bold
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

                // Giant green button
                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 360
                    Layout.preferredHeight: 60
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade700)
                    Material.foreground: Material.primaryTextColor

                    contentItem: Label {
                        text: "\uD83D\uDD0D Escanear Meu Computador"
                        font.pixelSize: 20
                        font.bold: true
                        font.weight: Font.Bold
                        color: parent.Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 16
                        color: parent.pressed
                            ? Material.color(Material.Green, Material.Shade900)
                            : parent.hovered
                                ? Material.color(Material.Green, Material.Shade600)
                                : Material.color(Material.Green, Material.Shade700)

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    onClicked: {
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
