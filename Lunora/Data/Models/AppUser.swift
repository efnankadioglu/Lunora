//
//  AppUser.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation

struct AppUser: Codable {
    let id: String
    let email: String
    let displayName: String?
    
    let createdAt: Date
    let updatedAt: Date
    let lastActiveAt: Date?
    
    let timezone: String
    let locale: String?
    
    let onboardingCompleted: Bool
    
    let currentActiveEnrollmentId: String?
    let currentActiveProgramId: String?
    
    let totalCompletedPrograms: Int?
    let totalEarnedBadges: Int?
}
