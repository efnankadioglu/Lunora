//
//  ProgramEnrollment.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation

struct ProgramEnrollment: Codable {
    let id: String
    let userId: String
    let programId: String
    let programVersion: Int
    let attemptNumber: Int
    
    let status: ProgramEnrollmentStatus
    
    let startedAt: Date
    let plannedEndAt: Date
    
    let completedAt: Date?
    let failedAt: Date?
    let abandonedAt: Date?
    let lastCheckInAt: Date?
    
    let lastCompletedDayNumber: Int?
    
    let completedDaysCount: Int
    let missedDaysCount: Int
    let completionRate: Double?
    
    let eligibleForBadge: Bool
    let badgeGranted: Bool
    let badgeGrantedAt: Date?
    let badgeId: String
    
    let failureReason: String?
    
    let currentStreak: Int?
    let bestStreak: Int?
    
    let restartOfEnrollmentId: String?
    
    let createdAt: Date
    let updatedAt: Date
}
