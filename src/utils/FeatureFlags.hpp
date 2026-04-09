// SPDX-License-Identifier: MIT
/*
 * EverFree — Feature Flags / A/B Testing System
 * Allows enabling/disabling features and running A/B tests
 */

#pragma once

#include <QString>
#include <QSettings>
#include <QRandomGenerator>
#include <QHash>

namespace EverFree {

/**
 * Feature Flags Manager
 * 
 * Usage:
 *   FeatureFlags::instance().isEnabled("onboarding_v2")
 *   FeatureFlags::instance().getVariant("button_color") // returns "A" or "B"
 */
class FeatureFlags {
public:
    static FeatureFlags& instance() {
        static FeatureFlags inst;
        return inst;
    }

    // Check if a feature is enabled
    bool isEnabled(const QString& feature) const {
        if (m_overrides.contains(feature)) {
            return m_overrides.value(feature);
        }
        auto it = m_defaults.find(feature);
        return it != m_defaults.end() ? it.value() : false;
    }

    // Get A/B test variant (returns one of the variants)
    QString getVariant(const QString& testName) const {
        if (m_variantOverrides.contains(testName)) {
            return m_variantOverrides.value(testName);
        }
        
        // Deterministic variant based on user ID (sticky assignment)
        QString userId = m_settings.value("analytics/userId", "").toString();
        if (userId.isEmpty()) {
            userId = generateUserId();
            m_settings.setValue("analytics/userId", userId);
        }
        
        // Hash user ID + test name to get consistent variant
        uint hash = qHash(userId + "/" + testName);
        int variantIndex = hash % 2; // 50/50 split
        return variantIndex == 0 ? "A" : "B";
    }

    // Override feature flag (for testing or admin)
    void setFeature(const QString& feature, bool enabled) {
        m_overrides[feature] = enabled;
        m_settings.setValue(QString("features/") + feature, enabled);
    }

    // Override A/B test variant (force specific variant)
    void setVariant(const QString& testName, const QString& variant) {
        m_variantOverrides[testName] = variant;
        m_settings.setValue(QString("variants/") + testName, variant);
    }

    // Load persisted settings
    void loadSettings() {
        m_settings.beginGroup("features");
        for (const auto& key : m_settings.childKeys()) {
            m_overrides[key] = m_settings.value(key, false).toBool();
        }
        m_settings.endGroup();

        m_settings.beginGroup("variants");
        for (const auto& key : m_settings.childKeys()) {
            m_variantOverrides[key] = m_settings.value(key, "").toString();
        }
        m_settings.endGroup();
    }

private:
    FeatureFlags() { loadSettings(); }

    QString generateUserId() const {
        return QString("user_%1").arg(QRandomGenerator::global()->generate(), 8, 16, QChar('0'));
    }

    mutable QSettings m_settings;
    QHash<QString, bool> m_overrides;
    QHash<QString, QString> m_variantOverrides;
    
    // Default feature flags
    const QHash<QString, bool> m_defaults = {
        {"onboarding_enabled", true},
        {"tooltips_enabled", true},
        {"error_suggestions_enabled", true},
        {"mode_indicator_enabled", true},
        {"keyboard_shortcuts_enabled", true},
        {"high_contrast_mode", false},
        {"telemetry_enabled", false}, // Explicit opt-in
        {"telemetry_asked", false},
    };
};

// Convenience macros
#define FEATURE(name) EverFree::FeatureFlags::instance().isEnabled(name)
#define VARIANT(name) EverFree::FeatureFlags::instance().getVariant(name)

} // namespace EverFree
