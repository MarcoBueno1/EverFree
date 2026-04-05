// SPDX-License-Identifier: MIT
/*
 * EverFree — ProgressModel
 * Tracks real-time progress for scan/process operations.
 *
 * FIX W-01: Use quint64 for byte counters (avoids negative for >8TB files).
 * FIX W-02: Reset timer on finish().
 * FIX W-05: Accumulate bytes across updateBytes() calls.
 * FIX W-13: Cap percent at 100%.
 */

#include "ProgressModel.hpp"
#include <algorithm>
#include <limits>

ProgressModel::ProgressModel(QObject* parent)
    : QObject(parent)
{}

void ProgressModel::start(int totalItems)
{
    m_done = 0;
    m_total = totalItems;
    m_currentFile.clear();
    m_inputBytes = 0;
    m_outputBytes = 0;
    m_active = true;
    m_timer.restart();
    emit activeChanged();
    emit progressUpdated();
    emit bytesUpdated();
}

void ProgressModel::update(const QString& file, int done, int total)
{
    m_done = done;
    m_total = total;
    m_currentFile = file;
    emit progressUpdated();
}

void ProgressModel::updateBytes(quint64 inputBytes, quint64 outputBytes)
{
    // FIX W-05: Accumulate bytes across calls instead of replacing
    m_inputBytes += inputBytes;
    m_outputBytes += outputBytes;
    emit bytesUpdated();
}

void ProgressModel::finish()
{
    m_active = false;
    // FIX W-02: Reset/invalidate timer so eta/throughput return "—"
    m_timer.invalidate();
    emit activeChanged();
    emit progressUpdated();
}

QString ProgressModel::eta() const noexcept
{
    // FIX W-02: Return "—" if timer is invalid (operation finished)
    if (!m_timer.isValid()) return "—";
    return batchpress::gui::formatETA(m_done, m_total, m_timer.elapsed() / 1000.0);
}

QString ProgressModel::throughput() const noexcept
{
    if (!m_timer.isValid() || m_timer.elapsed() <= 0) return "0/s";
    return batchpress::gui::formatThroughput(m_done, m_timer.elapsed() / 1000.0);
}

quint64 ProgressModel::inputBytes() const noexcept { return m_inputBytes; }
quint64 ProgressModel::outputBytes() const noexcept { return m_outputBytes; }

double ProgressModel::percent() const noexcept
{
    // FIX W-13: Cap at 100% to prevent display > 100%
    if (m_total <= 0) return 0.0;
    return std::min(100.0, 100.0 * m_done / m_total);
}
