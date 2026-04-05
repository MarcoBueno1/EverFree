// SPDX-License-Identifier: MIT
/*
 * EverFree — LocalCloudProvider implementation
 * Stores backups locally for testing. Replace with Supabase/S3 in production.
 */

#include "LocalCloudProvider.hpp"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUuid>

namespace EverFree {

LocalCloudProvider::LocalCloudProvider(QObject* parent)
    : CloudProvider(parent)
{
    m_backupDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation)
                  + "/backups";
    QDir().mkpath(m_backupDir);
    loadIndex();
}

void LocalCloudProvider::login(const QString& email, const QString& password)
{
    Q_UNUSED(password);
    if (!email.isEmpty()) {
        m_userEmail = email;
        m_userId = "local_" + QCryptographicHash::hash(email.toUtf8(), QCryptographicHash::Sha256).toHex().left(16);
        emit authStateChanged(true);
    }
}

void LocalCloudProvider::registerAccount(const QString& email, const QString& password,
                                          const QString& displayName)
{
    Q_UNUSED(displayName);
    login(email, password);
}

void LocalCloudProvider::logout()
{
    m_userEmail.clear();
    m_userId.clear();
    m_isPro = false;
    emit authStateChanged(false);
    emit subscriptionChanged(false);
}

void LocalCloudProvider::startCheckout()
{
    // In production: open payment page in browser
    m_isPro = true;
    emit subscriptionChanged(true);
}

void LocalCloudProvider::refreshSubscription()
{
    if (isAuthenticated()) m_isPro = true;
    emit subscriptionChanged(m_isPro);
}

void LocalCloudProvider::uploadBackup(const QString& localPath, const QString& sha256,
                                       qint64 fileSize,
                                       std::function<void(const CloudResult&, const QString&)> callback)
{
    QFile src(localPath);
    if (!src.exists()) {
        callback({false, "File not found: " + localPath}, "");
        return;
    }

    QString backupId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    QString destPath = m_backupDir + "/" + backupId;

    emit uploadProgress(QFileInfo(localPath).fileName(), 0, fileSize);

    if (!src.copy(destPath)) {
        callback({false, "Failed to copy: " + src.errorString()}, "");
        return;
    }

    BackupEntry entry;
    entry.originalPath = localPath;
    entry.fileName = QFileInfo(localPath).fileName();
    entry.originalSize = fileSize;
    entry.backupId = backupId;
    entry.backupTime = QDateTime::currentDateTime();
    entry.sha256 = sha256;
    entry.compressedSize = 0;
    m_backups.append(entry);
    saveIndex();

    emit uploadProgress(entry.fileName, fileSize, fileSize);
    callback({true, ""}, backupId);
}

void LocalCloudProvider::restoreBackup(const QString& backupId, const QString& targetPath,
                                        std::function<void(const CloudResult&)> callback)
{
    QString srcPath = m_backupDir + "/" + backupId;
    QFile src(srcPath);
    if (!src.exists()) {
        callback({false, "Backup not found: " + backupId});
        return;
    }

    QDir().mkpath(QFileInfo(targetPath).absolutePath());
    emit downloadProgress(QFileInfo(targetPath).fileName(), 0, src.size());

    if (!src.copy(targetPath)) {
        callback({false, "Failed to restore: " + src.errorString()});
        return;
    }

    emit downloadProgress(QFileInfo(targetPath).fileName(), src.size(), src.size());
    callback({true, ""});
}

void LocalCloudProvider::listBackups(std::function<void(const CloudResult&, const QVector<BackupEntry>&)> callback)
{
    callback({true, ""}, m_backups);
}

void LocalCloudProvider::deleteBackup(const QString& backupId,
                                       std::function<void(const CloudResult&)> callback)
{
    QString path = m_backupDir + "/" + backupId;
    QFile::remove(path);
    m_backups.removeIf([&](const BackupEntry& e) { return e.backupId == backupId; });
    saveIndex();
    emit storageChanged();
    callback({true, ""});
}

void LocalCloudProvider::getStorageUsage(std::function<void(const CloudResult&, qint64, qint64)> callback)
{
    qint64 used = 0;
    for (const auto& entry : m_backups) used += entry.originalSize;
    callback({true, ""}, used, -1); // -1 = unlimited for pro
}

void LocalCloudProvider::saveIndex()
{
    QJsonArray arr;
    for (const auto& e : m_backups) {
        QJsonObject obj;
        obj["originalPath"] = e.originalPath;
        obj["fileName"] = e.fileName;
        obj["originalSize"] = static_cast<double>(e.originalSize);
        obj["backupId"] = e.backupId;
        obj["backupTime"] = e.backupTime.toString(Qt::ISODate);
        obj["sha256"] = e.sha256;
        obj["compressedSize"] = static_cast<double>(e.compressedSize);
        arr.append(obj);
    }
    QFile f(m_backupDir + "/index.json");
    if (f.open(QIODevice::WriteOnly)) f.write(QJsonDocument(arr).toJson());
}

void LocalCloudProvider::loadIndex()
{
    QFile f(m_backupDir + "/index.json");
    if (!f.open(QIODevice::ReadOnly)) return;
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isArray()) return;
    for (const auto& val : doc.array()) {
        QJsonObject obj = val.toObject();
        BackupEntry e;
        e.originalPath = obj["originalPath"].toString();
        e.fileName = obj["fileName"].toString();
        e.originalSize = static_cast<qint64>(obj["originalSize"].toDouble());
        e.backupId = obj["backupId"].toString();
        e.backupTime = QDateTime::fromString(obj["backupTime"].toString(), Qt::ISODate);
        e.sha256 = obj["sha256"].toString();
        e.compressedSize = static_cast<qint64>(obj["compressedSize"].toDouble());
        m_backups.append(e);
    }
}

} // namespace EverFree

#include "moc_LocalCloudProvider.cpp"
