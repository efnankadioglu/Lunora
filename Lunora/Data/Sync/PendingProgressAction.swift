//
//  PendingProgressAction.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 17.04.2026.
//

import Foundation

struct PendingProgressAction: Codable {
    let id: UUID
    let userId: String
    let enrollmentId: String
    let dateKey: String

    let completedTaskIds: [String]
    let isCompleted: Bool

    let createdAt: Date
}
