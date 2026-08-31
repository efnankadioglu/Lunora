//
//  NotificationPromptManager.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import Foundation

enum NotificationPromptContext: String {
    case general
    case program
    case astrology
    case beauty
}

enum NotificationPromptDecision {
    case none

    // Apple daha önce hiç izin sormadı.
    case requestSystemPermission

    // Kullanıcı Apple popup'ında izin vermedi.
    case openSystemSettings

    // Apple izni var ama kullanıcı Lunora içinden
    // genel bildirimleri kapatmış.
    case enableLunoraNotifications
}

final class NotificationPromptManager {
    
    static let shared = NotificationPromptManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    
    // MARK: - Keys
    
    private let lastPromptDateKey =
    "lunora_notification_prompt_last_date"
    
    private let dismissCountKey =
    "lunora_notification_prompt_dismiss_count"
    
    private let hasSeenInitialPromptKey =
    "lunora_notification_prompt_seen_initial"
    
    
    // MARK: - Cooldown
    
    /// Kullanıcı bir hatırlatmayı kapattıktan sonra
    /// tekrar rahatsız edilmeden önce beklediğimiz süre.
    private let cooldownDays = 7
    
    
    // MARK: - Stored Values
    
    var hasSeenInitialPrompt: Bool {
        defaults.bool(forKey: hasSeenInitialPromptKey)
    }
    
    var dismissCount: Int {
        defaults.integer(forKey: dismissCountKey)
    }
    
    private var lastPromptDate: Date? {
        defaults.object(forKey: lastPromptDateKey) as? Date
    }
    
    
    // MARK: - Eligibility
    
    func canShowPrompt(
        for context: NotificationPromptContext
    ) -> Bool {
        
        // Burada sadece tekrar gösterim zamanını kontrol ediyoruz.
        // iOS izni ve Lunora genel bildirim tercihi
        // ayrı bir katmanda kontrol edilecek.
        
        guard let lastPromptDate else {
            return true
        }
        
        let calendar = Calendar.current
        
        guard let nextAllowedDate = calendar.date(
            byAdding: .day,
            value: cooldownDays,
            to: lastPromptDate
        ) else {
            return false
        }
        
        return Date() >= nextAllowedDate
    }
    
    
    // MARK: - Initial Prompt
    
    func markInitialPromptSeen() {
        
        defaults.set(
            true,
            forKey: hasSeenInitialPromptKey
        )
        
        markPromptShown()
    }
    
    
    // MARK: - Prompt Events
    
    func markPromptShown() {
        
        defaults.set(
            Date(),
            forKey: lastPromptDateKey
        )
        
        print("🔔 Notification prompt shown")
    }
    
    
    func markPromptDismissed() {
        
        let newCount = dismissCount + 1
        
        defaults.set(
            newCount,
            forKey: dismissCountKey
        )
        
        defaults.set(
            Date(),
            forKey: lastPromptDateKey
        )
        
        print(
            "🔔 Notification prompt dismissed | count: \(newCount)"
        )
    }
    
    
    func markNotificationsEnabled() {
        
        defaults.set(
            0,
            forKey: dismissCountKey
        )
        
        print("🟢 Notifications enabled from prompt")
    }
    
    // MARK: - Prompt Decision

    func evaluatePrompt(
        for context: NotificationPromptContext,
        completion: @escaping (NotificationPromptDecision) -> Void
    ) {

        NotificationManager.shared
            .getNotificationAuthorizationStatus { status in

                // MARK: Apple izni açık

                switch status {

                case .authorized,
                     .provisional,
                     .ephemeral:

                    // Hem Apple izni hem Lunora genel tercihi açıksa
                    // kullanıcıyı rahatsız etmiyoruz.
                    if NotificationPreferences.shared
                        .areNotificationsEnabled {

                        completion(.none)
                        return
                    }
                    
                    // Kullanıcı Lunora bildirimlerini bilinçli olarak yeni kapattıysa
                    // kararına saygı gösteriyoruz.
                    if NotificationPreferences.shared
                        .isInMasterDisableGracePeriod() {

                        completion(.none)
                        return
                    }

                    // Lunora içinden kapatılmışsa ancak cooldown
                    // bittiyse tekrar hatırlatabiliriz.
                    guard self.canShowPrompt(for: context) else {
                        completion(.none)
                        return
                    }

                    completion(.enableLunoraNotifications)


                // MARK: Apple izni reddedilmiş

                case .denied:

                    guard self.canShowPrompt(for: context) else {
                        completion(.none)
                        return
                    }

                    completion(.openSystemSettings)


                // MARK: Henüz Apple izni sorulmamış

                case .notDetermined:

                    guard self.canShowPrompt(for: context) else {
                        completion(.none)
                        return
                    }

                    completion(.requestSystemPermission)


                @unknown default:

                    completion(.none)
                }
            }
    }
    
    
    
}
