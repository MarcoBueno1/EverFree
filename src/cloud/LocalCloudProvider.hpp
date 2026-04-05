// SPDX-License-Identifier: MIT
/*
 * EverFree — LocalCloudProvider header
 * Test implementation: stores backups locally
 */

#pragma once

#include "CloudProvider.hpp"
#include <QVector>
#include <QString>
#include <functional>

namespace EverFree {

class LocalCloudProvider : public CloudProvider {
    Q_OBJECT

public:
    explicit LocalCloudProvider(QObject* parent = nullptr);

    // Auth
    void login(const QString& email, const QString& password) override;
    void registerAccount(const QString& email, const QString& password,
                          const QString& displayName = "") override;
    void logout() override;
    bool isAuthenticated() const override { return !m_userEmail.isEmpty(); }
    QString userId() const override { return m_userId; }
    QString userEmail() const override { return m_userEmail; }

    // Subscription
    bool isProUser() const override { return m_isPro; }
    void startCheckout() override;
    void refreshSubscription() override;
    void setPro(bool pro) { m_isPro = pro; emit subscriptionChanged(m_isPro); }

    // Backup operations
    void uploadBackup(const QString& localPath, const QString& sha256,
                       qint64 fileSize,
                       std::function<void(const CloudResult&, const QString&)> callback) override;
    void restoreBackup(const QString& backupId, const QString& targetPath,
                        std::function<void(const CloudResult&)> callback) override;
    void listBackups(std::function<void(const CloudResult&, const QVector<BackupEntry>&)> callback) override;
    void deleteBackup(const QString& backupId,
                       std::function<void(const CloudResult&)> callback) override;
    void getStorageUsage(std::function<void(const CloudResult&, qint64, qint64)> callback) override;

private:
    void saveIndex();
    void loadIndex();

    QString m_backupDir;
    QString m_userEmail;
    QString m_userId;
    bool m_isPro = false;
    QVector<BackupEntry> m_backups;
};

} // namespace EverFree
