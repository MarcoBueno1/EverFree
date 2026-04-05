// SPDX-License-Identifier: MIT
/*
 * EverFree — ProcessingDatabase implementation
 *
 * KEY OPTIMIZATIONS:
 *  1. All processed hashes loaded ONCE at startup → O(1) QSet lookup
 *  2. Writes buffered → single SQL transaction per processing run
 *  3. Zero SQL queries during the hot path (per-file compression)
 */

#include "ProcessingDatabase.hpp"
#include <QStandardPaths>
#include <QDir>
#include <QFileInfo>
#include <QSqlError>
#include <QDebug>

namespace EverFree {

ProcessingDatabase::ProcessingDatabase(QObject* parent)
    : QObject(parent)
    , m_db(QSqlDatabase::addDatabase("QSQLITE", "everfree_db"))
{
    m_dbPath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
               + "/processing_history.db";
    QDir().mkpath(QFileInfo(m_dbPath).absolutePath());
}

ProcessingDatabase::~ProcessingDatabase()
{
    if (m_db.isOpen()) {
        flush();  // Commit any pending writes
        m_db.close();
    }
    QSqlDatabase::removeDatabase("everfree_db");
}

bool ProcessingDatabase::openDatabase()
{
    m_db.setDatabaseName(m_dbPath);
    if (!m_db.open()) {
        qWarning() << "Failed to open database:" << m_db.lastError().text();
        return false;
    }
    // Optimize SQLite for bulk inserts
    QSqlQuery(m_db).exec("PRAGMA journal_mode=WAL");
    QSqlQuery(m_db).exec("PRAGMA synchronous=NORMAL");
    QSqlQuery(m_db).exec("PRAGMA cache_size=-8000");  // 8MB cache
    return true;
}

bool ProcessingDatabase::initialize()
{
    if (m_initialized) return true;
    if (!openDatabase()) return false;

    createTables();
    loadProcessedHashes();  // Load ALL hashes into memory — O(n) once

    m_initialized = true;
    emit databaseReady();
    return true;
}

void ProcessingDatabase::createTables()
{
    QSqlQuery q(m_db);

    if (!q.exec(R"(
        CREATE TABLE IF NOT EXISTS processed_files (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path       TEXT    NOT NULL,
            file_name       TEXT    NOT NULL,
            folder_path     TEXT    NOT NULL,
            input_sha256    TEXT    UNIQUE NOT NULL,
            output_sha256   TEXT    NOT NULL,
            original_size   INTEGER NOT NULL,
            compressed_size INTEGER NOT NULL,
            savings_pct     REAL    NOT NULL,
            format          TEXT    NOT NULL,
            processed_at    TEXT    NOT NULL DEFAULT (datetime('now')),
            processing_time_ms INTEGER NOT NULL DEFAULT 0,
            was_skipped     INTEGER NOT NULL DEFAULT 0
        )
    )")) {
        qWarning() << "Failed to create table:" << q.lastError().text();
    }

    // Indexes for fast report queries
    q.exec("CREATE INDEX IF NOT EXISTS idx_input_sha256 ON processed_files(input_sha256)");
    q.exec("CREATE INDEX IF NOT EXISTS idx_folder_path ON processed_files(folder_path)");
    q.exec("CREATE INDEX IF NOT EXISTS idx_processed_at ON processed_files(processed_at)");
    q.exec("CREATE INDEX IF NOT EXISTS idx_format ON processed_files(format)");
}

// ── Load ALL processed hashes into memory ONCE ────────────────────────

void ProcessingDatabase::loadProcessedHashes()
{
    m_processedHashes.clear();

    QSqlQuery q(m_db);
    // Only load non-skipped entries (skipped ones have empty output_sha256)
    if (q.exec("SELECT input_sha256 FROM processed_files WHERE was_skipped = 0")) {
        while (q.next()) {
            m_processedHashes.insert(q.value(0).toString());
        }
    } else {
        qWarning() << "Failed to load processed hashes:" << q.lastError().text();
    }
}

void ProcessingDatabase::addHashToMemory(const QString& inputSha256)
{
    m_processedHashes.insert(inputSha256);
}

// ── O(1) Lookup — no SQL query ────────────────────────────────────────

bool ProcessingDatabase::wasAlreadyProcessed(const QString& inputSha256) const
{
    return m_processedHashes.contains(inputSha256);
}

// ── Buffered Writes — no SQL until flush() ────────────────────────────

void ProcessingDatabase::recordProcessed(const QString& filePath,
                                          const QString& inputSha256,
                                          const QString& outputSha256,
                                          qint64 originalSize,
                                          qint64 compressedSize,
                                          const QString& format,
                                          int processingTimeMs)
{
    double savingsPct = originalSize > 0
        ? 100.0 * (1.0 - static_cast<double>(compressedSize) / originalSize)
        : 0.0;

    PendingRecord rec;
    rec.filePath = filePath;
    rec.fileName = QFileInfo(filePath).fileName();
    rec.folderPath = QFileInfo(filePath).absolutePath();
    rec.inputSha256 = inputSha256;
    rec.outputSha256 = outputSha256;
    rec.originalSize = originalSize;
    rec.compressedSize = compressedSize;
    rec.savingsPct = savingsPct;
    rec.format = format;
    rec.processingTimeMs = processingTimeMs;
    rec.wasSkipped = false;

    m_pending.append(rec);

    // Immediate signal for UI feedback (doesn't write to DB)
    emit recordAdded(rec.fileName, savingsPct);
}

void ProcessingDatabase::recordSkipped(const QString& filePath,
                                        const QString& inputSha256,
                                        qint64 originalSize)
{
    // Skipped files don't need buffering — they're already in the DB.
    // Just mark in memory so we don't re-check them this session.
    addHashToMemory(inputSha256);
}

// ── Flush — single transaction for ALL pending records ────────────────

void ProcessingDatabase::flush()
{
    if (m_pending.isEmpty()) return;

    QSqlQuery q(m_db);

    // Single transaction for all pending records
    if (!m_db.transaction()) {
        qWarning() << "Failed to begin transaction:" << m_db.lastError().text();
        return;
    }

    q.prepare(R"(
        INSERT OR REPLACE INTO processed_files
            (file_path, file_name, folder_path, input_sha256, output_sha256,
             original_size, compressed_size, savings_pct, format, processing_time_ms, was_skipped)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    )");

    int committed = 0;
    for (const auto& rec : m_pending) {
        q.addBindValue(rec.filePath);
        q.addBindValue(rec.fileName);
        q.addBindValue(rec.folderPath);
        q.addBindValue(rec.inputSha256);
        q.addBindValue(rec.outputSha256);
        q.addBindValue(rec.originalSize);
        q.addBindValue(rec.compressedSize);
        q.addBindValue(rec.savingsPct);
        q.addBindValue(rec.format);
        q.addBindValue(rec.processingTimeMs);
        q.addBindValue(rec.wasSkipped ? 1 : 0);

        if (q.exec()) {
            addHashToMemory(rec.inputSha256);
            committed++;
        } else {
            qWarning() << "Failed to insert record:" << q.lastError().text();
        }
    }

    if (committed > 0) {
        m_db.commit();
    } else {
        m_db.rollback();
    }

    m_pending.clear();
    emit flushed(committed);
}

void ProcessingDatabase::clearPending()
{
    m_pending.clear();
}

// ── Report Queries (read from disk) ───────────────────────────────────

QVector<ProcessingRecord> ProcessingDatabase::getRecords(int limit, int offset) const
{
    QVector<ProcessingRecord> records;
    QSqlQuery q(m_db);
    QString sql = "SELECT * FROM processed_files ORDER BY processed_at DESC";
    if (limit > 0) sql += QString(" LIMIT %1 OFFSET %2").arg(limit).arg(offset);

    if (q.exec(sql)) {
        while (q.next()) {
            ProcessingRecord r;
            r.filePath = q.value("file_path").toString();
            r.fileName = q.value("file_name").toString();
            r.originalSize = q.value("original_size").toLongLong();
            r.compressedSize = q.value("compressed_size").toLongLong();
            r.outputSha256 = q.value("output_sha256").toString();
            r.inputSha256 = q.value("input_sha256").toString();
            r.format = q.value("format").toString();
            r.savingsPct = q.value("savings_pct").toDouble();
            r.processedAt = QDateTime::fromString(q.value("processed_at").toString(), Qt::ISODate);
            r.folderPath = q.value("folder_path").toString();
            r.wasSkipped = q.value("was_skipped").toBool();
            r.processingTimeMs = q.value("processing_time_ms").toInt();
            records.append(r);
        }
    }
    return records;
}

QVector<ProcessingRecord> ProcessingDatabase::getRecordsByFolder(const QString& folderPath,
                                                                   int limit) const
{
    QVector<ProcessingRecord> records;
    QSqlQuery q(m_db);
    q.prepare("SELECT * FROM processed_files WHERE folder_path = ? ORDER BY processed_at DESC"
              + (limit > 0 ? QString(" LIMIT %1").arg(limit) : ""));
    q.addBindValue(folderPath);

    if (q.exec()) {
        while (q.next()) {
            ProcessingRecord r;
            r.filePath = q.value("file_path").toString();
            r.fileName = q.value("file_name").toString();
            r.originalSize = q.value("original_size").toLongLong();
            r.compressedSize = q.value("compressed_size").toLongLong();
            r.outputSha256 = q.value("output_sha256").toString();
            r.inputSha256 = q.value("input_sha256").toString();
            r.format = q.value("format").toString();
            r.savingsPct = q.value("savings_pct").toDouble();
            r.processedAt = QDateTime::fromString(q.value("processed_at").toString(), Qt::ISODate);
            r.folderPath = q.value("folder_path").toString();
            r.wasSkipped = q.value("was_skipped").toBool();
            r.processingTimeMs = q.value("processing_time_ms").toInt();
            records.append(r);
        }
    }
    return records;
}

qint64 ProcessingDatabase::getTotalSavings() const
{
    QSqlQuery q(m_db);
    if (q.exec("SELECT SUM(original_size - compressed_size) FROM processed_files WHERE was_skipped = 0")
        && q.next()) return q.value(0).toLongLong();
    return 0;
}

int ProcessingDatabase::getTotalProcessed() const
{
    QSqlQuery q(m_db);
    if (q.exec("SELECT COUNT(*) FROM processed_files WHERE was_skipped = 0") && q.next())
        return q.value(0).toInt();
    return 0;
}

QVector<FolderStats> ProcessingDatabase::getFolderStats() const
{
    QVector<FolderStats> stats;
    QSqlQuery q(m_db);
    if (q.exec(R"(
        SELECT folder_path, COUNT(*) as total_files,
               SUM(original_size) as total_original,
               SUM(compressed_size) as total_compressed,
               AVG(savings_pct) as avg_savings,
               MAX(strftime('%s', processed_at)) as last_processed
        FROM processed_files WHERE was_skipped = 0
        GROUP BY folder_path ORDER BY total_original DESC
    )")) {
        while (q.next()) {
            FolderStats s;
            s.folderPath = q.value(0).toString();
            s.totalFiles = q.value(1).toInt();
            s.totalOriginal = q.value(2).toLongLong();
            s.totalCompressed = q.value(3).toLongLong();
            s.avgSavingsPct = q.value(4).toDouble();
            s.lastProcessed = q.value(5).toInt();
            stats.append(s);
        }
    }
    return stats;
}

QVector<ProcessingRecord> ProcessingDatabase::getRecentRecords(int days) const
{
    QVector<ProcessingRecord> records;
    QSqlQuery q(m_db);
    q.prepare("SELECT * FROM processed_files WHERE processed_at >= datetime('now', ?) ORDER BY processed_at DESC");
    q.addBindValue(QString("-%1 days").arg(days));
    if (q.exec()) {
        while (q.next()) {
            ProcessingRecord r;
            r.filePath = q.value("file_path").toString();
            r.fileName = q.value("file_name").toString();
            r.originalSize = q.value("original_size").toLongLong();
            r.compressedSize = q.value("compressed_size").toLongLong();
            r.outputSha256 = q.value("output_sha256").toString();
            r.inputSha256 = q.value("input_sha256").toString();
            r.format = q.value("format").toString();
            r.savingsPct = q.value("savings_pct").toDouble();
            r.processedAt = QDateTime::fromString(q.value("processed_at").toString(), Qt::ISODate);
            r.folderPath = q.value("folder_path").toString();
            r.wasSkipped = q.value("was_skipped").toBool();
            r.processingTimeMs = q.value("processing_time_ms").toInt();
            records.append(r);
        }
    }
    return records;
}

QVector<QPair<QString, int>> ProcessingDatabase::getTopFormats(int limit) const
{
    QVector<QPair<QString, int>> formats;
    QSqlQuery q(m_db);
    q.prepare("SELECT format, COUNT(*) FROM processed_files WHERE was_skipped = 0 GROUP BY format ORDER BY COUNT(*) DESC LIMIT ?");
    q.addBindValue(limit);
    if (q.exec()) {
        while (q.next()) formats.append(qMakePair(q.value(0).toString(), q.value(1).toInt()));
    }
    return formats;
}

double ProcessingDatabase::getAvgSavingsPct() const
{
    QSqlQuery q(m_db);
    if (q.exec("SELECT AVG(savings_pct) FROM processed_files WHERE was_skipped = 0") && q.next())
        return q.value(0).toDouble();
    return 0.0;
}

void ProcessingDatabase::deleteRecord(const QString& inputSha256)
{
    QSqlQuery q(m_db);
    q.prepare("DELETE FROM processed_files WHERE input_sha256 = ?");
    q.addBindValue(inputSha256);
    if (q.exec()) m_processedHashes.remove(inputSha256);
}

void ProcessingDatabase::clearAll()
{
    QSqlQuery(m_db).exec("DELETE FROM processed_files");
    m_processedHashes.clear();
    m_pending.clear();
}

QString ProcessingDatabase::databasePath() const { return m_dbPath; }

} // namespace EverFree
