//
//  FirstExperienceNeed.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import Foundation

enum FirstExperienceNeed: String, CaseIterable {

    case somethingForMe
    case understandToday
    case makeProgress
    case relationships
    case beauty

    var title: String {
        switch self {

        case .somethingForMe:
            return "Bugün kendim için bir şey yapmak istiyorum"

        case .understandToday:
            return "Bugünü biraz daha iyi anlamak istiyorum"

        case .makeProgress:
            return "Bir konuda gerçekten ilerlemek istiyorum"

        case .relationships:
            return "İlişkime biraz daha yakından bakmak istiyorum"

        case .beauty:
            return "Bakım için bugünün nasıl olduğunu görmek istiyorum"
        }
    }

    var symbolName: String {
        switch self {

        case .somethingForMe:
            return "sparkles"

        case .understandToday:
            return "moon.stars.fill"

        case .makeProgress:
            return "leaf.fill"

        case .relationships:
            return "heart.fill"

        case .beauty:
            return "wand.and.stars"
        }
    }

    var previewSection: FirstExperiencePreviewSection {
        switch self {

        case .somethingForMe:
            return .actions

        case .understandToday:
            return .energy

        case .makeProgress:
            return .programs

        case .relationships:
            return .relationships

        case .beauty:
            return .beauty
        }
    }
}

enum FirstExperiencePreviewSection {
    case actions
    case energy
    case programs
    case relationships
    case beauty
}
