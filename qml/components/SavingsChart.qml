// SPDX-License-Identifier: MIT
/*
 * EverFree — SavingsChart
 * Simple bar chart comparing original vs projected size
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCharts

Rectangle {
    id: root

    property qint64 originalSize: 0
    property qint64 projectedSize: 0
    property string originalLabel: "Original"
    property string projectedLabel: "Depois"

    width: 400
    height: 250
    color: "transparent"

    ChartView {
        id: chartView
        anchors.fill: parent
        anchors.margins: 10
        theme: ChartView.ChartThemeDark
        antialiasing: true
        legend.visible: false
        backgroundColor: "transparent"

        BarSeries {
            id: barSeries
            axisX: BarCategoryAxis { categories: [root.originalLabel, root.projectedLabel] }
            axisY: ValueAxis { min: 0; max: Math.max(root.originalSize, root.projectedSize) * 1.1 }

            BarSet {
                label: "Tamanho"
                values: [root.originalSize, root.projectedSize]
                color: Material.color(Material.Green, Material.Shade600)
                borderColor: Material.color(Material.Green, Material.Shade400)
            }
        }
    }

    // Size labels on top of bars
    Label {
        text: formatBytes(root.originalSize)
        font.pixelSize: 12
        font.bold: true
        color: Material.foreground
        anchors.horizontalCenter: chartView.left
        anchors.bottom: chartView.top
        anchors.bottomMargin: 5
    }

    Label {
        text: formatBytes(root.projectedSize)
        font.pixelSize: 12
        font.bold: true
        color: Material.color(Material.Green, Material.Shade300)
        anchors.horizontalCenter: chartView.right
        anchors.bottom: chartView.top
        anchors.bottomMargin: 5
    }

    function formatBytes(bytes) {
        if (bytes < 1024) return bytes + " B"
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB"
        if (bytes < 1073741824) return (bytes / 1048576).toFixed(1) + " MB"
        return (bytes / 1073741824).toFixed(2) + " GB"
    }
}
