//
//  NotificationPreferencesSyncService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 25.08.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class NotificationPreferencesSyncService {

    static let shared = NotificationPreferencesSyncService()

    private let db = Firestore.firestore()
    private let preferences = NotificationPreferences.shared

    private let schemaVersion = 1

    private init() {}

    // MARK: - Bootstrap

    func bootstrap(
        completion: ((Result<Void, Error>) -> Void)? = nil
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion?(.success(()))
            return
        }

        let documentRef = db
            .collection("notification_preferences")
            .document(uid)

        documentRef.getDocument { [weak self] snapshot, error in
            guard let self else { return }

            if let error {
                print("❌ Notification preferences fetch failed: \(error.localizedDescription)")
                completion?(.failure(error))
                return
            }

            if let snapshot, snapshot.exists {
                let data = snapshot.data() ?? [:]

                let localSnapshot = self.preferences.makeSnapshot()

                let remoteSnapshot = NotificationPreferencesSnapshot(
                    masterEnabled: data["masterEnabled"] as? Bool
                        ?? localSnapshot.masterEnabled,

                    programEnabled: data["programEnabled"] as? Bool
                        ?? localSnapshot.programEnabled,

                    astrologyEnabled: data["astrologyEnabled"] as? Bool
                        ?? localSnapshot.astrologyEnabled,

                    beautyEnabled: data["beautyEnabled"] as? Bool
                        ?? localSnapshot.beautyEnabled
                )

                self.preferences.applyRemoteSnapshot(remoteSnapshot)

                print("✅ Notification preferences loaded from Firestore")

                completion?(.success(()))
                return
            }

            let localSnapshot = self.preferences.makeSnapshot()

            documentRef.setData([
                "masterEnabled": localSnapshot.masterEnabled,
                "programEnabled": localSnapshot.programEnabled,
                "astrologyEnabled": localSnapshot.astrologyEnabled,
                "beautyEnabled": localSnapshot.beautyEnabled,
                "schemaVersion": self.schemaVersion,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]) { error in
                if let error {
                    print("❌ Notification preferences creation failed: \(error.localizedDescription)")
                    completion?(.failure(error))
                    return
                }

                print("✅ Notification preferences created in Firestore")

                completion?(.success(()))
            }
        }
    }
    
    // MARK: - Push Current Preferences

    func syncCurrentPreferences() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let snapshot = preferences.makeSnapshot()

        db.collection("notification_preferences")
            .document(uid)
            .updateData([
                "masterEnabled": snapshot.masterEnabled,
                "programEnabled": snapshot.programEnabled,
                "astrologyEnabled": snapshot.astrologyEnabled,
                "beautyEnabled": snapshot.beautyEnabled,
                "schemaVersion": schemaVersion,
                "updatedAt": FieldValue.serverTimestamp()
            ]) { error in
                if let error {
                    print(
                        "❌ Notification preferences sync failed: \(error.localizedDescription)"
                    )
                    return
                }

                print("✅ Notification preferences synced to Firestore")
            }
    }
    
}
