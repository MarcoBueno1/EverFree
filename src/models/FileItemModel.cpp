// SPDX-License-Identifier: MIT
/*
 * EverFree — FileItemModel implementation
 *
 * FIX: Sort is O(n log n) — pre-computes sort keys once, then sorts.
 * No repeated data() calls inside the comparator.
 */

#include "FileItemModel.hpp"
#include <algorithm>
#include <numeric>
#include <QFileInfo>
#include <optional>

FileItemModel::FileItemModel(QObject* parent)
    : QAbstractListModel(parent)
{}

void FileItemModel::loadFiles(const std::vector<batchpress::FileItem>& files)
{
    beginResetModel();
    m_sourceFiles = files;
    m_filteredItems.clear();
    rebuildFilter();
    endResetModel();
    emit selectedCountChanged();
}

std::vector<batchpress::FileItem> FileItemModel::selectedFiles() const
{
    std::vector<batchpress::FileItem> result;
    result.reserve(m_filteredItems.size());
    for (const auto& item : m_filteredItems) {
        if (item.selected) result.push_back(item.file);
    }
    return result;
}

void FileItemModel::clear()
{
    beginResetModel();
    m_sourceFiles.clear();
    m_filteredItems.clear();
    endResetModel();
    emit selectedCountChanged();
}

int FileItemModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid()) return 0;
    return filteredCount();
}

QVariant FileItemModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || index.row() >= filteredCount()) return {};

    const auto& item = m_filteredItems[index.row()];
    const auto& f = item.file;
    bool isImg = (f.type == batchpress::FileItem::Type::Image);

    switch (role) {
        case FilePathRole: return QString::fromStdString(f.path.string());
        case FileNameRole: return QString::fromStdString(f.filename);
        case WidthRole: return static_cast<int>(f.width);
        case HeightRole: return static_cast<int>(f.height);
        case FileSizeRole: return static_cast<qint64>(f.file_size);
        case ProjectedSizeRole: return static_cast<qint64>(f.projected_size);
        case SavingsPctRole: return f.savings_pct;
        case QualityStarsRole:
            return std::visit([](const auto& m) { return batchpress::quality_stars(m.quality); }, f.meta);
        case SuggestedCodecRole:
            return std::visit([](const auto& m) { return QString::fromStdString(m.suggested_codec); }, f.meta);
        case IsSelectedRole: return item.selected;
        case IsImageRole: return isImg;
        case IsVideoRole: return !isImg;
        case ProjectedWidthRole:
            return std::visit([](const auto& m) { return static_cast<int>(m.projected_width); }, f.meta);
        case ProjectedHeightRole:
            return std::visit([](const auto& m) { return static_cast<int>(m.projected_height); }, f.meta);
        case DurationSecRole: {
            if (isImg) return 0.0;
            if (auto* vi = std::get_if<batchpress::VideoFileInfo>(&f.meta)) return vi->duration_sec;
            return 0.0;
        }
        case FormatRole: {
            if (isImg) {
                if (auto* ii = std::get_if<batchpress::ImageFileInfo>(&f.meta))
                    return QString::fromStdString(ii->format);
                return QString{};
            }
            if (auto* vi = std::get_if<batchpress::VideoFileInfo>(&f.meta))
                return QString::fromStdString(vi->container);
            return QString{};
        }
        case VideoCodecRole: {
            if (isImg) return QString{};
            if (auto* vi = std::get_if<batchpress::VideoFileInfo>(&f.meta))
                return QString::fromStdString(vi->video_codec);
            return QString{};
        }
        case AudioCodecRole: {
            if (isImg) return QString{};
            if (auto* vi = std::get_if<batchpress::VideoFileInfo>(&f.meta))
                return QString::fromStdString(vi->audio_codec);
            return QString{};
        }
        default: return {};
    }
}

QHash<int, QByteArray> FileItemModel::roleNames() const
{
    return {
        {FilePathRole, "filePath"}, {FileNameRole, "fileName"},
        {WidthRole, "width"}, {HeightRole, "height"},
        {FileSizeRole, "fileSize"}, {ProjectedSizeRole, "projectedSize"},
        {SavingsPctRole, "savingsPct"}, {QualityStarsRole, "qualityStars"},
        {SuggestedCodecRole, "suggestedCodec"}, {IsSelectedRole, "isSelected"},
        {IsImageRole, "isImage"}, {IsVideoRole, "isVideo"},
        {ProjectedWidthRole, "projectedWidth"}, {ProjectedHeightRole, "projectedHeight"},
        {DurationSecRole, "durationSec"}, {FormatRole, "format"},
        {VideoCodecRole, "videoCodec"}, {AudioCodecRole, "audioCodec"},
    };
}

bool FileItemModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (!index.isValid() || index.row() >= filteredCount()) return false;
    if (role == IsSelectedRole) {
        m_filteredItems[index.row()].selected = value.toBool();
        emit dataChanged(index, index, {IsSelectedRole});
        emit selectedCountChanged();
        return true;
    }
    return false;
}

void FileItemModel::applyFilter(const QString& filter, double minSavings, const QString& typeFilter)
{
    m_filterText = filter.toLower();
    m_minSavings = minSavings;
    m_typeFilter = typeFilter;
    rebuildFilter();
}

void FileItemModel::selectAll(bool selected)
{
    bool changed = false;
    for (auto& item : m_filteredItems) {
        if (item.selected != selected) { item.selected = selected; changed = true; }
    }
    if (changed) {
        emit dataChanged(index(0, 0), index(filteredCount() - 1, 0), {IsSelectedRole});
        emit selectedCountChanged();
    }
}

void FileItemModel::invertSelection()
{
    for (auto& item : m_filteredItems) item.selected = !item.selected;
    emit dataChanged(index(0, 0), index(filteredCount() - 1, 0), {IsSelectedRole});
    emit selectedCountChanged();
}

void FileItemModel::sortBy(int role, bool ascending)
{
    beginResetModel();

    // Pre-compute sort keys using data() — O(n) calls total
    std::vector<QVariant> keys;
    keys.reserve(m_filteredItems.size());
    for (int i = 0; i < filteredCount(); i++) {
        keys.push_back(data(index(i, 0), role));
    }

    // Sort indices by pre-computed keys — O(n log n) comparisons, zero data() calls
    std::vector<int> indices(m_filteredItems.size());
    std::iota(indices.begin(), indices.end(), 0);
    std::sort(indices.begin(), indices.end(),
        [&keys, ascending](int a, int b) {
            const auto& va = keys[a];
            const auto& vb = keys[b];
            bool less = false;
            if (va.typeId() == QMetaType::Int) less = va.toInt() < vb.toInt();
            else if (va.typeId() == QMetaType::LongLong) less = va.toLongLong() < vb.toLongLong();
            else if (va.typeId() == QMetaType::Double) less = va.toDouble() < vb.toDouble();
            else less = va.toString() < vb.toString();
            return ascending ? less : !less;
        });

    // Reorder by sorted indices — O(n)
    QVector<DisplayItem> sorted;
    sorted.reserve(indices.size());
    for (int idx : indices) sorted.append(m_filteredItems[idx]);
    m_filteredItems = std::move(sorted);

    endResetModel();
}

int FileItemModel::selectedCount() const
{
    int c = 0;
    for (const auto& item : m_filteredItems) if (item.selected) c++;
    return c;
}

uint64_t FileItemModel::selectedTotalSize() const
{
    uint64_t t = 0;
    for (const auto& item : m_filteredItems) if (item.selected) t += item.file.file_size;
    return t;
}

uint64_t FileItemModel::selectedProjectedSize() const
{
    uint64_t t = 0;
    for (const auto& item : m_filteredItems) if (item.selected) t += item.file.projected_size;
    return t;
}

void FileItemModel::rebuildFilter()
{
    beginResetModel();
    m_filteredItems.clear();

    int sourceIdx = 0;
    for (const auto& f : m_sourceFiles) {
        bool isImg = (f.type == batchpress::FileItem::Type::Image);

        if (m_typeFilter == "image" && !isImg) { sourceIdx++; continue; }
        if (m_typeFilter == "video" && isImg) { sourceIdx++; continue; }
        if (f.savings_pct < m_minSavings) { sourceIdx++; continue; }

        if (!m_filterText.isEmpty()) {
            QString fname = QString::fromStdString(f.filename).toLower();
            if (!fname.contains(m_filterText)) { sourceIdx++; continue; }
        }

        DisplayItem di;
        di.file = f;
        di.selected = true;
        di.sourceIndex = sourceIdx;
        m_filteredItems.append(di);
        sourceIdx++;
    }
    endResetModel();
    emit selectedCountChanged();
}
