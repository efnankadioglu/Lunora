//
//  NotificationPreferences.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import Foundation

struct NotificationPreferencesSnapshot {
    let masterEnabled: Bool
    let programEnabled: Bool
    let astrologyEnabled: Bool
    let beautyEnabled: Bool
}

enum LunoraNotificationCategory: String {
    case program
    case astrology
    case beauty
}

final class NotificationPreferences {

    static let shared = NotificationPreferences()

    private let defaults = UserDefaults.standard

    private init() {}


    // MARK: - Keys

    private let masterKey = "lunora_notifications_master"
    private let masterDisabledAtKey = "lunora_notifications_master_disabled_at"

    private func key(for category: LunoraNotificationCategory) -> String {
        return "lunora_notifications_\(category.rawValue)"
    }


    // MARK: - General Notifications

    var areNotificationsEnabled: Bool {

        if defaults.object(forKey: masterKey) == nil {
            return true
        }

        return defaults.bool(forKey: masterKey)
    }


    func setNotificationsEnabled(_ enabled: Bool) {

        defaults.set(enabled, forKey: masterKey)

        if enabled {
            // Kullanıcı tekrar açtıysa eski kapatma tarihini temizle.
            defaults.removeObject(forKey: masterDisabledAtKey)
        } else {
            // Kullanıcının bilinçli olarak kapattığı zamanı kaydet.
            defaults.set(Date(), forKey: masterDisabledAtKey)
        }

        setEnabled(enabled, for: .program)
        setEnabled(enabled, for: .astrology)
        setEnabled(enabled, for: .beauty)

        print("🔔 General notifications: \(enabled)")
    }
    
    var masterDisabledAt: Date? {
        defaults.object(forKey: masterDisabledAtKey) as? Date
    }

    func isInMasterDisableGracePeriod(days: Int = 14) -> Bool {

        guard let disabledAt = masterDisabledAt else {
            return false
        }

        guard let allowedDate = Calendar.current.date(
            byAdding: .day,
            value: days,
            to: disabledAt
        ) else {
            return false
        }

        return Date() < allowedDate
    }


    // MARK: - Category Preferences
    
    private func storedValue(
        for category: LunoraNotificationCategory
    ) -> Bool {
        let preferenceKey = key(for: category)

        if defaults.object(forKey: preferenceKey) == nil {
            return true
        }

        return defaults.bool(forKey: preferenceKey)
    }

    func isEnabled(_ category: LunoraNotificationCategory) -> Bool {
        // Genel bildirimler kapalıysa kategori her durumda kapalı.
        guard areNotificationsEnabled else {
            return false
        }

        return storedValue(for: category)
    }


    func setEnabled(
        _ enabled: Bool,
        for category: LunoraNotificationCategory
    ) {

        defaults.set(
            enabled,
            forKey: key(for: category)
        )

        print(
            "🔔 Notification preference | \(category.rawValue): \(enabled)"
        )
    }
    
    
    // MARK: - Sync

    func makeSnapshot() -> NotificationPreferencesSnapshot {
        NotificationPreferencesSnapshot(
            masterEnabled: areNotificationsEnabled,
            programEnabled: storedValue(for: .program),
            astrologyEnabled: storedValue(for: .astrology),
            beautyEnabled: storedValue(for: .beauty)
        )
    }

    func applyRemoteSnapshot(
        _ snapshot: NotificationPreferencesSnapshot
    ) {
        defaults.set(
            snapshot.masterEnabled,
            forKey: masterKey
        )

        defaults.set(
            snapshot.programEnabled,
            forKey: key(for: .program)
        )

        defaults.set(
            snapshot.astrologyEnabled,
            forKey: key(for: .astrology)
        )

        defaults.set(
            snapshot.beautyEnabled,
            forKey: key(for: .beauty)
        )

        if snapshot.masterEnabled {
            defaults.removeObject(forKey: masterDisabledAtKey)
        }
    }
}
