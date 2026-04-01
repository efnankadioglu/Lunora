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
    let id: Int
    let name: String
    let difficultyLevel: Int
    let difficultyScale: Int
    let durationDays: Int
    let durationText: String
    let dailyDurationText: String
    let coreProblems: [String]
    let oneSentenceSummary: String
    let fullText: [String]
    let imageName: String
    let badgeDescription: String
    let elements: String
}

extension Program {
    var defaultState: ProgramStatus {   // düzeltildi
        return .notStarted
    }
}
