// SPDX-License-Identifier: MIT
/*
 * EverFree — ConfirmDialog
 * Generic confirmation dialog
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root

    property string messageText: ""
    property string confirmText: "Confirmar"
    property string cancelText: "Cancelar"

    signal confirmed()
    signal cancelled()

    modal: true
    focus: true
    width: 400
    height: 200
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Material.primary: Material.Green

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Label {
            text: root.title
            font.pixelSize: 16
            font.bold: true
            color: Material.foreground
        }

        Label {
            text: root.messageText
            font.pixelSize: 13
            color: Material.hintTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignRight

            Button {
                text: root.cancelText
                flat: true
                onClicked: {
                    root.cancelled()
                    root.close()
                }
            }

            Button {
                text: root.confirmText
                highlighted: true
                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
        }
    }
}
