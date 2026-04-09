// SPDX-License-Identifier: MIT
/*
 * EverFree — UX Telemetry System
 * Anonymous usage metrics with explicit user consent
 */

#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QJsonObject>
#include <QSettings>
#include <QTimer>
#include <QMutex>

namespace EverFree {

/**
 * Telemetry Manager
 * 
 * Collects anonymous UX metrics to improve the product.
 * ALWAYS requires explicit user consent.
 * NEVER collects personal data, file contents, or identifiable info.
 * 
 * Metrics collected:
 * - Time to complete tasks (scan, compress, etc.)
 * - Feature usage frequency (which buttons are clicked)
 * - Error rates (what fails and how often)
 * - Session duration
 * - Screen navigation flow
 */
class TelemetryManager : public QObject {
    Q_OBJECT

public:
    explicit TelemetryManager(QObject* parent = nullptr);

    // Check if telemetry is enabled
    bool isEnabled() const { return m_enabled; }

    // Ask user for consent (shows dialog if not asked before)
    void requestConsent();

    // Enable/disable telemetry
    void setEnabled(bool enabled);

    // Record events (only if enabled)
    void recordScreenView(const QString& screenName);
    void recordButtonClicked(const QString& buttonName, const QString& screen = "");
    void recordTaskStarted(const QString& taskName);
    void recordTaskCompleted(const QString& taskName, int durationMs, bool success);
    void recordError(const QString& errorType, const QString& context = "");

    // Flush pending metrics to storage
    void flush();

signals:
    void enabledChanged(bool enabled);

private:
    void saveEvent(const QJsonObject& event);
    QString generateEventId() const;

    bool m_enabled = false;
    mutable QMutex m_mutex;
    QSettings m_settings;
    QTimer m_flushTimer;
    
    // Track current task timing
    QHash<QString, QDateTime> m_activeTasks;
};

} // namespace EverFree
