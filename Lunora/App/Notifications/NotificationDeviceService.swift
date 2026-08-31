//
//  NotificationDeviceService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseInstallations
import UserNotifications

final class NotificationDeviceService {

    static let shared = NotificationDeviceService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Register Current Device

    func registerCurrentDevice() {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        Installations.installations().installationID { [weak self] installationId, error in
            guard let self else { return }

            if let error {
                print(
                    "❌ Installation ID alınamadı: \(error.localizedDescription)"
                )
                return
            }

            guard let installationId else {
                return
            }

            UNUserNotificationCenter.current()
                .getNotificationSettings { settings in

                    let authorizationStatus =
                        self.authorizationStatusString(
                            settings.authorizationStatus
                        )

                    let appVersion =
                        Bundle.main.object(
                            forInfoDictionaryKey: "CFBundleShortVersionString"
                        ) as? String ?? "unknown"

                    let buildNumber =
                        Bundle.main.object(
                            forInfoDictionaryKey: "CFBundleVersion"
                        ) as? String ?? "unknown"

                    let deviceRef = self.db
                        .collection("notification_preferences")
                        .document(uid)
                        .collection("devices")
                        .document(installationId)

                    deviceRef.getDocument { document, error in

                        if let error {
                            print(
                                "❌ Notification device fetch failed: \(error.localizedDescription)"
                            )
                            return
                        }

                        var data: [String: Any] = [
                            "platform": "ios",
                            "authorizationStatus": authorizationStatus,
                            "appVersion": appVersion,
                            "buildNumber": buildNumber,
                            "timeZone": TimeZone.current.identifier,
                            "locale": Locale.current.identifier,
                            "lastSeenAt": FieldValue.serverTimestamp()
                        ]

                        if document?.exists != true {
                            data["createdAt"] = FieldValue.serverTimestamp()
                        }

                        deviceRef.setData(
                            data,
                            merge: true
                        ) { error in

                            if let error {
                                print(
                                    "❌ Notification device registration failed: \(error.localizedDescription)"
                                )
                                return
                            }

                            print("✅ Notification device registered")
                        }
                    }
                }
        }
    }

    // MARK: - Authorization Status

    private func authorizationStatusString(
        _ status: UNAuthorizationStatus
    ) -> String {

        switch status {

        case .notDetermined:
            return "notDetermined"

        case .denied:
            return "denied"

        case .authorized:
            return "authorized"

        case .provisional:
            return "provisional"

        case .ephemeral:
            return "ephemeral"

        @unknown default:
            return "unknown"
        }
    }
}
