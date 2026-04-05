// SPDX-License-Identifier: MIT
/*
 * EverFree — BigButton
 * Large, prominent button for simple mode actions
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Button {
    id: root

    property string icon: ""
    property bool isPrimary: true

    implicitHeight: 64
    implicitWidth: 280

    Material.background: isPrimary ?
        Material.color(Material.Green, Material.Shade600) :
        Material.color(Material.Grey, Material.Shade700)
    Material.foreground: isPrimary ? Material.primaryTextColor : Material.foreground

    font.pixelSize: 18
    font.bold: true
    font.weight: Font.Bold

    flat: false

    contentItem: RowLayout {
        spacing: 12

        Label {
            text: root.icon
            font.pixelSize: 28
            color: root.Material.foreground
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            text: root.text
            font: root.font
            color: root.Material.foreground
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideMiddle
            Layout.fillWidth: true
        }
    }

    background: Rectangle {
        implicitHeight: root.implicitHeight
        implicitWidth: root.implicitWidth
        radius: 16
        color: root.pressed ?
            Material.color(Material.Green, Material.Shade800) :
            root.Material.background

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
}
