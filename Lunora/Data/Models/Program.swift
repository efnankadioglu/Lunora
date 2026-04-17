//
//  Program.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 23.01.2026.
//

import Foundation

struct ProgramResponse: Codable {
    let programs: [Program]
}

struct Program: Codable {
    let id: String
    
    // 🔥 SYSTEM
    let version: Int?
    let isActive: Bool?
    
    let name: String
    let difficultyLevel: Int
    let difficultyScale: Int
    let durationDays: Int
    let durationText: String
    let imageName: String
    
    // 🔥 BADGE
    let badgeId: String?
    let badgeTitle: String?
    let badgeDescription: String
    let badgeImageName: String?
    
    // 🔥 RULES
    let completionRuleType: CompletionRuleType?
    let allowRestart: Bool?
    let dailyTaskCompletionThreshold: Double?
    
    let elements: String
    let dailyDurationText: String
    let coreProblems: [String]
    let oneSentenceSummary: String
    let fullText: [String]
    
    let dailyTasks: [DailyTask]
    
    let weeklyReflection: ProgramSection
    let goldenRules: ProgramSection
    let realImpact: ProgramSection
    let dailyPlanSummary: ProgramSection
    let processResult: ProgramSection
}

struct ProgramSection: Codable {
    let title: String
    let shortDescription: String
    let details: [String]
}

extension Program {
    
    func formatted() -> Program {
        return Program(
            id: id,
            version: version ?? 1,
            isActive: isActive ?? true,
            
            name: name,
            difficultyLevel: difficultyLevel,
            difficultyScale: difficultyScale,
            durationDays: durationDays,
            durationText: durationText,
            imageName: imageName,
            
            badgeId: badgeId ?? "badge_\(id)",
            badgeTitle: badgeTitle.map { formatText($0) },
            badgeDescription: formatText(badgeDescription),
            badgeImageName: badgeImageName,
            
            completionRuleType: completionRuleType ?? .strictDailyThreshold,
            allowRestart: allowRestart ?? true,
            dailyTaskCompletionThreshold: dailyTaskCompletionThreshold ?? 0.5,
            
            elements: elements,
            dailyDurationText: dailyDurationText,
            coreProblems: coreProblems.map { formatText($0) },
            oneSentenceSummary: formatText(oneSentenceSummary),
            fullText: fullText.map { formatText($0) },
            
            dailyTasks: dailyTasks,
            
            weeklyReflection: weeklyReflection.formatted(),
            goldenRules: goldenRules.formatted(),
            realImpact: realImpact.formatted(),
            dailyPlanSummary: dailyPlanSummary.formatted(),
            processResult: processResult.formatted()
        )
    }
    
    private func formatText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "* ", with: "\n• ")
    }
}

extension ProgramSection {
    
    func formatted() -> ProgramSection {
        return ProgramSection(
            title: title,
            shortDescription: formatText(shortDescription),
            details: details.map { formatText($0) }
        )
    }
    
    private func formatText(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "* ", with: "\n• ")
    }
}
