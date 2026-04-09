// SPDX-License-Identifier: MIT
/*
 * EverFree — VideoProcessWorker implementation.
 * FIX: Uses shared_ptr<atomic<bool>> for thread-safe cancellation.
 */

#include "VideoProcessWorker.hpp"
#include <QPointer>
#include <stdexcept>

VideoProcessWorker::VideoProcessWorker(const std::vector<batchpress::FileItem>& files,
                                        batchpress::VideoConfig config, QObject* parent)
    : QThread(parent)
    , m_files(files)
    , m_config(std::move(config))
    , m_cancelled(std::make_shared<std::atomic<bool>>(false))
{}

void VideoProcessWorker::run()
{
    QPointer<VideoProcessWorker> selfGuard(this);
    auto cancelled = m_cancelled;

    try {
        m_config.on_progress = [selfGuard, cancelled](const batchpress::fs::path& path,
                                                       uint64_t frameDone, uint64_t frameTotal,
                                                       uint32_t filesDone, uint32_t filesTotal) {
            if (!selfGuard || cancelled->load()) return;
            QString filename = QString::fromStdString(path.filename().string());
            QMetaObject::invokeMethod(selfGuard, [selfGuard, filename, frameDone, frameTotal, filesDone, filesTotal]() {
                emit selfGuard->progressUpdated(
                    filename,
                    static_cast<int>(frameDone),
                    static_cast<int>(frameTotal),
                    static_cast<int>(filesDone),
                    static_cast<int>(filesTotal));
            }, Qt::QueuedConnection);
        };

        if (cancelled->load()) { emit processFailed("Video processing cancelled"); return; }

        auto report = batchpress::process_video_files(m_files, m_config);

        if (cancelled->load()) { emit processFailed("Video processing cancelled"); return; }

        emit processComplete(std::move(report));
    } catch (const std::exception& e) {
        if (selfGuard) emit processFailed(QString::fromLatin1(e.what()));
    } catch (...) {
        if (selfGuard) emit processFailed("Unknown error during video processing");
    }
}
