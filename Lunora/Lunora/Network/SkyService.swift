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

    func fetchSkyDay(for date: String, completion: @escaping (Result<DailyAstrology, Error>) -> Void) {

        db.collection("sky_days").document(date).getDocument { snapshot, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                let error = NSError(
                    domain: "SkyService",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Bu tarihe ait Firestore verisi bulunamadı."]
                )
                completion(.failure(error))
                return
            }

            guard
                let date = data["date"] as? String,
                let moonPhase = data["moon_phase"] as? String,
                let dailyComment = data["daily_comment"] as? String,
                let celestialEvents = data["celestial_events"] as? [String],
                let suitabilityScore = data["suitability_score"] as? Int,
                let moonSign = data["moon_sign"] as? String
            else {
                let error = NSError(
                    domain: "SkyService",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: "Firestore veri formatı beklenen yapıda değil."]
                )
                completion(.failure(error))
                return
            }

            let item = DailyAstrology(
                date: date,
                moonPhase: moonPhase,
                dailyComment: dailyComment,
                celestialEvents: celestialEvents,
                suitabilityScore: suitabilityScore,
                moonSign: moonSign
            )

            completion(.success(item))
        }
    }
}
