// SPDX-License-Identifier: MIT
/*
 * EverFree — SubscriptionDialog
 * Shows plan options, login/register, and account management.
 * FIX: Now waits for async login response before closing.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import EverFree 1.0

Dialog {
    id: root
    title: appController.isPro ? "\u2b50 Sua Conta Pro" : "\uD83D\uDE80 Fa\u00e7a Upgrade para Pro"
    modal: true
    focus: true
    width: 480
    height: appController.isPro ? 420 : 520
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    Material.primary: Material.Green

    // State for login in progress
    property bool loginInProgress: false
    property bool loginError: false
    property string loginErrorMessage: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // Error message
        Label {
            visible: root.loginError
            text: "\u26A0\uFE0F " + root.loginErrorMessage
            font.pixelSize: 13
            color: Material.color(Material.Red, Material.Shade300)
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        // ── LOGGED IN (Pro user) ───────────────────────────────
        ColumnLayout {
            visible: appController.isPro
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "\u2705 Voc\u00ea est\u00e1 no plano Pro!"
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

                    Label { text: "\uD83D\uDCE7 " + appController.userEmail; font.pixelSize: 14; color: Material.foreground }
                    Label { text: "\uD83D\uDCCB Plano: " + appController.planTier.toUpperCase(); font.pixelSize: 14; color: Material.foreground }
                    Label { text: "\uD83D\uDCC5 Expira: " + appController.subscriptionExpiry; font.pixelSize: 14; color: Material.foreground }
                    Label { text: "\u2601\uFE0F Backups: " + appController.backupsUsed; font.pixelSize: 14; color: Material.foreground }
                }
            }

            // Benefits
            Label { text: "\u2728 Seus benef\u00edcios:"; font.pixelSize: 14; font.bold: true; color: Material.color(Material.Green, Material.Shade300) }
            Label { text: "\u2601\uFE0F  Backup autom\u00e1tico na nuvem antes de comprimir"; font.pixelSize: 13; color: Material.hintTextColor }
            Label { text: "\uD83D\uDD04  Rollback \u2014 restaure originais a qualquer momento"; font.pixelSize: 13; color: Material.hintTextColor }
            Label { text: "\uD83D\uDCE6  Backups ilimitados"; font.pixelSize: 13; color: Material.hintTextColor }

            Button {
                text: "\uD83D\uDEAA Sair da conta"
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

                    Label { text: "\uD83C\uDD93 Plano Gratuito"; font.pixelSize: 16; font.bold: true; color: Material.foreground }
                    Label { text: "\u2705 Compress\u00e3o ilimitada  \u274C Sem backup  \u274C Sem rollback"; font.pixelSize: 12; color: Material.hintTextColor }
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
                        text: "\u2b50 Plano Pro \u2014 R$ 9,90/m\u00eas"
                        font.pixelSize: 16
                        font.bold: true
                        color: Material.color(Material.Green, Material.Shade300)
                    }

                    Label { text: "\u2601\uFE0F Backup autom\u00e1tico antes de comprimir"; font.pixelSize: 13; color: Material.foreground }
                    Label { text: "\uD83D\uDD04 Rollback \u2014 restaure originais quando quiser"; font.pixelSize: 13; color: Material.foreground }
                    Label { text: "\uD83D\uDCE6 Backups ilimitados na nuvem"; font.pixelSize: 13; color: Material.foreground }
                }
            }

            // Login form
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Label { text: "J\u00e1 tem conta? Fa\u00e7a login:"; font.pixelSize: 13; color: Material.hintTextColor }

                TextField {
                    id: loginEmail
                    Layout.fillWidth: true
                    placeholderText: "E-mail"
                    font.pixelSize: 14
                    enabled: !root.loginInProgress
                }

                TextField {
                    id: loginPassword
                    Layout.fillWidth: true
                    placeholderText: "Senha"
                    echoMode: TextInput.Password
                    font.pixelSize: 14
                    enabled: !root.loginInProgress

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            doLogin()
                            event.accepted = true
                        }
                    }
                }

                // Loading indicator
                Label {
                    visible: root.loginInProgress
                    text: "Entrando..."
                    font.pixelSize: 13
                    color: Material.hintTextColor
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: root.loginInProgress ? "Entrando..." : "Entrar"
                        highlighted: true
                        Material.background: Material.color(Material.Green, Material.Shade600)
                        Layout.fillWidth: true
                        enabled: loginEmail.text && loginPassword.text && !root.loginInProgress
                        onClicked: doLogin()
                    }

                    Button {
                        text: "Criar conta gr\u00e1tis"
                        flat: true
                        Layout.fillWidth: true
                        enabled: loginEmail.text && loginPassword.text && !root.loginInProgress
                        onClicked: {
                            if (loginEmail.text && loginPassword.text) {
                                root.loginInProgress = true
                                root.loginError = false
                                appController.cloudRegister(loginEmail.text, loginPassword.text)
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

                Label { text: "\uD83E\uDDEA Teste (demo):"; font.pixelSize: 12; color: Material.hintTextColor }

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

    function doLogin() {
        if (loginEmail.text && loginPassword.text && !root.loginInProgress) {
            root.loginInProgress = true
            root.loginError = false
            appController.cloudLogin(loginEmail.text, loginPassword.text)
        }
    }

    // Listen for login results
    Connections {
        target: appController
        function onCloudLoginSuccess() {
            root.loginInProgress = false
            root.loginError = false
            // Close after a short delay to let UI update
            Qt.callLater(function() { root.close() })
        }
        function onCloudLoginFailed(error) {
            root.loginInProgress = false
            root.loginError = true
            root.loginErrorMessage = error || "Falha no login. Verifique suas credenciais."
        }
    }
}
