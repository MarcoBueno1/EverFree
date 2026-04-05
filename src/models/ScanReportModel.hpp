// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI scan report model.
 */

#pragma once

#include <QObject>
#include <batchpress/types.hpp>
#include <batchpress/scanner.hpp>

/**
 * @brief Exposes aggregated scan report data to QML.
 *
 * Properties:
 *   totalFiles, imageCount, videoCount, totalSize, totalProjectedSize,
 *   totalSavings, savingsPct, scanElapsedSec
 */
class ScanReportModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(int totalFiles READ totalFiles NOTIFY reportChanged FINAL)
    Q_PROPERTY(int imageCount READ imageCount NOTIFY reportChanged FINAL)
    Q_PROPERTY(int videoCount READ videoCount NOTIFY reportChanged FINAL)
    Q_PROPERTY(qint64 totalSize READ totalSize NOTIFY reportChanged FINAL)
    Q_PROPERTY(qint64 totalProjectedSize READ totalProjectedSize NOTIFY reportChanged FINAL)
    Q_PROPERTY(qint64 totalSavings READ totalSavings NOTIFY reportChanged FINAL)
    Q_PROPERTY(double savingsPct READ savingsPct NOTIFY reportChanged FINAL)
    Q_PROPERTY(double scanElapsedSec READ scanElapsedSec NOTIFY reportChanged FINAL)
    Q_PROPERTY(bool valid READ isValid NOTIFY reportChanged FINAL)

public:
    explicit ScanReportModel(QObject* parent = nullptr);

    void loadReport(const batchpress::FileScanReport& report);
    void clear();

    int totalFiles() const noexcept { return m_valid ? m_report.files.size() : 0; }
    int imageCount() const noexcept { return m_valid ? m_report.image_count() : 0; }
    int videoCount() const noexcept { return m_valid ? m_report.video_count() : 0; }
    qint64 totalSize() const noexcept { return m_valid ? static_cast<qint64>(m_report.total_size()) : 0; }
    qint64 totalProjectedSize() const noexcept { return m_valid ? static_cast<qint64>(m_report.total_projected_size()) : 0; }
    qint64 totalSavings() const noexcept { return m_valid ? static_cast<qint64>(m_report.total_savings()) : 0; }
    double savingsPct() const noexcept { return m_valid ? m_report.overall_savings_pct() : 0.0; }
    double scanElapsedSec() const noexcept { return m_valid ? m_report.elapsed_sec : 0.0; }
    bool isValid() const noexcept { return m_valid; }

signals:
    void reportChanged();

private:
    batchpress::FileScanReport m_report;
    bool m_valid = false;
};
