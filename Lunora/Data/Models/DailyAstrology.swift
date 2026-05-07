//
//  DailyAstrology.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.12.2025.
//
//import Foundation
//
//struct DailyAstrology: Codable {
//    let date: String
//    let moonPhase: String
//    let dailyComment: String
//    let celestialEvents: [String]
//    let suitabilityScore: Int
//    let moonSign: String
//
//}
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

    init(
        date: String,
        moonPhase: String,
        dailyComment: String,
        celestialEvents: [String],
        suitabilityScore: Int,
        moonSign: String
    ) {
        self.date = date
        self.moonPhase = moonPhase
        self.dailyComment = dailyComment
        self.celestialEvents = celestialEvents
        self.suitabilityScore = suitabilityScore
        self.moonSign = moonSign
    }

    init?(firestoreData data: [String: Any]) {
        guard
            let date = data["date"] as? String,
            let moonPhase = data["moon_phase"] as? String,
            let dailyComment = data["daily_comment"] as? String,
            let celestialEvents = data["celestial_events"] as? [String],
            let suitabilityScore = data["suitability_score"] as? Int,
            let moonSign = data["moon_sign"] as? String
        else {
            return nil
        }

        self.date = date
        self.moonPhase = moonPhase
        self.dailyComment = dailyComment
        self.celestialEvents = celestialEvents
        self.suitabilityScore = suitabilityScore
        self.moonSign = moonSign
    }
}
