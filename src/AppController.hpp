// SPDX-License-Identifier: MIT
/*
 * EverFree — AppController
 * 100% non-blocking UI with continuous progress feedback.
 *
 * All long-running operations run on background QThread workers.
 * cancel() is fully non-blocking (no wait()).
 * Scan supports multiple folders with per-folder progress.
 * Settings are persisted via QSettings.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QVector>
#include <QThread>
#include <QSettings>

#include <batchpress/types.hpp>
#include <batchpress/scanner.hpp>
#include <batchpress/processor.hpp>
#include <batchpress/video_processor.hpp>

#include "workers/ScanWorker.hpp"
#include "workers/ProcessWorker.hpp"
#include "workers/VideoProcessWorker.hpp"
#include "models/FileItemModel.hpp"
#include "models/ScanReportModel.hpp"
#include "models/ProgressModel.hpp"
#include "cloud/CloudProvider.hpp"
#include "cloud/LicenseManager.hpp"
#include "db/ProcessingDatabase.hpp"

enum class AppMode { None, Simple, Advanced };

enum class AppState {
    Idle,
    ModeSelected,
    Scanning,
    ScanComplete,
    AwaitingConfirmation, // ← New: user sees preview before committing
    Selecting,
    Processing,
    Complete,
    Error
};

/**
 * @brief Main controller — zero blocking calls on the UI thread.
 *
 * Key design decisions:
 * - cancel() never blocks — disconnects workers and lets them die naturally
 * - Scan iterates all folders with per-folder progress updates
 * - Simple mode shows preview before compressing (no accidental data loss)
 * - All worker cleanup happens via deleteLater() in signal handlers
 */
class AppController : public QObject {
    Q_OBJECT

    Q_PROPERTY(AppMode mode READ mode WRITE setMode NOTIFY modeChanged FINAL)
    Q_PROPERTY(AppState state READ state NOTIFY stateChanged FINAL)
    Q_PROPERTY(FileItemModel* fileModel READ fileModel CONSTANT FINAL)
    Q_PROPERTY(ScanReportModel* reportModel READ reportModel CONSTANT FINAL)
    Q_PROPERTY(ProgressModel* progressModel READ progressModel CONSTANT FINAL)
    Q_PROPERTY(QString simpleStatus READ simpleStatus NOTIFY simpleStatusChanged FINAL)

    // Advanced mode settings (persisted via QSettings)
    Q_PROPERTY(QStringList folderPaths READ folderPaths NOTIFY folderPathsChanged FINAL)
    Q_PROPERTY(QString vcodec READ vcodec WRITE setVcodec NOTIFY vcodecChanged FINAL)
    Q_PROPERTY(int crf READ crf WRITE setCrf NOTIFY crfChanged FINAL)
    Q_PROPERTY(QString maxRes READ maxRes WRITE setMaxRes NOTIFY maxResChanged FINAL)
    Q_PROPERTY(QString imageFormat READ imageFormat WRITE setImageFormat NOTIFY imageFormatChanged FINAL)
    Q_PROPERTY(int imageQuality READ imageQuality WRITE setImageQuality NOTIFY imageQualityChanged FINAL)
    Q_PROPERTY(QString resizeSpec READ resizeSpec WRITE setResizeSpec NOTIFY resizeSpecChanged FINAL)
    Q_PROPERTY(int threads READ threads WRITE setThreads NOTIFY threadsChanged FINAL)
    Q_PROPERTY(bool recursive READ recursive WRITE setRecursive NOTIFY recursiveChanged FINAL)

    // Error tracking
    Q_PROPERTY(QStringList errorPaths READ errorPaths NOTIFY errorPathsChanged FINAL)
    Q_PROPERTY(int errorCount READ errorCount NOTIFY errorPathsChanged FINAL)

    // Cloud backup & subscription
    Q_PROPERTY(bool isPro READ isPro NOTIFY proStatusChanged FINAL)
    Q_PROPERTY(QString planTier READ planTier NOTIFY proStatusChanged FINAL)
    Q_PROPERTY(QString userEmail READ userEmail NOTIFY proStatusChanged FINAL)
    Q_PROPERTY(bool isAuthenticated READ cloudAuthenticated NOTIFY proStatusChanged FINAL)
    Q_PROPERTY(QString subscriptionExpiry READ subscriptionExpiry NOTIFY proStatusChanged FINAL)
    Q_PROPERTY(int backupsUsed READ backupsUsed NOTIFY proStatusChanged FINAL)

    // Scan progress for multi-folder
    Q_PROPERTY(int currentFolder READ currentFolder NOTIFY currentFolderChanged FINAL)
    Q_PROPERTY(int totalFolders READ totalFolders NOTIFY currentFolderChanged FINAL)
    Q_PROPERTY(QString currentFolderName READ currentFolderName NOTIFY currentFolderChanged FINAL)

public:
    explicit AppController(QObject* parent = nullptr);
    ~AppController();

    // Mode
    AppMode mode() const noexcept { return m_mode; }
    void setMode(AppMode mode);

    // State
    AppState state() const noexcept { return m_state; }

    // Models
    FileItemModel* fileModel() const noexcept { return m_fileModel; }
    ScanReportModel* reportModel() const noexcept { return m_reportModel; }
    ProgressModel* progressModel() const noexcept { return m_progressModel; }

    QString simpleStatus() const noexcept { return m_simpleStatus; }

    // Folder management
    QStringList folderPaths() const noexcept { return m_folderPaths; }
    Q_INVOKABLE void addFolder(const QString& path);
    Q_INVOKABLE void removeFolder(int index);
    Q_INVOKABLE void clearFolders();
    Q_INVOKABLE void addDefaultUserFolders();

    // Advanced settings (with QSettings persistence)
    QString vcodec() const noexcept { return m_vcodec; }
    void setVcodec(const QString& c);
    int crf() const noexcept { return m_crf; }
    void setCrf(int c);
    QString maxRes() const noexcept { return m_maxRes; }
    void setMaxRes(const QString& r);
    QString imageFormat() const noexcept { return m_imageFormat; }
    void setImageFormat(const QString& f);
    int imageQuality() const noexcept { return m_imageQuality; }
    void setImageQuality(int q);
    QString resizeSpec() const noexcept { return m_resizeSpec; }
    void setResizeSpec(const QString& s);
    int threads() const noexcept { return m_threads; }
    void setThreads(int t);
    bool recursive() const noexcept { return m_recursive; }
    void setRecursive(bool r);

    // Errors
    QStringList errorPaths() const noexcept { return m_errorPaths; }
    int errorCount() const noexcept { return m_errorPaths.size(); }
    Q_INVOKABLE void clearErrors();

    // Multi-folder scan progress
    int currentFolder() const noexcept { return m_currentFolder; }
    int totalFolders() const noexcept { return m_totalFolders; }
    QString currentFolderName() const noexcept { return m_currentFolderName; }

    // ── Actions ─────────────────────────────────────────────────────

    /** Start scanning selected folder(s) — iterates ALL folders */
    Q_INVOKABLE void startScan();

    /**
     * 100% non-blocking cancel.
     * Disconnects all worker signals and lets threads finish naturally.
     * No wait() calls — UI never freezes.
     */
    Q_INVOKABLE void cancel();

    /** Process selected files (advanced mode) */
    Q_INVOKABLE void startProcessing();

    /**
     * Simple mode flow:
     * 1. Scan all folders
     * 2. Show preview (AwaitingConfirmation state)
     * 3. User confirms → process all with savings > 20%
     */
    Q_INVOKABLE void startSimpleMode();

    /** User confirmed — proceed with compression */
    Q_INVOKABLE void confirmAndProcess();

    /** User declined — go back to idle */
    Q_INVOKABLE void cancelConfirmation();

    /** Reset everything to idle */
    Q_INVOKABLE void reset();

    /** Get default folders for simple mode */
    static QStringList getDefaultUserFolders();

    Q_INVOKABLE bool isImageType(int index) const;
    Q_INVOKABLE bool isVideoType(int index) const;

    // ── Cloud Backup & Subscription ──────────────────────────

    bool isPro() const noexcept { return m_license && m_license->isPro(); }
    QString planTier() const {
        if (!m_license) return "free";
        if (m_license->tier() == EverFree::Tier::ProTrial) return "trial";
        if (m_license->tier() == EverFree::Tier::Pro) return "pro";
        return "free";
    }
    QString userEmail() const { return m_license ? m_license->userEmail() : QString(); }
    bool cloudAuthenticated() const { return m_license && m_license->isAuthenticated(); }
    QString subscriptionExpiry() const { return m_license ? m_license->subscriptionExpiry() : QString(); }
    int backupsUsed() const { return m_license ? m_license->backupsUsed() : 0; }

    Q_INVOKABLE void cloudLogin(const QString& email, const QString& password);
    Q_INVOKABLE void cloudRegister(const QString& email, const QString& password);
    Q_INVOKABLE void cloudLogout();
    Q_INVOKABLE void activatePro();
    Q_INVOKABLE void activateProTrial();
    Q_INVOKABLE void deactivatePro();

    /** Upload file to cloud before compression (only for Pro users). */
    Q_INVOKABLE void backupFile(const QString& localPath, qint64 fileSize);

    /** Restore a backed-up file to original location. */
    Q_INVOKABLE void restoreFile(const QString& backupId, const QString& targetPath);

    /** Get list of all backups for the RollbackPage. */
    Q_INVOKABLE void fetchBackups();

signals:
    void proStatusChanged();
    void cloudLoginSuccess();
    void cloudLoginFailed(const QString& error);
    void cloudLogoutComplete();
    void backupComplete(const QString& fileName, bool success);
    void backupListReady();
    void restoreComplete(bool success);

    void modeChanged();
    void stateChanged();
    void simpleStatusChanged();
    void folderPathsChanged();
    void vcodecChanged();
    void crfChanged();
    void maxResChanged();
    void imageFormatChanged();
    void imageQualityChanged();
    void resizeSpecChanged();
    void threadsChanged();
    void recursiveChanged();
    void errorPathsChanged();
    void currentFolderChanged();

    void scanProgress(const QString& file, int done, int total);
    void scanFinished();
    void processProgress(const QString& file, int done, int total, qint64 inBytes, qint64 outBytes);
    void processFinished();

private slots:
    void onScanProgress(const QString& file, int done, int total);
    void onScanComplete(batchpress::FileScanReport report);
    void onScanFailed(const QString& error);

    void onProcessProgress(const QString& file, int done, int total,
                           qint64 inBytes, qint64 outBytes);
    void onProcessComplete(batchpress::BatchReport report);
    void onProcessFailed(const QString& error);

    void onVideoProcessComplete(batchpress::VideoBatchReport result);
    void onVideoProcessFailed(const QString& error);

    void onSimpleProcessComplete(batchpress::BatchReport report);
    void onSimpleVideoComplete(batchpress::VideoBatchReport result);

private:
    void setState(AppState s);
    void addErrorPath(const QString& path);
    void startVideoProcessing();
    void scanNextFolder();
    void saveSettings();
    void loadSettings();

    AppMode m_mode = AppMode::None;
    AppState m_state = AppState::Idle;

    FileItemModel* m_fileModel;
    ScanReportModel* m_reportModel;
    ProgressModel* m_progressModel;

    QString m_simpleStatus = "Ready";

    QStringList m_folderPaths;

    // Advanced settings
    QString m_vcodec = "auto";
    int m_crf = -1;
    QString m_maxRes = "1080p";
    QString m_imageFormat = "same";
    int m_imageQuality = 90;
    QString m_resizeSpec = "fit:1920x1080";
    int m_threads = 0;
    bool m_recursive = true;

    // Errors
    QStringList m_errorPaths;

    // Multi-folder scan state
    int m_currentFolder = 0;
    int m_totalFolders = 0;
    QString m_currentFolderName;

    // Merged scan report across all folders
    batchpress::FileScanReport m_mergedReport;

    // Workers
    ScanWorker* m_scanWorker = nullptr;
    ProcessWorker* m_processWorker = nullptr;
    VideoProcessWorker* m_videoWorker = nullptr;

    bool m_processingImages = false;
    bool m_processingVideos = false;

    // Pending video files for chained processing
    std::vector<batchpress::FileItem> m_pendingVideoFiles;
    batchpress::VideoConfig m_pendingVideoConfig;

    // Shared hash cache for duplicate detection
    std::shared_ptr<batchpress::HashCache> m_hashCache;

    // Cloud backup service & license management
    EverFree::CloudProvider* m_cloudProvider = nullptr;
    EverFree::LicenseManager* m_license = nullptr;
    QVector<EverFree::BackupEntry> m_backups;

    // Local processing history database (works for ALL users)
    EverFree::ProcessingDatabase* m_db = nullptr;

    /** Check if file was already processed (by hash). */
    Q_INVOKABLE bool wasFileProcessed(const QString& inputSha256) const;

    /** Get total savings ever achieved. */
    Q_INVOKABLE qint64 getTotalSavings() const;

    /** Get total files ever processed. */
    Q_INVOKABLE int getTotalProcessed() const;

    /** Get average savings percentage. */
    Q_INVOKABLE double getAvgSavingsPct() const;

    /** Get recent processing records (for reports). */
    Q_INVOKABLE QVariantList getRecentRecords(int days) const;

    /** Get per-folder stats (for reports). */
    Q_INVOKABLE QVariantList getFolderStats() const;

    /** Get top formats (for reports). */
    Q_INVOKABLE QVariantList getTopFormats(int limit = 10) const;

    // Settings persistence
    QSettings m_settings;
};
