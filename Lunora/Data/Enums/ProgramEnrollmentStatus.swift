//
//  ProgramEnrollmentStatus.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation

enum ProgramEnrollmentStatus: String, Codable {
    case active
    case completed
    case failed
    case abandoned
    case paused
}
