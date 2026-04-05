// SPDX-License-Identifier: MIT
/*
 * EverFree — AdvancedMode implementation
 * Full control for power users
 */

#include "AdvancedMode.hpp"
#include <QCoreApplication>

namespace EverFree {

// ── Convert to batchpress configs ────────────────────────────────────────────

batchpress::Config AdvancedMode::Config::toBatchConfig() const
{
    batchpress::Config cfg;

    // Format
    if (imageFormat == "jpg") cfg.format = batchpress::ImageFormat::JPEG;
    else if (imageFormat == "png") cfg.format = batchpress::ImageFormat::PNG;
    else if (imageFormat == "webp") cfg.format = batchpress::ImageFormat::WebP;
    else if (imageFormat == "bmp") cfg.format = batchpress::ImageFormat::BMP;
    else cfg.format = batchpress::ImageFormat::Same;

    cfg.quality = imageQuality;

    // Resize
    if (!resizeSpec.isEmpty()) {
        cfg.resize = batchpress::parse_resize(resizeSpec.toStdString());
    }

    cfg.num_threads = threads;
    cfg.dedup_enabled = dedup;
    cfg.hash_cache = hash_cache;

    return cfg;
}

batchpress::VideoConfig AdvancedMode::Config::toVideoConfig() const
{
    batchpress::VideoConfig cfg;

    // Video codec
    if (vcodec == "h265") cfg.video_codec = batchpress::VideoCodec::H265;
    else if (vcodec == "h264") cfg.video_codec = batchpress::VideoCodec::H264;
    else if (vcodec == "vp9") cfg.video_codec = batchpress::VideoCodec::VP9;
    else cfg.video_codec = batchpress::VideoCodec::Auto;

    // CRF
    if (crf >= 0) cfg.crf = crf;

    // Resolution
    if (maxRes == "4k") cfg.resolution = batchpress::ResolutionCap::Cap4K;
    else if (maxRes == "1080p") cfg.resolution = batchpress::ResolutionCap::Cap1080p;
    else cfg.resolution = batchpress::ResolutionCap::Original;

    cfg.audio_bitrate_kbps = -1;  // auto
    cfg.num_threads = threads;
    cfg.dedup_enabled = dedup;

    return cfg;
}

// ── Available Options ────────────────────────────────────────────────────────

QStringList AdvancedMode::availableCodecs()
{
    return {"auto", "h265", "h264", "vp9"};
}

int AdvancedMode::defaultCrfForCodec(const QString& codec)
{
    if (codec == "h265") return 28;
    if (codec == "h264") return 26;
    if (codec == "vp9") return 33;
    return -1; // auto
}

QStringList AdvancedMode::availableResolutions()
{
    return {"original", "4k", "1080p", "720p", "480p"};
}

QStringList AdvancedMode::availableImageFormats()
{
    return {"same", "webp", "jpg", "png", "bmp"};
}

// ── Validation ────────────────────────────────────────────────────────────────

QStringList AdvancedMode::validate(const Config& cfg)
{
    QStringList warnings;

    if (cfg.imageQuality < 1 || cfg.imageQuality > 100) {
        warnings.append("Qualidade da imagem deve ser entre 1 e 100");
    }

    // FIX I-02: Simplified CRF validation (cfg.crf < -1 covers the redundant check)
    if (cfg.crf < -1 || cfg.crf > 51) {
        warnings.append("CRF deve ser entre 0 e 51 (ou -1 para automático)");
    }

    if (cfg.threads < 0) {
        warnings.append("Número de threads não pode ser negativo");
    }

    if (cfg.vcodec != "auto" && cfg.vcodec != "h265" &&
        cfg.vcodec != "h264" && cfg.vcodec != "vp9") {
        warnings.append("Codec de vídeo desconhecido: " + cfg.vcodec);
    }

    return warnings;
}

} // namespace EverFree
