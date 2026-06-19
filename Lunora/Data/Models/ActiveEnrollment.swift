//
//  ActiveEnrollment.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 11.04.2026.
//

import Foundation
import FirebaseFirestore

struct ActiveEnrollment {
    let enrollmentId: String
    let userId: String
    let programId: String

    let programName: String?
    let durationDays: Int

    let badgeId: String
    let badgeDescription: String
    let programImageName: String

    let status: String
    let currentDay: Int
    let completedDaysCount: Int
    let progressPercent: Double

    let isCompleted: Bool
    let isFailed: Bool
    let earnedBadge: Bool

    let startedAt: Timestamp?
    let completedAt: Timestamp?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    let completionReason: String?
    let finalProgressPercent: Double?

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

        self.programName = data["programName"] as? String
        self.durationDays = data["durationDays"] as? Int ?? 0
        
        self.badgeId = data["badgeId"] as? String ?? ""
        self.badgeDescription = data["badgeDescription"] as? String ?? ""
        self.programImageName = data["programImageName"] as? String ?? ""

        self.status = status
        self.currentDay = currentDay
        self.completedDaysCount = completedDaysCount
        self.progressPercent = data["progressPercent"] as? Double ?? 0.0

        self.isCompleted = isCompleted
        self.isFailed = isFailed
        self.earnedBadge = data["earnedBadge"] as? Bool ?? false

        self.startedAt = data["startedAt"] as? Timestamp
        self.completedAt = data["completedAt"] as? Timestamp
        self.createdAt = data["createdAt"] as? Timestamp
        self.updatedAt = data["updatedAt"] as? Timestamp

        self.completionReason = data["completionReason"] as? String
        self.finalProgressPercent = data["finalProgressPercent"] as? Double
    }
}
