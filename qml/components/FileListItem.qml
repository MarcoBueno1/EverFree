import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {
    id: root
    height: visible ? 52 : 0
    visible: matchesFilter

    property alias fileName: nameLabel.text
    property alias fileSize: sizeLabel.text
    property alias projectedSize: projectedLabel.text
    property alias isImage: typeIcon.isImage
    property alias savingsPct: savingsLabel.value
    property alias qualityStars: starsLabel.text
    property alias isSelected: itemCheck.checked
    property bool isVideo: false
    property string filterText: ""
    property int filterType: 0 // 0=All, 1=Images, 2=Videos
    property bool hovered: false

    // Filter matching logic
    property bool matchesFilter: {
        var typeMatch = filterType === 0 ||
            (filterType === 1 && isImage) ||
            (filterType === 2 && isVideo)
        var nameMatch = filterText === "" ||
            nameLabel.text.toLowerCase().indexOf(filterText.toLowerCase()) >= 0
        return typeMatch && nameMatch
    }

    // Roles from FileItemModel
    property string filePath: ""
    property string suggestedCodec: ""
    property int fileWidth: 0
    property int fileHeight: 0
    property string durationSec: ""
    property int projWidth: 0
    property int projHeight: 0

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
            checked: true
            Material.foreground: Material.color(Material.Green, Material.Shade300)
        }

        // Type icon
        Label {
            id: typeIcon
            property bool isImage: true
            text: isImage ? "\uD83D\uDDBC\uFE0F" : "\uD83C\uDFAC"
            font.pixelSize: 18
        }

        // File name and details
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                id: nameLabel
                text: fileName
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
                    if (root.durationSec !== "" && root.durationSec !== "0")
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
                    text: fileSize
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
                    text: projectedSize
                    font.pixelSize: 12
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                }
            }
        }

        // Savings percentage
        Label {
            id: savingsLabel
            property real value: 0
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
            text: qualityStars
            font.pixelSize: 12
            color: Material.color(Material.Yellow, Material.Shade300)
            Layout.minimumWidth: 50
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
