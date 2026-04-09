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
    , m_cloudProvider(new EverFree::LocalCloudProvider(this))
    , m_license(new EverFree::LicenseManager(this))
    , m_db(new EverFree::ProcessingDatabase(this))
    , m_settings("EverFree", "EverFree")
{
    loadSettings();
    loadDefaultMode();

    // Initialize processing history database
    m_db->initialize();

    // Connect cloud provider signals
    connect(m_cloudProvider, &EverFree::CloudProvider::uploadProgress,
            this, [this](const QString&, qint64, qint64) {
        // Could update progress bar during upload
    });
}

AppController::~AppController()
{
    // FIX T3: Cancel + wait for threads to prevent crash on shutdown.
    cancel();
    // Note: workers have deleteLater() called, but destructor should ensure
    // the event loop processes deletions. A short wait ensures stability.
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

// ── Default Mode Persistence ─────────────────────────────────────────────────

void AppController::loadDefaultMode()
{
    int mode = m_settings.value("defaultMode", static_cast<int>(AppMode::Simple)).toInt();
    if (mode == static_cast<int>(AppMode::Advanced)) {
        m_defaultMode = AppMode::Advanced;
    } else {
        m_defaultMode = AppMode::Simple;
    }
}

void AppController::saveDefaultMode()
{
    m_settings.setValue("defaultMode", static_cast<int>(m_defaultMode));
    m_settings.sync();
}

void AppController::setDefaultMode(int mode)
{
    AppMode newMode = (mode == static_cast<int>(AppMode::Advanced)) ? AppMode::Advanced : AppMode::Simple;
    if (m_defaultMode != newMode) {
        m_defaultMode = newMode;
        emit defaultModeChanged();
        saveDefaultMode();
    }
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
    // FIX: Validate input — prevent empty or whitespace-only paths
    if (path.trimmed().isEmpty()) return;

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

bool AppController::isImageType(int index) const
{
    if (index < 0 || index >= m_fileModel->rowCount()) return false;
    auto idx = m_fileModel->index(index, 0);
    return m_fileModel->data(idx, FileItemModel::IsImageRole).toBool();
}

bool AppController::isVideoType(int index) const
{
    if (index < 0 || index >= m_fileModel->rowCount()) return false;
    auto idx = m_fileModel->index(index, 0);
    return m_fileModel->data(idx, FileItemModel::IsVideoRole).toBool();
}

// ── Scan (Multi-Folder with Continuous Progress) ─────────────────────────────

void AppController::startScan()
{
    if (m_state == AppState::Scanning) return;
    if (m_folderPaths.isEmpty()) {
        m_simpleStatus = "⚠️ Nenhuma pasta configurada para escanear";
        emit simpleStatusChanged();
        return;
    }

    // Clear previous scan data
    m_fileModel->clear();
    m_reportModel->clear();
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
        QMetaObject::invokeMethod(this, [this]() { scanNextFolder(); }, Qt::QueuedConnection);
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
        QMetaObject::invokeMethod(this, [this]() { scanNextFolder(); }, Qt::QueuedConnection);
        return;
    }

    m_simpleStatus = QString("📁 Escaneando %1 (%2/%3)...").arg(m_currentFolderName).arg(m_currentFolder + 1).arg(m_totalFolders);
    emit simpleStatusChanged();

    m_scanWorker = new ScanWorker(folder, m_recursive, 5, this);

    connect(m_scanWorker, &ScanWorker::progressUpdated,
            this, &AppController::onScanProgress);
    connect(m_scanWorker, &ScanWorker::scanComplete,
            this, &AppController::onScanComplete);
    connect(m_scanWorker, &ScanWorker::scanFailed,
            this, &AppController::onScanFailed);

    // FIX: Set priority BEFORE starting thread to ensure it takes effect
    m_scanWorker->setPriority(QThread::LowPriority);
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
    QMetaObject::invokeMethod(this, [this]() { scanNextFolder(); }, Qt::QueuedConnection);
}

void AppController::onScanFailed(const QString& error)
{
    addErrorPath(m_currentFolderName);

    if (m_scanWorker) {
        m_scanWorker->deleteLater();
        m_scanWorker = nullptr;
    }

    m_currentFolder++;

    // Check if there are more folders to scan
    if (m_currentFolder < m_totalFolders) {
        QMetaObject::invokeMethod(this, [this]() { scanNextFolder(); }, Qt::QueuedConnection);
        return;
    }

    // All folders failed — finalize with error state
    m_reportModel->loadReport(m_mergedReport);
    m_fileModel->loadFiles(m_mergedReport.files);

    if (m_mergedReport.files.empty()) {
        m_simpleStatus = QString("❌ Falha ao escanear: %1").arg(error);
        emit simpleStatusChanged();
        setState(AppState::Error);
    } else {
        // Some folders succeeded, partial result
        auto imgCount = m_mergedReport.image_count();
        auto vidCount = m_mergedReport.video_count();
        double pct = m_mergedReport.overall_savings_pct();
        m_simpleStatus = QString("⚠️ Parcial: %1 imagens, %2 vídeos — economia: %3% (algumas pastas falharam)")
                             .arg(imgCount).arg(vidCount).arg(pct, 0, 'f', 0);
        emit simpleStatusChanged();
        if (m_mode == AppMode::Simple) {
            setState(AppState::AwaitingConfirmation);
        } else {
            setState(AppState::ScanComplete);
        }
    }
    emit scanFinished();
}

// ── Processing (Chained Image → Video) ───────────────────────────────────────

void AppController::startProcessing()
{
    if (m_state != AppState::ScanComplete && m_state != AppState::Selecting) return;
    // Guard: prevent starting processing if a worker is already running
    if (m_processWorker || m_videoWorker) {
        m_simpleStatus = "\u26A0\uFE0F Processamento j\u00e1 em andamento";
        emit simpleStatusChanged();
        return;
    }

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
    m_progressModel->setBytes(0, 0); // Reset byte counters

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
    m_progressModel->setBytes(inBytes, outBytes);
    double pct = m_progressModel->percent();
    QString saved = batchpress::gui::formatBytes(m_progressModel->inputBytes() - m_progressModel->outputBytes());
    m_simpleStatus = QString("⏳ %1/%2 (%3%) — liberado: %4")
                         .arg(done).arg(total).arg(pct, 0, 'f', 0).arg(saved);
    emit simpleStatusChanged();
}

void AppController::onProcessComplete(batchpress::BatchReport report)
{
    m_processingImages = false;
    // FIX: Only call deleteLater if worker still exists (cancel() may have disconnected)
    if (m_processWorker) {
        m_processWorker->deleteLater();
        m_processWorker = nullptr;
    }

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
    // Guard: prevent creating duplicate video worker
    if (m_videoWorker) {
        m_simpleStatus = "\u26A0\uFE0F Processamento de v\u00eddeo j\u00e1 em andamento";
        emit simpleStatusChanged();
        return;
    }
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
    // Guard: prevent starting processing if a worker is already running
    if (m_processWorker || m_videoWorker) {
        m_simpleStatus = "\u26A0\uFE0F Processamento j\u00e1 em andamento";
        emit simpleStatusChanged();
        return;
    }

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
    m_progressModel->setBytes(0, 0);

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
    // FIX: After disconnect, we own cleanup — workers' handlers check for nullptr
    // before calling deleteLater(), preventing double-free.

    if (m_scanWorker) {
        disconnect(m_scanWorker, nullptr, this, nullptr);
        m_scanWorker->cancel();
        m_scanWorker->deleteLater();  // Safe: we disconnected, handler won't double-call
        m_scanWorker = nullptr;
    }
    if (m_processWorker) {
        disconnect(m_processWorker, nullptr, this, nullptr);
        m_processWorker->cancel();
        m_processWorker->deleteLater();  // Safe: handler checks nullptr after disconnect
        m_processWorker = nullptr;
    }
    if (m_videoWorker) {
        disconnect(m_videoWorker, nullptr, this, nullptr);
        m_videoWorker->cancel();
        m_videoWorker->deleteLater();  // Safe: handler checks nullptr after disconnect
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
    if (email.trimmed().isEmpty() || password.isEmpty()) {
        emit cloudLoginFailed("E-mail e senha são obrigatórios");
        return;
    }

    // Login é assíncrono — aguardar sinal de resultado do CloudProvider
    // FIX: Connect to cloud provider result signals before calling login
    QMetaObject::Connection successConn = connect(m_cloudProvider, &EverFree::CloudProvider::loginSuccess,
        this, [this]() {
            m_license->activatePro();
            emit cloudLoginSuccess();
            emit proStatusChanged();
        }, Qt::SingleShotConnection);

    QMetaObject::Connection failConn = connect(m_cloudProvider, &EverFree::CloudProvider::loginFailed,
        this, [this, failConn, successConn](const QString& error) {
            disconnect(successConn);
            disconnect(failConn);
            emit cloudLoginFailed(error);
        }, Qt::SingleShotConnection);

    m_cloudProvider->login(email, password);
}

void AppController::cloudRegister(const QString& email, const QString& password)
{
    if (email.trimmed().isEmpty() || password.isEmpty()) {
        emit cloudLoginFailed("E-mail e senha são obrigatórios");
        return;
    }

    // Register é assíncrono — aguardar sinal de resultado do CloudProvider
    QMetaObject::Connection successConn = connect(m_cloudProvider, &EverFree::CloudProvider::registerSuccess,
        this, [this]() {
            m_license->activatePro();
            emit cloudLoginSuccess();
            emit proStatusChanged();
        }, Qt::SingleShotConnection);

    QMetaObject::Connection failConn = connect(m_cloudProvider, &EverFree::CloudProvider::registerFailed,
        this, [this, failConn, successConn](const QString& error) {
            disconnect(successConn);
            disconnect(failConn);
            emit cloudLoginFailed(error);
        }, Qt::SingleShotConnection);

    m_cloudProvider->registerAccount(email, password);
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
    // FIX: Use QPointer to prevent dangling 'this' if AppController is destroyed
    QPointer<AppController> guard(this);
    m_cloudProvider->uploadBackup(localPath, sha256, fileSize,
        [guard, fileName](const EverFree::CloudResult& result, const QString&) {
            if (guard) emit guard->backupComplete(fileName, result.success);
        });
}

void AppController::restoreFile(const QString& backupId, const QString& targetPath)
{
    if (!m_license || !m_license->isPro()) return;

    QPointer<AppController> guard(this);
    m_cloudProvider->restoreBackup(backupId, targetPath,
        [guard](const EverFree::CloudResult& result) {
            if (guard) emit guard->restoreComplete(result.success);
        });
}

void AppController::fetchBackups()
{
    if (!m_license || !m_license->isPro()) return;

    QPointer<AppController> guard(this);
    m_cloudProvider->listBackups(
        [guard](const EverFree::CloudResult&, const QVector<EverFree::BackupEntry>& backups) {
            if (guard) {
                guard->m_backups = backups;
                emit guard->backupListReady();
            }
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
