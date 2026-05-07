//
//  DailyLog.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation
import FirebaseFirestore

struct DailyLog {
    let logId: String
    let enrollmentId: String
    let userId: String
    let programId: String
    let dateKey: String
    let dayNumber: Int
    let completedTaskIds: [String]
    let isCompleted: Bool
    let completedAt: Timestamp?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

    // MARK: - Manuel init (cache/local kullanım için)
    init(
        logId: String,
        enrollmentId: String,
        userId: String,
        programId: String,
        dateKey: String,
        dayNumber: Int,
        completedTaskIds: [String],
        isCompleted: Bool,
        completedAt: Timestamp?,
        createdAt: Timestamp?,
        updatedAt: Timestamp?
    ) {
        self.logId = logId
        self.enrollmentId = enrollmentId
        self.userId = userId
        self.programId = programId
        self.dateKey = dateKey
        self.dayNumber = dayNumber
        self.completedTaskIds = completedTaskIds
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Firestore init
    init?(documentId: String, data: [String: Any]) {
        guard
            let enrollmentId = data["enrollmentId"] as? String,
            let userId = data["userId"] as? String,
            let programId = data["programId"] as? String,
            let dateKey = data["dateKey"] as? String,
            let dayNumber = data["dayNumber"] as? Int,
            let completedTaskIds = data["completedTaskIds"] as? [String],
            let isCompleted = data["isCompleted"] as? Bool
        else {
            return nil
        }

        self.logId = documentId
        self.enrollmentId = enrollmentId
        self.userId = userId
        self.programId = programId
        self.dateKey = dateKey
        self.dayNumber = dayNumber
        self.completedTaskIds = completedTaskIds
        self.isCompleted = isCompleted
        self.completedAt = data["completedAt"] as? Timestamp
        self.createdAt = data["createdAt"] as? Timestamp
        self.updatedAt = data["updatedAt"] as? Timestamp
    }
}

