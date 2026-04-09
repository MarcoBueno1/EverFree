// SPDX-License-Identifier: MIT
/*
 * EverFree — SavingsBadge
 * Shows estimated savings percentage as a colorful badge
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Rectangle {
    id: root

    property double savingsPct: 0
    property alias text: badgeText.text

    width: badgeLayout.implicitWidth + 16
    height: 28
    radius: 14
    color: {
        if (savingsPct >= 80) return Material.color(Material.Green, Material.Shade700)
        if (savingsPct >= 50) return Material.color(Material.Blue, Material.Shade600)
        if (savingsPct >= 30) return Material.color(Material.Orange, Material.Shade600)
        return Material.color(Material.Red, Material.Shade500)
    }

    Behavior on color {
        ColorAnimation { duration: 300 }
    }
    
    // FIX: Add accessibility and text label for colorblind users
    Accessible.role: Accessible.StaticText
    Accessible.name: qsTr("Economia de %1%").arg(Math.round(savingsPct))
    Accessible.description: {
        if (savingsPct >= 80) return "Excelente - Economia excelente"
        if (savingsPct >= 50) return "Bom - Economia boa"
        if (savingsPct >= 30) return "Moderado - Economia moderada"
        return "Baixo - Economia baixa"
    }

    RowLayout {
        id: badgeLayout
        anchors.centerIn: parent
        spacing: 4

        Label {
            id: badgeText
            text: savingsPct.toFixed(0) + "%"
            font.pixelSize: 12
            font.bold: true
            color: Material.primaryTextColor
        }
    }
}
