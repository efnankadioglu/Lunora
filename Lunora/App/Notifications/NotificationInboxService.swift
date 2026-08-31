//
//  NotificationInboxService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.08.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class NotificationInboxService {

    static let shared = NotificationInboxService()

    private let db = Firestore.firestore()

    private var listener: ListenerRegistration?

    private init() {}

    // MARK: - Observe Notifications

    func observeNotifications(
        limit: Int = 100,
        completion: @escaping (
            Result<[NotificationInboxItem], Error>
        ) -> Void
    ) {

        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }

        listener?.remove()

        listener = db
            .collection("users")
            .document(uid)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .addSnapshotListener { snapshot, error in

                if let error {
                    completion(.failure(error))
                    return
                }

                let notifications = snapshot?
                    .documents
                    .compactMap { document in
                        NotificationInboxItem(
                            id: document.documentID,
                            data: document.data()
                        )
                    } ?? []

                completion(.success(notifications))
            }
    }

    // MARK: - Mark As Read

    func markAsRead(
        notificationId: String
    ) {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("users")
            .document(uid)
            .collection("notifications")
            .document(notificationId)
            .updateData([
                "readAt": FieldValue.serverTimestamp()
            ]) { error in

                if let error {
                    print(
                        "❌ Notification mark as read failed: \(error.localizedDescription)"
                    )
                    return
                }

                print("✅ Notification marked as read")
            }
    }

    // MARK: - Stop Listening

    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
