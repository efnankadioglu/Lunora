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

        print("📦 Toplam program:", programs.count)

        let batch = db.batch()

        for program in programs {

            print("⬆️ Yükleniyor:", program.id)

            let docRef = db.collection("programs").document(program.id)

            let data: [String: Any] = [
                "id": program.id,
                "name": program.name,
                "difficultyLevel": program.difficultyLevel,
                "difficultyScale": program.difficultyScale,
                "durationDays": program.durationDays,
                "durationText": program.durationText,
                "imageName": program.imageName,
                "badgeDescription": program.badgeDescription,
                "version": program.version ?? 1,
                    "isActive": program.isActive ?? true,
                    "badgeId": program.badgeId ?? "badge_\(program.id)",
                    "badgeTitle": program.badgeTitle ?? "\(program.name) Rozeti",
                    "badgeImageName": program.badgeImageName ?? program.imageName,
                    "completionRuleType": program.completionRuleType?.rawValue ?? "strict_daily_threshold",
                    "dailyTaskCompletionThreshold": program.dailyTaskCompletionThreshold ?? 0.5,
                    "allowRestart": program.allowRestart ?? true,
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

            batch.setData(data, forDocument: docRef, merge: false)
        }

        batch.commit { error in
            if let error = error {
                print("❌ Batch commit error:", error)
                completion(.failure(error))
            } else {
                print("✅ Tüm programlar Firestore'a yüklendi")
                completion(.success(()))
            }
        }
    }
}
