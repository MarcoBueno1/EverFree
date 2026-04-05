// SPDX-License-Identifier: MIT
/*
 * EverFree — ProgressModel header
 *
 * FIX W-01: quint64 for byte counters.
 * FIX W-02: isValid() check on timer.
 */

#pragma once

#include <QObject>
#include <QElapsedTimer>
#include <utils/FileUtils.hpp>
#include <cstdint>

/**
 * @brief Tracks real-time progress for scan/process operations.
 *
 * Exposed to QML with properties for binding to UI elements.
 */
class ProgressModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(int done READ done NOTIFY progressUpdated FINAL)
    Q_PROPERTY(int total READ total NOTIFY progressUpdated FINAL)
    Q_PROPERTY(double percent READ percent NOTIFY progressUpdated FINAL)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY progressUpdated FINAL)
    Q_PROPERTY(QString eta READ eta NOTIFY progressUpdated FINAL)
    Q_PROPERTY(QString throughput READ throughput NOTIFY progressUpdated FINAL)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
    // FIX W-01: quint64 for byte counters (safe up to 16 EB)
    Q_PROPERTY(quint64 inputBytes READ inputBytes NOTIFY bytesUpdated FINAL)
    Q_PROPERTY(quint64 outputBytes READ outputBytes NOTIFY bytesUpdated FINAL)

public:
    explicit ProgressModel(QObject* parent = nullptr);

    void start(int totalItems);
    void update(const QString& file, int done, int total);
    // FIX W-05: Accumulates bytes across calls
    void updateBytes(quint64 inputBytes, quint64 outputBytes);
    void finish();

    int done() const noexcept { return m_done; }
    int total() const noexcept { return m_total; }
    double percent() const noexcept;
    const QString& currentFile() const noexcept { return m_currentFile; }
    QString eta() const noexcept;
    QString throughput() const noexcept;
    bool active() const noexcept { return m_active; }
    quint64 inputBytes() const noexcept;
    quint64 outputBytes() const noexcept;

signals:
    void progressUpdated();
    void bytesUpdated();
    void activeChanged();

private:
    int m_done = 0;
    int m_total = 0;
    QString m_currentFile;
    bool m_active = false;
    QElapsedTimer m_timer;
    // FIX W-01: quint64 for large files
    quint64 m_inputBytes = 0;
    quint64 m_outputBytes = 0;
};
