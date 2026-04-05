// SPDX-License-Identifier: MIT
/*
 * EverFree — main.cpp
 * FIX W-14: qputenv BEFORE QGuiApplication.
 * FIX C-09: qmlRegisterUncreatableType to prevent duplicate instances.
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QDebug>

#include "AppController.hpp"
#include "utils/ThemeManager.hpp"

int main(int argc, char* argv[])
{
    // FIX W-14: MUST be before QGuiApplication construction
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");

    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);
    app.setApplicationName("EverFree");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("EverFree");

    // FIX C-09: Uncreatable types — QML can access enums but cannot create instances
    qmlRegisterUncreatableType<AppController>("EverFree", 1, 0, "AppController",
        "Use appController global object");
    qmlRegisterUncreatableType<FileItemModel>("EverFree", 1, 0, "FileItemModel",
        "Access via appController.fileModel");
    qmlRegisterUncreatableType<ScanReportModel>("EverFree", 1, 0, "ScanReportModel",
        "Access via appController.reportModel");
    qmlRegisterUncreatableType<ProgressModel>("EverFree", 1, 0, "ProgressModel",
        "Access via appController.progressModel");
    qmlRegisterUncreatableType<ThemeManager>("EverFree", 1, 0, "ThemeManager",
        "Use themeManager global object");

    AppController controller;
    ThemeManager theme;
    theme.applyTheme(&app);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);
    engine.rootContext()->setContextProperty("themeManager", &theme);

    const QUrl url(QStringLiteral("qrc:/qt/qml/EverFree/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { qCritical() << "Failed to load QML"; qApp->exit(-1); },
        Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
