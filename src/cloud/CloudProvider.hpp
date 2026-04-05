// SPDX-License-Identifier: MIT
/*
 * EverFree — Cloud Provider Interface
 * Abstract interface for cloud storage backends (Supabase, Firebase, S3, etc.)
 */

#pragma once

#include <QObject>
#include <QString>
#include <QByteArray>
#include <QDateTime>
#include <functional>
#include <memory>

namespace EverFree {

/**
 * @brief Represents a single backed-up file.
 */
struct BackupEntry {
    QString originalPath;       // Full path on local disk
    QString fileName;           // Just the filename
    qint64  originalSize;       // Size before compression
    QString backupId;           // Cloud storage ID
    QDateTime backupTime;
    QString sha256;             // Hash of original (for integrity check)
    qint64  compressedSize;     // Size after compression (for comparison)
};

/**
 * @brief Result of a cloud operation.
 */
struct CloudResult {
    bool success = false;
    QString error;
    int httpStatus = 0;
};

/**
 * @brief Abstract cloud provider interface.
 *
 * Implement this for any backend:
 *   - SupabaseCloudProvider (recommended for startups)
 *   - FirebaseCloudProvider
 *   - S3CloudProvider
 *   - LocalCloudProvider (for testing — stores in ~/.local/share/EverFree/backups/)
 */
class CloudProvider : public QObject {
    Q_OBJECT

public:
    explicit CloudProvider(QObject* parent = nullptr) : QObject(parent) {}

    // ── Authentication ───────────────────────────────────────────────

    /** Login with email/password. Emits authStateChanged on result. */
    virtual void login(const QString& email, const QString& password) = 0;

    /** Register new account. */
    virtual void registerAccount(const QString& email, const QString& password,
                                  const QString& displayName = "") = 0;

    /** Logout and clear tokens. */
    virtual void logout() = 0;

    /** Check if currently authenticated. */
    virtual bool isAuthenticated() const = 0;

    /** Get current user ID (empty if not logged in). */
    virtual QString userId() const = 0;

    /** Get current user email. */
    virtual QString userEmail() const = 0;

    // ── Subscription ──────────────────────────────────────────────────

    /** Check if user has active Pro subscription. */
    virtual bool isProUser() const = 0;

    /** Initiate payment flow (opens browser). */
    virtual void startCheckout() = 0;

    /** Check subscription status from server. */
    virtual void refreshSubscription() = 0;

    // ── Backup Operations ─────────────────────────────────────────────

    /**
     * Upload a file to cloud backup before compression.
     * @param localPath  Absolute path to original file
     * @param sha256     SHA-256 hash of original file
     * @param fileSize   Size in bytes
     * @param callback   Called when upload completes (success/fail)
     */
    virtual void uploadBackup(const QString& localPath, const QString& sha256,
                               qint64 fileSize,
                               std::function<void(const CloudResult&, const QString& backupId)> callback) = 0;

    /**
     * Download a backed-up file and restore it to original location.
     * @param backupId   Cloud storage ID of the backup
     * @param targetPath Where to restore the file
     * @param callback   Called when download/restore completes
     */
    virtual void restoreBackup(const QString& backupId, const QString& targetPath,
                                std::function<void(const CloudResult&)> callback) = 0;

    /**
     * List all backups for the current user.
     * @param callback Called with list of BackupEntry
     */
    virtual void listBackups(std::function<void(const CloudResult&, const QVector<BackupEntry>&)> callback) = 0;

    /**
     * Delete a backup from cloud storage.
     */
    virtual void deleteBackup(const QString& backupId,
                               std::function<void(const CloudResult&)> callback) = 0;

    /**
     * Get storage usage info (used/total).
     */
    virtual void getStorageUsage(std::function<void(const CloudResult&, qint64 used, qint64 total)> callback) = 0;

signals:
    void authStateChanged(bool authenticated);
    void subscriptionChanged(bool isPro);
    void storageChanged();
    void uploadProgress(const QString& fileName, qint64 bytesSent, qint64 bytesTotal);
    void downloadProgress(const QString& fileName, qint64 bytesReceived, qint64 bytesTotal);
};

} // namespace EverFree
