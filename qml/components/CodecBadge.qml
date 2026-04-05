// SPDX-License-Identifier: MIT
/*
 * EverFree — CodecBadge
 * Shows codec name as a small colored badge
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: root

    property string codec: ""

    width: codecLayout.implicitWidth + 12
    height: 22
    radius: 11
    color: codecColor

    property color codecColor: {
        if (codec.includes("WebP") || codec.includes("H.265") || codec.includes("h265"))
            return Material.color(Material.Green, Material.Shade800)
        if (codec.includes("H.264") || codec.includes("h264"))
            return Material.color(Material.Blue, Material.Shade700)
        if (codec.includes("VP9"))
            return Material.color(Material.Purple, Material.Shade700)
        return Material.color(Material.Grey, Material.Shade700)
    }

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    RowLayout {
        id: codecLayout
        anchors.centerIn: parent
        spacing: 2

        Label {
            text: codec
            font.pixelSize: 10
            font.bold: true
            color: Material.primaryTextColor
            elide: Text.ElideMiddle
        }
    }
}
