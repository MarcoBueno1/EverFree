// SPDX-License-Identifier: MIT
/*
 * EverFree — SimpleMode
 * Automatic configuration for non-technical users.
 * Zero decisions: scan → compress → done.
 */

#pragma once

#include <QString>
#include <QStringList>
#include <batchpress/types.hpp>
#include <batchpress/processor.hpp>
#include <batchpress/video_processor.hpp>

namespace EverFree {

/**
 * @brief Generates optimal auto-settings for simple mode.
 *
 * Non-technical users don't need to choose codecs or quality.
 * This class provides sensible defaults that "just work".
 */
class SimpleMode {
public:
    /**
     * @brief Get default folders to scan for the current platform.
     *
     * Windows: C:\Users\<user>\Pictures, Videos, Desktop, Documents
     * Linux:   /home/<user>/Pictures, Videos, Desktop, Documents
     * macOS:   /Users/<user>/Pictures, Movies, Desktop, Documents
     */
    static QStringList getDefaultFolders();

    /**
     * @brief Get optimal image config for simple mode.
     *
     * Uses WebP q85 with fit:1920x1080 resize.
     * Great balance of quality vs size.
     */
    static batchpress::Config getImageConfig();

    /**
     * @brief Get optimal video config for simple mode.
     *
     * Uses H.265 CRF 28, 1080p max, auto audio.
     */
    static batchpress::VideoConfig getVideoConfig();

    /**
     * @brief Get friendly status message for simple mode.
     */
    static QString getStatusMessage(int done, int total, double savingsPct);

    /**
     * @brief Get friendly summary after processing.
     */
    static QString getSummary(qint64 totalSaved, int filesProcessed);
};

} // namespace EverFree
