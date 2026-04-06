// SPDX-License-Identifier: MIT
/*
 * EverFree — main.cpp
 * FIX W-14: qputenv BEFORE QGuiApplication.
 * FIX C-09: qmlRegisterUncreatableType to prevent duplicate instances.
 * FIX W-15: Use QApplication for better window management on Wayland.
 */

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QDir>
#include <QDebug>
#include <QTimer>
#include <QQuickWindow>

#include "AppController.hpp"
#include "utils/ThemeManager.hpp"

int main(int argc, char* argv[])
{
    // FIX W-14: MUST be before QApplication construction
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    
    // FIX W-16: Force X11/XCB platform for reliable window management on Wayland
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM")) {
        qputenv("QT_QPA_PLATFORM", "xcb");
    }

    QApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QApplication app(argc, argv);
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
    
    qDebug() << "[EverFree] Loading QML from:" << url;
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [](QObject *obj, const QUrl &url) {
            if (obj == nullptr) {
                qCritical() << "[EverFree] Failed to load QML:" << url;
                qApp->exit(-1);
            } else {
                qDebug() << "[EverFree] QML loaded successfully:" << url;
            }
        }, Qt::QueuedConnection);
    
    QObject::connect(&app, &QApplication::lastWindowClosed,
        &app, []() { qDebug() << "[EverFree] Last window closed, exiting..."; });
    QObject::connect(&app, &QApplication::aboutToQuit,
        &app, []() { qDebug() << "[EverFree] Application about to quit..."; });

    engine.load(url);
    
    // FIX W-17: Force QQuickWindow to appear after QML is loaded
    QTimer::singleShot(500, [&app]() {
        QQuickWindow *window = qobject_cast<QQuickWindow*>(qApp->topLevelWindows().first());
        if (window) {
            qDebug() << "[EverFree] Found QQuickWindow, raising...";
            window->raise();
            window->requestActivate();
            window->show();
        } else {
            qDebug() << "[EverFree] No QQuickWindow found at 500ms";
            qDebug() << "[EverFree] Top level widgets:" << qApp->topLevelWidgets();
        }
    });
    
    int result = app.exec();
    qDebug() << "[EverFree] Application exited with code:" << result;
    return result;
}
