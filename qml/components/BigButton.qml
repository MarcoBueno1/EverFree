// SPDX-License-Identifier: MIT
/*
 * EverFree — BigButton (DEPRECATED)
 * This component is not currently used in any active page.
 * Kept for potential future use. Safe to remove if never referenced.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Button {
    id: root
    Layout.preferredHeight: 64
    Layout.fillWidth: true

    property string iconText: ""

    contentItem: RowLayout {
        spacing: 12
        Label {
            text: root.iconText
            font.pixelSize: 28
        }
        Label {
            text: root.text
            font.pixelSize: 18
            font.bold: true
            color: "white"
        }
    }

    background: Rectangle {
        radius: 14
        color: root.pressed
            ? Material.color(Material.Green, Material.Shade900)
            : (root.hovered
                ? Material.color(Material.Green, Material.Shade600)
                : Material.color(Material.Green, Material.Shade700))
        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
