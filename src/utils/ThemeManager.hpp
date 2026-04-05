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
    Q_PROPERTY(QString currentTheme READ currentTheme NOTIFY darkModeChanged FINAL)

public:
    explicit ThemeManager(QObject* parent = nullptr);

    bool darkMode() const noexcept { return m_darkMode; }
    QString currentTheme() const noexcept { return m_darkMode ? "MaterialDark" : "MaterialLight"; }

    /**
     * @brief Apply the theme to the entire application.
     */
    Q_INVOKABLE void applyTheme(QGuiApplication* app);

    /**
     * @brief Toggle between light and dark mode.
     */
    Q_INVOKABLE void toggleTheme();

public slots:
    void setDarkMode(bool dark);

signals:
    void darkModeChanged();

private:
    QPalette createDarkPalette();
    QPalette createLightPalette();

    bool m_darkMode = false;
};
