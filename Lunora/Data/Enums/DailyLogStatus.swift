//
//  DailyLogStatus.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//


import Foundation

enum DailyLogStatus: String, Codable {
    case pending
    case partial
    case completed
    case missed
    case skipped
}
