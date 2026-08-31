//
//  AstroRecommendationModels.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import Foundation

struct AstroActivity: Codable {

    let id: String
    let title: String
    let shortDescription: String

    let topics: [String]
    let actions: [String]
    let context: [String]
    let intensity: String
    let relationshipModes: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case shortDescription = "short_description"
        case topics
        case actions
        case context
        case intensity
        case relationshipModes = "relationship_modes"
    }
}

// MARK: - Score Debug

struct AstroScoreContribution {

    let ruleId: String
    let dimension: String
    let tag: String
    let modifier: Double
    let source: String
}

struct AstroScoreBreakdown {

    let contributions: [AstroScoreContribution]

    let dimensionScores: [String: Double]

    let conditionalModifier: Double
}


// MARK: - Ranked Result

struct RankedAstroActivity {

    let activity: AstroActivity

    let astroFitScore: Double

    let eligible: Bool

    let suppressionReasons: [String]

    let strongNegativeRuleIds: [String]

    let scoreBreakdown: AstroScoreBreakdown
}
