import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root
    height: visible ? 64 : 0
    visible: matchesFilter

    // Cores compartilhadas
    property color primaryColor: "#10B981"
    property color surfaceColor: "#1F2937"
    property color surfaceHover: "#374151"
    property color textPrimary: "#F9FAFB"
    property color textSecondary: "#9CA3AF"
    property color textMuted: "#6B7280"
    property color successColor: "#10B981"
    property color warningColor: "#F59E0B"

    property string filePath: model.filePath !== undefined ? model.filePath : ""
    property string fileName: model.fileName !== undefined ? model.fileName : ""
    property var fileSizeRaw: model.fileSize !== undefined ? model.fileSize : 0
    property var projectedSizeRaw: model.projectedSize !== undefined ? model.projectedSize : 0
    property bool isImage: model.isImage !== undefined ? model.isImage : false
    property bool isVideo: model.isVideo !== undefined ? model.isVideo : false
    property real savingsPct: model.savingsPct !== undefined ? model.savingsPct : 0
    property string qualityStars: model.qualityStars !== undefined ? model.qualityStars : ""
    property string suggestedCodec: model.suggestedCodec !== undefined ? model.suggestedCodec : ""
    property int fileWidth: model.width !== undefined ? model.width : 0
    property int fileHeight: model.height !== undefined ? model.height : 0
    property int projWidth: model.projectedWidth !== undefined ? model.projectedWidth : 0
    property int projHeight: model.projectedHeight !== undefined ? model.projectedHeight : 0
    property var durationSec: model.durationSec !== undefined ? model.durationSec : 0
    property bool isSelected: model.isSelected !== undefined ? model.isSelected : true

    property string filterText: ""
    property int filterType: 0
    property bool hovered: false

    property string fileSize: formatFileSize(fileSizeRaw)
    property string projectedSize: formatFileSize(projectedSizeRaw)

    property bool matchesFilter: {
        var typeMatch = filterType === 0 ||
            (filterType === 1 && isImage) ||
            (filterType === 2 && isVideo)
        var nameMatch = filterText === "" ||
            fileName.toLowerCase().indexOf(filterText.toLowerCase()) >= 0
        return typeMatch && nameMatch
    }

    function formatFileSize(bytes) {
        if (bytes === undefined || bytes === null) return ""
        bytes = Number(bytes)
        if (bytes === 0) return "0 B"
        var k = 1024
        var sizes = ["B", "KB", "MB", "GB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return (bytes / Math.pow(k, i)).toFixed(i > 0 ? 1 : 0) + " " + sizes[i]
    }

    function toggleSelection() {
        var newSelected = !root.isSelected
        var idx = index !== undefined ? index : -1
        if (idx >= 0 && ListView.view && ListView.view.model) {
            var modelIdx = ListView.view.model.index(idx, 0)
            ListView.view.model.setData(modelIdx, newSelected, FileItemModel.IsSelectedRole)
        }
    }

    // Fundo com hover
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 10
        color: root.hovered ? root.surfaceHover : "transparent"
        border.color: root.isSelected ? root.primaryColor : "transparent"
        border.width: root.isSelected ? 1 : 0

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.toggleSelection()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        // Checkbox estilizado
        Rectangle {
            width: 22
            height: 22
            radius: 6
            color: root.isSelected ? root.primaryColor : "transparent"
            border.color: root.isSelected ? root.primaryColor : root.textMuted
            border.width: 2
            Layout.alignment: Qt.AlignVCenter

            Label {
                anchors.centerIn: parent
                text: "✓"
                font.pixelSize: 14
                font.bold: true
                color: "white"
                visible: root.isSelected
            }
        }

        // Ícone do tipo
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: root.isImage ? "#3B82F6" : "#8B5CF6"
            opacity: 0.2
            Layout.alignment: Qt.AlignVCenter

            Label {
                anchors.centerIn: parent
                text: root.isImage ? "🖼" : "🎬"
                font.pixelSize: 18
            }
        }

        // Informações do arquivo
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            Label {
                text: root.fileName
                font.pixelSize: 14
                font.bold: true
                color: root.textPrimary
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                wrapMode: Text.NoWrap
            }

            Label {
                text: {
                    var parts = []
                    if (root.fileWidth > 0 && root.fileHeight > 0)
                        parts.push("%1×%2".arg(root.fileWidth).arg(root.fileHeight))
                    if (root.suggestedCodec !== "")
                        parts.push(root.suggestedCodec)
                    if (root.projWidth > 0 && root.projHeight > 0)
                        parts.push("→ %1×%2".arg(root.projWidth).arg(root.projHeight))
                    return parts.join(" • ")
                }
                font.pixelSize: 12
                color: root.textSecondary
                visible: text !== ""
                elide: Text.ElideRight
                Layout.fillWidth: true
                wrapMode: Text.NoWrap
            }
        }

        // Espaçador
        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 20
        }

        // Tamanho original → comprimido
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            Label {
                text: root.fileSize
                font.pixelSize: 13
                color: root.textSecondary
            }

            Label {
                text: "→"
                font.pixelSize: 13
                color: root.primaryColor
            }

            Label {
                text: root.projectedSize
                font.pixelSize: 13
                font.bold: true
                color: root.primaryColor
            }
        }

        // Badge de economia
        Rectangle {
            width: 52
            height: 26
            radius: 13
            color: root.savingsPct > 0 ? Qt.rgba(16, 185, 129, 0.2) : "transparent"
            Layout.alignment: Qt.AlignVCenter

            Label {
                anchors.centerIn: parent
                text: root.savingsPct > 0 ? "-%1%".arg(Math.round(root.savingsPct)) : ""
                font.pixelSize: 12
                font.bold: true
                color: root.savingsPct > 0 ? root.successColor : root.textMuted
            }
        }
    }
}
