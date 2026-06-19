//
//  ElementProgressItem.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 8.06.2026.
//

import Foundation

struct ElementProgressItem {
    let key: String
    let name: String
    let emoji: String
    let totalCount: Int
    let completedCount: Int
    
    var percentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(completedCount) / Double(totalCount)) * 100)
    }
}
