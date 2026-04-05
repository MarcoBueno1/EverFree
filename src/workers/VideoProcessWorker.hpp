// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI video process worker.
 */

#pragma once

#include <QThread>
#include <QString>
#include <batchpress/video_processor.hpp>
#include <batchpress/types.hpp>
#include <vector>
#include <atomic>

/**
 * @brief Runs process_video_files() on a background QThread.
 *
 * Emits signals thread-safely via Qt::QueuedConnection.
 * Supports cooperative cancellation.
 */
class VideoProcessWorker : public QThread {
    Q_OBJECT

public:
    explicit VideoProcessWorker(const std::vector<batchpress::FileItem>& files,
                                 batchpress::VideoConfig config, QObject* parent = nullptr);

    void cancel() noexcept { m_cancelled = true; }

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
    std::atomic<bool> m_cancelled{false};
};
