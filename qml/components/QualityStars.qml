// SPDX-License-Identifier: MIT
/*
 * EverFree — QualityStars
 * Shows quality rating as star icons (★★★★☆)
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Row {
    id: root

    property int stars: 3
    property int maxStars: 5

    spacing: 2

    Repeater {
        model: maxStars

        Label {
            text: index < root.stars ? "★" : "☆"
            font.pixelSize: 14
            color: index < root.stars ?
                Material.color(Material.Amber, Material.Shade400) :
                Material.hintTextColor
        }
    }
}
