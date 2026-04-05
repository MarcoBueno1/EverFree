import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "homeModePicker"

    // Prevent back navigation from home
    StackView.onRemoved: destroy()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item { Layout.fillHeight: true }

        // Title section
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Label {
                text: "\uD83C\uDF3F"
                font.pixelSize: 64
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Bem-vindo ao EverFree")
                font.pixelSize: 32
                font.bold: true
                font.weight: Font.Bold
                color: Material.foreground
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: qsTr("Libere espa\u00e7o no seu disco automaticamente")
                font.pixelSize: 16
                color: Material.hintTextColor
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.topMargin: 4
            }
        }

        Item { Layout.fillHeight: true; Layout.preferredHeight: 20 }

        // Two cards side by side
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            Layout.bottomMargin: 20
            spacing: 30

            // Modo Simples card
            Rectangle {
                id: simpleCard
                Layout.fillWidth: true
                Layout.preferredHeight: 320
                Material.background: Material.color(Material.Grey, Material.Shade800)
                Material.elevation: hovered ? 8 : 2

                property bool hovered: false

                Behavior on Material.elevation {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: simpleCard.hovered = true
                    onExited: simpleCard.hovered = false
                    onClicked: selectSimpleMode()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 16

                    // Icon
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 80
                        height: 80
                        radius: 40
                        color: Material.color(Material.Green, Material.Shade800)

                        Label {
                            anchors.centerIn: parent
                            text: "\u26A1"
                            font.pixelSize: 40
                        }
                    }

                    Label {
                        text: qsTr("Modo Simples")
                        font.pixelSize: 22
                        font.bold: true
                        font.weight: Font.Bold
                        color: Material.color(Material.Green, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: qsTr("Um clique, zero decis\u00f5es.\nEscaneia e comprime tudo automaticamente.")
                        font.pixelSize: 14
                        color: Material.hintTextColor
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { Layout.fillHeight: true }

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 220
                        text: qsTr("\u26A1 Come\u00e7ar Agora")
                        highlighted: true
                        Material.background: Material.color(Material.Green, Material.Shade700)
                        Material.foreground: Material.primaryTextColor
                        font.pixelSize: 15
                        font.bold: true
                        onClicked: selectSimpleMode()
                    }
                }
            }

            // Modo Avan\u00e7ado card
            Rectangle {
                id: advancedCard
                Layout.fillWidth: true
                Layout.preferredHeight: 320
                Material.background: Material.color(Material.Grey, Material.Shade800)
                Material.elevation: hovered ? 8 : 2

                property bool hovered: false

                Behavior on Material.elevation {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: advancedCard.hovered = true
                    onExited: advancedCard.hovered = false
                    onClicked: selectAdvancedMode()
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 16

                    // Icon
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 80
                        height: 80
                        radius: 40
                        color: Material.color(Material.Blue, Material.Shade800)

                        Label {
                            anchors.centerIn: parent
                            text: "\uD83D\uDD27"
                            font.pixelSize: 40
                        }
                    }

                    Label {
                        text: qsTr("Modo Avan\u00e7ado")
                        font.pixelSize: 22
                        font.bold: true
                        font.weight: Font.Bold
                        color: Material.color(Material.Blue, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: qsTr("Controle total: pastas, codecs, qualidade e configura\u00e7\u00f5es.")
                        font.pixelSize: 14
                        color: Material.hintTextColor
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { Layout.fillHeight: true }

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 220
                        text: qsTr("\uD83D\uDD27 Configurar")
                        highlighted: true
                        Material.background: Material.color(Material.Blue, Material.Shade700)
                        Material.foreground: Material.primaryTextColor
                        font.pixelSize: 15
                        font.bold: true
                        onClicked: selectAdvancedMode()
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    function selectSimpleMode() {
        appController.setMode(AppController.Simple)
        appController.startSimpleMode()
    }

    function selectAdvancedMode() {
        appController.setMode(AppController.Advanced)
    }
}
