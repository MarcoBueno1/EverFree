// SPDX-License-Identifier: MIT
/*
 * EverFree — AdvancedMode
 * Full control for power users: codecs, CRF, resize, threads, etc.
 */

#pragma once

#include <QString>
#include <batchpress/types.hpp>
#include <batchpress/processor.hpp>
#include <batchpress/video_processor.hpp>

namespace EverFree {

/**
 * @brief Manages advanced mode configuration.
 *
 * Provides full control over encoding parameters,
 * folder selection, and processing options.
 */
class AdvancedMode {
public:
    struct Config {
        // Image settings
        QString imageFormat = "same";   // jpg, png, webp, bmp, same
        int imageQuality = 90;           // 1-100
        QString resizeSpec = "";         // e.g. "1920x1080", "50%", "fit:1280x720", ""

        // Video settings
        QString vcodec = "auto";         // h265, h264, vp9, auto
        int crf = -1;                    // -1 = auto, lower = better quality
        QString maxRes = "1080p";        // 1080p, 4k, original

        // General
        int threads = 0;                 // 0 = auto (use all cores)
        bool recursive = true;
        bool dedup = true;
        QString outputDir = "";          // "" = in-place

        // FIX W-15: Hash cache for duplicate detection (set by AppController)
        std::shared_ptr<batchpress::HashCache> hash_cache;

        /**
         * @brief Build batchpress::Config from these settings.
         */
        batchpress::Config toBatchConfig() const;

        /**
         * @brief Build batchpress::VideoConfig from these settings.
         */
        batchpress::VideoConfig toVideoConfig() const;
    };

    /**
     * @brief Get list of available video codecs.
     */
    static QStringList availableCodecs();

    /**
     * @brief Get default CRF for a given codec.
     */
    static int defaultCrfForCodec(const QString& codec);

    /**
     * @brief Get available max resolution options.
     */
    static QStringList availableResolutions();

    /**
     * @brief Get available image format options.
     */
    static QStringList availableImageFormats();

    /**
     * @brief Validate and normalize configuration.
     * @returns List of warnings (empty = all good)
     */
    static QStringList validate(const Config& cfg);
};

} // namespace EverFree
