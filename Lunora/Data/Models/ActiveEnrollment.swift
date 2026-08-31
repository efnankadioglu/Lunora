//
//  ActiveEnrollment.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 11.04.2026.
//

//import Foundation
//import FirebaseFirestore
//
//struct ActiveEnrollment {
//    let enrollmentId: String
//    let userId: String
//    let programId: String
//
//    let programName: String?
//    let durationDays: Int
//
//    let badgeId: String
//    let badgeDescription: String
//    let programImageName: String
//    let badgeTitle: String
//    let badgeImageName: String
//
//    let status: String
//    let currentDay: Int
//    let completedDaysCount: Int
//    let progressPercent: Double
//
//    let isCompleted: Bool
//    let isFailed: Bool
//    let earnedBadge: Bool
//    
//    let badgeEvaluationCompleted: Bool
//    let finalizationVersion: Int
//
//    let startedAt: Timestamp?
//    let completedAt: Timestamp?
//    let createdAt: Timestamp?
//    let updatedAt: Timestamp?
//
//    let completionReason: String?
//    let finalProgressPercent: Double?
//
//    init?(documentId: String, data: [String: Any]) {
//        guard
//            let userId = data["userId"] as? String,
//            let programId = data["programId"] as? String,
//            let status = data["status"] as? String,
//            let currentDay = data["currentDay"] as? Int,
//            let completedDaysCount = data["completedDaysCount"] as? Int,
//            let isCompleted = data["isCompleted"] as? Bool,
//            let isFailed = data["isFailed"] as? Bool
//        else {
//            return nil
//        }
//
//        self.enrollmentId = documentId
//        self.userId = userId
//        self.programId = programId
//
//        self.programName = data["programName"] as? String
//        self.durationDays = data["durationDays"] as? Int ?? 0
//        
//        self.badgeId = data["badgeId"] as? String ?? ""
//        self.badgeDescription = data["badgeDescription"] as? String ?? ""
//        self.programImageName = data["programImageName"] as? String ?? ""
//        self.badgeTitle = data["badgeTitle"] as? String ?? ""
//        self.badgeImageName = data["badgeImageName"] as? String ?? self.programImageName
//
//        self.status = status
//        self.currentDay = currentDay
//        self.completedDaysCount = completedDaysCount
//        self.progressPercent = data["progressPercent"] as? Double ?? 0.0
//
//        self.isCompleted = isCompleted
//        self.isFailed = isFailed
//        self.earnedBadge = data["earnedBadge"] as? Bool ?? false
//        
//        self.badgeEvaluationCompleted =
//            data["badgeEvaluationCompleted"] as? Bool ?? false
//
//        self.finalizationVersion =
//            data["finalizationVersion"] as? Int ?? 0
//
//        self.startedAt = data["startedAt"] as? Timestamp
//        self.completedAt = data["completedAt"] as? Timestamp
//        self.createdAt = data["createdAt"] as? Timestamp
//        self.updatedAt = data["updatedAt"] as? Timestamp
//
//        self.completionReason = data["completionReason"] as? String
//        self.finalProgressPercent = data["finalProgressPercent"] as? Double
//    }
//}
//


import Foundation
import FirebaseFirestore

struct ActiveEnrollment {

    let enrollmentId: String
    let userId: String
    let programId: String

    let programName: String?
    let durationDays: Int

    // MARK: - Badge Snapshot

    let badgeId: String
    let badgeTitle: String
    let badgeDescription: String
    let badgeImageName: String
    let programImageName: String

    // MARK: - Progress

    let status: String
    let currentDay: Int
    let completedDaysCount: Int
    let progressPercent: Double

    // MARK: - Completion State

    let isCompleted: Bool
    let isFailed: Bool
    let earnedBadge: Bool

    /// Rozet uygunluğu daha önce kesin olarak değerlendirildi mi?
    let badgeEvaluationCompleted: Bool

    /// Hangi finalization sistemiyle tamamlandığını takip eder.
    let finalizationVersion: Int

    // MARK: - Dates

    let startedAt: Timestamp?
    let completedAt: Timestamp?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    // MARK: - Final Result

    let completionReason: String?
    let finalProgressPercent: Double?

    // MARK: - Firestore Init

    init?(documentId: String, data: [String: Any]) {

        guard
            let userId = data["userId"] as? String,
            let programId = data["programId"] as? String,
            let status = data["status"] as? String,
            let currentDay = data["currentDay"] as? Int,
            let completedDaysCount = data["completedDaysCount"] as? Int,
            let isCompleted = data["isCompleted"] as? Bool,
            let isFailed = data["isFailed"] as? Bool
        else {
            return nil
        }

        self.enrollmentId = documentId
        self.userId = userId
        self.programId = programId

        self.programName =
            data["programName"] as? String

        self.durationDays =
            data["durationDays"] as? Int ?? 0

        // MARK: Badge

        self.badgeId =
            data["badgeId"] as? String ?? ""

        self.badgeTitle =
            data["badgeTitle"] as? String ?? ""

        self.badgeDescription =
            data["badgeDescription"] as? String ?? ""

        self.programImageName =
            data["programImageName"] as? String ?? ""

        self.badgeImageName =
            data["badgeImageName"] as? String
            ?? self.programImageName

        // MARK: Progress

        self.status = status

        self.currentDay = currentDay

        self.completedDaysCount =
            completedDaysCount

        self.progressPercent =
            data["progressPercent"] as? Double ?? 0.0

        // MARK: Completion

        self.isCompleted = isCompleted
        self.isFailed = isFailed

        self.earnedBadge =
            data["earnedBadge"] as? Bool ?? false

        self.badgeEvaluationCompleted =
            data["badgeEvaluationCompleted"] as? Bool
            ?? false

        self.finalizationVersion =
            data["finalizationVersion"] as? Int
            ?? 0

        // MARK: Dates

        self.startedAt =
            data["startedAt"] as? Timestamp

        self.completedAt =
            data["completedAt"] as? Timestamp

        self.createdAt =
            data["createdAt"] as? Timestamp

        self.updatedAt =
            data["updatedAt"] as? Timestamp

        // MARK: Final Result

        self.completionReason =
            data["completionReason"] as? String

        self.finalProgressPercent =
            data["finalProgressPercent"] as? Double
    }
}
