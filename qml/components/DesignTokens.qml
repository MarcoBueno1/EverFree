// SPDX-License-Identifier: MIT
/*
 * EverFree — Design Tokens
 * Centralized visual design constants for consistency across all pages
 *
 * USAGE in QML:
 *   import "../components"
 *   leftPadding: DesignTokens.pagePadding
 *   radius: DesignTokens.cardRadius
 */

pragma Singleton

import QtQuick

QtObject {
    // ── Spacing ──────────────────────────────────────────────────────
    readonly property int spacingXS: 4
    readonly property int spacingSM: 8
    readonly property int spacingMD: 12
    readonly property int spacingLG: 16
    readonly property int spacingXL: 20
    readonly property int spacingXXL: 24

    // ── Page Layout ──────────────────────────────────────────────────
    readonly property int pagePadding: 30
    readonly property int pagePaddingSM: 24
    readonly property int pagePaddingLG: 32

    // ── Cards & Containers ───────────────────────────────────────────
    readonly property int cardRadius: 12
    readonly property int cardRadiusSM: 8
    readonly property int cardRadiusLG: 14
    readonly property int cardMargin: 16
    readonly property int cardElevation: 2

    // ── Buttons ──────────────────────────────────────────────────────
    readonly property int buttonHeight: 48
    readonly property int buttonHeightSM: 36
    readonly property int buttonHeightLG: 56
    readonly property int buttonRadius: 12
    readonly property int buttonRadiusSM: 8
    readonly property int buttonRadiusLG: 14

    // ── Typography ───────────────────────────────────────────────────
    // Display/Hero numbers
    readonly property int fontSizeHero: 64
    readonly property int fontSizeDisplay: 48
    
    // Headings
    readonly property int fontSizeH1: 26
    readonly property int fontSizeH2: 22
    readonly property int fontSizeH3: 20
    readonly property int fontSizeH4: 18
    
    // Body
    readonly property int fontSizeBody: 14
    readonly property int fontSizeBodySM: 13
    readonly property int fontSizeBodyLG: 15
    
    // Captions/Labels
    readonly property int fontSizeCaption: 12
    readonly property int fontSizeCaptionSM: 11

    // ── Icon Sizes ───────────────────────────────────────────────────
    readonly property int iconSizeSM: 16
    readonly property int iconSizeMD: 20
    readonly property int iconSizeLG: 24
    readonly property int iconSizeXL: 32
    readonly property int iconSizeXXL: 48
    readonly property int iconSizeHero: 64

    // ── Colors (Dark Theme) ─────────────────────────────────────────
    readonly property string bgWindow: "#303030"
    readonly property string bgCard: "#3A3A3A"
    readonly property string bgCardAlt: "#404040"
    readonly property string bgButton: "#4A4A4A"
    readonly property string borderDefault: "#505050"
    readonly property string borderLight: "#606060"

    // ── Colors (Light Theme) ────────────────────────────────────────
    readonly property string bgWindowLight: "#F5F5F5"
    readonly property string bgCardLight: "#FAFAFA"
    readonly property string bgCardAltLight: "#F0F0F0"
    readonly property string bgButtonLight: "#E8E8E8"
    readonly property string borderDefaultLight: "#E0E0E0"
    readonly property string borderLightLight: "#D0D0D0"

    // ── Animations ──────────────────────────────────────────────────
    readonly property int animDurationFast: 150
    readonly property int animDurationNormal: 250
    readonly property int animDurationSlow: 400
}
