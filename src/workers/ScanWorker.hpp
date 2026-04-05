// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI scan worker.
 */

#pragma once

#include <QThread>
#include <QString>
#include <batchpress/scanner.hpp>
#include <batchpress/types.hpp>
#include <atomic>

/**
 * @brief Runs scan_files() on a background QThread.
 *
 * Emits signals thread-safely via Qt::QueuedConnection.
 * Supports cooperative cancellation.
 */
class ScanWorker : public QThread {
    Q_OBJECT

public:
    explicit ScanWorker(const QString& rootDir, bool recursive = true,
                        uint32_t samplesPerDir = 5, QObject* parent = nullptr);

    void cancel() noexcept { m_cancelled = true; }

protected:
    void run() override;

signals:
    void progressUpdated(const QString& filename, int done, int total);
    void scanComplete(batchpress::FileScanReport report);
    void scanFailed(const QString& error);

private:
    QString m_rootDir;
    bool m_recursive;
    uint32_t m_samplesPerDir;
    std::atomic<bool> m_cancelled{false};
};
