//
//  FirstExperienceCoordinator.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 26.08.2026.
//

import Foundation

final class FirstExperienceCoordinator {

    let state: FirstExperienceState

    init(userID: String) {
        self.state = FirstExperienceState(
            userID: userID
        )
    }

    // MARK: - Start

    var shouldStartFirstExperience: Bool {
        !state.hasCompletedFirstExperience
    }

    var currentStep: FirstExperienceStep {
        state.currentStep
    }

    // MARK: - Selection

    func selectNeed(
        _ need: FirstExperienceNeed
    ) {
        state.selectedNeed = need
        state.currentStep = .selectedPreview
    }

    // MARK: - Second Pillar

    func moveToSecondPillar() {
        state.currentStep = .secondPillar
    }

    // MARK: - Back

    func moveBack() {

        switch state.currentStep {

        case .needSelection:
            break

        case .selectedPreview:
            state.currentStep = .needSelection

        case .secondPillar:
            state.currentStep = .selectedPreview

        case .completed:
            break
        }
    }

    // MARK: - Completion

    func completeFirstExperience() {
        state.complete()
    }

    // MARK: - Helpers

    var selectedNeed: FirstExperienceNeed? {
        state.selectedNeed
    }

    var selectedPreviewSection: FirstExperiencePreviewSection? {
        state.selectedNeed?.previewSection
    }

    var shouldShowProgramsAsSecondPillar: Bool {

        guard let selectedNeed = state.selectedNeed else {
            return true
        }

        return selectedNeed.previewSection != .programs
    }

    // MARK: - Development

    func resetFirstExperience() {
        state.reset()
    }
}
