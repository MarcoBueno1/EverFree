// SPDX-License-Identifier: MIT
/*
 * EverFree — ErrorReportDialog
 * Shows list of inaccessible folders that were skipped
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Dialog {
    id: root

    title: qsTr("⚠️ Pastas Ignoradas")
    modal: true
    focus: true
    width: 550
    height: 450
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Material.primary: Material.Orange

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Label {
            text: "Estas pastas não puderam ser acessadas e foram ignoradas:"
            font.pixelSize: 13
            color: Material.hintTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Error list
        ListView {
            id: errorListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: appController.errorPaths

            delegate: Rectangle {
                width: errorListView.width - 10
                height: 44
                radius: 8
                // FIX: Use lighter grey for better contrast
                color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade200)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Label {
                        text: "⛔"
                        font.pixelSize: 16
                    }

                    Label {
                        text: modelData
                        font.pixelSize: 12
                        color: Material.color(Material.Orange, Material.Shade300)
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: "Nenhuma pasta ignorada ✅"
                font.pixelSize: 14
                color: Material.color(Material.Green, Material.Shade300)
                visible: errorListView.count === 0
            }
        }

        Label {
            text: "💡 Dica: Execute como administrador/root para acessar essas pastas."
            font.pixelSize: 11
            color: Material.hintTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // Buttons
        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignRight

            Button {
                text: "Limpar Lista"
                flat: true
                onClicked: appController.clearErrors()
            }

            Button {
                text: "Fechar"
                highlighted: true
                onClicked: root.close()
            }
        }
    }
}
