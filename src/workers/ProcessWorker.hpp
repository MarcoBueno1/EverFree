// SPDX-License-Identifier: MIT
/*
 * EverFree — ProcessWorker with thread-safe cancellation.
 * FIX: Uses shared_ptr<atomic<bool>> to prevent use-after-free in callbacks.
 */

#pragma once

#include <QThread>
#include <QString>
#include <batchpress/processor.hpp>
#include <batchpress/types.hpp>
#include <vector>
#include <atomic>
#include <memory>

class ProcessWorker : public QThread {
    Q_OBJECT

public:
    explicit ProcessWorker(const std::vector<batchpress::FileItem>& files,
                           batchpress::Config config, QObject* parent = nullptr);

    void cancel() noexcept { if (m_cancelled) m_cancelled->store(true); }

protected:
    void run() override;

signals:
    void progressUpdated(const QString& filename, int done, int total,
                         uint64_t inputBytes, uint64_t outputBytes);
    void processComplete(batchpress::BatchReport report);
    void processFailed(const QString& error);

private:
    std::vector<batchpress::FileItem> m_files;
    batchpress::Config m_config;
    // FIX: Shared ownership to prevent use-after-free
    std::shared_ptr<std::atomic<bool>> m_cancelled;
};
