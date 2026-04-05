// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI utility helpers.
 */

#pragma once

#include <QString>
#include <QLocale>
#include <cstdint>

namespace batchpress::gui {

/**
 * @brief Human-readable file size string.
 * e.g. "2.4 MB", "156 KB", "1.8 GB"
 */
inline QString formatBytes(uint64_t bytes) noexcept
{
    static const char* units[] = {"B", "KB", "MB", "GB", "TB"};
    double size = static_cast<double>(bytes);
    int unit = 0;
    while (size >= 1024.0 && unit < 4) {
        size /= 1024.0;
        ++unit;
    }
    return QLocale().toString(size, 'f', unit == 0 ? 0 : 1) + " " + units[unit];
}

/**
 * @brief Human-readable duration string.
 * e.g. "2h 15m", "45s", "3m 12s"
 */
inline QString formatDuration(double seconds) noexcept
{
    auto secs = static_cast<int64_t>(seconds);
    if (secs < 60) return QString::number(secs) + "s";
    if (secs < 3600) return QString("%1m %2s").arg(secs / 60).arg(secs % 60);
    int64_t h = secs / 3600;
    int64_t m = (secs % 3600) / 60;
    return QString("%1h %2m").arg(h).arg(m);
}

/**
 * @brief Estimate ETA given progress and elapsed time.
 * @param done Items completed
 * @param total Total items
 * @param elapsedSec Elapsed time in seconds
 * @return Formatted ETA string, or "—" if cannot compute
 */
inline QString formatETA(int done, int total, double elapsedSec) noexcept
{
    if (done == 0 || done >= total || elapsedSec <= 0.0) return "—";
    double rate = static_cast<double>(done) / elapsedSec;
    double remaining = static_cast<double>(total - done) / rate;
    return formatDuration(remaining);
}

/**
 * @brief Throughput string (files/sec).
 */
inline QString formatThroughput(int done, double elapsedSec) noexcept
{
    if (elapsedSec <= 0.0) return "0/s";
    double rate = static_cast<double>(done) / elapsedSec;
    return QLocale().toString(rate, 'f', 1) + "/s";
}

} // namespace batchpress::gui
