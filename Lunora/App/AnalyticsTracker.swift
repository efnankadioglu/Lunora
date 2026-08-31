//
//  AnalyticsTracker.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 30.08.2026.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsTracker {

    static let shared = AnalyticsTracker()

    private init() {}

    // MARK: - Program

    func programDetailViewed(programId: String) {
        Analytics.logEvent("program_detail_viewed", parameters: [
            "program_id": programId
        ])
    }

    func programStarted(programId: String) {
        Analytics.logEvent("program_started", parameters: [
            "program_id": programId
        ])
    }

    func taskCompleted(
        programId: String,
        dayNumber: Int,
        taskId: String
    ) {
        Analytics.logEvent("task_completed", parameters: [
            "program_id": programId,
            "day_number": dayNumber,
            "task_id": taskId
        ])
    }

    func dayCompleted(
        programId: String,
        dayNumber: Int
    ) {
        Analytics.logEvent("day_completed", parameters: [
            "program_id": programId,
            "day_number": dayNumber
        ])
    }

    func programCompleted(programId: String) {
        Analytics.logEvent("program_completed", parameters: [
            "program_id": programId
        ])
    }

    // MARK: - Authentication

    func loginSuccess(method: String) {
        Analytics.logEvent("login_success", parameters: [
            "method": method
        ])
    }

    func loginFailed(
        method: String,
        error: Error
    ) {
        let nsError = error as NSError

        Analytics.logEvent("login_failed", parameters: [
            "method": method,
            "error_domain": nsError.domain,
            "error_code": nsError.code
        ])
    }

    // MARK: - Errors

    func criticalActionFailed(
        action: String,
        screen: String? = nil,
        error: Error
    ) {
        let nsError = error as NSError

        var parameters: [String: Any] = [
            "action": action,
            "error_domain": nsError.domain,
            "error_code": nsError.code
        ]

        if let screen {
            parameters["screen"] = screen
        }

        Analytics.logEvent(
            "critical_action_failed",
            parameters: parameters
        )
    }

    // MARK: - Daily Sky

    func dailySkyOpened() {
        Analytics.logEvent(
            "daily_sky_opened",
            parameters: nil
        )
    }

    // MARK: - Notifications

    func notificationOpened(category: String? = nil) {
        var parameters: [String: Any] = [:]

        if let category {
            parameters["category"] = category
        }

        Analytics.logEvent(
            "notification_opened",
            parameters: parameters.isEmpty ? nil : parameters
        )
    }

    // MARK: - Badge

    func badgeEarned(badgeId: String) {
        Analytics.logEvent("badge_earned", parameters: [
            "badge_id": badgeId
        ])
    }

    // MARK: - Onboarding

    func onboardingCompleted() {
        Analytics.logEvent(
            "onboarding_completed",
            parameters: nil
        )
    }
}
