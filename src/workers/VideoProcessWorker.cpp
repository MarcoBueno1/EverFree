// SPDX-License-Identifier: MIT
/*
 * EverFree — VideoProcessWorker with QPointer guard.
 */

#include "VideoProcessWorker.hpp"
#include <QPointer>
#include <stdexcept>

VideoProcessWorker::VideoProcessWorker(const std::vector<batchpress::FileItem>& files,
                                        batchpress::VideoConfig config, QObject* parent)
    : QThread(parent), m_files(files), m_config(std::move(config))
{}

void VideoProcessWorker::run()
{
    QPointer<VideoProcessWorker> selfGuard(this);

    try {
        m_config.on_progress = [this, selfGuard](const batchpress::fs::path& path,
                                                  uint64_t frameDone, uint64_t frameTotal,
                                                  uint32_t filesDone, uint32_t filesTotal) {
            if (!selfGuard || m_cancelled.load()) return;
            QString filename = QString::fromStdString(path.filename().string());
            emit progressUpdated(filename, static_cast<int>(frameDone), static_cast<int>(frameTotal),
                                 static_cast<int>(filesDone), static_cast<int>(filesTotal));
        };

        if (m_cancelled.load()) { emit processFailed("Video processing cancelled"); return; }

        auto report = batchpress::process_video_files(m_files, m_config);

        if (m_cancelled.load()) { emit processFailed("Video processing cancelled"); return; }

        emit processComplete(std::move(report));
    } catch (const std::exception& e) {
        if (selfGuard) emit processFailed(QString::fromLatin1(e.what()));
    } catch (...) {
        if (selfGuard) emit processFailed("Unknown error during video processing");
    }
}
