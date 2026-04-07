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

    // Reference to components and stackView
    property Component simpleWelcomeComp: null
    property Component scanPageComp: null
    property var stackViewRef: null

    // Save default mode preference
    property bool saveDefaultMode: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item { Layout.fillHeight: true }

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

            // Modo Avançado card
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

        // Bottom action bar: save default mode + close
        Rectangle {
            Layout.fillWidth: true
            height: 60
            Material.background: Material.color(Material.Grey, Material.Shade900)
            border.color: Material.color(Material.Grey, Material.Shade800)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 32
                anchors.rightMargin: 32
                spacing: 16

                CheckBox {
                    id: saveDefaultCheck
                    text: qsTr("Salvar como modo padr\u00e3o")
                    checked: root.saveDefaultMode
                    onCheckedChanged: root.saveDefaultMode = checked
                    Material.foreground: Material.foreground
                    font.pixelSize: 14
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: qsTr("\u2715 Sair")
                    flat: true
                    Material.foreground: Material.hintTextColor
                    font.pixelSize: 14
                    onClicked: Qt.quit()
                }
            }
        }
    }

    function selectSimpleMode() {
        appController.setMode(AppController.Simple)
        if (saveDefaultMode) {
            appController.defaultMode = AppController.Simple
            appController.saveDefaultMode()
        }
        if (stackViewRef) stackViewRef.push(simpleWelcomeComp)
        else if (stackView) stackView.push(simpleWelcomeComp)
    }

    function selectAdvancedMode() {
        appController.setMode(AppController.Advanced)
        if (saveDefaultMode) {
            appController.defaultMode = AppController.Advanced
            appController.saveDefaultMode()
        }
        if (stackViewRef) stackViewRef.push(scanPageComp)
        else if (stackView) stackView.push(scanPageComp)
    }
}
