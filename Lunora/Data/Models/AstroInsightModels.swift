//
//  AstroInsightModels.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.05.2026.
//

import Foundation

struct AstroInsightRoot: Codable {
    let events: [AstroInsightEvent]
}

struct AstroInsightEvent: Codable {
    let id: String
    let type: String
    let title: String
    let subtitle: String
    let sign: String
    let date: String
    let dateRange: AstroInsightDateRange
    let content: AstroInsightContent
    let tags: [String]
    let isActive: Bool
}

struct AstroInsightDateRange: Codable {
    let start: String
    let end: String
}

struct AstroInsightContent: Codable {
    let feeling: String
    let effect: String
    let meaning: String
    let actions: [String]
    let avoid: [String]
    let ritual: String
    let beauty: String
}

struct DailySkyDisplayData {
    let dailyAstrology: DailyAstrology
    let moonSignInsight: AstroInsightEvent?
    let extraEventInsights: [AstroInsightEvent]
}
