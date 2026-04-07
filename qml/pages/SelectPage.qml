import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "selectPage"
    leftPadding: 24
    rightPadding: 24
    topPadding: 20
    bottomPadding: 24

    // Filter state
    property string filterText: ""
    property int filterType: 0 // 0=All, 1=Images, 2=Videos
    property int selectedCount: 0

    // Helper function to format bytes
    function formatBytes(bytes) {
        if (bytes === 0) return "0 B"
        if (bytes < 1024) return bytes + " B"
        var k = 1024
        var sizes = ["KB", "MB", "GB", "TB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return (bytes / Math.pow(k, i)).toFixed(i > 0 ? 1 : 0) + " " + sizes[i]
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Summary header
        Item {
            Layout.fillWidth: true
            implicitHeight: summaryContent.height + 24

            Rectangle {
                id: summaryCard
                anchors.fill: parent
                radius: 10
                Material.background: Material.color(Material.Green, Material.Shade900)
                Material.elevation: 2

                RowLayout {
                    id: summaryContent
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Label {
                        text: "\uD83D\uDCCB"
                        font.pixelSize: 24
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Label {
                            text: qsTr("%1 arquivos").arg(appController.fileModel.rowCount())
                            font.pixelSize: 15
                            font.bold: true
                            color: Material.color(Material.Green, Material.Shade200)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: qsTr("Economia estimada: %1").arg(formatBytes(appController.reportModel.totalSavings))
                            font.pixelSize: 14
                            color: Material.color(Material.Green, Material.Shade300)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "%1 \u2192 %2"
                                .arg(formatBytes(appController.reportModel.totalSize))
                                .arg(formatBytes(appController.reportModel.totalProjectedSize))
                            font.pixelSize: 12
                            color: Material.color(Material.Green, Material.Shade400)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // Filter bar
        RowLayout {
            spacing: 12

            // Search field
            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: qsTr("\uD83D\uDD0E Filtrar por nome...")
                text: root.filterText
                Material.background: Material.color(Material.Grey, Material.Shade800)
                Material.foreground: Material.foreground
                font.pixelSize: 14
                implicitHeight: 40

                onTextChanged: root.filterText = text

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        clear()
                        event.accepted = true
                    }
                }
            }

            Button {
                visible: searchField.text.length > 0
                text: "\u2715"
                flat: true
                display: AbstractButton.TextOnly
                Material.foreground: Material.hintTextColor
                onClicked: searchField.clear()
            }
        }

        // Filter type toggles
        RowLayout {
            spacing: 8

            Button {
                text: qsTr("Todos")
                highlighted: root.filterType === 0
                flat: root.filterType !== 0
                Material.background: root.filterType === 0
                    ? Material.color(Material.Green, Material.Shade700) : "transparent"
                Material.foreground: root.filterType === 0
                    ? Material.primaryTextColor : Material.hintTextColor
                font.pixelSize: 13
                onClicked: root.filterType = 0
            }

            Button {
                text: qsTr("\uD83D\uDDBC\uFE0F Imagens")
                highlighted: root.filterType === 1
                flat: root.filterType !== 1
                Material.background: root.filterType === 1
                    ? Material.color(Material.Green, Material.Shade700) : "transparent"
                Material.foreground: root.filterType === 1
                    ? Material.primaryTextColor : Material.hintTextColor
                font.pixelSize: 13
                onClicked: root.filterType = 1
            }

            Button {
                text: qsTr("\uD83C\uDFAC V\u00eddeos")
                highlighted: root.filterType === 2
                flat: root.filterType !== 2
                Material.background: root.filterType === 2
                    ? Material.color(Material.Green, Material.Shade700) : "transparent"
                Material.foreground: root.filterType === 2
                    ? Material.primaryTextColor : Material.hintTextColor
                font.pixelSize: 13
                onClicked: root.filterType = 2
            }
        }

        // File list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Material.background: Material.color(Material.Grey, Material.Shade800)
            Material.elevation: 2

            ListView {
                id: fileList
                anchors.fill: parent
                anchors.margins: 4
                clip: true
                spacing: 2
                ScrollBar.vertical: ScrollBar {}

                model: appController.fileModel

                delegate: FileListItem {
                    width: fileList.width
                    filterText: root.filterText
                    filterType: root.filterType
                }
            }
        }

        // Action buttons
        RowLayout {
            spacing: 12

            Button {
                text: qsTr("\u2190 Voltar")
                flat: true
                Material.foreground: Material.hintTextColor
                onClicked: {
                    appController.reset()
                    StackView.view.pop()
                }
            }

            Button {
                text: qsTr("Selecionar Todos")
                flat: true
                Material.foreground: Material.foreground
                onClicked: selectAllFiles(true)
            }

            Button {
                text: qsTr("Inverter Sele\u00e7\u00e3o")
                flat: true
                Material.foreground: Material.foreground
                onClicked: invertSelection()
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Processar Selecionados \u25B6\uFE0F")
                highlighted: true
                Material.background: Material.color(Material.Green, Material.Shade700)
                Material.foreground: Material.primaryTextColor
                font.pixelSize: 15
                font.bold: true
                onClicked: appController.startProcessing()
            }
        }
    }

    function selectAllFiles(selected) {
        // Note: This requires a selectAll method on AppController or iteration
        // For now, placeholder
    }

    function invertSelection() {
        // Note: This requires selection inversion logic
        // For now, placeholder
    }
}
