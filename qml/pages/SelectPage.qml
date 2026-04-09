import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "selectPage"

    // Paleta de cores personalizada
    property color primaryColor: "#10B981"      // Verde esmeralda moderno
    property color primaryDark: "#059669"       // Verde mais escuro
    property color primaryLight: "#D1FAE5"      // Verde claro para fundos
    property color accentColor: "#3B82F6"       // Azul para destaques
    property color surfaceColor: "#1F2937"      // Cinza escuro para cards
    property color surfaceLight: "#374151"      // Cinza médio
    property color backgroundColor: "#111827"   // Fundo muito escuro
    property color textPrimary: "#F9FAFB"       // Texto principal
    property color textSecondary: "#9CA3AF"     // Texto secundário
    property color textMuted: "#6B7280"         // Texto discreto
    property color borderColor: "#374151"       // Bordas sutis
    property color successColor: "#10B981"      // Verde para economia
    property color warningColor: "#F59E0B"      // Amarelo para alertas

    leftPadding: 28
    rightPadding: 28
    topPadding: 24
    bottomPadding: 28

    property string filterText: ""
    property int filterType: 0

    function calculateSelectedCount() {
        return appController.fileModel.selectedCount
    }

    function formatBytes(bytes) {
        if (bytes === 0) return "0 B"
        if (bytes < 1024) return bytes + " B"
        var k = 1024
        var sizes = ["KB", "MB", "GB", "TB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return (bytes / Math.pow(k, i)).toFixed(i > 0 ? 1 : 0) + " " + sizes[i]
    }

    function calculateSavingsPercent() {
        var totalSize = appController.reportModel.totalSize
        var projectedSize = appController.reportModel.totalProjectedSize
        if (totalSize === 0) return 0
        return Math.round(((totalSize - projectedSize) / totalSize) * 100)
    }

    background: Rectangle {
        color: root.backgroundColor
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // === HEADER COM ESTATÍSTICAS ===
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 100
            radius: 16
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.primaryDark }
                GradientStop { position: 1.0; color: root.primaryColor }
            }
            Material.elevation: 4
            border.color: Qt.lighter(root.primaryColor, 1.2)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 24

                // Ícone com fundo
                Rectangle {
                    width: 56
                    height: 56
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.2)
                    Layout.alignment: Qt.AlignVCenter

                    Label {
                        anchors.centerIn: parent
                        text: "📋"
                        font.pixelSize: 28
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 6

                    Row {
                        spacing: 12

                        Label {
                            text: qsTr("%1 arquivos").arg(appController.fileModel.rowCount())
                            font.pixelSize: 20
                            font.bold: true
                            color: root.textPrimary
                        }

                        Rectangle {
                            width: savingsPercentLabel.width + 16
                            height: 28
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.25)
                            visible: calculateSavingsPercent() > 0

                            Label {
                                id: savingsPercentLabel
                                anchors.centerIn: parent
                                text: "-%1%".arg(calculateSavingsPercent())
                                font.pixelSize: 14
                                font.bold: true
                                color: "#6EE7B7"
                            }
                        }
                    }

                    Label {
                        text: qsTr("Economia estimada: %1").arg(formatBytes(appController.reportModel.totalSavings))
                        font.pixelSize: 15
                        color: root.primaryLight
                        font.bold: true
                    }

                    Row {
                        spacing: 8

                        Label {
                            text: formatBytes(appController.reportModel.totalSize)
                            font.pixelSize: 13
                            color: Qt.rgba(1, 1, 1, 0.6)
                            font.strikeout: true
                        }

                        Label {
                            text: "→"
                            font.pixelSize: 13
                            color: Qt.rgba(1, 1, 1, 0.6)
                        }

                        Label {
                            text: formatBytes(appController.reportModel.totalProjectedSize)
                            font.pixelSize: 13
                            font.bold: true
                            color: "#6EE7B7"
                        }
                    }
                }

                // Barra de progresso visual
                Rectangle {
                    width: 80
                    height: 80
                    radius: 40
                    color: "transparent"
                    Layout.alignment: Qt.AlignVCenter
                    visible: calculateSavingsPercent() > 0

                    // Círculo de progresso simplificado
                    Canvas {
                        id: savingsCircle
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            var centerX = width / 2
                            var centerY = height / 2
                            var radius = 34

                            ctx.clearRect(0, 0, width, height)

                            // Fundo do círculo
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.2)
                            ctx.lineWidth = 6
                            ctx.stroke()

                            // Progresso
                            var percent = calculateSavingsPercent() / 100
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, -Math.PI/2, -Math.PI/2 + (2 * Math.PI * percent))
                            ctx.strokeStyle = "#6EE7B7"
                            ctx.lineWidth = 6
                            ctx.lineCap = "round"
                            ctx.stroke()

                            // Texto no centro
                            ctx.fillStyle = "white"
                            ctx.font = "bold 18px sans-serif"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillText("%1%".arg(calculateSavingsPercent()), centerX, centerY)
                        }
                    }

                    // Repaint when savings percent changes
                    Connections {
                        target: appController.reportModel
                        function onTotalSizeChanged() { savingsCircle.requestPaint() }
                        function onTotalProjectedSizeChanged() { savingsCircle.requestPaint() }
                    }
                }
            }
        }

        // === CAMPO DE BUSCA ===
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 48
            radius: 12
            color: root.surfaceColor
            border.color: root.borderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                Label {
                    text: "🔍"
                    font.pixelSize: 18
                    Layout.leftMargin: 16
                    Layout.rightMargin: 8
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Filtrar por nome...")
                    text: root.filterText
                    color: root.textPrimary

                    palette.placeholderText: root.textMuted

                    font.pixelSize: 15

                    background: Rectangle {
                        color: "transparent"
                    }

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
                    text: "✕"
                    flat: true
                    display: AbstractButton.TextOnly
                    Material.foreground: root.textMuted
                    onClicked: searchField.clear()
                    Layout.preferredWidth: 40
                    Layout.rightMargin: 8
                }
            }
        }

        // === FILTROS ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: qsTr("Todos")
                highlighted: root.filterType === 0
                flat: root.filterType !== 0
                Material.background: root.filterType === 0 ? root.primaryColor : "transparent"
                Material.foreground: root.filterType === 0 ? "white" : root.textSecondary
                font.pixelSize: 14
                font.bold: root.filterType === 0
                Layout.preferredWidth: implicitWidth + 24
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: root.filterType === 0 ? root.primaryColor : "transparent"
                    radius: 20
                    border.color: root.filterType === 0 ? "transparent" : root.borderColor
                    border.width: 1
                }

                onClicked: root.filterType = 0
            }

            Button {
                text: qsTr("🖼️ Imagens")
                highlighted: root.filterType === 1
                flat: root.filterType !== 1
                Material.background: root.filterType === 1 ? root.primaryColor : "transparent"
                Material.foreground: root.filterType === 1 ? "white" : root.textSecondary
                font.pixelSize: 14
                font.bold: root.filterType === 1
                Layout.preferredWidth: implicitWidth + 24
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: root.filterType === 1 ? root.primaryColor : "transparent"
                    radius: 20
                    border.color: root.filterType === 1 ? "transparent" : root.borderColor
                    border.width: 1
                }

                onClicked: root.filterType = 1
            }

            Button {
                text: qsTr("🎬 Vídeos")
                highlighted: root.filterType === 2
                flat: root.filterType !== 2
                Material.background: root.filterType === 2 ? root.primaryColor : "transparent"
                Material.foreground: root.filterType === 2 ? "white" : root.textSecondary
                font.pixelSize: 14
                font.bold: root.filterType === 2
                Layout.preferredWidth: implicitWidth + 24
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: root.filterType === 2 ? root.primaryColor : "transparent"
                    radius: 20
                    border.color: root.filterType === 2 ? "transparent" : root.borderColor
                    border.width: 1
                }

                onClicked: root.filterType = 2
            }

            Item { Layout.fillWidth: true }

            Label {
                text: qsTr("%1 selecionados").arg(root.calculateSelectedCount())
                font.pixelSize: 13
                Material.foreground: root.textMuted
                visible: root.calculateSelectedCount() > 0
            }
        }

        // === LISTA DE ARQUIVOS ===
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.surfaceColor
            radius: 16
            Material.elevation: 2
            clip: true
            border.color: root.borderColor
            border.width: 1

            ListView {
                id: fileList
                anchors.fill: parent
                anchors.margins: 8
                anchors.rightMargin: 4
                clip: true
                spacing: 2
                ScrollBar.vertical: ScrollBar {
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    active: true
                    width: 8
                    background: Rectangle { color: "transparent" }
                    contentItem: Rectangle {
                        implicitWidth: 6
                        radius: 3
                        color: root.primaryColor
                        opacity: 0.6
                    }
                }

                model: appController.fileModel

                delegate: FileListItem {
                    width: fileList.width
                    filterText: root.filterText
                    filterType: root.filterType
                }

                highlightMoveDuration: 200
            }
        }

        // === BOTÕES DE AÇÃO ===
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Button {
                text: qsTr("← Voltar")
                enabled: true
                font.pixelSize: 15
                Layout.preferredHeight: 44

                contentItem: Label {
                    text: "← Voltar"
                    font: parent.font
                    color: root.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? root.surfaceLight : "transparent"
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1
                }

                onClicked: {
                    appController.cancel()
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: qsTr("Selecionar Todos")
                enabled: true
                font.pixelSize: 14
                visible: root.calculateSelectedCount() < appController.fileModel.rowCount()

                contentItem: Label {
                    text: "Selecionar Todos"
                    font: parent.font
                    color: root.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.hovered ? root.surfaceLight : "transparent"
                    radius: 10
                    border.color: root.borderColor
                    border.width: 1
                }

                onClicked: {
                    appController.fileModel.selectAll(true)
                }
            }

            Button {
                id: processButton
                text: qsTr("Processar Selecionados ▶")
                enabled: root.calculateSelectedCount() > 0
                font.pixelSize: 15
                font.bold: true
                Layout.preferredHeight: 48
                Layout.preferredWidth: implicitWidth + 32

                contentItem: Label {
                    text: processButton.text
                    font: processButton.font
                    color: processButton.enabled ? "white" : root.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: processButton.enabled ?
                           (processButton.hovered ? Qt.lighter(root.primaryColor, 1.1) : root.primaryColor) :
                           Qt.darker(root.primaryColor, 0.7)
                    radius: 24
                }

                onClicked: appController.startProcessing()
            }
        }
    }

    function invertSelection() {
        appController.fileModel.invertSelection()
    }
}
