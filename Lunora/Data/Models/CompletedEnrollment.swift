//
//  CompletedEnrollment.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 29.04.2026.
//
import Foundation
import FirebaseFirestore

struct CompletedEnrollment {

    let enrollmentId: String
    let userId: String
    let programId: String
    let status: ProgramEnrollmentStatus
    let isCompleted: Bool
    let completedAt: Timestamp?
    let completionNote: String?
    let completedDaysCount: Int

    init?(documentId: String, data: [String: Any]) {
        guard
            let userId = data["userId"] as? String,
            let programId = data["programId"] as? String
        else {
            return nil
        }

        let statusRaw = data["status"] as? String ?? ""
        let status = ProgramEnrollmentStatus(rawValue: statusRaw) ?? .active
        let isCompleted = data["isCompleted"] as? Bool ?? false

        guard status == .completed || isCompleted == true else {
            return nil
        }

        self.enrollmentId = documentId
        self.userId = userId
        self.programId = programId
        self.status = status
        self.isCompleted = isCompleted
        self.completedAt = data["completedAt"] as? Timestamp
        self.completionNote = data["completionNote"] as? String
        self.completedDaysCount = data["completedDaysCount"] as? Int ?? 0
    }
}
