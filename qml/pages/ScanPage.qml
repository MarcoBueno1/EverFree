import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "scanPage"
    leftPadding: 30
    rightPadding: 30
    topPadding: 20
    bottomPadding: 30

    property bool scanComplete: false

    Component.onCompleted: scanComplete = false

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        // ── Title + Cancel ────────────────────────────────────────────
        RowLayout {
            spacing: 16

            Label {
                text: scanComplete ? "✅" : "🔍"
                font.pixelSize: 28
            }

            Label {
                text: scanComplete
                    ? qsTr("Escaneamento Concluído")
                    : qsTr("Escaneando arquivos...")
                font.pixelSize: 22
                font.bold: true
                color: Material.foreground
            }

            Item { Layout.fillWidth: true }

            // CANCEL BUTTON — always visible during scan
            Button {
                visible: !scanComplete
                text: "✕ Cancelar"
                flat: true
                Material.foreground: Material.color(Material.Red, Material.Shade400)
                font.pixelSize: 14
                onClicked: {
                    appController.cancel()
                    scanComplete = false
                }
            }
        }

        // ── SCANNING (in progress) ────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !scanComplete
            spacing: 20

            // Multi-folder progress: "Pasta 2 de 5"
            Label {
                text: appController.totalFolders > 1
                    ? "📁 Pasta %1 de %2 — %3"
                        .arg(appController.currentFolder + 1)
                        .arg(appController.totalFolders)
                        .arg(appController.currentFolderName)
                    : "📁 Escaneando %1".arg(appController.currentFolderName)
                font.pixelSize: 15
                color: Material.color(Material.Green, Material.Shade300)
                Layout.alignment: Qt.AlignHCenter
                visible: appController.currentFolderName !== ""
            }

            // Indeterminate progress (per-folder, when total unknown)
            ProgressBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                indeterminate: true
                visible: !progressModel.active || progressModel.total === 0

                background: Rectangle {
                    implicitHeight: 8
                    radius: 4
                    color: Material.color(Material.Grey, Material.Shade700)
                }
                contentItem: Item {
                    Rectangle {
                        width: parent.width * 0.3
                        height: parent.height
                        radius: 4
                        color: Material.color(Material.Green, Material.Shade500)
                        NumberAnimation on x {
                            from: 0
                            to: parent.width * 0.7
                            duration: 1200
                            loops: Animation.Infinite
                        }
                    }
                }
            }

            // Determinate progress (per-file within folder)
            ColumnLayout {
                Layout.fillWidth: true
                visible: progressModel.total > 0
                spacing: 8

                ProgressBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    from: 0; to: 100
                    value: progressModel.percent
                    background: Rectangle {
                        implicitHeight: 8; radius: 4
                        color: Material.color(Material.Grey, Material.Shade700)
                    }
                    contentItem: Rectangle {
                        implicitHeight: 8; radius: 4
                        width: progressModel.percent / 100 * parent.width
                        color: Material.color(Material.Green, Material.Shade500)
                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                    }
                }

                RowLayout {
                    spacing: 12
                    Label {
                        text: "%1 / %2 arquivos".arg(progressModel.done).arg(progressModel.total)
                        font.pixelSize: 13
                        color: Material.hintTextColor
                    }
                    Label {
                        text: "(%1%)".arg(progressModel.percent, 0, 'f', 0)
                        font.pixelSize: 13
                        font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                    }
                }
            }

            // Current file
            Label {
                text: "📄 " + progressModel.currentFile
                font.pixelSize: 13
                color: Material.hintTextColor
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                visible: progressModel.currentFile !== ""
            }

            // Scanning file list (auto-scroll)
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Material.color(Material.Grey, Material.Shade900)

                ListView {
                    id: scanningList
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    model: appController.fileModel
                    spacing: 2

                    // Auto-scroll to bottom as files are discovered
                    onCountChanged: if (count > 0) positionViewAtEnd()

                    delegate: RowLayout {
                        width: scanningList.width
                        spacing: 8
                        opacity: 0
                        NumberAnimation on opacity { from: 0; to: 1; duration: 200; running: true }

                        Label { text: isImage ? "🖼️" : "🎬"; font.pixelSize: 14 }
                        Label {
                            text: fileName
                            font.pixelSize: 12
                            color: Material.hintTextColor
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                        Label {
                            text: fileSize
                            font.pixelSize: 11
                            color: Material.accentColor
                        }
                    }
                }
            }
        }

        // ── SCAN COMPLETE — Summary + Next Steps ──────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: scanComplete
            spacing: 20

            Label { text: "✅"; font.pixelSize: 48; Layout.alignment: Qt.AlignHCenter }

            Label {
                text: "Escaneamento Finalizado!"
                font.pixelSize: 20
                font.bold: true
                color: Material.color(Material.Green, Material.Shade300)
                Layout.alignment: Qt.AlignHCenter
            }

            // Stats grid
            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                columns: 2
                columnSpacing: 40
                rowSpacing: 16

                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "📁"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: reportModel.totalFiles
                        font.pixelSize: 28; font.bold: true; color: Material.foreground
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Arquivos"; font.pixelSize: 12; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }
                ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
                    Label { text: "📉"; font.pixelSize: 28; Layout.alignment: Qt.AlignHCenter }
                    Label {
                        text: "%1%".arg(reportModel.savingsPct, 0, 'f', 0)
                        font.pixelSize: 28; font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label { text: "Economia estimada"; font.pixelSize: 12; color: Material.hintTextColor; Layout.alignment: Qt.AlignHCenter }
                }
            }

            // Size comparison
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16
                Label { text: reportModel.totalSize; font.pixelSize: 14; color: Material.hintTextColor }
                Label { text: "→"; font.pixelSize: 20; color: Material.color(Material.Green, Material.Shade300) }
                Label {
                    text: reportModel.totalProjectedSize
                    font.pixelSize: 16; font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                }
                Label {
                    text: "(%1 liberados)".arg(reportModel.totalSavings)
                    font.pixelSize: 13; color: Material.accentColor
                }
            }

            Item { Layout.fillHeight: true }

            // ── Action Buttons ────────────────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Button {
                    text: "← Voltar"
                    flat: true
                    Material.foreground: Material.hintTextColor
                    onClicked: { appController.reset(); StackView.view.pop(null) }
                }

                // MODE SIMPLES: shows "Confirmar e Comprimir"
                Button {
                    visible: appController.mode === AppController.Simple
                    text: "✅ Confirmar e Comprimir"
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade600)
                    Material.foreground: Material.primaryTextColor
                    font.pixelSize: 15; font.bold: true
                    onClicked: appController.confirmAndProcess()
                }

                // MODE AVANÇADO: shows "Próximo →" (goes to selection)
                Button {
                    visible: appController.mode === AppController.Advanced
                    text: "Próximo →"
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade700)
                    Material.foreground: Material.primaryTextColor
                    font.pixelSize: 15; font.bold: true
                    onClicked: { /* navigate to select page */ }
                }
            }
        }
    }

    // Detect scan completion
    Connections {
        target: appController
        function onStateChanged() {
            if (appController.state === AppController.ScanComplete
                || appController.state === AppController.AwaitingConfirmation) {
                scanComplete = true
            }
        }
    }
}
