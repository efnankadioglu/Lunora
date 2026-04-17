//
//  EarnedBadge.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//
import Foundation

struct EarnedBadge: Codable {
    let id: String
    let badgeId: String
    let programId: String
    let enrollmentId: String
    
    let awardedAt: Date
    let status: String
    
    let isSeen: Bool
    let isFeatured: Bool
    
    let badgeTitleSnapshot: String?
    let badgeDescriptionSnapshot: String?
    let iconNameSnapshot: String?
    
    let createdAt: Date
    let updatedAt: Date
}
