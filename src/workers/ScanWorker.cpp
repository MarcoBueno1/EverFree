// SPDX-License-Identifier: MIT
/*
 * EverFree — ScanWorker with QPointer guard for thread safety.
 */

#include "ScanWorker.hpp"
#include <QPointer>
#include <stdexcept>

ScanWorker::ScanWorker(const QString& rootDir, bool recursive, uint32_t samplesPerDir, QObject* parent)
    : QThread(parent), m_rootDir(rootDir), m_recursive(recursive), m_samplesPerDir(samplesPerDir)
{}

void ScanWorker::run()
{
    QPointer<ScanWorker> selfGuard(this);

    try {
        batchpress::ScanConfig cfg;
        cfg.root_dir = m_rootDir.toStdString();
        cfg.recursive = m_recursive;
        cfg.samples_per_dir = m_samplesPerDir;
        cfg.num_threads = 0;

        cfg.on_progress = [this, selfGuard](const std::string& filename, uint32_t done, uint32_t total) {
            if (!selfGuard || m_cancelled.load()) return;
            emit progressUpdated(QString::fromStdString(filename), static_cast<int>(done),
                                 static_cast<int>(total));
        };

        if (m_cancelled.load()) { emit scanFailed("Scan cancelled"); return; }

        auto report = batchpress::scan_files(cfg);

        if (m_cancelled.load()) { emit scanFailed("Scan cancelled"); return; }

        emit scanComplete(std::move(report));
    } catch (const std::exception& e) {
        if (selfGuard) emit scanFailed(QString::fromLatin1(e.what()));
    } catch (...) {
        if (selfGuard) emit scanFailed("Unknown error during scan");
    }
}
