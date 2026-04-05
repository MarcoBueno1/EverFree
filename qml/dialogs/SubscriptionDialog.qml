// SPDX-License-Identifier: MIT
/*
 * EverFree — SubscriptionDialog
 * Shows plan options, login/register, and account management.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Dialog {
    id: root
    title: appController.isPro ? "⭐ Sua Conta Pro" : "🚀 Faça Upgrade para Pro"
    modal: true
    focus: true
    width: 480
    height: appController.isPro ? 420 : 520
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    Material.primary: Material.Green

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // ── LOGGED IN (Pro user) ───────────────────────────────
        ColumnLayout {
            visible: appController.isPro
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "✅ Você está no plano Pro!"
                font.pixelSize: 18
                font.bold: true
                color: Material.color(Material.Green, Material.Shade300)
                Layout.alignment: Qt.AlignHCenter
            }

            // Account info
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 12
                color: Material.color(Material.Grey, Material.Shade800)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label { text: "📧 " + appController.userEmail; font.pixelSize: 14; color: Material.foreground }
                    Label { text: "📋 Plano: " + appController.planTier.toUpperCase(); font.pixelSize: 14; color: Material.foreground }
                    Label { text: "📅 Expira: " + appController.subscriptionExpiry; font.pixelSize: 14; color: Material.foreground }
                    Label { text: "☁️ Backups: " + appController.backupsUsed; font.pixelSize: 14; color: Material.foreground }
                }
            }

            // Benefits
            Label { text: "✨ Seus benefícios:"; font.pixelSize: 14; font.bold: true; color: Material.color(Material.Green, Material.Shade300) }
            Label { text: "☁️  Backup automático na nuvem antes de comprimir"; font.pixelSize: 13; color: Material.hintTextColor }
            Label { text: "🔄  Rollback — restaure originais a qualquer momento"; font.pixelSize: 13; color: Material.hintTextColor }
            Label { text: "📦  Backups ilimitados"; font.pixelSize: 13; color: Material.hintTextColor }

            Button {
                text: "🚪 Sair da conta"
                flat: true
                Material.foreground: Material.color(Material.Red, Material.Shade400)
                onClicked: {
                    appController.cloudLogout()
                    root.close()
                }
            }
        }

        // ── NOT LOGGED IN (Free user) ──────────────────────────
        ColumnLayout {
            visible: !appController.isPro
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            // Free plan info
            Rectangle {
                Layout.fillWidth: true
                height: 70
                radius: 12
                color: Material.color(Material.Grey, Material.Shade800)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 4

                    Label { text: "🆓 Plano Gratuito"; font.pixelSize: 16; font.bold: true; color: Material.foreground }
                    Label { text: "✅ Compressão ilimitada  ❌ Sem backup  ❌ Sem rollback"; font.pixelSize: 12; color: Material.hintTextColor }
                }
            }

            // Pro benefits
            Rectangle {
                Layout.fillWidth: true
                height: 120
                radius: 12
                color: Material.color(Material.Green, Material.Shade900)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Label {
                        text: "⭐ Plano Pro — R$ 9,90/mês"
                        font.pixelSize: 16
                        font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                    }

                    Label { text: "☁️ Backup automático antes de comprimir"; font.pixelSize: 13; color: Material.foreground }
                    Label { text: "🔄 Rollback — restaure originais quando quiser"; font.pixelSize: 13; color: Material.foreground }
                    Label { text: "📦 Backups ilimitados na nuvem"; font.pixelSize: 13; color: Material.foreground }
                }
            }

            // Login form
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label { text: "Já tem conta? Faça login:"; font.pixelSize: 13; color: Material.hintTextColor }

                TextField {
                    id: loginEmail
                    Layout.fillWidth: true
                    placeholderText: "E-mail"
                    font.pixelSize: 14
                }

                TextField {
                    id: loginPassword
                    Layout.fillWidth: true
                    placeholderText: "Senha"
                    echoMode: TextInput.Password
                    font.pixelSize: 14
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "Entrar"
                        highlighted: true
                        Material.background: Material.color(Material.Green, Material.Shade600)
                        Layout.fillWidth: true
                        onClicked: {
                            if (loginEmail.text && loginPassword.text) {
                                appController.cloudLogin(loginEmail.text, loginPassword.text)
                                root.close()
                            }
                        }
                    }

                    Button {
                        text: "Criar conta grátis"
                        flat: true
                        Layout.fillWidth: true
                        onClicked: {
                            if (loginEmail.text && loginPassword.text) {
                                appController.cloudRegister(loginEmail.text, loginPassword.text)
                                root.close()
                            }
                        }
                    }
                }
            }

            // Demo/Test buttons
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Material.color(Material.Grey, Material.Shade700)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label { text: "🧪 Teste (demo):"; font.pixelSize: 12; color: Material.hintTextColor }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "Ativar Pro Trial (7 dias)"
                        flat: true
                        Material.foreground: Material.accentColor
                        Layout.fillWidth: true
                        onClicked: { appController.activateProTrial(); root.close() }
                    }

                    Button {
                        text: "Ativar Pro (demo)"
                        flat: true
                        Material.foreground: Material.accentColor
                        Layout.fillWidth: true
                        onClicked: { appController.activatePro(); root.close() }
                    }
                }
            }
        }

        // Close button
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 8

            Button {
                text: "Fechar"
                onClicked: root.close()
            }
        }
    }
}
