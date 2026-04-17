//
//  ProgressCache.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 13.04.2026.
//

import Foundation

struct ProgressCache: Codable {
    let programId: String
    let programName: String
    let totalDays: Int

    let dateKey: String
    let dayNumber: Int

    let todayCompletedTaskIds: [String]
    let todayIsCompleted: Bool

    let currentStreak: Int

    let allDailyLogs: [CachedDailyLog]
}

struct CachedDailyLog: Codable {
    let dateKey: String
    let dayNumber: Int
    let completedTaskIds: [String]
    let isCompleted: Bool
}
