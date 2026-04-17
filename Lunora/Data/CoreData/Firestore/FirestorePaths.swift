//
//  FirestorePaths.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 6.04.2026.
//

import Foundation

enum FirestoreCollection {
    static let users = "users"
    static let programs = "programs"
    static let badges = "badges"
    static let programEnrollments = "program_enrollments"
    static let dailyLogs = "daily_logs"
    static let earnedBadges = "earned_badges"
}

enum FirestorePath {
    
    static func userDocument(userId: String) -> String {
        return "\(FirestoreCollection.users)/\(userId)"
    }
    
    static func userProgramEnrollments(userId: String) -> String {
        return "\(FirestoreCollection.users)/\(userId)/\(FirestoreCollection.programEnrollments)"
    }
    
    static func userProgramEnrollmentDocument(userId: String, enrollmentId: String) -> String {
        return "\(FirestoreCollection.users)/\(userId)/\(FirestoreCollection.programEnrollments)/\(enrollmentId)"
    }
    
    static func dailyLogs(userId: String, enrollmentId: String) -> String {
        return "\(FirestoreCollection.users)/\(userId)/\(FirestoreCollection.programEnrollments)/\(enrollmentId)/\(FirestoreCollection.dailyLogs)"
    }
    
    static func earnedBadges(userId: String) -> String {
        return "\(FirestoreCollection.users)/\(userId)/\(FirestoreCollection.earnedBadges)"
    }
    
    static func programDocument(programId: String) -> String {
        return "\(FirestoreCollection.programs)/\(programId)"
    }
    
    static func badgeDocument(badgeId: String) -> String {
        return "\(FirestoreCollection.badges)/\(badgeId)"
    }
}
