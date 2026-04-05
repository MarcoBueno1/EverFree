// SPDX-License-Identifier: MIT
/*
 * EverFree — SettingsDialog
 * Advanced settings for power users
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Dialog {
    id: root

    title: qsTr("⚙️ Configurações Avançadas")
    modal: true
    focus: true
    width: 500
    height: 650
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    Material.primary: Material.Green

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Label {
            text: "🖼️ Imagens"
            font.pixelSize: 16
            font.bold: true
            color: Material.color(Material.Green, Material.Shade300)
        }

        // Image format
        RowLayout {
            spacing: 12
            Label { text: "Formato:"; width: 120 }
            ComboBox {
                id: formatCombo
                Layout.fillWidth: true
                model: ["Mesmo (same)", "WebP", "JPEG", "PNG", "BMP"]
                property var values: ["same", "webp", "jpg", "png", "bmp"]
            }
        }

        // Image quality
        RowLayout {
            spacing: 12
            Label { text: "Qualidade:"; width: 120 }
            Slider {
                id: qualitySlider
                Layout.fillWidth: true
                from: 1
                to: 100
                value: appController.imageQuality
            }
            Label { text: qualitySlider.value.toFixed(0); width: 30 }
        }

        // Resize spec
        RowLayout {
            spacing: 12
            Label { text: "Redimensionar:"; width: 120 }
            TextField {
                id: resizeField
                Layout.fillWidth: true
                text: appController.resizeSpec
                placeholderText: "fit:1920x1080, 50%, 1920x1080"
            }
        }

        Label {
            text: "🎬 Vídeos"
            font.pixelSize: 16
            font.bold: true
            color: Material.color(Material.Green, Material.Shade300)
        }

        // Video codec
        RowLayout {
            spacing: 12
            Label { text: "Codec:"; width: 120 }
            ComboBox {
                id: codecCombo
                Layout.fillWidth: true
                model: ["Automático", "H.265", "H.264", "VP9"]
                property var values: ["auto", "h265", "h264", "vp9"]
            }
        }

        // CRF
        RowLayout {
            spacing: 12
            Label { text: "CRF (qualidade):"; width: 120 }
            Slider {
                id: crfSlider
                Layout.fillWidth: true
                from: -1
                to: 51
                value: appController.crf
            }
            Label { text: crfSlider.value < 0 ? "Auto" : crfSlider.value.toFixed(0); width: 40 }
        }

        // Max resolution
        RowLayout {
            spacing: 12
            Label { text: "Resolução máx:"; width: 120 }
            ComboBox {
                id: resCombo
                Layout.fillWidth: true
                model: ["Original", "4K", "1080p", "720p", "480p"]
                property var values: ["original", "4k", "1080p", "720p", "480p"]
            }
        }

        Label {
            text: "⚡ Geral"
            font.pixelSize: 16
            font.bold: true
            color: Material.color(Material.Green, Material.Shade300)
        }

        // Threads
        RowLayout {
            spacing: 12
            Label { text: "Threads:"; width: 120 }
            SpinBox {
                id: threadBox
                from: 0
                to: 64
                value: appController.threads
            }
            Label { text: "(0 = automático)"; color: Material.hintTextColor }
        }

        Item { Layout.fillHeight: true }

        // Buttons
        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignRight

            Button {
                text: "Cancelar"
                flat: true
                onClicked: root.close()
            }

            Button {
                text: "Salvar"
                highlighted: true
                onClicked: {
                    // Apply settings to appController
                    appController.imageFormat = formatCombo.values[formatCombo.currentIndex]
                    appController.imageQuality = qualitySlider.value
                    appController.resizeSpec = resizeField.text
                    appController.vcodec = codecCombo.values[codecCombo.currentIndex]
                    appController.crf = crfSlider.value
                    appController.maxRes = resCombo.values[resCombo.currentIndex]
                    appController.threads = threadBox.value
                    root.close()
                }
            }
        }
    }
}
