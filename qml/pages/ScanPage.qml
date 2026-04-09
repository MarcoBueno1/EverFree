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
    topPadding: 24
    bottomPadding: 28

    property bool scanComplete: false

    Component.onCompleted: scanComplete = false

    // ── Background da página ────────────────────────────────────────────────
    background: Rectangle {
        // FIX: Better contrast
        color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // ── Cabeçalho: título + botão cancelar ─────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                id: headerIcon
                text: scanComplete ? "\u2705" : "\uD83D\uDD0D"
                font.pixelSize: 24
            }

            Label {
                text: scanComplete
                    ? qsTr("Escaneamento conclu\u00eddo")
                    : qsTr("Escaneando arquivos...")
                font.pixelSize: 20
                font.bold: true
                color: Material.foreground
            }

            Item { Layout.fillWidth: true }

            Button {
                visible: !scanComplete
                text: "\u2715 Cancelar"
                flat: true
                Material.foreground: Material.color(Material.Red, Material.Shade400)
                font.pixelSize: 13
                onClicked: {
                    appController.cancel()
                    scanComplete = false
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════
        // ESTADO: ESCANEANDO
        // ══════════════════════════════════════════════════════════════════
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !scanComplete
            spacing: 16

            // Badge da pasta atual ─────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 8
                // FIX: Better contrast
                color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
                border.color: Material.color(Material.Green, Material.Shade800)
                border.width: 1
                visible: appController.currentFolderName !== ""

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    // Ponto pulsante
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 8
                        color: Material.color(Material.Green, Material.Shade400)

                        SequentialAnimation on opacity {
                            running: !scanComplete
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.2; duration: 700; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
                        }
                    }

                    Label {
                        text: appController.totalFolders > 1
                            ? "\uD83D\uDCC1 " + appController.currentFolderName
                            : "\uD83D\uDCC1 Escaneando " + appController.currentFolderName
                        font.pixelSize: 14
                        font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }

                    Label {
                        visible: appController.totalFolders > 1
                        text: "Pasta " + (appController.currentFolder + 1) +
                              " de " + appController.totalFolders
                        font.pixelSize: 12
                        color: Material.hintTextColor
                    }
                }
            }

            // Barra de progresso ──────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Indeterminada (início, total ainda desconhecido)
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 8
                    color: Material.color(Material.Grey, Material.Shade700)
                    visible: !appController.progressModel.active || appController.progressModel.total === 0
                    clip: true

                    Rectangle {
                        id: indetermBar
                        width: parent.width * 0.28
                        height: parent.height
                        radius: 8
                        color: Material.color(Material.Green, Material.Shade500)

                        NumberAnimation on x {
                            from: -indetermBar.width
                            to: indetermBar.parent.width
                            duration: 1400
                            loops: Animation.Infinite
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                // Determinada (com contagem de arquivos)
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: appController.progressModel.total > 0
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 8
                        color: Material.color(Material.Grey, Material.Shade700)
                        clip: true

                        Rectangle {
                            width: appController.progressModel.percent / 100 * parent.width
                            height: parent.height
                            radius: 8
                            color: Material.color(Material.Green, Material.Shade500)

                            Behavior on width {
                                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 8

                        Label {
                            text: appController.progressModel.done + " / " + appController.progressModel.total + " arquivos"
                            font.pixelSize: 13
                            color: Material.hintTextColor
                        }

                        Label {
                            text: Math.round(appController.progressModel.percent) + "%"
                            font.pixelSize: 13
                            font.bold: true
                            color: Material.color(Material.Green, Material.Shade300)
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            visible: appController.progressModel.eta !== ""
                            text: "ETA " + appController.progressModel.eta
                            font.pixelSize: 12
                            color: Material.hintTextColor
                            opacity: 0.7
                        }
                    }
                }
            }

            // Arquivo sendo analisado agora ───────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 8
                // FIX: Better contrast
                color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
                visible: appController.progressModel.currentFile !== ""

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Label {
                        text: "\uD83D\uDCC4"
                        font.pixelSize: 13
                        opacity: 0.6
                    }

                    Label {
                        Layout.fillWidth: true
                        text: appController.progressModel.currentFile
                        font.pixelSize: 12
                        font.family: "monospace"
                        color: Material.color(Material.Grey, Material.Shade300)
                        elide: Text.ElideMiddle
                    }
                }
            }

            // Lista de arquivos descobertos ────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                // FIX: Better contrast
                color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
                // FIX: Better contrast for border
                border.color: themeManager.darkMode ? "#505050" : Material.color(Material.Grey, Material.Shade400)
                border.width: 1

                // Cabeçalho da lista
                Rectangle {
                    id: listHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 30
                    radius: 10
                    // FIX: Better contrast
                    color: themeManager.darkMode ? "#4A4A4A" : Material.color(Material.Grey, Material.Shade300)

                    // Cobre cantos inferiores arredondados do header
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 10
                        color: parent.color
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14

                        Label {
                            text: qsTr("Arquivos encontrados")
                            font.pixelSize: 11
                            font.bold: true
                            color: Material.hintTextColor
                            opacity: 0.7
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            text: appController.fileModel.count > 0
                                  ? appController.fileModel.count + " itens"
                                  : ""
                            font.pixelSize: 11
                            color: Material.color(Material.Green, Material.Shade400)
                        }
                    }
                }

                ListView {
                    id: scanningList
                    anchors.top: listHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    anchors.topMargin: 2
                    clip: true
                    model: appController.fileModel
                    spacing: 1

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    onCountChanged: {
                        if (count > 0) positionViewAtEnd()
                    }

                    delegate: Rectangle {
                        width: scanningList.width
                        height: 34
                        color: "transparent"
                        radius: 8

                        // FIX: Only animate new items, not every visible item
                        opacity: 0
                        NumberAnimation on opacity {
                            from: 0; to: 1
                            duration: 220
                            running: parent.opacity === 0  // Only run once
                            easing.type: Easing.OutCubic
                        }

                        // Hover
                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: Material.color(Material.Grey, Material.Shade500)
                            opacity: mouseArea.containsMouse ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            // Ícone tipo
                            Label {
                                text: isImage ? "\uD83D\uDDBC\uFE0F" : "\uD83C\uDFAC"
                                font.pixelSize: 13
                                opacity: 0.85
                            }

                            // Nome do arquivo
                            Label {
                                Layout.fillWidth: true
                                text: fileName
                                font.pixelSize: 13
                                color: Material.color(Material.Grey, Material.Shade200)
                                elide: Text.ElideMiddle
                            }

                            // Tamanho atual
                            Label {
                                text: fileSize
                                font.pixelSize: 12
                                font.family: "monospace"
                                color: Material.hintTextColor
                                opacity: 0.7
                                horizontalAlignment: Text.AlignRight
                            }

                            // Economia estimada
                            Rectangle {
                                width: savingsBadgeLabel.width + 10
                                height: 18
                                radius: 8
                                color: Material.color(Material.Green, Material.Shade800)
                                border.color: Material.color(Material.Green, Material.Shade600)
                                border.width: 1
                                visible: savingsPct > 0

                                Label {
                                    id: savingsBadgeLabel
                                    anchors.centerIn: parent
                                    text: "-" + savingsPct + "%"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Material.color(Material.Green, Material.Shade300)
                                }
                            }
                        }
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════
        // ESTADO: SCAN COMPLETO
        // ══════════════════════════════════════════════════════════════════
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: scanComplete
            spacing: 20

            // Ícone de sucesso animado
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 72
                height: 72

                Label {
                    anchors.centerIn: parent
                    text: "\u2705"
                    font.pixelSize: 48

                    NumberAnimation on scale {
                        from: 0.4; to: 1.0
                        duration: 400
                        running: scanComplete
                        easing.type: Easing.OutBack
                    }
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Escaneamento finalizado!")
                font.pixelSize: 20
                font.bold: true
                color: Material.color(Material.Green, Material.Shade300)
            }

            // Cards de estatísticas
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                // Card: total de arquivos
                Rectangle {
                    width: 160
                    height: 88
                    radius: 10
                    // FIX: Better contrast
                    color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)
                    // FIX: Better contrast for border
                    border.color: themeManager.darkMode ? "#505050" : Material.color(Material.Grey, Material.Shade400)
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uD83D\uDCC1"
                            font.pixelSize: 24
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: appController.reportModel.totalFiles
                            font.pixelSize: 26
                            font.bold: true
                            color: Material.foreground
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Arquivos")
                            font.pixelSize: 12
                            color: Material.hintTextColor
                        }
                    }
                }

                // Card: economia estimada
                Rectangle {
                    width: 160
                    height: 88
                    radius: 10
                    color: Material.color(Material.Green, Material.Shade900)
                    border.color: Material.color(Material.Green, Material.Shade700)
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "\uD83D\uDCC9"
                            font.pixelSize: 24
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "%1%".arg(Math.round(appController.reportModel.savingsPct))
                            font.pixelSize: 26
                            font.bold: true
                            color: Material.color(Material.Green, Material.Shade300)
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Economia estimada")
                            font.pixelSize: 12
                            color: Material.color(Material.Green, Material.Shade500)
                        }
                    }
                }
            }

            // Linha tamanho atual → tamanho após compressão
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Label {
                    text: appController.reportModel.totalSize
                    font.pixelSize: 15
                    color: Material.hintTextColor
                }

                Label {
                    text: "\u2192"
                    font.pixelSize: 20
                    color: Material.color(Material.Green, Material.Shade400)
                }

                Label {
                    text: appController.reportModel.totalProjectedSize
                    font.pixelSize: 17
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                }

                Rectangle {
                    height: 22
                    width: savingsAmountLabel.width + 12
                    radius: 12
                    color: Material.color(Material.Green, Material.Shade900)
                    border.color: Material.color(Material.Green, Material.Shade700)
                    border.width: 1

                    Label {
                        id: savingsAmountLabel
                        anchors.centerIn: parent
                        text: "\u2193 " + appController.reportModel.totalSavings + " liberados"
                        font.pixelSize: 12
                        color: Material.color(Material.Green, Material.Shade300)
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Botões de ação
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Button {
                    text: qsTr("\u2190 Voltar")
                    flat: true
                    Material.foreground: Material.hintTextColor
                    onClicked: {
                        scanComplete = false
                        appController.reset()
                    }
                }

                Button {
                    visible: appController.mode === AppController.Simple
                    text: qsTr("\u2705 Confirmar e Comprimir")
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade600)
                    Material.foreground: Material.primaryTextColor
                    font.pixelSize: 15
                    font.bold: true
                    onClicked: appController.confirmAndProcess()
                }

                Button {
                    visible: appController.mode === AppController.Advanced
                    text: qsTr("Pr\u00f3ximo \u2192")
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade700)
                    Material.foreground: Material.primaryTextColor
                    font.pixelSize: 15
                    font.bold: true
                    onClicked: appController.startProcessing()
                }
            }
        }
    }

    Connections {
        target: appController
        function onStateChanged() {
            if (appController.state === AppController.ScanComplete ||
                appController.state === AppController.AwaitingConfirmation) {
                scanComplete = true
            }
        }
    }
}
