//
//  DailyInsightService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 14.05.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseFunctions

final class DailyInsightService {

    static let shared = DailyInsightService()

    private let db = Firestore.firestore()
    private let functions = Functions.functions(region: "us-central1")

    private init() {}

    func fetchTodayInsight(
        userId: String,
        completion: @escaping (Result<DailyInsight, Error>) -> Void
    ) {
        let dateKey = makeTodayDateKey()

        fetchCachedInsight(
            userId: userId,
            dateKey: dateKey
        ) { [weak self] cachedResult in
            guard let self = self else { return }

            switch cachedResult {
            case .success(let cachedInsight):
                completion(.success(cachedInsight))

            case .failure:
                self.generateInsightWithCloudFunction(
                    userId: userId,
                    dateKey: dateKey
                ) { functionResult in
                    switch functionResult {
                    case .success(let generatedInsight):
                        completion(.success(generatedInsight))

                    case .failure(let error):
                        print("🔴 DailyInsight AI/fonksiyon hatası:", error.localizedDescription)

                        let fallback = DailyInsight.fallback(dateKey: dateKey)
                        completion(.success(fallback))
                    }
                }
            }
        }
    }

    private func fetchCachedInsight(
        userId: String,
        dateKey: String,
        completion: @escaping (Result<DailyInsight, Error>) -> Void
    ) {
        let insightRef = db
            .collection(FirestoreCollection.users)
            .document(userId)
            .collection(FirestoreCollection.dailyInsights)
            .document(dateKey)

        insightRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let snapshot = snapshot,
                snapshot.exists,
                let data = snapshot.data(),
                let insight = DailyInsight(documentId: snapshot.documentID, data: data)
            else {
                completion(.failure(NSError(domain: "DailyInsight", code: 404)))
                return
            }

            print("🟢 DailyInsight cache bulundu:", dateKey)
            completion(.success(insight))
        }
    }

    private func generateInsightWithCloudFunction(
        userId: String,
        dateKey: String,
        completion: @escaping (Result<DailyInsight, Error>) -> Void
    ) {
        let payload: [String: Any] = [
            "dateKey": dateKey,
            "userId": userId
        ]

        print("🟣 DailyInsight payload userId:", userId)
        print("🟣 DailyInsight payload dateKey:", dateKey)

        functions.httpsCallable("generateDailyInsight").call(payload) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = result?.data as? [String: Any],
                let title = data["title"] as? String,
                let subtitle = data["subtitle"] as? String,
                let body = data["body"] as? String
            else {
                completion(.failure(NSError(domain: "DailyInsight", code: -1)))
                return
            }

            let insight = DailyInsight(
                dateKey: data["dateKey"] as? String ?? dateKey,
                title: title,
                subtitle: subtitle,
                body: body,
                source: data["source"] as? String ?? "openai",
                createdAt: nil
            )

            print("🟢 DailyInsight Cloud Function’dan geldi")
            completion(.success(insight))
        }
    }

    private func makeTodayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
}
