// SPDX-License-Identifier: MIT
/*
 * EverFree — AppController implementation
 *
 * KEY DESIGN PRINCIPLES:
 * 1. ZERO blocking calls on the UI thread
 * 2. Continuous progress feedback for every operation
 * 3. cancel() is fully non-blocking (no wait())
 * 4. Multi-folder scan with per-folder progress
 * 5. Simple mode shows preview before compressing (no accidental data loss)
 * 6. All settings persisted via QSettings
 */

#include "AppController.hpp"
#include "SimpleMode.hpp"
#include "AdvancedMode.hpp"
#include "utils/FileUtils.hpp"
#include "cloud/LocalCloudProvider.hpp"
#include "db/ProcessingDatabase.hpp"

#include <QStandardPaths>
#include <QDir>
#include <QDateTime>
#include <QCoreApplication>
#include <QMetaObject>
#include <QFileInfo>
#include <QStorageInfo>
#include <QCryptographicHash>

// ── Helpers ───────────────────────────────────────────────────────────────────

static QString homePath() { return QDir::homePath(); }

// ── Construction ──────────────────────────────────────────────────────────────

AppController::AppController(QObject* parent)
    : QObject(parent)
    , m_fileModel(new FileItemModel(this))
    , m_reportModel(new ScanReportModel(this))
    , m_progressModel(new ProgressModel(this))
    , m_hashCache(std::make_shared<batchpress::HashCache>())
    , m_settings("EverFree", "EverFree")
    , m_cloudProvider(new EverFree::LocalCloudProvider(this))
    , m_license(new EverFree::LicenseManager(this))
    , m_db(new EverFree::ProcessingDatabase(this))
{
    loadSettings();

    // Initialize processing history database
    m_db->initialize();

    // Connect cloud provider signals
    connect(m_cloudProvider, &EverFree::CloudProvider::uploadProgress,
            this, [this](const QString& fileName, qint64 sent, qint64 total) {
        Q_UNUSED(sent); Q_UNUSED(total);
        // Could update progress bar during upload
    });
}

AppController::~AppController()
{
    // Non-blocking cancel — workers clean themselves up
    cancel();
}

// ── Settings Persistence ─────────────────────────────────────────────────────

void AppController::loadSettings()
{
    m_vcodec = m_settings.value("vcodec", "auto").toString();
    m_crf = m_settings.value("crf", -1).toInt();
    m_maxRes = m_settings.value("maxRes", "1080p").toString();
    m_imageFormat = m_settings.value("imageFormat", "same").toString();
    m_imageQuality = m_settings.value("imageQuality", 90).toInt();
    m_resizeSpec = m_settings.value("resizeSpec", "fit:1920x1080").toString();
    m_threads = m_settings.value("threads", 0).toInt();
    m_recursive = m_settings.value("recursive", true).toBool();
}

void AppController::saveSettings()
{
    m_settings.setValue("vcodec", m_vcodec);
    m_settings.setValue("crf", m_crf);
    m_settings.setValue("maxRes", m_maxRes);
    m_settings.setValue("imageFormat", m_imageFormat);
    m_settings.setValue("imageQuality", m_imageQuality);
    m_settings.setValue("resizeSpec", m_resizeSpec);
    m_settings.setValue("threads", m_threads);
    m_settings.setValue("recursive", m_recursive);
    m_settings.sync();
}

// ── Mode ──────────────────────────────────────────────────────────────────────

void AppController::setMode(AppMode mode)
{
    if (m_mode != mode) {
        m_mode = mode;
        emit modeChanged();
        if (mode == AppMode::Simple) {
            m_simpleStatus = "Pronto — escaneie com um clique";
        } else {
            m_simpleStatus = "Pronto — selecione pastas e configure";
        }
        emit simpleStatusChanged();
    }
}

void AppController::setState(AppState s)
{
    if (m_state != s) {
        m_state = s;
        emit stateChanged();
    }
}

// ── Folders ───────────────────────────────────────────────────────────────────

void AppController::addFolder(const QString& path)
{
    if (!m_folderPaths.contains(path)) {
        m_folderPaths.append(path);
        emit folderPathsChanged();
    }
}

void AppController::removeFolder(int index)
{
    if (index >= 0 && index < m_folderPaths.size()) {
        m_folderPaths.removeAt(index);
        emit folderPathsChanged();
    }
}

void AppController::clearFolders()
{
    m_folderPaths.clear();
    emit folderPathsChanged();
}

void AppController::addDefaultUserFolders()
{
    m_folderPaths = getDefaultUserFolders();
    emit folderPathsChanged();
}

QStringList AppController::getDefaultUserFolders()
{
    QStringList folders;
    QString home = homePath();
    QStringList names = {
        "Pictures", "Videos", "Desktop", "Documents", "Downloads",
        "Imagens", "Vídeos", "Área de Trabalho", "Documentos", "Músicas", "Music"
    };
    for (const auto& name : names) {
        QString path = QDir(home).filePath(name);
        if (QDir(path).exists()) folders.append(path);
    }
    if (folders.isEmpty()) folders.append(home);
    return folders;
}

// ── Advanced settings (auto-save) ────────────────────────────────────────────

void AppController::setVcodec(const QString& c) { if (m_vcodec != c) { m_vcodec = c; emit vcodecChanged(); saveSettings(); } }
void AppController::setCrf(int c) { if (m_crf != c) { m_crf = c; emit crfChanged(); saveSettings(); } }
void AppController::setMaxRes(const QString& r) { if (m_maxRes != r) { m_maxRes = r; emit maxResChanged(); saveSettings(); } }
void AppController::setImageFormat(const QString& f) { if (m_imageFormat != f) { m_imageFormat = f; emit imageFormatChanged(); saveSettings(); } }
void AppController::setImageQuality(int q) { if (m_imageQuality != q) { m_imageQuality = q; emit imageQualityChanged(); saveSettings(); } }
void AppController::setResizeSpec(const QString& s) { if (m_resizeSpec != s) { m_resizeSpec = s; emit resizeSpecChanged(); saveSettings(); } }
void AppController::setThreads(int t) { if (m_threads != t) { m_threads = t; emit threadsChanged(); saveSettings(); } }
void AppController::setRecursive(bool r) { if (m_recursive != r) { m_recursive = r; emit recursiveChanged(); saveSettings(); } }

void AppController::clearErrors() { m_errorPaths.clear(); emit errorPathsChanged(); }
void AppController::addErrorPath(const QString& path) {
    if (!m_errorPaths.contains(path)) { m_errorPaths.append(path); emit errorPathsChanged(); }
}

bool AppController::isImageType(int) const { return false; }
bool AppController::isVideoType(int) const { return false; }

// ── Scan (Multi-Folder with Continuous Progress) ─────────────────────────────

void AppController::startScan()
{
    if (m_state == AppState::Scanning) return;
    if (m_folderPaths.isEmpty()) return;

    clearErrors();
    m_mergedReport = batchpress::FileScanReport{};
    m_currentFolder = 0;
    m_totalFolders = m_folderPaths.size();
    emit currentFolderChanged();

    setState(AppState::Scanning);
    m_progressModel->start(0);
    m_simpleStatus = QString("Preparando scan de %1 pasta(s)...").arg(m_totalFolders);
    emit simpleStatusChanged();

    // Start scanning first folder
    scanNextFolder();
}

void AppController::scanNextFolder()
{
    if (m_currentFolder >= m_totalFolders) {
        // All folders scanned — merge complete
        m_reportModel->loadReport(m_mergedReport);
        m_fileModel->loadFiles(m_mergedReport.files);
        setState(AppState::ScanComplete);
        emit scanFinished();

        auto imgCount = m_mergedReport.image_count();
        auto vidCount = m_mergedReport.video_count();
        double pct = m_mergedReport.overall_savings_pct();
        m_simpleStatus = QString("✅ %1 imagens, %2 vídeos — economia: %3%")
                             .arg(imgCount).arg(vidCount).arg(pct, 0, 'f', 0);
        emit simpleStatusChanged();
        return;
    }

    QString folder = m_folderPaths[m_currentFolder];
    m_currentFolderName = QFileInfo(folder).fileName();
    if (m_currentFolderName.isEmpty()) m_currentFolderName = folder;
    emit currentFolderChanged();

    // Check accessibility
    if (!QDir(folder).exists() || !QDir(folder).isReadable()) {
        addErrorPath(folder);
        m_simpleStatus = QString("⚠️ Pasta inacessível, pulando: %1").arg(m_currentFolderName);
        emit simpleStatusChanged();
        m_currentFolder++;
        // Continue to next folder immediately
        QMetaObject::invokeMethod(this, "scanNextFolder", Qt::QueuedConnection);
        return;
    }

    // Check disk space
    QStorageInfo storage(folder);
    if (storage.bytesAvailable() > 0 && storage.bytesAvailable() < 100LL * 1024 * 1024) {
        addErrorPath(folder);
        m_simpleStatus = QString("⚠️ Disco quase cheio (%1 livre), pulando: %2")
                             .arg(batchpress::gui::formatBytes(storage.bytesAvailable()))
                             .arg(m_currentFolderName);
        emit simpleStatusChanged();
        m_currentFolder++;
        QMetaObject::invokeMethod(this, "scanNextFolder", Qt::QueuedConnection);
        return;
    }

    m_simpleStatus = QString("📁 Escaneando %1 (%2/%3)...").arg(m_currentFolderName).arg(m_currentFolder + 1).arg(m_totalFolders);
    emit simpleStatusChanged();

    m_scanWorker = new ScanWorker(folder, m_recursive, 5, this);
    // Low priority so it doesn't compete with UI
    m_scanWorker->setPriority(QThread::LowPriority);

    connect(m_scanWorker, &ScanWorker::progressUpdated,
            this, &AppController::onScanProgress);
    connect(m_scanWorker, &ScanWorker::scanComplete,
            this, &AppController::onScanComplete);
    connect(m_scanWorker, &ScanWorker::scanFailed,
            this, &AppController::onScanFailed);

    m_scanWorker->start();
}

void AppController::onScanProgress(const QString& file, int done, int total)
{
    m_progressModel->update(file, done, total);
}

void AppController::onScanComplete(batchpress::FileScanReport report)
{
    // Merge this folder's report into the global one
    m_mergedReport.files.insert(m_mergedReport.files.end(),
                                report.files.begin(), report.files.end());

    // Clean up worker (non-blocking)
    if (m_scanWorker) {
        m_scanWorker->deleteLater();
        m_scanWorker = nullptr;
    }

    m_currentFolder++;

    // If this was the last folder, finalize
    if (m_currentFolder >= m_totalFolders) {
        m_reportModel->loadReport(m_mergedReport);
        m_fileModel->loadFiles(m_mergedReport.files);

        auto imgCount = m_mergedReport.image_count();
        auto vidCount = m_mergedReport.video_count();
        double pct = m_mergedReport.overall_savings_pct();
        uint64_t totalSize = m_mergedReport.total_size();
        uint64_t projectedSize = m_mergedReport.total_projected_size();
        uint64_t savings = totalSize > projectedSize ? totalSize - projectedSize : 0;

        if (m_mode == AppMode::Simple) {
            // Show preview and ask for confirmation before compressing
            m_simpleStatus = QString("📊 %1 arquivos encontrados — economia estimada: %2 (%3)")
                                 .arg(imgCount + vidCount)
                                 .arg(pct, 0, 'f', 0)
                                 .arg(batchpress::gui::formatBytes(savings));
            emit simpleStatusChanged();
            setState(AppState::AwaitingConfirmation);
        } else {
            m_simpleStatus = QString("✅ %1 imagens, %2 vídeos — economia: %3%")
                                 .arg(imgCount).arg(vidCount).arg(pct, 0, 'f', 0);
            emit simpleStatusChanged();
            setState(AppState::ScanComplete);
        }
        emit scanFinished();
        return;
    }

    // Continue to next folder
    QMetaObject::invokeMethod(this, "scanNextFolder", Qt::QueuedConnection);
}

void AppController::onScanFailed(const QString& error)
{
    addErrorPath(m_currentFolderName);

    if (m_scanWorker) {
        m_scanWorker->deleteLater();
        m_scanWorker = nullptr;
    }

    m_currentFolder++;
    QMetaObject::invokeMethod(this, "scanNextFolder", Qt::QueuedConnection);
}

// ── Processing (Chained Image → Video) ───────────────────────────────────────

void AppController::startProcessing()
{
    if (m_state != AppState::ScanComplete && m_state != AppState::Selecting) return;

    auto selectedFiles = m_fileModel->selectedFiles();
    if (selectedFiles.empty()) {
        m_simpleStatus = "Nenhum arquivo selecionado";
        emit simpleStatusChanged();
        return;
    }

    // Check disk space
    if (!selectedFiles.empty()) {
        QString firstPath = QString::fromStdString(selectedFiles.front().path.string());
        QStorageInfo storage(firstPath);
        uint64_t totalInputSize = 0;
        for (const auto& f : selectedFiles) totalInputSize += f.file_size;
        if (storage.bytesAvailable() > 0 &&
            static_cast<uint64_t>(storage.bytesAvailable()) < totalInputSize / 2) {
            m_simpleStatus = "⚠️ Espaço em disco insuficiente para compressão segura";
            emit simpleStatusChanged();
            setState(AppState::Error);
            return;
        }
    }

    std::vector<batchpress::FileItem> images, videos;
    for (const auto& f : selectedFiles) {
        if (f.type == batchpress::FileItem::Type::Image) images.push_back(f);
        else if (f.type == batchpress::FileItem::Type::Video) videos.push_back(f);
    }

    EverFree::AdvancedMode::Config advCfg;
    advCfg.vcodec = m_vcodec;
    advCfg.crf = m_crf;
    advCfg.maxRes = m_maxRes;
    advCfg.imageFormat = m_imageFormat;
    advCfg.imageQuality = m_imageQuality;
    advCfg.resizeSpec = m_resizeSpec;
    advCfg.threads = m_threads;
    advCfg.dedup = true;
    advCfg.hash_cache = m_hashCache;

    setState(AppState::Processing);
    int totalFiles = static_cast<int>(images.size() + videos.size());
    m_progressModel->start(totalFiles);
    m_progressModel->updateBytes(0, 0); // Reset byte counters

    m_pendingVideoFiles = std::move(videos);
    m_pendingVideoConfig = advCfg.toVideoConfig();
    m_pendingVideoConfig.hash_cache = m_hashCache;
    m_pendingVideoConfig.num_threads = m_threads;

    if (!images.empty()) {
        m_processingImages = true;
        batchpress::Config imgCfg = advCfg.toBatchConfig();
        imgCfg.num_threads = m_threads;
        imgCfg.hash_cache = m_hashCache;

        m_processWorker = new ProcessWorker(images, imgCfg, this);
        m_processWorker->setPriority(QThread::LowPriority);

        connect(m_processWorker, &ProcessWorker::progressUpdated,
                this, &AppController::onProcessProgress);
        connect(m_processWorker, &ProcessWorker::processComplete,
                this, &AppController::onProcessComplete);
        connect(m_processWorker, &ProcessWorker::processFailed,
                this, &AppController::onProcessFailed);

        m_simpleStatus = QString("🖼️ Comprimindo %1 imagens...").arg(images.size());
        emit simpleStatusChanged();

        m_processWorker->start();
    } else if (!m_pendingVideoFiles.empty()) {
        startVideoProcessing();
    } else {
        setState(AppState::Complete);
    }
}

void AppController::onProcessProgress(const QString& file, int done, int total,
                                       qint64 inBytes, qint64 outBytes)
{
    m_progressModel->update(file, done, total);
    m_progressModel->updateBytes(inBytes, outBytes);
    double pct = m_progressModel->percent();
    QString saved = batchpress::gui::formatBytes(m_progressModel->inputBytes() - m_progressModel->outputBytes());
    m_simpleStatus = QString("⏳ %1/%2 (%3%) — liberado: %4")
                         .arg(done).arg(total).arg(pct, 0, 'f', 0).arg(saved);
    emit simpleStatusChanged();
}

void AppController::onProcessComplete(batchpress::BatchReport report)
{
    m_processingImages = false;
    if (m_processWorker) { m_processWorker->deleteLater(); m_processWorker = nullptr; }

    if (!m_pendingVideoFiles.empty()) {
        startVideoProcessing();
        return;
    }

    // Flush all buffered records to DB in a single transaction
    if (m_db) m_db->flush();

    setState(AppState::Complete);
    emit processFinished();
    qint64 saved = report.bytes_saved();
    m_simpleStatus = EverFree::SimpleMode::getSummary(saved, report.succeeded);
    emit simpleStatusChanged();
}

void AppController::onProcessFailed(const QString& error)
{
    m_processingImages = false;
    m_pendingVideoFiles.clear();
    if (m_processWorker) { m_processWorker->deleteLater(); m_processWorker = nullptr; }
    if (m_videoWorker) { m_videoWorker->deleteLater(); m_videoWorker = nullptr; }
    setState(AppState::Error);
    m_simpleStatus = "❌ Erro: " + error;
    emit simpleStatusChanged();
}

void AppController::onVideoProcessComplete(batchpress::VideoBatchReport result)
{
    m_processingVideos = false;
    m_pendingVideoFiles.clear();
    if (m_videoWorker) { m_videoWorker->deleteLater(); m_videoWorker = nullptr; }
    setState(AppState::Complete);
    emit processFinished();
    qint64 saved = result.bytes_saved();
    m_simpleStatus = EverFree::SimpleMode::getSummary(saved, result.succeeded);
    emit simpleStatusChanged();
}

void AppController::onVideoProcessFailed(const QString& error)
{
    m_processingVideos = false;
    m_pendingVideoFiles.clear();
    if (m_videoWorker) { m_videoWorker->deleteLater(); m_videoWorker = nullptr; }
    setState(AppState::Error);
    m_simpleStatus = "❌ Erro no vídeo: " + error;
    emit simpleStatusChanged();
}

void AppController::startVideoProcessing()
{
    if (m_pendingVideoFiles.empty()) return;
    m_processingVideos = true;

    m_videoWorker = new VideoProcessWorker(m_pendingVideoFiles, m_pendingVideoConfig, this);
    m_videoWorker->setPriority(QThread::LowPriority);

    connect(m_videoWorker, &VideoProcessWorker::progressUpdated,
            this, &AppController::onProcessProgress);
    connect(m_videoWorker, &VideoProcessWorker::processComplete,
            this, &AppController::onSimpleVideoComplete);
    connect(m_videoWorker, &VideoProcessWorker::processFailed,
            this, &AppController::onVideoProcessFailed);

    m_simpleStatus = QString("🎬 Comprimindo %1 vídeos...").arg(m_pendingVideoFiles.size());
    emit simpleStatusChanged();

    m_videoWorker->start();
}

// ── Simple Mode (Scan → Preview → Confirm → Process) ─────────────────────────

void AppController::startSimpleMode()
{
    // Step 1: Set up folders and start scan
    if (m_folderPaths.isEmpty()) {
        addDefaultUserFolders();
    }
    startScan();

    // After scan completes, onScanComplete will auto-advance if mode == Simple
    // But instead of auto-processing, we go to AwaitingConfirmation
}

void AppController::confirmAndProcess()
{
    if (m_state != AppState::AwaitingConfirmation) return;

    auto allFiles = m_fileModel->selectedFiles();
    if (allFiles.empty()) {
        m_simpleStatus = "Nenhum arquivo para comprimir";
        emit simpleStatusChanged();
        setState(AppState::Complete);
        return;
    }

    std::vector<batchpress::FileItem> images, videos;
    for (const auto& f : allFiles) {
        if (f.type == batchpress::FileItem::Type::Image) images.push_back(f);
        else if (f.type == batchpress::FileItem::Type::Video) videos.push_back(f);
    }

    setState(AppState::Processing);
    int totalFiles = static_cast<int>(images.size() + videos.size());
    m_progressModel->start(totalFiles);
    m_progressModel->updateBytes(0, 0);

    auto imgCfg = EverFree::SimpleMode::getImageConfig();
    auto vidCfg = EverFree::SimpleMode::getVideoConfig();
    imgCfg.hash_cache = m_hashCache;
    vidCfg.hash_cache = m_hashCache;

    m_pendingVideoFiles = std::move(videos);
    m_pendingVideoConfig = vidCfg;
    m_pendingVideoConfig.hash_cache = m_hashCache;

    if (!images.empty()) {
        m_processingImages = true;
        imgCfg.num_threads = 0;
        m_processWorker = new ProcessWorker(images, imgCfg, this);
        m_processWorker->setPriority(QThread::LowPriority);

        connect(m_processWorker, &ProcessWorker::progressUpdated,
                this, &AppController::onProcessProgress);
        connect(m_processWorker, &ProcessWorker::processComplete,
                this, &AppController::onSimpleProcessComplete);
        connect(m_processWorker, &ProcessWorker::processFailed,
                this, &AppController::onProcessFailed);

        m_simpleStatus = QString("🖼️ Comprimindo %1 imagens...").arg(images.size());
        emit simpleStatusChanged();
        m_processWorker->start();
    } else if (!m_pendingVideoFiles.empty()) {
        startVideoProcessing();
    } else {
        setState(AppState::Complete);
    }
}

void AppController::cancelConfirmation()
{
    if (m_state == AppState::AwaitingConfirmation) {
        setState(AppState::ScanComplete);
    }
}

void AppController::onSimpleProcessComplete(batchpress::BatchReport report)
{
    m_processingImages = false;
    if (m_processWorker) { m_processWorker->deleteLater(); m_processWorker = nullptr; }

    if (!m_pendingVideoFiles.empty()) {
        startVideoProcessing();
        return;
    }

    // Flush all buffered records to DB in a single transaction
    if (m_db) m_db->flush();

    setState(AppState::Complete);
    emit processFinished();
    qint64 saved = report.bytes_saved();
    m_simpleStatus = EverFree::SimpleMode::getSummary(saved, report.succeeded);
    emit simpleStatusChanged();
}

void AppController::onSimpleVideoComplete(batchpress::VideoBatchReport result)
{
    m_processingVideos = false;
    m_pendingVideoFiles.clear();
    if (m_videoWorker) { m_videoWorker->deleteLater(); m_videoWorker = nullptr; }

    // Flush all buffered records to DB in a single transaction
    if (m_db) m_db->flush();

    setState(AppState::Complete);
    emit processFinished();
    qint64 saved = result.bytes_saved();
    m_simpleStatus = EverFree::SimpleMode::getSummary(saved, result.succeeded);
    emit simpleStatusChanged();
}

// ── Cancel (100% Non-Blocking) ───────────────────────────────────────────────

void AppController::cancel()
{
    // NON-BLOCKING: Disconnect signals, set cancel flag, let threads die naturally.
    // No wait() calls — the UI thread never blocks.
    // Workers clean themselves up via deleteLater() in their completion handlers.

    if (m_scanWorker) {
        disconnect(m_scanWorker, nullptr, this, nullptr);
        m_scanWorker->cancel();
        // Worker will call deleteLater() on itself in onScanComplete/onScanFailed
        m_scanWorker = nullptr;
    }
    if (m_processWorker) {
        disconnect(m_processWorker, nullptr, this, nullptr);
        m_processWorker->cancel();
        m_processWorker = nullptr;
    }
    if (m_videoWorker) {
        disconnect(m_videoWorker, nullptr, this, nullptr);
        m_videoWorker->cancel();
        m_videoWorker = nullptr;
    }

    // Flush whatever was buffered so far (even on cancel, save progress)
    if (m_db) m_db->flush();

    m_processingImages = false;
    m_processingVideos = false;
    m_pendingVideoFiles.clear();
    setState(AppState::Idle);
}

// ── Cloud Backup & Subscription ────────────────────────────────────────

void AppController::cloudLogin(const QString& email, const QString& password)
{
    m_cloudProvider->login(email, password);
    m_license->activatePro(); // Local testing — auto-activate pro
    emit cloudLoginSuccess();
    emit proStatusChanged();
}

void AppController::cloudRegister(const QString& email, const QString& password)
{
    m_cloudProvider->registerAccount(email, password);
    m_license->activatePro();
    emit cloudLoginSuccess();
    emit proStatusChanged();
}

void AppController::cloudLogout()
{
    m_cloudProvider->logout();
    m_license->deactivatePro();
    emit cloudLogoutComplete();
    emit proStatusChanged();
}

void AppController::activatePro()
{
    m_license->activatePro();
    emit proStatusChanged();
}

void AppController::activateProTrial()
{
    m_license->activateProTrial();
    emit proStatusChanged();
}

void AppController::deactivatePro()
{
    m_license->deactivatePro();
    emit proStatusChanged();
}

void AppController::backupFile(const QString& localPath, qint64 fileSize)
{
    if (!m_license || !m_license->isPro()) return;

    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly)) return;

    QCryptographicHash hash(QCryptographicHash::Sha256);
    hash.addData(&file);
    QString sha256 = hash.result().toHex();

    QString fileName = QFileInfo(localPath).fileName();
    m_cloudProvider->uploadBackup(localPath, sha256, fileSize,
        [this, fileName](const EverFree::CloudResult& result, const QString&) {
            emit backupComplete(fileName, result.success);
        });
}

void AppController::restoreFile(const QString& backupId, const QString& targetPath)
{
    if (!m_license || !m_license->isPro()) return;

    m_cloudProvider->restoreBackup(backupId, targetPath,
        [this](const EverFree::CloudResult& result) {
            emit restoreComplete(result.success);
        });
}

void AppController::fetchBackups()
{
    if (!m_license || !m_license->isPro()) return;

    m_cloudProvider->listBackups(
        [this](const EverFree::CloudResult&, const QVector<EverFree::BackupEntry>& backups) {
            m_backups = backups;
            emit backupListReady();
        });
}

// ── Processing Database (all users) ──────────────────────────────────────────

bool AppController::wasFileProcessed(const QString& inputSha256) const
{
    return m_db && m_db->wasAlreadyProcessed(inputSha256);
}

qint64 AppController::getTotalSavings() const
{
    return m_db ? m_db->getTotalSavings() : 0;
}

int AppController::getTotalProcessed() const
{
    return m_db ? m_db->getTotalProcessed() : 0;
}

double AppController::getAvgSavingsPct() const
{
    return m_db ? m_db->getAvgSavingsPct() : 0.0;
}

QVariantList AppController::getRecentRecords(int days) const
{
    QVariantList list;
    if (!m_db) return list;
    for (const auto& r : m_db->getRecentRecords(days)) {
        list.append(QVariantMap{
            {"fileName", r.fileName},
            {"filePath", r.filePath},
            {"originalSize", r.originalSize},
            {"compressedSize", r.compressedSize},
            {"savingsPct", r.savingsPct},
            {"format", r.format},
            {"processedAt", r.processedAt.toString("dd/MM/yyyy hh:mm")},
            {"folderPath", r.folderPath},
        });
    }
    return list;
}

QVariantList AppController::getFolderStats() const
{
    QVariantList list;
    if (!m_db) return list;
    for (const auto& s : m_db->getFolderStats()) {
        list.append(QVariantMap{
            {"folderPath", s.folderPath},
            {"totalFiles", s.totalFiles},
            {"totalOriginal", s.totalOriginal},
            {"totalCompressed", s.totalCompressed},
            {"avgSavingsPct", s.avgSavingsPct},
            {"lastProcessed", s.lastProcessed},
        });
    }
    return list;
}

QVariantList AppController::getTopFormats(int limit) const
{
    QVariantList list;
    if (!m_db) return list;
    for (const auto& [fmt, cnt] : m_db->getTopFormats(limit)) {
        list.append(QVariantMap{{"format", fmt}, {"count", cnt}});
    }
    return list;
}

// ── Reset ─────────────────────────────────────────────────────────────────────

void AppController::reset()
{
    cancel();
    m_fileModel->clear();
    m_reportModel->clear();
    m_progressModel->finish();
    clearErrors();
    m_mergedReport = batchpress::FileScanReport{};
    m_simpleStatus = "Ready";
    emit simpleStatusChanged();
    setState(AppState::Idle);
}
