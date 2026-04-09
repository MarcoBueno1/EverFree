import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "reportPage"
    leftPadding: 30
    rightPadding: 30
    topPadding: 20
    bottomPadding: 30

    property bool hasErrors: appController.errorCount > 0

    background: Rectangle {
        // FIX: Better contrast
        color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // Header
        RowLayout {
            spacing: 16

            Label {
                text: appController.state === AppController.Error ? "\u26A0\uFE0F" : "\u2705"
                font.pixelSize: 28
            }

            Label {
                text: appController.state === AppController.Error
                    ? qsTr("Conclu\u00eddo com Erros")
                    : qsTr("Conclu\u00eddo!")
                font.pixelSize: 22
                font.bold: true
                font.weight: Font.Bold
                color: appController.state === AppController.Error
                    ? Material.color(Material.Orange, Material.Shade300)
                    : Material.color(Material.Green, Material.Shade300)
            }

            Item { Layout.fillWidth: true }

            // Error count badge
            Label {
                visible: root.hasErrors
                text: "\u26A0\uFE0F %1 pasta(s) ignorada(s)".arg(appController.errorCount)
                font.pixelSize: 13
                color: Material.color(Material.Orange, Material.Shade300)
            }
        }

        // Main results card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 220
            // FIX: Better contrast
            Material.background: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
            Material.elevation: 4

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                // Big savings number
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    // Original size
                    ColumnLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter

                        Label {
                            text: qsTr("Tamanho Original")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: reportModel.totalSize
                            font.pixelSize: 26
                            font.bold: true
                            color: Material.foreground
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Arrow
                    Label {
                        text: "\u2192"
                        font.pixelSize: 36
                        color: Material.color(Material.Green, Material.Shade300)
                    }

                    // Final size
                    ColumnLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter

                        Label {
                            text: qsTr("Tamanho Final")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            text: reportModel.totalProjectedSize
                            font.pixelSize: 26
                            font.bold: true
                            color: Material.color(Material.Green, Material.Shade300)
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Savings highlight
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 40
                        radius: 20
                        color: Material.color(Material.Green, Material.Shade900)

                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Economia de %1").arg(reportModel.totalSavings)
                            font.pixelSize: 16
                            font.bold: true
                            color: Material.color(Material.Green, Material.Shade300)
                        }
                    }

                    Label {
                        text: "(%1% menor)".arg(Math.round(reportModel.savingsPct))
                        font.pixelSize: 16
                        color: Material.hintTextColor
                    }
                }

                // Visual bar chart
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    // Bar label
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Label {
                            text: "\uD83D\uDCC1"
                            font.pixelSize: 14
                        }

                        Label {
                            text: qsTr("%1 arquivos (%2 imagens, %3 v\u00eddeos)")
                                .arg(reportModel.totalFiles)
                                .arg(reportModel.imageCount)
                                .arg(reportModel.videoCount)
                            font.pixelSize: 12
                            color: Material.hintTextColor
                        }
                    }

                    // Bar visualization
                    Item {
                        Layout.fillWidth: true
                        height: 32

                        // Original bar (full width)
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width
                            height: 16
                            radius: 8
                            color: Material.color(Material.Grey, Material.Shade600)
                            opacity: 0.5
                        }

                        // Compressed bar (proportional)
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * (1 - reportModel.savingsPct / 100)
                            height: 16
                            radius: 8
                            color: Material.color(Material.Green, Material.Shade500)

                            Behavior on width {
                                NumberAnimation {
                                    duration: 800
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    // Bar labels
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Label {
                            text: qsTr("Original: %1").arg(reportModel.totalSize)
                            font.pixelSize: 11
                            color: Material.hintTextColor
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: qsTr("Final: %1").arg(reportModel.totalProjectedSize)
                            font.pixelSize: 11
                            color: Material.color(Material.Green, Material.Shade400)
                        }
                    }
                }
            }
        }

        // Codec breakdown card — FIX: Show placeholder message
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            // FIX: Better contrast
            Material.background: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
            Material.elevation: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: "\uD83D\uDCCA Resumo por Codec"
                        font.pixelSize: 16
                        font.bold: true
                        color: Material.foreground
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        text: "Em breve"
                        font.pixelSize: 11
                        font.italic: true
                        color: Material.hintTextColor
                    }
                }

                // Placeholder message
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Estatísticas detalhadas por codec estarão disponíveis em uma atualização futura."
                        font.pixelSize: 13
                        color: Material.hintTextColor
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Error paths button (if errors exist)
        Button {
            visible: root.hasErrors
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("\u26A0\uFE0F Ver Pastas Ignoradas (%1)").arg(appController.errorCount)
            flat: true
            Material.foreground: Material.color(Material.Orange, Material.Shade300)
            onClicked: errorDialog.open()
        }

        // Action buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Button {
                text: qsTr("\uD83D\uDD04 Nova Compress\u00e3o")
                highlighted: false
                Material.foreground: Material.foreground
                onClicked: {
                    appController.cancel()
                }
            }

            Button {
                text: qsTr("\uD83D\uDCCB Ver Detalhes")
                highlighted: false
                Material.foreground: Material.foreground
                onClicked: {
                    // Show detailed report dialog
                }
            }

            Button {
                text: qsTr("\u2705 Fechar")
                highlighted: true
                Material.background: Material.color(Material.Green, Material.Shade700)
                Material.foreground: Material.primaryTextColor
                font.pixelSize: 15
                font.bold: true
                onClicked: {
                    appController.cancel()
                }
            }
        }
    }

    // Error paths dialog
    Dialog {
        id: errorDialog
        title: qsTr("Pastas Ignoradas")
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Math.min(500, parent.width - 40)
        modal: true
        dim: true
        standardButtons: Dialog.Close

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            Label {
                text: qsTr("As seguintes pastas n\u00e3o puderam ser acessadas:")
                font.pixelSize: 13
                color: Material.hintTextColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 200
                clip: true
                model: appController.errorPaths
                spacing: 4

                delegate: RowLayout {
                    width: ListView.view.width
                    spacing: 8

                    Label {
                        text: "\u26A0\uFE0F"
                        font.pixelSize: 14
                    }

                    Label {
                        text: modelData
                        font.pixelSize: 13
                        color: Material.color(Material.Orange, Material.Shade300)
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Limpar Erros")
                flat: true
                Material.foreground: Material.hintTextColor
                onClicked: {
                    appController.clearErrors()
                    errorDialog.close()
                }
            }
        }
    }
}
