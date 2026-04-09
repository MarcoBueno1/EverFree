// SPDX-License-Identifier: MIT
/*
 * EverFree — OnboardingDialog
 * First-time user guide (3 screens)
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Dialog {
    id: root

    title: ""
    modal: true
    focus: true
    width: 520
    height: 480
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    closePolicy: Popup.CloseOnEscape

    // Track current onboarding page
    property int currentPage: 0
    readonly property int totalPages: 3

    // Don't close on click outside
    background: Rectangle {
        // FIX: Use lighter grey for better contrast with text
        color: themeManager.darkMode ? "#303030" : Material.color(Material.Grey, Material.Shade50)
        radius: 14
        border.color: Material.color(Material.Green, Material.Shade700)
        border.width: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // Progress indicator
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Repeater {
                model: root.totalPages

                Rectangle {
                    width: index === root.currentPage ? 24 : 8
                    height: 8
                    radius: 8
                    color: index === root.currentPage ? 
                           Material.color(Material.Green, Material.Shade400) :
                           index < root.currentPage ?
                           Material.color(Material.Green, Material.Shade600) :
                           Material.color(Material.Grey, Material.Shade600)
                    
                    Behavior on width { 
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic } 
                    }
                    Behavior on color { 
                        ColorAnimation { duration: 200 } 
                    }
                }
            }
        }

        // Swipeable content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentPage

            // ── Page 1: Welcome ──────────────────────────────────────────
            ColumnLayout {
                spacing: 20

                Item { Layout.fillHeight: true }

                Label {
                    text: "🌿"
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("Bem-vindo ao EverFree!")
                    font.pixelSize: 26
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("Libere espaço no seu disco automaticamente")
                    font.pixelSize: 16
                    color: Material.foreground
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Label {
                    text: qsTr("Escaneie pastas, comprima imagens e vídeos,\ne recupere gigas de espaço sem esforço.")
                    font.pixelSize: 14
                    color: Material.hintTextColor
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }
            }

            // ── Page 2: How It Works ─────────────────────────────────────
            ColumnLayout {
                spacing: 24

                Label {
                    text: qsTr("Como Funciona?")
                    font.pixelSize: 24
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                    Layout.alignment: Qt.AlignHCenter
                }

                // Step 1
                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Rectangle {
                        width: 48; height: 48; radius: 14
                        color: Material.color(Material.Green, Material.Shade800)
                        Label {
                            anchors.centerIn: parent
                            text: "📂"; font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label {
                            text: qsTr("1. Escaneie")
                            font.pixelSize: 16; font.bold: true
                            color: Material.foreground
                        }
                        Label {
                            text: qsTr("Selecione pastas para analisar automaticamente")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                // Step 2
                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Rectangle {
                        width: 48; height: 48; radius: 14
                        color: Material.color(Material.Green, Material.Shade800)
                        Label {
                            anchors.centerIn: parent
                            text: "📊"; font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label {
                            text: qsTr("2. Preview")
                            font.pixelSize: 16; font.bold: true
                            color: Material.foreground
                        }
                        Label {
                            text: qsTr("Veja quanto espaço pode liberar antes de comprimir")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                // Step 3
                RowLayout {
                    spacing: 16
                    Layout.fillWidth: true

                    Rectangle {
                        width: 48; height: 48; radius: 14
                        color: Material.color(Material.Green, Material.Shade800)
                        Label {
                            anchors.centerIn: parent
                            text: "⚡"; font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label {
                            text: qsTr("3. Comprima")
                            font.pixelSize: 16; font.bold: true
                            color: Material.foreground
                        }
                        Label {
                            text: qsTr("Um clique e pronto! Seus arquivos serão otimizados")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // ── Page 3: Ready! ───────────────────────────────────────────
            ColumnLayout {
                spacing: 20

                Item { Layout.fillHeight: true }

                Label {
                    text: "✅"
                    font.pixelSize: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("Tudo Pronto!")
                    font.pixelSize: 26
                    font.bold: true
                    color: Material.color(Material.Green, Material.Shade300)
                    Layout.alignment: Qt.AlignHCenter
                }

                // Mode explanation
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    radius: 12
                    // FIX: Use lighter grey for better contrast
                    color: themeManager.darkMode ? "#3A3A3A" : Material.color(Material.Grey, Material.Shade100)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Label {
                            text: "🔰 " + qsTr("Modo Simples")
                            font.pixelSize: 16; font.bold: true
                            color: Material.color(Material.Green, Material.Shade300)
                        }
                        Label {
                            text: qsTr("Perfeito para iniciantes — um clique e pronto!")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            height: 1; Layout.fillWidth: true
                            color: Material.color(Material.Grey, Material.Shade700)
                        }

                        Label {
                            text: "🎛️ " + qsTr("Modo Avançado")
                            font.pixelSize: 16; font.bold: true
                            color: Material.color(Material.Blue, Material.Shade300)
                        }
                        Label {
                            text: qsTr("Controle total para experts — codecs, qualidade, resolução")
                            font.pixelSize: 13
                            color: Material.hintTextColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }

                Label {
                    text: qsTr("💡 Você pode mudar o modo nas configurações (⚙️)")
                    font.pixelSize: 12
                    color: Material.hintTextColor
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Navigation buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Button {
                text: qsTr("Pular")
                flat: true
                visible: root.currentPage < root.totalPages - 1
                Material.foreground: Material.hintTextColor
                onClicked: root.currentPage = root.totalPages - 1
            }

            Item { Layout.fillWidth: true }

            Button {
                id: prevButton
                text: qsTr("← Anterior")
                flat: true
                visible: root.currentPage > 0
                Material.foreground: Material.foreground
                onClicked: root.currentPage--
            }

            Button {
                id: nextButton
                text: root.currentPage === root.totalPages - 1 ? 
                      qsTr("Começar a Usar 🚀") : 
                      qsTr("Próximo →")
                highlighted: true
                Material.background: Material.color(Material.Green, Material.Shade700)
                Material.foreground: Material.primaryTextColor
                font.bold: true
                onClicked: {
                    if (root.currentPage < root.totalPages - 1) {
                        root.currentPage++
                    } else {
                        // Signal to main.qml to save onboarding state
                        root.accept()
                    }
                }
            }
        }
    }
}
