// SPDX-License-Identifier: MIT
/*
 * EverFree — ProcessWorker with QPointer guard.
 */

#include "ProcessWorker.hpp"
#include <QPointer>
#include <stdexcept>

ProcessWorker::ProcessWorker(const std::vector<batchpress::FileItem>& files,
                              batchpress::Config config, QObject* parent)
    : QThread(parent), m_files(files), m_config(std::move(config))
{}

void ProcessWorker::run()
{
    QPointer<ProcessWorker> selfGuard(this);

    try {
        m_config.on_progress = [this, selfGuard](const batchpress::TaskResult& result,
                                                  uint64_t done, uint64_t total) {
            if (!selfGuard || m_cancelled.load()) return;
            QString filename = QString::fromStdString(result.input_path.filename().string());
            emit progressUpdated(filename, static_cast<int>(done), static_cast<int>(total),
                                 result.input_bytes, result.output_bytes);
        };

        if (m_cancelled.load()) { emit processFailed("Processing cancelled"); return; }

        auto report = batchpress::process_files(m_files, m_config);

        if (m_cancelled.load()) { emit processFailed("Processing cancelled"); return; }

        emit processComplete(std::move(report));
    } catch (const std::exception& e) {
        if (selfGuard) emit processFailed(QString::fromLatin1(e.what()));
    } catch (...) {
        if (selfGuard) emit processFailed("Unknown error during processing");
    }
}
