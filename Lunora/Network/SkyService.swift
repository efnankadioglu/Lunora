//
//  SkyService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 1.04.2026.
//

import Foundation
import FirebaseFirestore

final class SkyService {

    private let db = Firestore.firestore()

    func fetchSkyDay(
        for date: String,
        completion: @escaping (Result<DailyAstrology, Error>) -> Void
    ) {
        db.collection("sky_days").document(date).getDocument { snapshot, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                let error = NSError(
                    domain: "SkyService",
                    code: 404,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Bu tarihe ait Firestore verisi bulunamadı."
                    ]
                )
                completion(.failure(error))
                return
            }

            var normalizedData = data

            if normalizedData["date"] == nil {
                normalizedData["date"] = date
            }

            print("✅ SkyService date:", normalizedData["date"] ?? "nil")
            print("✅ moon_sign_display:", normalizedData["moon_sign_display"] ?? "nil")
            print("✅ sections:", normalizedData["sections"] ?? "nil")

            guard let item = DailyAstrology(firestoreData: normalizedData) else {
                let error = NSError(
                    domain: "SkyService",
                    code: 500,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Firestore veri formatı beklenen yapıda değil."
                    ]
                )
                completion(.failure(error))
                return
            }

            completion(.success(item))
        }
    }
}
