//
//  EarnedBadgeService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class EarnedBadgeService {
    static let shared = EarnedBadgeService()
    private init() {}

    private let db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func awardBadge(for programId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "EarnedBadgeService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."
            ])))
            return
        }

        let badgeData: [String: Any] = [
            "programId": programId,
            "earnedAt": Timestamp(date: Date()),
            "isSeen": false,
            "isFeatured": false
        ]

        db.collection("users")
            .document(userId)
            .collection("earned_badges")
            .document(programId)
            .setData(badgeData, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func fetchEarnedBadges(completion: @escaping (Result<[EarnedBadge], Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "EarnedBadgeService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."
            ])))
            return
        }

        db.collection("users")
            .document(userId)
            .collection("earned_badges")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                    let badges: [EarnedBadge] = documents.compactMap { document in
                        let data = document.data()

                        guard
                            let badgeId = data["badgeId"] as? String,
                            let programId = data["programId"] as? String,
                            let enrollmentId = data["enrollmentId"] as? String,
                            let awardedAtTimestamp = data["awardedAt"] as? Timestamp,
                            let status = data["status"] as? String,
                            let isSeen = data["isSeen"] as? Bool,
                            let isFeatured = data["isFeatured"] as? Bool,
                            let createdAtTimestamp = data["createdAt"] as? Timestamp,
                            let updatedAtTimestamp = data["updatedAt"] as? Timestamp
                        else {
                            return nil
                        }

                        return EarnedBadge(
                            id: document.documentID,
                            badgeId: badgeId,
                            programId: programId,
                            enrollmentId: enrollmentId,
                            awardedAt: awardedAtTimestamp.dateValue(),
                            status: status,
                            isSeen: isSeen,
                            isFeatured: isFeatured,
                            badgeTitleSnapshot: data["badgeTitleSnapshot"] as? String,
                            badgeDescriptionSnapshot: data["badgeDescriptionSnapshot"] as? String,
                            iconNameSnapshot: data["iconNameSnapshot"] as? String,
                            createdAt: createdAtTimestamp.dateValue(),
                            updatedAt: updatedAtTimestamp.dateValue()
                        )
                    
                 }

                    completion(.success(badges))
                }
    }
}
