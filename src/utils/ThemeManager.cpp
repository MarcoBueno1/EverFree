// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI theme manager implementation.
 */

#include "ThemeManager.hpp"
#include <QSettings>

ThemeManager::ThemeManager(QObject* parent)
    : QObject(parent)
{
    // Restore preference from settings
    QSettings settings("batchpress", "batchpress_gui");
    m_darkMode = settings.value("darkMode", false).toBool();
    m_highContrast = settings.value("highContrast", false).toBool();
}

void ThemeManager::applyTheme(QGuiApplication* app)
{
    if (!app) return;
    
    QPalette palette;
    if (m_highContrast) {
        palette = m_darkMode ? createHighContrastDarkPalette() : createHighContrastLightPalette();
    } else {
        palette = m_darkMode ? createDarkPalette() : createLightPalette();
    }
    
    app->setPalette(palette);
    emit darkModeChanged();
}

void ThemeManager::toggleTheme()
{
    m_darkMode = !m_darkMode;
    QSettings settings("batchpress", "batchpress_gui");
    settings.setValue("darkMode", m_darkMode);
    applyTheme(qGuiApp);
}

void ThemeManager::setDarkMode(bool dark)
{
    if (m_darkMode == dark) return;
    m_darkMode = dark;
    QSettings settings("batchpress", "batchpress_gui");
    settings.setValue("darkMode", m_darkMode);
    applyTheme(qGuiApp);
}

void ThemeManager::setHighContrast(bool enabled)
{
    if (m_highContrast == enabled) return;
    m_highContrast = enabled;
    QSettings settings("batchpress", "batchpress_gui");
    settings.setValue("highContrast", m_highContrast);
    emit highContrastChanged();
    applyTheme(qGuiApp);
}

void ThemeManager::toggleHighContrast()
{
    setHighContrast(!m_highContrast);
}

QPalette ThemeManager::createDarkPalette()
{
    QPalette palette;
    QColor bg(0x1e, 0x1e, 0x1e);
    QColor window(0x12, 0x12, 0x12);
    QColor text(0xe0, 0xe0, 0xe0);
    QColor button(0x3a, 0x3a, 0x3a);
    QColor highlight(0x4a, 0x90, 0xd9);

    palette.setColor(QPalette::ColorRole::Window, window);
    palette.setColor(QPalette::ColorRole::Base, bg);
    palette.setColor(QPalette::ColorRole::WindowText, text);
    palette.setColor(QPalette::ColorRole::Text, text);
    palette.setColor(QPalette::ColorRole::Button, button);
    palette.setColor(QPalette::ColorRole::ButtonText, text);
    palette.setColor(QPalette::ColorRole::Highlight, highlight);
    palette.setColor(QPalette::ColorRole::HighlightedText, Qt::white);
    palette.setColor(QPalette::ColorRole::Link, highlight);
    palette.setColor(QPalette::ColorGroup::Disabled, QPalette::ColorRole::WindowText,
                     QColor(0x80, 0x80, 0x80));
    palette.setColor(QPalette::ColorGroup::Disabled, QPalette::ColorRole::Text,
                     QColor(0x80, 0x80, 0x80));
    return palette;
}

QPalette ThemeManager::createLightPalette()
{
    QPalette palette;
    QColor bg(0xf5, 0xf5, 0xf5);
    QColor window(0xff, 0xff, 0xff);
    QColor text(0x21, 0x21, 0x21);
    QColor button(0xe0, 0xe0, 0xe0);
    QColor highlight(0x4a, 0x90, 0xd9);

    palette.setColor(QPalette::ColorRole::Window, window);
    palette.setColor(QPalette::ColorRole::Base, bg);
    palette.setColor(QPalette::ColorRole::WindowText, text);
    palette.setColor(QPalette::ColorRole::Text, text);
    palette.setColor(QPalette::ColorRole::Button, button);
    palette.setColor(QPalette::ColorRole::ButtonText, text);
    palette.setColor(QPalette::ColorRole::Highlight, highlight);
    palette.setColor(QPalette::ColorRole::HighlightedText, Qt::white);
    palette.setColor(QPalette::ColorRole::Link, highlight);
    palette.setColor(QPalette::ColorGroup::Disabled, QPalette::ColorRole::WindowText,
                     QColor(0xa0, 0xa0, 0xa0));
    palette.setColor(QPalette::ColorGroup::Disabled, QPalette::ColorRole::Text,
                     QColor(0xa0, 0xa0, 0xa0));
    return palette;
}

QPalette ThemeManager::createHighContrastDarkPalette()
{
    QPalette palette;
    palette.setColor(QPalette::Window, QColor(0, 0, 0));
    palette.setColor(QPalette::WindowText, QColor(255, 255, 255));
    palette.setColor(QPalette::Base, QColor(20, 20, 20));
    palette.setColor(QPalette::AlternateBase, QColor(40, 40, 40));
    palette.setColor(QPalette::ToolTipBase, QColor(255, 255, 120));
    palette.setColor(QPalette::ToolTipText, QColor(0, 0, 0));
    palette.setColor(QPalette::Text, QColor(255, 255, 255));
    palette.setColor(QPalette::Button, QColor(60, 60, 60));
    palette.setColor(QPalette::ButtonText, QColor(255, 255, 255));
    palette.setColor(QPalette::BrightText, QColor(255, 255, 0));
    palette.setColor(QPalette::Link, QColor(0, 255, 255));
    palette.setColor(QPalette::Highlight, QColor(0, 120, 215));
    palette.setColor(QPalette::HighlightedText, QColor(255, 255, 255));
    return palette;
}

QPalette ThemeManager::createHighContrastLightPalette()
{
    QPalette palette;
    palette.setColor(QPalette::Window, QColor(255, 255, 255));
    palette.setColor(QPalette::WindowText, QColor(0, 0, 0));
    palette.setColor(QPalette::Base, QColor(240, 240, 240));
    palette.setColor(QPalette::AlternateBase, QColor(220, 220, 220));
    palette.setColor(QPalette::ToolTipBase, QColor(255, 255, 200));
    palette.setColor(QPalette::ToolTipText, QColor(0, 0, 0));
    palette.setColor(QPalette::Text, QColor(0, 0, 0));
    palette.setColor(QPalette::Button, QColor(200, 200, 200));
    palette.setColor(QPalette::ButtonText, QColor(0, 0, 0));
    palette.setColor(QPalette::BrightText, QColor(0, 0, 255));
    palette.setColor(QPalette::Link, QColor(0, 0, 200));
    palette.setColor(QPalette::Highlight, QColor(0, 100, 200));
    palette.setColor(QPalette::HighlightedText, QColor(255, 255, 255));
    return palette;
}
