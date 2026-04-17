//
//  ProgramMigrationService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 3.04.2026.
//

import Foundation
import FirebaseFirestore

final class ProgramMigrationService {
    static let shared = ProgramMigrationService()
    private init() {}

    private let db = Firestore.firestore()

    func uploadAllProgramsFromLocalJSON(completion: @escaping (Result<Void, Error>) -> Void) {

        let programs = ProgramLoader.loadPrograms()

        // ✅ EKLENDİ → kaç program geliyor gör
        print("📦 Toplam program:", programs.count)

        let batch = db.batch()

        for program in programs {

            // ✅ EKLENDİ → hangi program yükleniyor gör
            print("⬆️ Yükleniyor:", program.id)

            // Firestore document ID string olmalı
            let docRef = db.collection("programs").document(program.id) // 🔥 "\( )" kaldırıldı (zaten String)

            let data: [String: Any] = [
                "id": program.id,
                "name": program.name,
                "difficultyLevel": program.difficultyLevel,
                "difficultyScale": program.difficultyScale,
                "durationDays": program.durationDays,
                "durationText": program.durationText,
                "imageName": program.imageName,
                "badgeDescription": program.badgeDescription,
                "elements": program.elements,
                "dailyDurationText": program.dailyDurationText,
                "coreProblems": program.coreProblems,
                "oneSentenceSummary": program.oneSentenceSummary,
                "fullText": program.fullText,

                "dailyTasks": program.dailyTasks.map { task in
                    [
                        "id": task.id,
                        "title": task.title,
                        "shortDescription": task.shortDescription,
                        "details": task.details
                    ]
                },

                "weeklyReflection": [
                    "title": program.weeklyReflection.title,
                    "shortDescription": program.weeklyReflection.shortDescription,
                    "details": program.weeklyReflection.details
                ],

                "goldenRules": [
                    "title": program.goldenRules.title,
                    "shortDescription": program.goldenRules.shortDescription,
                    "details": program.goldenRules.details
                ],

                "realImpact": [
                    "title": program.realImpact.title,
                    "shortDescription": program.realImpact.shortDescription,
                    "details": program.realImpact.details
                ],

                "dailyPlanSummary": [
                    "title": program.dailyPlanSummary.title,
                    "shortDescription": program.dailyPlanSummary.shortDescription,
                    "details": program.dailyPlanSummary.details
                ],

                "processResult": [
                    "title": program.processResult.title,
                    "shortDescription": program.processResult.shortDescription,
                    "details": program.processResult.details
                ]
            ]

            // 🔥 ÖNEMLİ: merge false yapıyoruz (temiz yazsın)
            batch.setData(data, forDocument: docRef, merge: false) // ✅ DEĞİŞTİRİLDİ
        }

        batch.commit { error in
            if let error = error {
                print("❌ Batch commit error:", error) // ✅ EKLENDİ
                completion(.failure(error))
            } else {
                print("✅ Tüm programlar Firestore'a yüklendi") // ✅ EKLENDİ
                completion(.success(()))
            }
        }
    }
}
