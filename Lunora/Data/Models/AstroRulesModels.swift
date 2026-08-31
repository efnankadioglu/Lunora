//
//  AstroRulesModels.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import Foundation

// MARK: - Root

struct AstroRulesFile: Codable {

    let scoringPolicy: AstroScoringPolicy
    let planetProfiles: [String: AstroPlanetProfile]
    let rules: [AstroRuleDefinition]

    enum CodingKeys: String, CodingKey {
        case scoringPolicy = "scoring_policy"
        case planetProfiles = "planet_profiles"
        case rules
    }
}


// MARK: - Scoring Policy

struct AstroScoringPolicy: Codable {

    let baseScore: Double
    let finalScoreRange: [Double]
    let scorePrecisionDecimals: Int
    let aggregation: AstroAggregationPolicy

    enum CodingKeys: String, CodingKey {
        case baseScore = "base_score"
        case finalScoreRange = "final_score_range"
        case scorePrecisionDecimals = "score_precision_decimals"
        case aggregation
    }
}


struct AstroAggregationPolicy: Codable {

    let aspectTotalCapPerTag: [Int]
    let secondaryTotalCapPerTag: [Int]
    let planetStatusTotalCapPerTag: [Int]

    let directStatusTotalBonusCapPerActivity: Int
    let conditionalActivityModifierTotalCap: [Int]

    let criticalActions: [String]

    let criticalActionGateByIntensity:
        [String: AstroMinimumScoreGate]

    let relationshipModeGate:
        [String: AstroRelationshipModeGate]

    let rankingFormula: AstroRankingFormula

    enum CodingKeys: String, CodingKey {

        case aspectTotalCapPerTag =
            "aspect_total_cap_per_tag"

        case secondaryTotalCapPerTag =
            "secondary_total_cap_per_tag"

        case planetStatusTotalCapPerTag =
            "planet_status_total_cap_per_tag"

        case directStatusTotalBonusCapPerActivity =
            "direct_status_total_bonus_cap_per_activity"

        case conditionalActivityModifierTotalCap =
            "conditional_activity_modifier_total_cap"

        case criticalActions =
            "critical_actions"

        case criticalActionGateByIntensity =
            "critical_action_gate_by_intensity"

        case relationshipModeGate =
            "relationship_mode_gate"

        case rankingFormula =
            "ranking_formula"
    }
}


struct AstroMinimumScoreGate: Codable {

    let mode: String
    let minimumScore: Double?
    let rule: String

    enum CodingKeys: String, CodingKey {
        case mode
        case minimumScore = "minimum_score"
        case rule
    }
}


struct AstroRelationshipModeGate: Codable {

    let mode: String

    let relationshipModeThreshold: Double?

    let rule: String

    enum CodingKeys: String, CodingKey {
        case mode

        case relationshipModeThreshold =
            "relationship_mode_threshold"

        case rule
    }
}


struct AstroRankingFormula: Codable {

    let relationshipFormulaAppliesWhen: String?
    let dimensionScoreRule: String?
    let missingDimensionPolicy: String?

    let nonRelationship: [String: Double]
    let relationship: [String: Double]

    enum CodingKeys: String, CodingKey {

        case relationshipFormulaAppliesWhen =
            "relationship_formula_applies_when"

        case dimensionScoreRule =
            "dimension_score_rule"

        case missingDimensionPolicy =
            "missing_dimension_policy"

        case nonRelationship =
            "non_relationship"

        case relationship
    }
}


// MARK: - Planet Profiles

struct AstroPlanetProfile: Codable {

    let actions: [String]
    let topics: [String]

    let relationshipModes: [String]

    enum CodingKeys: String, CodingKey {
        case actions
        case topics

        case relationshipModes =
            "relationship_modes"
    }
}


// MARK: - Rule

struct AstroRuleDefinition: Codable {

    let id: String
    let category: String
    let role: String

    let match: AstroRuleMatch

    let modifiers: AstroRuleModifiers

    let profileEffect: AstroProfileEffect?

    let conditionalActivityRules:
        [AstroConditionalActivityRule]?

    let replaces: [String]?

    enum CodingKeys: String, CodingKey {

        case id
        case category
        case role
        case match
        case modifiers

        case profileEffect =
            "profile_effect"

        case conditionalActivityRules =
            "conditional_activity_rules"

        case replaces
    }
}


// MARK: - Match

struct AstroRuleMatch: Codable {

    // Lunar condition
    let condition: String?

    // Eclipse
    let event: String?
    let window: String?

    // Moon next aspect
    let moonNextAspect: String?

    // Moon
    let moonPhase: String?
    let moonSign: String?

    // Planet status
    let planet: String?
    let status: String?

    let usePlanetProfile: Bool?

    // Planetary aspect
    let planetPair: [String]?
    let aspectTypes: [String]?

    enum CodingKeys: String, CodingKey {

        case condition
        case event
        case window

        case moonNextAspect =
            "moon_next_aspect"

        case moonPhase =
            "moon_phase"

        case moonSign =
            "moon_sign"

        case planet
        case status

        case usePlanetProfile =
            "use_planet_profile"

        case planetPair =
            "planet_pair"

        case aspectTypes =
            "aspect_types"
    }
}


// MARK: - Modifiers

struct AstroRuleModifiers: Codable {

    let actions: [String: Int]
    let topics: [String: Int]
    let contexts: [String: Int]

    let relationshipModes: [String: Int]

    enum CodingKeys: String, CodingKey {
        case actions
        case topics
        case contexts

        case relationshipModes =
            "relationship_modes"
    }
}


// MARK: - Planet Profile Effect

struct AstroProfileEffect: Codable {

    let actions: Int?
    let topics: Int?

    let relationshipModes: Int?

    enum CodingKeys: String, CodingKey {

        case actions
        case topics

        case relationshipModes =
            "relationship_modes"
    }
}


// MARK: - Conditional Activity Rule

struct AstroConditionalActivityRule: Codable {

    let when: AstroConditionalWhen

    let activityModifier: Int

    let reason: String

    let hardBlockAllowed: Bool?

    enum CodingKeys: String, CodingKey {

        case when

        case activityModifier =
            "activity_modifier"

        case reason

        case hardBlockAllowed =
            "hard_block_allowed"
    }
}


struct AstroConditionalWhen: Codable {

    let intensity: [String]?

    let anyActions: [String]?

    let topicsAny: [String]?

    let contextAny: [String]?

    enum CodingKeys: String, CodingKey {

        case intensity

        case anyActions =
            "any_actions"

        case topicsAny =
            "topics_any"

        case contextAny =
            "context_any"
    }
}
