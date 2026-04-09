// SPDX-License-Identifier: MIT
/*
 * EverFree — Telemetry Manager Implementation
 */

#include "TelemetryManager.hpp"
#include "FeatureFlags.hpp"
#include <QRandomGenerator>
#include <QJsonArray>
#include <QJsonDocument>
#include <QDebug>
#include <QCoreApplication>

namespace EverFree {

TelemetryManager::TelemetryManager(QObject* parent)
    : QObject(parent)
{
    m_enabled = FeatureFlags::instance().isEnabled("telemetry_enabled");
    
    // Auto-flush every 30 seconds
    m_flushTimer.setInterval(30000);
    connect(&m_flushTimer, &QTimer::timeout, this, [this]() { flush(); });
    m_flushTimer.start();
}

void TelemetryManager::requestConsent()
{
    if (FeatureFlags::instance().isEnabled("telemetry_asked")) {
        return; // Already asked
    }

    // Note: In a real app, this would emit a signal to show a consent dialog
    // For now, we'll default to disabled until user explicitly enables
    qInfo() << "[Telemetry] User consent not yet requested. Will prompt on next settings open.";
}

void TelemetryManager::setEnabled(bool enabled)
{
    m_enabled = enabled;
    FeatureFlags::instance().setFeature("telemetry_enabled", enabled);
    FeatureFlags::instance().setFeature("telemetry_asked", true);
    emit enabledChanged(enabled);
    
    if (enabled) {
        qInfo() << "[Telemetry] Enabled - Anonymous usage metrics will be collected";
    } else {
        qInfo() << "[Telemetry] Disabled - No metrics will be collected";
    }
}

void TelemetryManager::recordScreenView(const QString& screenName)
{
    if (!m_enabled) return;
    
    QMutexLocker locker(&m_mutex);
    QJsonObject event;
    event["type"] = "screen_view";
    event["screen"] = screenName;
    event["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    event["session_id"] = m_settings.value("analytics/sessionId", "").toString();
    
    saveEvent(event);
}

void TelemetryManager::recordButtonClicked(const QString& buttonName, const QString& screen)
{
    if (!m_enabled) return;
    
    QMutexLocker locker(&m_mutex);
    QJsonObject event;
    event["type"] = "button_click";
    event["button"] = buttonName;
    event["screen"] = screen;
    event["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    saveEvent(event);
}

void TelemetryManager::recordTaskStarted(const QString& taskName)
{
    if (!m_enabled) return;
    
    m_activeTasks[taskName] = QDateTime::currentDateTime();
}

void TelemetryManager::recordTaskCompleted(const QString& taskName, int durationMs, bool success)
{
    if (!m_enabled) return;
    
    QMutexLocker locker(&m_mutex);
    QJsonObject event;
    event["type"] = "task_complete";
    event["task"] = taskName;
    event["duration_ms"] = durationMs;
    event["success"] = success;
    event["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    saveEvent(event);
    m_activeTasks.remove(taskName);
}

void TelemetryManager::recordError(const QString& errorType, const QString& context)
{
    if (!m_enabled) return;
    
    QMutexLocker locker(&m_mutex);
    QJsonObject event;
    event["type"] = "error";
    event["error_type"] = errorType;
    event["context"] = context;
    event["timestamp"] = QDateTime::currentDateTime().toString(Qt::ISODate);
    
    saveEvent(event);
}

void TelemetryManager::flush()
{
    // In a real implementation, this would send metrics to a server
    // For now, we just ensure they're saved locally
    m_settings.sync();
}

void TelemetryManager::saveEvent(const QJsonObject& event)
{
    // Store events in a local JSON array (max 1000 events, then rotate)
    QJsonArray events = m_settings.value("telemetry/events", QJsonArray()).toArray();
    
    if (events.size() >= 1000) {
        // Keep only last 500 events
        events = events.mid(500);
    }
    
    events.append(event);
    m_settings.setValue("telemetry/events", events);
}

QString TelemetryManager::generateEventId() const
{
    return QString("evt_%1").arg(QRandomGenerator::global()->generate(), 8, 16, QChar('0'));
}

} // namespace EverFree
