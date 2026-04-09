// SPDX-License-Identifier: MIT
/*
 * EverFree — ProcessWorker implementation.
 * FIX: Uses shared_ptr<atomic<bool>> for thread-safe cancellation.
 */

#include "ProcessWorker.hpp"
#include <QPointer>
#include <stdexcept>

ProcessWorker::ProcessWorker(const std::vector<batchpress::FileItem>& files,
                              batchpress::Config config, QObject* parent)
    : QThread(parent)
    , m_files(files)
    , m_config(std::move(config))
    , m_cancelled(std::make_shared<std::atomic<bool>>(false))
{}

void ProcessWorker::run()
{
    QPointer<ProcessWorker> selfGuard(this);
    auto cancelled = m_cancelled;

    try {
        m_config.on_progress = [selfGuard, cancelled](const batchpress::TaskResult& result,
                                                       uint64_t done, uint64_t total) {
            if (!selfGuard || cancelled->load()) return;
            QString filename = QString::fromStdString(result.input_path.filename().string());
            QMetaObject::invokeMethod(selfGuard, [selfGuard, filename, done, total, result]() {
                emit selfGuard->progressUpdated(
                    filename,
                    static_cast<int>(done),
                    static_cast<int>(total),
                    result.input_bytes,
                    result.output_bytes);
            }, Qt::QueuedConnection);
        };

        if (cancelled->load()) { emit processFailed("Processing cancelled"); return; }

        auto report = batchpress::process_files(m_files, m_config);

        if (cancelled->load()) { emit processFailed("Processing cancelled"); return; }

        emit processComplete(std::move(report));
    } catch (const std::exception& e) {
        if (selfGuard) emit processFailed(QString::fromLatin1(e.what()));
    } catch (...) {
        if (selfGuard) emit processFailed("Unknown error during processing");
    }
}
