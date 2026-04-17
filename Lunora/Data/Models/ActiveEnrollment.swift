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
    let status: String
    let currentDay: Int
    let completedDaysCount: Int
    let isCompleted: Bool
    let isFailed: Bool
    let startedAt: Timestamp?
    let createdAt: Timestamp?
    let updatedAt: Timestamp?

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
        self.status = status
        self.currentDay = currentDay
        self.completedDaysCount = completedDaysCount
        self.isCompleted = isCompleted
        self.isFailed = isFailed
        self.startedAt = data["startedAt"] as? Timestamp
        self.createdAt = data["createdAt"] as? Timestamp
        self.updatedAt = data["updatedAt"] as? Timestamp
    }
}
