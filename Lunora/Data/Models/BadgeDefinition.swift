//
//  BadgeDefinition.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation

struct BadgeDefinition: Codable {
    let id: String
    let programId: String
    
    let title: String
    let description: String
    let iconName: String?
    
    let ruleType: String
    let isActive: Bool
    
    let createdAt: Date
    let updatedAt: Date
}
