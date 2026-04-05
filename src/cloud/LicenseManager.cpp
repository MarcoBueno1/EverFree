// SPDX-License-Identifier: MIT
/*
 * EverFree — LicenseManager implementation
 */

#include "LicenseManager.hpp"

namespace EverFree {

LicenseManager::LicenseManager(QObject* parent)
    : QObject(parent)
    , m_settings("EverFree", "EverFree")
{
    loadState();
}

void LicenseManager::activateProTrial()
{
    m_tier = Tier::ProTrial;
    m_expiry = QDateTime::currentDateTime().addDays(7);
    m_userEmail = "trial@everfree.app";
    saveState();
    emit tierChanged();
    emit authChanged();
}

void LicenseManager::activatePro()
{
    m_tier = Tier::Pro;
    m_expiry = QDateTime::currentDateTime().addYears(1);
    if (m_userEmail.isEmpty()) m_userEmail = "pro@everfree.app";
    saveState();
    emit tierChanged();
    emit authChanged();
}

void LicenseManager::deactivatePro()
{
    m_tier = Tier::Free;
    m_userEmail.clear();
    m_expiry = QDateTime();
    saveState();
    emit tierChanged();
    emit authChanged();
}

void LicenseManager::saveState()
{
    m_settings.setValue("tier", static_cast<int>(m_tier));
    m_settings.setValue("userEmail", m_userEmail);
    m_settings.setValue("expiry", m_expiry.toString(Qt::ISODate));
    m_settings.setValue("backupsUsed", m_backupsUsed);
    m_settings.sync();
}

void LicenseManager::loadState()
{
    m_tier = static_cast<Tier>(m_settings.value("tier", 0).toInt());
    m_userEmail = m_settings.value("userEmail", "").toString();
    m_expiry = QDateTime::fromString(m_settings.value("expiry", "").toString(), Qt::ISODate);
    m_backupsUsed = m_settings.value("backupsUsed", 0).toInt();

    // Check if trial expired
    if (m_tier == Tier::ProTrial && m_expiry < QDateTime::currentDateTime()) {
        m_tier = Tier::Free;
        saveState();
        emit tierChanged();
    }
}

} // namespace EverFree
