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
    
    // FIX: Add accessibility for screen readers
    Accessible.role: Accessible.StaticText
    Accessible.name: qsTr("%1 de %2 estrelas").arg(stars).arg(maxStars)
    Accessible.description: qsTr("Qualidade avaliada como %1 estrelas de %2").arg(stars).arg(maxStars)

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
