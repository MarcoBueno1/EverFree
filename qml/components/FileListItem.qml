import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root
    height: visible ? 52 : 0
    visible: matchesFilter

    // Roles from FileItemModel - using direct model role binding
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
    property int filterType: 0 // 0=All, 1=Images, 2=Videos
    property bool hovered: false

    // Computed properties
    property string fileSize: formatFileSize(fileSizeRaw)
    property string projectedSize: formatFileSize(projectedSizeRaw)

    // Filter matching logic
    property bool matchesFilter: {
        var typeMatch = filterType === 0 ||
            (filterType === 1 && isImage) ||
            (filterType === 2 && isVideo)
        var nameMatch = filterText === "" ||
            fileName.toLowerCase().indexOf(filterText.toLowerCase()) >= 0
        return typeMatch && nameMatch
    }

    // Helper function to format file size
    function formatFileSize(bytes) {
        if (bytes === undefined || bytes === null) return ""
        bytes = Number(bytes)
        if (bytes === 0) return "0 B"
        var k = 1024
        var sizes = ["B", "KB", "MB", "GB"]
        var i = Math.floor(Math.log(bytes) / Math.log(k))
        return (bytes / Math.pow(k, i)).toFixed(i > 0 ? 1 : 0) + " " + sizes[i]
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 8
        color: root.hovered
            ? Qt.lighter(Material.color(Material.Grey, Material.Shade800), 1.1)
            : "transparent"

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
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Checkbox
        CheckBox {
            id: itemCheck
            checked: root.isSelected
            Material.foreground: Material.color(Material.Green, Material.Shade300)
        }

        // Type icon
        Label {
            id: typeIcon
            property bool isImage: root.isImage
            text: isImage ? "\uD83D\uDDBC\uFE0F" : "\uD83C\uDFAC"
            font.pixelSize: 18
        }

        // File name and details
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                id: nameLabel
                text: root.fileName
                font.pixelSize: 13
                color: Material.foreground
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }

            // Resolution or duration info
            Label {
                property string detail: ""
                text: {
                    var parts = []
                    if (root.fileWidth > 0 && root.fileHeight > 0)
                        parts.push("%1\u00d7%2".arg(root.fileWidth).arg(root.fileHeight))
                    if (root.durationSec !== 0 && root.durationSec !== "0")
                        parts.push(root.durationSec)
                    if (root.suggestedCodec !== "")
                        parts.push(root.suggestedCodec)
                    if (root.projWidth > 0 && root.projHeight > 0)
                        parts.push("\u2192 %1\u00d7%2".arg(root.projWidth).arg(root.projHeight))
                    return parts.join(" \u2022 ")
                }
                font.pixelSize: 11
                color: Material.hintTextColor
                visible: text !== ""
            }
        }

        // Size info: original -> projected
        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                spacing: 4

                Label {
                    id: sizeLabel
                    text: root.fileSize
                    font.pixelSize: 12
                    color: Material.hintTextColor
                }

                Label {
                    text: "\u2192"
                    font.pixelSize: 12
                    color: Material.color(Material.Green, Material.Shade300)
                }

                Label {
                    id: projectedLabel
                    text: root.projectedSize
                    font.pixelSize: 12
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                }
            }
        }

        // Savings percentage
        Label {
            id: savingsLabel
            property real value: root.savingsPct
            text: value > 0 ? "-%1%".arg(Math.round(value)) : ""
            font.pixelSize: 12
            font.bold: true
            color: value > 0 ? Material.color(Material.Green, Material.Shade300) : Material.hintTextColor
            Layout.minimumWidth: 50
            horizontalAlignment: Text.AlignHCenter
        }

        // Quality stars
        Label {
            id: starsLabel
            text: root.qualityStars
            font.pixelSize: 12
            color: Material.color(Material.Yellow, Material.Shade300)
            Layout.minimumWidth: 50
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
