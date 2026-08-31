//
//  PendingProgressAction.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 17.04.2026.
//

//import Foundation
//
//struct PendingProgressAction: Codable {
//    let id: UUID
//    let userId: String
//    let enrollmentId: String
//    let dateKey: String
//
//    let completedTaskIds: [String]
//    let isCompleted: Bool
//
//    let createdAt: Date
//}

import Foundation

struct PendingProgressAction: Codable {

    let id: UUID
    let userId: String
    let enrollmentId: String
    let dateKey: String
    let completedTaskIds: [String]
    let isCompleted: Bool
    let createdAt: Date

    let shouldFinalizeProgram: Bool?

    init(
        id: UUID,
        userId: String,
        enrollmentId: String,
        dateKey: String,
        completedTaskIds: [String],
        isCompleted: Bool,
        createdAt: Date,
        shouldFinalizeProgram: Bool? = nil
    ) {
        self.id = id
        self.userId = userId
        self.enrollmentId = enrollmentId
        self.dateKey = dateKey
        self.completedTaskIds = completedTaskIds
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.shouldFinalizeProgram = shouldFinalizeProgram
    }
}
