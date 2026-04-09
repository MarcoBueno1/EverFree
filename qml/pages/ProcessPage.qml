import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "processPage"
    leftPadding: 30
    rightPadding: 30
    topPadding: 20
    bottomPadding: 30

    property bool processingComplete: false
    property int successCount: 0
    property int failCount: 0

    Component.onCompleted: {
        processingComplete = false
        successCount = 0
        failCount = 0
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // ── Title + Cancel ────────────────────────────────────────────
        RowLayout {
            spacing: 16

            Label {
                text: processingComplete ? "✅" : "⏳"
                font.pixelSize: 28
            }

            Label {
                text: processingComplete
                    ? qsTr("Compressão Concluída!")
                    : qsTr("Comprimindo...")
                font.pixelSize: 22
                font.bold: true
                color: Material.foreground
            }

            Item { Layout.fillWidth: true }

            // CANCEL BUTTON — prominent, always visible during processing
            Button {
                visible: !processingComplete
                text: "✕ Cancelar"
                flat: true
                Material.foreground: Material.color(Material.Red, Material.Shade400)
                font.pixelSize: 14
                font.bold: true
                onClicked: {
                    appController.cancel()
                    processingComplete = true
                    failCount = 1 // Mark as user-cancelled
                }
            }
        }

        // ── PROCESSING (in progress) ─────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !processingComplete
            spacing: 24

            // Big percentage
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Label {
                    text: "%1%".arg(progressModel.percent, 0, 'f', 0)
                    font.pixelSize: 64
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: "%1 de %2 arquivos".arg(progressModel.done).arg(progressModel.total)
                    font.pixelSize: 15
                    color: Material.hintTextColor
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Animated progress bar
            ProgressBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 14
                from: 0; to: 100
                value: progressModel.percent
                background: Rectangle {
                    implicitHeight: 14; radius: 7
                    color: Material.color(Material.Grey, Material.Shade700)
                }
                contentItem: Rectangle {
                    implicitHeight: 14; radius: 7
                    width: progressModel.percent / 100 * parent.width
                    color: Material.color(Material.Green, Material.Shade500)
                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }

            // Current file
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 8
                color: Material.color(Material.Grey, Material.Shade800)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Label { text: "📄"; font.pixelSize: 20 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            text: "Arquivo atual:"
                            font.pixelSize: 11
                            color: Material.hintTextColor
                        }
                        Label {
                            text: progressModel.currentFile || "Aguardando..."
                            font.pixelSize: 13
                            color: Material.foreground
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Stats row: ETA, Throughput, Bytes saved
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 40

                // ETA
                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "⏱️"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: progressModel.eta
                        font.pixelSize: 18; font.bold: true
                        color: Material.foreground
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Tempo restante"; font.pixelSize: 11; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }

                // Throughput
                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "📊"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: progressModel.throughput
                        font.pixelSize: 18; font.bold: true
                        color: Material.foreground
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Velocidade"; font.pixelSize: 11; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }

                // Bytes saved
                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "📉"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: {
                            var saved = progressModel.inputBytes - progressModel.outputBytes
                            if (saved < 1024) return saved + " B"
                            if (saved < 1048576) return (saved / 1024).toFixed(1) + " KB"
                            if (saved < 1073741824) return (saved / 1048576).toFixed(1) + " MB"
                            return (saved / 1073741824).toFixed(2) + " GB"
                        }
                        font.pixelSize: 18; font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Liberado"; font.pixelSize: 11; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }
            }

            // Processing log (last files)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Material.color(Material.Grey, Material.Shade900)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Label {
                        text: "Log de processamento"
                        font.pixelSize: 12
                        font.bold: true
                        color: Material.hintTextColor
                    }

                    // Placeholder — would be connected to a real log model
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        ScrollBar.vertical: ScrollBar {}

                        model: 0 // Replace with actual log model

                        delegate: RowLayout {
                            width: parent.width
                            spacing: 8
                            Label { text: "✅"; font.pixelSize: 12 }
                            Label {
                                text: "Arquivo processado"
                                font.pixelSize: 12
                                color: Material.hintTextColor
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        // ── COMPLETION SUMMARY ───────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: processingComplete
            spacing: 20

            Label { text: "🎉"; font.pixelSize: 64; Layout.alignment: Qt.AlignHCenter }

            Label {
                text: failCount > 0 && successCount === 0
                    ? "Operação Cancelada"
                    : "Compressão Finalizada!"
                font.pixelSize: 22
                font.bold: true
                color: failCount > 0 && successCount === 0
                    ? Material.hintTextColor
                    : Material.color(Material.Green, Material.Shade300)
                Layout.alignment: Qt.AlignHCenter
            }

            // Final stats
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 40

                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "✅"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: successCount
                        font.pixelSize: 28; font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Sucesso"; font.pixelSize: 12; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }

                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "❌"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: failCount
                        font.pixelSize: 28; font.bold: true
                        color: Material.color(Material.Red, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Falhas"; font.pixelSize: 12; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }

                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "📉"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: {
                            var saved = progressModel.inputBytes - progressModel.outputBytes
                            if (saved < 1048576) return (saved / 1024).toFixed(0) + " KB"
                            if (saved < 1073741824) return (saved / 1048576).toFixed(1) + " MB"
                            return (saved / 1073741824).toFixed(2) + " GB"
                        }
                        font.pixelSize: 28; font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Liberados"; font.pixelSize: 12; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }
            }

            Item { Layout.fillHeight: true }

            // Action buttons
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Button {
                    text: "← Voltar ao Início"
                    flat: true
                    Material.foreground: Material.hintTextColor
                    onClicked: {
                        appController.cancel()
                    }
                }

                Button {
                    text: "📋 Ver Relatório"
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade600)
                    Material.foreground: Material.primaryTextColor
                    font.pixelSize: 15; font.bold: true
                    onClicked: { /* navigate to report */ }
                }
            }
        }
    }

    // Detect completion
    Connections {
        target: appController
        function onStateChanged() {
            if (appController.state === AppController.Complete) {
                processingComplete = true
                successCount = progressModel.done
            } else if (appController.state === AppController.Error) {
                processingComplete = true
                failCount = Math.max(failCount, 1)
            }
        }
        function onProcessFinished() {
            processingComplete = true
        }
    }
}
