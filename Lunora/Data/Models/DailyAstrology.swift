//
//  DailyAstrology.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.12.2025.
//
import Foundation

struct DailyAstrology: Codable {
    let date: String
    let moonPhase: String
    let dailyComment: String
    let celestialEvents: [String]
    let suitabilityScore: Int
    let moonSign: String

    enum CodingKeys: String, CodingKey {
        case date
        case moonPhase = "moon_phase"
        case dailyComment = "daily_comment"
        case celestialEvents = "celestial_events"
        case suitabilityScore = "suitability_score"
        case moonSign = "moon_sign"
    }
}
