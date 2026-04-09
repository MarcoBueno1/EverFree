// SPDX-License-Identifier: MIT
/*
 * EverFree — VideoProcessWorker with thread-safe cancellation.
 * FIX: Uses shared_ptr<atomic<bool>> to prevent use-after-free in callbacks.
 */

#pragma once

#include <QThread>
#include <QString>
#include <batchpress/video_processor.hpp>
#include <batchpress/types.hpp>
#include <vector>
#include <atomic>
#include <memory>

class VideoProcessWorker : public QThread {
    Q_OBJECT

public:
    explicit VideoProcessWorker(const std::vector<batchpress::FileItem>& files,
                                 batchpress::VideoConfig config, QObject* parent = nullptr);

    void cancel() noexcept { if (m_cancelled) m_cancelled->store(true); }

protected:
    void run() override;

signals:
    void progressUpdated(const QString& filename, int frameDone, int frameTotal,
                         int filesDone, int filesTotal);
    void processComplete(batchpress::VideoBatchReport report);
    void processFailed(const QString& error);

private:
    std::vector<batchpress::FileItem> m_files;
    batchpress::VideoConfig m_config;
    // FIX: Shared ownership to prevent use-after-free
    std::shared_ptr<std::atomic<bool>> m_cancelled;
};
