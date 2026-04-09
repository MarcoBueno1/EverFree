// SPDX-License-Identifier: MIT
/*
 * EverFree — RollbackPage
 * Lists all cloud backups and allows restoring originals.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Page {
    id: root
    objectName: "rollbackPage"
    leftPadding: 30
    rightPadding: 30
    topPadding: 20
    bottomPadding: 30

    Component.onCompleted: {
        if (appController.isPro) appController.fetchBackups()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        // Title
        RowLayout {
            spacing: 16

            Label { text: "🔄"; font.pixelSize: 28 }
            Label {
                text: "Rollback — Restaurar Originais"
                font.pixelSize: 22
                font.bold: true
                color: Material.foreground
            }
            Item { Layout.fillWidth: true }

            Button {
                text: "↻ Atualizar"
                flat: true
                visible: appController.isPro
                onClicked: appController.fetchBackups()
            }

            Button {
                text: "← Voltar"
                flat: true
                onClicked: StackView.view.pop()
            }
        }

        // Not Pro message
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !appController.isPro
            spacing: 16

            Label {
                text: "🔒"
                font.pixelSize: 64
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Rollback disponível apenas no plano Pro"
                font.pixelSize: 18
                font.bold: true
                color: Material.foreground
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Faça upgrade para ter backup na nuvem e rollback a qualquer momento."
                font.pixelSize: 14
                color: Material.hintTextColor
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "⭐ Fazer Upgrade"
                highlighted: true
                Material.background: Material.color(Material.Green, Material.Shade600)
                Material.foreground: Material.primaryTextColor
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 15
                onClicked: subscriptionDialog.open()
            }
        }

        // Pro — backup list
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: appController.isPro
            spacing: 12

            Label {
                text: "Seus backups na nuvem:"
                font.pixelSize: 14
                color: Material.hintTextColor
            }

            // Backup list — TODO: Connect to C++ backup model
            ListView {
                id: backupList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                ScrollBar.vertical: ScrollBar {}

                // Model would be populated from C++ — for now placeholder
                model: 0

                delegate: Rectangle {
                    width: backupList.width - 10
                    height: 60
                    radius: 8
                    color: Material.color(Material.Grey, Material.Shade800)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Label { text: "📦"; font.pixelSize: 20 }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Label {
                                text: "backup_file_name.jpg"
                                font.pixelSize: 14
                                font.bold: true
                                color: Material.foreground
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }

                            Label {
                                text: "Original: 2.4 MB  •  05/04/2026 14:30"
                                font.pixelSize: 11
                                color: Material.hintTextColor
                            }
                        }

                        Button {
                            text: "🔄 Restaurar"
                            highlighted: true
                            Material.background: Material.color(Material.Green, Material.Shade600)
                            font.pixelSize: 12
                            onClicked: {
                                // Restore this backup
                                confirmRestoreDialog.open()
                            }
                        }
                    }
                }

                // Empty state
                Label {
                    anchors.centerIn: parent
                    text: "Nenhum backup encontrado.\nOs backups são criados automaticamente ao comprimir arquivos."
                    font.pixelSize: 14
                    color: Material.hintTextColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: backupList.count === 0
                }
            }
        }
    }

    // Confirmation dialog for restore
    Dialog {
        id: confirmRestoreDialog
        title: "Confirmar Rollback"
        modal: true
        width: 400
        height: 200
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            Label {
                text: "Restaurar este arquivo vai substituir a versão comprimida pelo original.\n\nDeseja continuar?"
                font.pixelSize: 13
                color: Material.hintTextColor
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                Button {
                    text: "Cancelar"
                    flat: true
                    onClicked: confirmRestoreDialog.close()
                }
                Button {
                    text: "Restaurar"
                    highlighted: true
                    Material.background: Material.color(Material.Green, Material.Shade600)
                    onClicked: {
                        // appController.restoreFile(backupId, originalPath)
                        confirmRestoreDialog.close()
                    }
                }
            }
        }
    }
}
