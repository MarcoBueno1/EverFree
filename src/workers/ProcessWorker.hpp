// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI process worker.
 */

#pragma once

#include <QThread>
#include <QString>
#include <batchpress/processor.hpp>
#include <batchpress/types.hpp>
#include <vector>
#include <atomic>

/**
 * @brief Runs process_files() on a background QThread for images.
 *
 * Emits signals thread-safely via Qt::QueuedConnection.
 * Supports cooperative cancellation.
 */
class ProcessWorker : public QThread {
    Q_OBJECT

public:
    explicit ProcessWorker(const std::vector<batchpress::FileItem>& files,
                           batchpress::Config config, QObject* parent = nullptr);

    void cancel() noexcept { m_cancelled = true; }

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
    std::atomic<bool> m_cancelled{false};
};
