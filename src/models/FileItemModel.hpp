// SPDX-License-Identifier: MIT
/*
 * Copyright (C) 2018 Marco Antônio Bueno da Silva <bueno.marco@gmail.com>
 *
 * This file is part of batchpress — Qt6 Desktop GUI file item model.
 */

#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <batchpress/types.hpp>
#include <memory>

/**
 * @brief QAbstractListModel wrapping std::vector<FileItem> for QML.
 *
 * Roles exposed to QML:
 *   filePath, fileName, width, height, projectedSize, savingsPct,
 *   qualityStars, suggestedCodec, isSelected, isImage, fileSize,
 *   projectedWidth, projectedHeight, durationSec, format, isVideo
 */
class FileItemModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum Roles {
        FilePathRole = Qt::UserRole + 1,
        FileNameRole,
        WidthRole,
        HeightRole,
        FileSizeRole,
        ProjectedSizeRole,
        SavingsPctRole,
        QualityStarsRole,
        SuggestedCodecRole,
        IsSelectedRole,
        IsImageRole,
        IsVideoRole,
        ProjectedWidthRole,
        ProjectedHeightRole,
        DurationSecRole,
        FormatRole,
        VideoCodecRole,
        AudioCodecRole,
    };

    explicit FileItemModel(QObject* parent = nullptr);

    // DisplayItem is public so sortBy can use it
    struct DisplayItem {
        batchpress::FileItem file;
        bool selected = true;
        int sourceIndex = 0;
    };

    void loadFiles(const std::vector<batchpress::FileItem>& files);
    std::vector<batchpress::FileItem> selectedFiles() const;
    void clear();
    int filteredCount() const { return static_cast<int>(m_filteredItems.size()); }

    // QAbstractListModel
    int rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override;

    /**
     * @brief Apply text filter and/or min savings filter.
     * @param filter Lowercase text to match against filename
     * @param minSavings Minimum savings percentage (0-100)
     * @param typeFilter "image", "video", or "all"
     */
    Q_INVOKABLE void applyFilter(const QString& filter, double minSavings, const QString& typeFilter);

    /**
     * @brief Select or deselect all visible (filtered) items.
     */
    Q_INVOKABLE void selectAll(bool selected);

    /**
     * @brief Invert selection of visible items.
     */
    Q_INVOKABLE void invertSelection();

    /**
     * @brief Sort by a given role index. Ascending or descending.
     */
    Q_INVOKABLE void sortBy(int role, bool ascending);

    Q_INVOKABLE int selectedCount() const;
    Q_INVOKABLE uint64_t selectedTotalSize() const;
    Q_INVOKABLE uint64_t selectedProjectedSize() const;

signals:
    void selectedCountChanged();

private:
    std::vector<batchpress::FileItem> m_sourceFiles;
    QVector<DisplayItem> m_filteredItems;
    QString m_filterText;
    double m_minSavings = 0.0;
    QString m_typeFilter = "all";

    void rebuildFilter();
};
