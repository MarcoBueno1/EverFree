// SPDX-License-Identifier: MIT
/*
 * EverFree — FolderCard (DEPRECATED)
 * This component is not currently used in any active page.
 * AdvancedWelcome uses an inline delegate instead.
 * Kept for potential future use. Safe to remove if never referenced.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: root

    property string folderPath: ""
    property alias hovered: mouseArea.containsMouse

    width: parent ? parent.width - 20 : 400
    height: 48
    radius: 12
    color: hovered ? Material.color(Material.Grey, Material.Shade700) :
                     Material.color(Material.Grey, Material.Shade800)

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 8
        spacing: 12

        Label {
            text: "📁"
            font.pixelSize: 20
        }

        Label {
            text: root.folderPath
            font.pixelSize: 14
            elide: Text.ElideMiddle
            color: Material.foreground
            Layout.fillWidth: true
        }

        Button {
            text: "✕"
            flat: true
            font.pixelSize: 16
            Material.foreground: Material.color(Material.Red, Material.Shade400)
            onClicked: {
                // Signal to parent
                removeRequested()
            }
        }
    }

    signal removeRequested()
}
