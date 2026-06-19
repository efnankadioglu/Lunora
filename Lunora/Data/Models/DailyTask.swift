//
//  DailyTask.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 2.04.2026.
//

import Foundation

struct DailyTask: Codable {
    let id: String
    let title: String
    let shortDescription: String
    let details: [String]
    
    // Yeni alanlar
    let elementKey: String?
    let elementName: String?
    let elementEmoji: String?
    
    let timeOfDay: String?
    let estimatedDurationText: String?
    let estimatedMinutes: Int?
    
    // Kişisel harita görevi gibi opsiyonel görevler için
    let isRequired: Bool?
}
