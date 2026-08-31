//
//  FirstExperienceState.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import Foundation

enum FirstExperienceStep: Int {

    case needSelection = 0
    case selectedPreview = 1
    case secondPillar = 2
    case completed = 3
}

final class FirstExperienceState {

    private let defaults: UserDefaults
    private let userID: String

    init(
        userID: String,
        defaults: UserDefaults = .standard
    ) {
        self.userID = userID
        self.defaults = defaults
    }

    // MARK: - Keys

    private var selectedNeedKey: String {
        "firstExperience.\(userID).selectedNeed"
    }

    private var currentStepKey: String {
        "firstExperience.\(userID).currentStep"
    }

    private var completedKey: String {
        "firstExperience.\(userID).completed"
    }

    // MARK: - Selected Need

    var selectedNeed: FirstExperienceNeed? {
        get {
            guard let rawValue = defaults.string(
                forKey: selectedNeedKey
            ) else {
                return nil
            }

            return FirstExperienceNeed(rawValue: rawValue)
        }

        set {
            if let newValue {
                defaults.set(
                    newValue.rawValue,
                    forKey: selectedNeedKey
                )
            } else {
                defaults.removeObject(
                    forKey: selectedNeedKey
                )
            }
        }
    }

    // MARK: - Current Step

    var currentStep: FirstExperienceStep {
        get {
            guard defaults.object(
                forKey: currentStepKey
            ) != nil else {
                return .needSelection
            }

            let rawValue = defaults.integer(
                forKey: currentStepKey
            )

            return FirstExperienceStep(
                rawValue: rawValue
            ) ?? .needSelection
        }

        set {
            defaults.set(
                newValue.rawValue,
                forKey: currentStepKey
            )
        }
    }

    // MARK: - Completion

    var hasCompletedFirstExperience: Bool {
        defaults.bool(forKey: completedKey)
    }

    func complete() {
        currentStep = .completed

        defaults.set(
            true,
            forKey: completedKey
        )
    }

    // MARK: - Reset

    func reset() {
        defaults.removeObject(
            forKey: selectedNeedKey
        )

        defaults.removeObject(
            forKey: currentStepKey
        )

        defaults.removeObject(
            forKey: completedKey
        )
    }
}
