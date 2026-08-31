//
//  NotificationManager.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import Foundation
import UserNotifications
import UIKit

final class NotificationManager {

    // MARK: - Singleton

    static let shared = NotificationManager()

    private init() {}


    // MARK: - Notification Permission

    func requestNotificationPermission(
        completion: @escaping (Bool) -> Void
    ) {

        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in

            if let error = error {
                print("🔴 Notification permission error: \(error.localizedDescription)")
            }

            print(
                granted
                ? "🟢 Notification permission granted"
                : "🟡 Notification permission denied"
            )

            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }


    // MARK: - Current Permission Status

    func getNotificationAuthorizationStatus(
        completion: @escaping (UNAuthorizationStatus) -> Void
    ) {

        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in

                DispatchQueue.main.async {
                    completion(settings.authorizationStatus)
                }
            }
    }


    // MARK: - Open iOS Notification Settings

    func openSystemNotificationSettings() {

        guard let settingsURL = URL(
            string: UIApplication.openNotificationSettingsURLString
        ) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }
    
    // MARK: - Test Notification

    func scheduleTestNotification() {

        let content = UNMutableNotificationContent()
        content.title = "Lunora ✨"
        content.body = "Bildirim sistemi başarıyla çalışıyor."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "lunora_test_notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in

            if let error = error {
                print("🔴 Test notification error: \(error.localizedDescription)")
            } else {
                print("🟢 Test notification scheduled")
            }
        }
    }
}
