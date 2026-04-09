import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import EverFree 1.0

Page {
    id: root
    objectName: "advancedWelcome"
    leftPadding: 30
    rightPadding: 30
    topPadding: 20
    bottomPadding: 30

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
        spacing: 20

        // Title
        Label {
            text: qsTr("\uD83D\uDCC2 Selecione as pastas")
            font.pixelSize: 24
            font.bold: true
            font.weight: Font.Bold
            color: Material.foreground
            Layout.bottomMargin: 4
        }

        // Folder list card
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Material.background: Material.color(Material.Grey, Material.Shade800)
            Material.elevation: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Folder list header
                RowLayout {
                    spacing: 8

                    Label {
                        text: qsTr("Pastas selecionadas: %1").arg(appController.folderPaths.length)
                        font.pixelSize: 13
                        color: Material.hintTextColor
                    }

                    Item { Layout.fillWidth: true }

                    // Recursive checkbox
                    CheckBox {
                        id: recursiveCheck
                        text: qsTr("Busca recursiva")
                        checked: appController.recursive
                        Material.foreground: Material.hintTextColor
                        font.pixelSize: 13
                        onCheckedChanged: appController.recursive = checked
                    }
                }

                // Folder list
                ListView {
                    id: folderList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: appController.folderPaths
                    spacing: 4
                    ScrollBar.vertical: ScrollBar {}

                    delegate: RowLayout {
                        width: folderList.width
                        spacing: 8

                        Label {
                            text: "\uD83D\uDCC1"
                            font.pixelSize: 16
                        }

                        Label {
                            text: modelData
                            font.pixelSize: 13
                            color: Material.foreground
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                            
                            ToolTip.visible: hovered
                            ToolTip.text: "Double-click para abrir no gerenciador de arquivos"
                        }

                        RoundButton {
                            text: "\u2715"
                            font.pixelSize: 12
                            flat: true
                            display: AbstractButton.TextOnly
                            Material.foreground: Material.color(Material.Red, Material.Shade400)
                            onClicked: appController.removeFolder(index)
                        }

                        // Double-click to open folder
                        MouseArea {
                            anchors.fill: parent
                            onDoubleClicked: {
                                var path = appController.folderPaths[index]
                                Qt.openUrlExternally("file://" + path)
                            }
                        }
                    }

                    // Empty state
                    Label {
                        anchors.centerIn: parent
                        visible: folderList.count === 0
                        text: qsTr("Nenhuma pasta selecionada.\nAdicione pastas para come\u00e7ar a escaneamento.")
                        font.pixelSize: 14
                        color: Material.hintTextColor
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        // Action buttons
        RowLayout {
            spacing: 12

            Button {
                text: qsTr("\u2795 Adicionar Pasta")
                highlighted: false
                Material.foreground: Material.foreground
                onClicked: folderDialog.open()
            }

            Button {
                text: qsTr("\uD83C\uDFE0 Adicionar Pastas do Usu\u00e1rio")
                highlighted: false
                Material.foreground: Material.foreground
                onClicked: appController.addDefaultUserFolders()
            }

            Item { Layout.fillWidth: true }

            Button {
                id: scanButton
                text: qsTr("\uD83D\uDD0D Escanear")
                highlighted: true
                Material.background: Material.color(Material.Green, Material.Shade700)
                Material.foreground: Material.primaryTextColor
                font.pixelSize: 15
                font.bold: true
                enabled: appController.folderPaths.length > 0

                onClicked: appController.startScan()
            }
        }
    }

    FileDialog {
        id: folderDialog
        title: qsTr("Selecionar Pasta")
        fileMode: FileDialog.Directory
        onAccepted: {
            if (selectedFolder) {
                // FIX: Use proper URL decoding for paths with special characters
                var path = selectedFolder.toString()
                if (path.startsWith("file://")) {
                    path = path.substring(7)  // Remove "file://"
                }
                // Decode URL-encoded characters (e.g., %20 -> space)
                path = decodeURIComponent(path)
                appController.addFolder(path)
            }
        }
    }
}
