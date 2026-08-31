//
//  GuidedOnboardingManager.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 28.08.2026.
//

import Foundation

enum GuidedOnboardingStep: String {
    case dailySkyCard

    case dailySkyOverview
    case dailySkyActions
    case dailySkyAvoid
    case dailySkyRelationships
    case dailySkyBeauty
    case dailySkyUpcoming

    case programCard
    case programDetail

    case todayTasks
    case programProgress
    case completed
}

final class GuidedOnboardingManager {

    static let shared = GuidedOnboardingManager()

    private let defaults = UserDefaults.standard

    // Sadece uygulama açıkken yaşar.
    // App kapanınca otomatik sıfırlanır.
    private var activeSessionUserIDs = Set<String>()

    private init() {
        print("🧠 NEW GUIDED MANAGER ÇALIŞTI")
    }


    // MARK: - Keys

    private func stepKey(
        for userID: String
    ) -> String {
        "guidedOnboarding.step.\(userID)"
    }


    // MARK: - Start

    func start(
        for userID: String
    ) {
        activeSessionUserIDs.insert(userID)

        defaults.set(
            GuidedOnboardingStep.dailySkyCard.rawValue,
            forKey: stepKey(for: userID)
        )

        print("🧭 GUIDED START → dailySkyCard")
    }


    // MARK: - State

    func isActive(
        for userID: String
    ) -> Bool {
        activeSessionUserIDs.contains(userID)
    }


    func currentStep(
        for userID: String
    ) -> GuidedOnboardingStep? {

        guard isActive(for: userID) else {
            return nil
        }

        guard
            let rawValue = defaults.string(
                forKey: stepKey(for: userID)
            )
        else {
            return nil
        }

        return GuidedOnboardingStep(
            rawValue: rawValue
        )
    }


    // MARK: - Advance

    func advance(
        for userID: String
    ) {
        guard
            let currentStep = currentStep(
                for: userID
            )
        else {
            return
        }

        let nextStep: GuidedOnboardingStep

        switch currentStep {

        case .dailySkyCard:
            nextStep = .dailySkyOverview

        case .dailySkyOverview:
            nextStep = .dailySkyActions

        case .dailySkyActions:
            nextStep = .dailySkyAvoid

        case .dailySkyAvoid:
            nextStep = .dailySkyRelationships

        case .dailySkyRelationships:
            nextStep = .dailySkyBeauty

        case .dailySkyBeauty:
            nextStep = .dailySkyUpcoming

        case .dailySkyUpcoming:
            nextStep = .programCard

        case .programCard:
            nextStep = .programDetail

        case .programDetail:
            nextStep = .programProgress

        case .todayTasks:
            nextStep = .programProgress

        case .programProgress:
            nextStep = .completed

        case .completed:
            finish(for: userID)
            return
        }

        defaults.set(
            nextStep.rawValue,
            forKey: stepKey(for: userID)
        )

        print(
            "🧭 GUIDED ADVANCE → \(nextStep.rawValue)"
        )
    }


    // MARK: - Finish

    func finish(
        for userID: String
    ) {
        activeSessionUserIDs.remove(userID)

        defaults.set(
            GuidedOnboardingStep.completed.rawValue,
            forKey: stepKey(for: userID)
        )

        print("🧭 GUIDED FINISHED")
    }


    // MARK: - Replay

    func restart(
        for userID: String
    ) {
        start(for: userID)
    }


#if DEBUG

    func debugJump(
        to step: GuidedOnboardingStep,
        for userID: String
    ) {
        activeSessionUserIDs.insert(userID)

        defaults.set(
            step.rawValue,
            forKey: stepKey(for: userID)
        )

        print(
            "🧪 GUIDED DEBUG → \(step.rawValue)"
        )
    }

#endif
}
