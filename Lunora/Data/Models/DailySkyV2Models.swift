//
//  DailySkyV2Models.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import Foundation

// MARK: - 1. Ham Astroloji Datası
// dailyAstroData.json

struct DailyAstroDataDay: Codable {
    let date: String
    let timezone: String
    let astroSignals: [AstroSignal]

    enum CodingKeys: String, CodingKey {
        case date
        case timezone
        case astroSignals = "astro_signals"
    }
}

struct AstroSignal: Codable {
    let type: String

    let value: String?
    let planet: String?
    let status: String?
    let sign: String?

    let startAt: String?
    let endAt: String?

    let planetPair: [String]?
    let aspectType: String?

    let condition: String?

    let sourcePlanet: String?
    let sourceAspectType: String?

    let event: String?

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case planet
        case status
        case sign

        case startAt = "start_at"
        case endAt = "end_at"

        case planetPair = "planet_pair"
        case aspectType = "aspect_type"

        case condition

        case sourcePlanet = "source_planet"
        case sourceAspectType = "source_aspect_type"

        case event
    }
}


// MARK: - 2. Günlük Yorum Datası
// dailyInterpretationData.json

struct DailyInterpretationDataDay: Codable {
    let date: String
    let timezone: String
    let schemaVersion: String
    let contentVersion: String

    let generalDailyInterpretation: InterpretationTextBlock
    let avoidToday: [String]
    let relationships: RelationshipInterpretation

    enum CodingKeys: String, CodingKey {
        case date
        case timezone
        case schemaVersion = "schema_version"
        case contentVersion = "content_version"
        case generalDailyInterpretation = "general_daily_interpretation"
        case avoidToday = "avoid_today"
        case relationships
    }
}

struct InterpretationTextBlock: Codable {
    let title: String
    let summaryText: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case title
        case summaryText = "summary_text"
        case text
    }
}

struct RelationshipInterpretation: Codable {

    let theme: RelationshipTheme

    let general: InterpretationTextBlock

    let focusedInterpretations:
        [RelationshipFocusedInterpretation]

    let goodForToday:
        RelationshipGoodForToday

    let avoidToday: [String]

    enum CodingKeys: String, CodingKey {

        case theme
        case general

        case focusedInterpretations =
            "focused_interpretations"

        case goodForToday =
            "good_for_today"

        case avoidToday =
            "avoid_today"
    }
}

struct RelationshipFocusedInterpretation: Codable {

    let mode: String

    let title: String

    let summaryText: String

    let text: String

    let goodForToday:
        RelationshipGoodForToday

    let avoidToday: [String]

    enum CodingKeys: String, CodingKey {

        case mode
        case title

        case summaryText =
            "summary_text"

        case text

        case goodForToday =
            "good_for_today"

        case avoidToday =
            "avoid_today"
    }
}

struct RelationshipTheme: Codable {
    let title: String
    let keywords: [String]
    let displayKeywords: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case keywords
        case displayKeywords = "display_keywords"
    }
}

struct RelationshipGoodForToday: Codable {
    let title: String
    let text: String
}


// MARK: - 3. Güzellik Datası
// dailyBeautyData.json

struct DailyBeautyDataDay: Codable {
    let date: String
    let timezone: String
    let schemaVersion: String
    let rulesetVersion: String
    let beautyRecommendations: [BeautyRecommendation]

    enum CodingKeys: String, CodingKey {
        case date
        case timezone
        case schemaVersion = "schema_version"
        case rulesetVersion = "ruleset_version"
        case beautyRecommendations = "beauty_recommendations"
    }
}

struct BeautyRecommendation: Codable {
    let category: String
    let recommendation: String

    let startAt: String
    let endAt: String

    let traditionalGoals: [String]
    let astroBasis: [BeautyAstroBasis]
    let ruleIds: [String]

    let displayText: String

    enum CodingKeys: String, CodingKey {
        case category
        case recommendation

        case startAt = "start_at"
        case endAt = "end_at"

        case traditionalGoals = "traditional_goals"
        case astroBasis = "astro_basis"
        case ruleIds = "rule_ids"

        case displayText = "display_text"
    }
}

struct BeautyAstroBasis: Codable {
    let type: String
    let value: String?
    let planet: String?
}


// MARK: - Yeni Günlük Gökyüzü Paketi

struct DailySkyV2Data {
    let astro: DailyAstroDataDay
    let interpretation: DailyInterpretationDataDay?
    let beauty: DailyBeautyDataDay?
}
