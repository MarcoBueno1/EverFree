// SPDX-License-Identifier: MIT
/*
 * EverFree — ProcessingDatabase
 * Local SQLite database tracking every processed file.
 *
 * OPTIMIZATION: All processed hashes are loaded into a QSet at startup.
 * Lookups are O(1) via QSet::contains() — zero SQL queries during compression.
 * Database writes are batched at the end of each processing run.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QSet>
#include <QVector>
#include <QDateTime>
#include <QPair>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariant>

namespace EverFree {

struct ProcessingRecord {
    QString filePath;
    QString fileName;
    qint64  originalSize;
    qint64  compressedSize;
    QString outputSha256;
    QString inputSha256;
    QString format;
    double  savingsPct;
    QDateTime processedAt;
    QString folderPath;
    bool    wasSkipped;
    int     processingTimeMs;
};

struct FolderStats {
    QString folderPath;
    int     totalFiles;
    qint64  totalOriginal;
    qint64  totalCompressed;
    double  avgSavingsPct;
    int     lastProcessed;
};

/**
 * Pending write — buffered to avoid per-file SQL overhead.
 * All records are flushed in a single transaction.
 */
struct PendingRecord {
    QString filePath;
    QString fileName;
    QString folderPath;
    QString inputSha256;
    QString outputSha256;
    qint64  originalSize;
    qint64  compressedSize;
    double  savingsPct;
    QString format;
    int     processingTimeMs;
    bool    wasSkipped;
};

class ProcessingDatabase : public QObject {
    Q_OBJECT

public:
    explicit ProcessingDatabase(QObject* parent = nullptr);
    ~ProcessingDatabase();

    /** Initialize DB and load all hashes into memory. Must call before any other method. */
    bool initialize();

    /** O(1) lookup — checks in-memory QSet, zero SQL queries. */
    bool wasAlreadyProcessed(const QString& inputSha256) const;

    /**
     * Buffer a processed file record. NO SQL write yet.
     * Call flush() to commit all pending records in one transaction.
     */
    void recordProcessed(const QString& filePath,
                          const QString& inputSha256,
                          const QString& outputSha256,
                          qint64 originalSize,
                          qint64 compressedSize,
                          const QString& format,
                          int processingTimeMs);

    /** Buffer a skipped file (already processed). */
    void recordSkipped(const QString& filePath,
                        const QString& inputSha256,
                        qint64 originalSize);

    /**
     * Flush ALL pending records to disk in a SINGLE SQL transaction.
     * Updates the in-memory hash set after successful commit.
     * Call this at the end of each processing run.
     */
    void flush();

    /** Clear pending records (e.g., on cancel). */
    void clearPending();

    // ── Report queries (read from disk, not from pending buffer) ──

    QVector<ProcessingRecord> getRecords(int limit = -1, int offset = 0) const;
    QVector<ProcessingRecord> getRecordsByFolder(const QString& folderPath, int limit = -1) const;
    qint64 getTotalSavings() const;
    int getTotalProcessed() const;
    QVector<FolderStats> getFolderStats() const;
    QVector<ProcessingRecord> getRecentRecords(int days) const;
    QVector<QPair<QString, int>> getTopFormats(int limit = 10) const;
    double getAvgSavingsPct() const;
    void deleteRecord(const QString& inputSha256);
    void clearAll();
    QString databasePath() const;

    /** Number of pending records waiting to be flushed. */
    int pendingCount() const noexcept { return m_pending.size(); }

signals:
    void databaseReady();
    void recordAdded(const QString& fileName, double savingsPct);
    void flushed(int recordsCommitted);

private:
    bool openDatabase();
    void createTables();
    void loadProcessedHashes();
    void addHashToMemory(const QString& inputSha256);

    QSqlDatabase m_db;
    QString m_dbPath;
    bool m_initialized = false;

    // O(1) lookup — loaded once at startup, updated on flush
    QSet<QString> m_processedHashes;

    // Buffered writes — flushed in batch
    QVector<PendingRecord> m_pending;
};

} // namespace EverFree
