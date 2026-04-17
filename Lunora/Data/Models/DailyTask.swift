//
//  DailyTask.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 2.04.2026.
//

import Foundation

struct DailyTask: Codable {
    let id: String
    let title: String
    let shortDescription: String
    let details: [String]
}
