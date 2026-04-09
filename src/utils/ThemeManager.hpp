// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI theme manager.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QGuiApplication>
#include <QPalette>
#include <QColor>

/**
 * @brief Manages light/dark theme for the application.
 *
 * Exposed to QML as `themeManager`.
 */
class ThemeManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged FINAL)
    Q_PROPERTY(bool highContrast READ highContrast WRITE setHighContrast NOTIFY highContrastChanged FINAL)
    Q_PROPERTY(QString currentTheme READ currentTheme NOTIFY darkModeChanged FINAL)

public:
    explicit ThemeManager(QObject* parent = nullptr);

    bool darkMode() const noexcept { return m_darkMode; }
    bool highContrast() const noexcept { return m_highContrast; }
    QString currentTheme() const noexcept { 
        if (m_highContrast) return m_darkMode ? "HighContrastDark" : "HighContrastLight";
        return m_darkMode ? "MaterialDark" : "MaterialLight"; 
    }

    /**
     * @brief Apply the theme to the entire application.
     */
    Q_INVOKABLE void applyTheme(QGuiApplication* app);

    /**
     * @brief Toggle between light and dark mode.
     */
    Q_INVOKABLE void toggleTheme();

    /**
     * @brief Toggle high contrast mode for accessibility.
     */
    Q_INVOKABLE void toggleHighContrast();

public slots:
    void setDarkMode(bool dark);
    void setHighContrast(bool enabled);

signals:
    void darkModeChanged();
    void highContrastChanged();

private:
    QPalette createDarkPalette();
    QPalette createLightPalette();
    QPalette createHighContrastDarkPalette();
    QPalette createHighContrastLightPalette();

    bool m_darkMode = false;
    bool m_highContrast = false;
};
