//
//  ProgressModels.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.04.2026.
//

import Foundation

// Kullanıcının program ilerleme bilgisi
struct UserProgramProgress: Codable {
    let programId: String
    var currentDay: Int
    var streakDays: Int
    var completionPercentage: Int
    var remainingTimeText: String
    
    var completedTaskIds: Set<String>
}

// UI state (accordion aç/kapa vs)
struct DailyTaskUIState {
    let taskId: String
    var isCompleted: Bool
    var isExpanded: Bool
}

enum ProgramInfoBlockType: String, CaseIterable {
    case weeklyReflection
    case goldenRules
    case realImpact
    case dailyPlanSummary
    case processResult
}

struct InfoBlockUIState {
    let type: ProgramInfoBlockType
    var isExpanded: Bool
}
