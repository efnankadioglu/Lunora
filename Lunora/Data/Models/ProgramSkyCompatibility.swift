//
//  ProgramSkyCompatibility.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 7.08.2026.
//
//
//  ProgramSkyCompatibility.swift
//  Lunora
//

import Foundation

struct ProgramSkyCompatibility {

    let status: ProgramSkyCompatibilityStatus

    let title: String

    let description: String

    let matchedItems: [ProgramSkyCompatibilityItem]
}

enum ProgramSkyCompatibilityStatus: String {

    case supportive
    case neutral
    case slowDown
}

struct ProgramSkyCompatibilityItem {

    let id: String

    let title: String

    let symbol: String?
}
