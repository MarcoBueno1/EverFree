// SPDX-License-Identifier: MIT
/*
 * EverFree — ScanWorker implementation.
 * FIX: Uses shared_ptr<atomic<bool>> for thread-safe cancellation.
 */

#include "ScanWorker.hpp"
#include <QPointer>
#include <stdexcept>

ScanWorker::ScanWorker(const QString& rootDir, bool recursive, uint32_t samplesPerDir, QObject* parent)
    : QThread(parent)
    , m_rootDir(rootDir)
    , m_recursive(recursive)
    , m_samplesPerDir(samplesPerDir)
    , m_cancelled(std::make_shared<std::atomic<bool>>(false))
{}

void ScanWorker::run()
{
    QPointer<ScanWorker> selfGuard(this);
    // FIX: Capture cancelled by shared_ptr copy (not by this pointer)
    auto cancelled = m_cancelled;

    try {
        batchpress::ScanConfig cfg;
        cfg.root_dir = m_rootDir.toStdString();
        cfg.recursive = m_recursive;
        cfg.samples_per_dir = m_samplesPerDir;
        cfg.num_threads = 0;

        cfg.on_progress = [selfGuard, cancelled](const std::string& filename, uint32_t done, uint32_t total) {
            if (!selfGuard || cancelled->load()) return;
            QMetaObject::invokeMethod(selfGuard, [selfGuard, filename, done, total]() {
                emit selfGuard->progressUpdated(
                    QString::fromStdString(filename),
                    static_cast<int>(done),
                    static_cast<int>(total));
            }, Qt::QueuedConnection);
        };

        if (cancelled->load()) { emit scanFailed("Scan cancelled"); return; }

        auto report = batchpress::scan_files(cfg);

        if (cancelled->load()) { emit scanFailed("Scan cancelled"); return; }

        emit scanComplete(std::move(report));
    } catch (const std::exception& e) {
        if (selfGuard) emit scanFailed(QString::fromLatin1(e.what()));
    } catch (...) {
        if (selfGuard) emit scanFailed("Unknown error during scan");
    }
}
