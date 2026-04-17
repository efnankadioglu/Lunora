//
//  CompletionRuleType.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation

enum CompletionRuleType: String, Codable {
    case strictAllDays = "strict_all_days"
    case minRequiredDays = "min_required_days"
    case scoreBased = "score_based"
    case strictDailyThreshold = "strict_daily_threshold"
}
