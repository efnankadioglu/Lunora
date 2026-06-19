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
    
    // SYSTEM
    let version: Int?
    let isActive: Bool?
    
    let name: String
    let difficultyLevel: Int
    let difficultyScale: Int
    let durationDays: Int
    let durationText: String
    let imageName: String
    
    // BADGE
    let badgeId: String?
    let badgeTitle: String?
    let badgeDescription: String
    let badgeImageName: String?
    
    // RULES
    let completionRuleType: CompletionRuleType?
    let allowRestart: Bool?
    let dailyTaskCompletionThreshold: Double?
    
    let elements: String
    let dailyDurationText: String
    
    // Yeni süre alanları
    let dailyDurationMinMinutes: Int?
    let dailyDurationMaxMinutes: Int?
    
    // Yeni program elementleri
    let programElements: [ProgramElement]?
    
    let coreProblems: [String]
    let oneSentenceSummary: String
    let fullText: [String]
    
    // Eski format: program seviyesinde görevler
    let dailyTasks: [DailyTask]
    
    // Yeni format: gün gün görevler
    let days: [ProgramDay]?
    
    let weeklyReflection: ProgramSection
    let goldenRules: ProgramSection
    
    // Eski bazı programlarda kullanılan alanlar.
    // Yeni JSON'da yoksa boş section olarak gelir.
    let realImpact: ProgramSection
    let dailyPlanSummary: ProgramSection
    let processResult: ProgramSection
}

// MARK: - New Models

struct ProgramElement: Codable {
    let key: String
    let name: String
    let emoji: String
}

struct ProgramDay: Codable {
    let dayNumber: Int
    let title: String
    let dailyDurationText: String?
    let tasks: [DailyTask]
}

struct ProgramSection: Codable {
    let title: String
    let shortDescription: String
    let details: [String]
    
    static let empty = ProgramSection(
        title: "",
        shortDescription: "",
        details: []
    )
}

// MARK: - Custom Decode

extension Program {
    
    enum CodingKeys: String, CodingKey {
        case id
        case version
        case isActive
        case name
        case difficultyLevel
        case difficultyScale
        case durationDays
        case durationText
        case imageName
        case badgeId
        case badgeTitle
        case badgeDescription
        case badgeImageName
        case completionRuleType
        case allowRestart
        case dailyTaskCompletionThreshold
        case elements
        case dailyDurationText
        case dailyDurationMinMinutes
        case dailyDurationMaxMinutes
        case programElements
        case coreProblems
        case oneSentenceSummary
        case fullText
        case dailyTasks
        case days
        case weeklyReflection
        case goldenRules
        case realImpact
        case dailyPlanSummary
        case processResult
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        version = try container.decodeIfPresent(Int.self, forKey: .version)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        
        name = try container.decode(String.self, forKey: .name)
        difficultyLevel = try container.decode(Int.self, forKey: .difficultyLevel)
        difficultyScale = try container.decode(Int.self, forKey: .difficultyScale)
        durationDays = try container.decode(Int.self, forKey: .durationDays)
        durationText = try container.decode(String.self, forKey: .durationText)
        imageName = try container.decode(String.self, forKey: .imageName)
        
        badgeId = try container.decodeIfPresent(String.self, forKey: .badgeId)
        badgeTitle = try container.decodeIfPresent(String.self, forKey: .badgeTitle)
        badgeDescription = try container.decode(String.self, forKey: .badgeDescription)
        badgeImageName = try container.decodeIfPresent(String.self, forKey: .badgeImageName)
        
        completionRuleType = try container.decodeIfPresent(CompletionRuleType.self, forKey: .completionRuleType)
        allowRestart = try container.decodeIfPresent(Bool.self, forKey: .allowRestart)
        dailyTaskCompletionThreshold = try container.decodeIfPresent(Double.self, forKey: .dailyTaskCompletionThreshold)
        
        elements = try container.decode(String.self, forKey: .elements)
        dailyDurationText = try container.decode(String.self, forKey: .dailyDurationText)
        dailyDurationMinMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyDurationMinMinutes)
        dailyDurationMaxMinutes = try container.decodeIfPresent(Int.self, forKey: .dailyDurationMaxMinutes)
        programElements = try container.decodeIfPresent([ProgramElement].self, forKey: .programElements)
        
        coreProblems = try container.decode([String].self, forKey: .coreProblems)
        oneSentenceSummary = try container.decode(String.self, forKey: .oneSentenceSummary)
        fullText = try container.decode([String].self, forKey: .fullText)
        
        // Eski JSON'da dailyTasks var.
        // Yeni JSON'da days var, dailyTasks olmayabilir.
        dailyTasks = try container.decodeIfPresent([DailyTask].self, forKey: .dailyTasks) ?? []
        days = try container.decodeIfPresent([ProgramDay].self, forKey: .days)
        
        weeklyReflection = try container.decodeIfPresent(ProgramSection.self, forKey: .weeklyReflection) ?? .empty
        goldenRules = try container.decodeIfPresent(ProgramSection.self, forKey: .goldenRules) ?? .empty
        
        realImpact = try container.decodeIfPresent(ProgramSection.self, forKey: .realImpact) ?? .empty
        dailyPlanSummary = try container.decodeIfPresent(ProgramSection.self, forKey: .dailyPlanSummary) ?? .empty
        processResult = try container.decodeIfPresent(ProgramSection.self, forKey: .processResult) ?? .empty
    }
}
// MARK: - Formatting

extension Program {
    
    func formatted() -> Program {
        return Program(
            id: id,
            version: version ?? 1,
            isActive: isActive ?? true,
            
            name: formatText(name),
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
            dailyDurationMinMinutes: dailyDurationMinMinutes,
            dailyDurationMaxMinutes: dailyDurationMaxMinutes,
            programElements: programElements,
            
            coreProblems: coreProblems.map { formatText($0) },
            oneSentenceSummary: formatText(oneSentenceSummary),
            fullText: fullText.map { formatText($0) },
            
            dailyTasks: dailyTasks.map { $0.formatted() },
            days: days?.map { $0.formatted() },
            
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

extension ProgramDay {
    
    func formatted() -> ProgramDay {
        return ProgramDay(
            dayNumber: dayNumber,
            title: title,
            dailyDurationText: dailyDurationText,
            tasks: tasks.map { $0.formatted() }
        )
    }
}

extension DailyTask {
    
    func formatted() -> DailyTask {
        return DailyTask(
            id: id,
            title: formatText(title),
            shortDescription: formatText(shortDescription),
            details: details.map { formatText($0) },
            elementKey: elementKey,
            elementName: elementName,
            elementEmoji: elementEmoji,
            timeOfDay: timeOfDay,
            estimatedDurationText: estimatedDurationText,
            estimatedMinutes: estimatedMinutes,
            isRequired: isRequired
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
            title: formatText(title),
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
