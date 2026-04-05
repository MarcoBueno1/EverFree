// SPDX-License-Identifier: MIT
/*
 * EverFree — StatusBar
 * Shows current status text in footer
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

ToolBar {
    id: root

    property string statusText: ""
    property int itemCount: 0
    property string selectedText: ""

    Material.background: Material.color(Material.Grey, Material.Shade800)
    Material.elevation: 2

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 16

        Label {
            text: root.statusText
            font.pixelSize: 12
            color: Material.hintTextColor
            elide: Text.ElideMiddle
            Layout.fillWidth: true
        }

        Label {
            text: root.selectedText
            font.pixelSize: 12
            font.bold: true
            color: Material.color(Material.Green, Material.Shade300)
            visible: root.selectedText.length > 0
        }
    }
}
