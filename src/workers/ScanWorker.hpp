// SPDX-License-Identifier: MIT
/*
 * EverFree — ScanWorker with thread-safe cancellation.
 * FIX: Uses shared_ptr<atomic<bool>> to prevent use-after-free in callbacks.
 */

#pragma once

#include <QThread>
#include <QString>
#include <atomic>
#include <memory>

#include <batchpress/scanner.hpp>

class ScanWorker : public QThread {
    Q_OBJECT

public:
    explicit ScanWorker(const QString& rootDir, bool recursive, uint32_t samplesPerDir, QObject* parent = nullptr);

    void cancel() { m_cancelled->store(true); }

signals:
    void progressUpdated(const QString& file, int done, int total);
    void scanComplete(batchpress::FileScanReport report);
    void scanFailed(const QString& error);

protected:
    void run() override;

private:
    QString m_rootDir;
    bool m_recursive;
    uint32_t m_samplesPerDir;
    // FIX: Shared ownership of cancel flag to prevent use-after-free
    std::shared_ptr<std::atomic<bool>> m_cancelled;
};
