// SPDX-License-Identifier: MIT
/*
 * EverFree — LicenseManager
 * Manages free vs Pro subscription state.
 * Persists via QSettings.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QSettings>

namespace EverFree {

/**
 * @brief Subscription tier.
 */
enum class Tier {
    Free,       // No login, no backup, no rollback
    ProTrial,   // 7-day trial (limited backups)
    Pro         // Full backup + rollback
};

/**
 * @brief Manages license state.
 *
 * Free users: full compression, no cloud features
 * Pro users: cloud backup before compression, rollback capability
 */
class LicenseManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(Tier tier READ tier NOTIFY tierChanged FINAL)
    Q_PROPERTY(bool isPro READ isPro NOTIFY tierChanged FINAL)
    Q_PROPERTY(QString userEmail READ userEmail NOTIFY authChanged FINAL)
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY authChanged FINAL)
    Q_PROPERTY(QString subscriptionExpiry READ subscriptionExpiry NOTIFY tierChanged FINAL)
    Q_PROPERTY(int backupsUsed READ backupsUsed NOTIFY storageChanged FINAL)
    Q_PROPERTY(int backupsLimit READ backupsLimit NOTIFY storageChanged FINAL)

public:
    explicit LicenseManager(QObject* parent = nullptr);

    Tier tier() const noexcept { return m_tier; }
    bool isPro() const noexcept { return m_tier == Tier::Pro || m_tier == Tier::ProTrial; }
    QString userEmail() const noexcept { return m_userEmail; }
    bool isAuthenticated() const noexcept { return !m_userEmail.isEmpty(); }
    QString subscriptionExpiry() const noexcept { return m_expiry.toString("dd/MM/yyyy"); }
    int backupsUsed() const noexcept { return m_backupsUsed; }
    int backupsLimit() const noexcept {
        return m_tier == Tier::ProTrial ? 50 : -1; // -1 = unlimited
    }

    /** Simulate purchase for testing (remove in production). */
    Q_INVOKABLE void activateProTrial();
    Q_INVOKABLE void activatePro();
    Q_INVOKABLE void deactivatePro();

signals:
    void tierChanged();
    void authChanged();
    void storageChanged();

private:
    void saveState();
    void loadState();

    Tier m_tier = Tier::Free;
    QString m_userEmail;
    QDateTime m_expiry;
    int m_backupsUsed = 0;
    QSettings m_settings;
};

} // namespace EverFree
