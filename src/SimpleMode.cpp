// SPDX-License-Identifier: MIT
/*
 * EverFree — SimpleMode
 */

#include "SimpleMode.hpp"
#include "utils/FileUtils.hpp"
#include <QDir>

namespace EverFree {

QStringList SimpleMode::getDefaultFolders()
{
    QStringList folders;
    QString home = QDir::homePath();
    // No duplicates
    QStringList folderNames = {
        "Pictures", "Videos", "Desktop", "Documents", "Downloads",
        "Imagens", "Vídeos", "Área de Trabalho", "Documentos", "Músicas", "Music"
    };
    for (const auto& name : folderNames) {
        QString path = QDir(home).filePath(name);
        if (QDir(path).exists()) folders.append(path);
    }
    if (folders.isEmpty()) folders.append(home);
    return folders;
}

batchpress::Config SimpleMode::getImageConfig()
{
    batchpress::Config cfg;
    cfg.format = batchpress::ImageFormat::WebP;
    cfg.quality = 85;
    cfg.resize = batchpress::parse_resize("fit:1920x1080");
    cfg.num_threads = 0;
    cfg.dedup_enabled = true;
    return cfg;
}

batchpress::VideoConfig SimpleMode::getVideoConfig()
{
    batchpress::VideoConfig cfg;
    cfg.video_codec = batchpress::VideoCodec::H265;
    cfg.crf = 28;
    cfg.resolution = batchpress::ResolutionCap::Cap1080p;
    cfg.audio_bitrate_kbps = -1;
    cfg.num_threads = 0;
    cfg.dedup_enabled = true;
    return cfg;
}

QString SimpleMode::getStatusMessage(int done, int total, double savingsPct)
{
    if (total == 0) return "Preparando...";
    int pct = total > 0 ? (done * 100 / total) : 0;
    return QString("%1% concluído — economia estimada: %2%").arg(pct).arg(savingsPct, 0, 'f', 0);
}

QString SimpleMode::getSummary(qint64 totalSaved, int filesProcessed)
{
    QString savedStr = batchpress::gui::formatBytes(totalSaved);
    return QString("✅ Concluído! %1 liberados em %2 arquivos").arg(savedStr).arg(filesProcessed);
}

} // namespace EverFree
