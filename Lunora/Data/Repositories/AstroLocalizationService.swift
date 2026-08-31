//
//  AstroLocalizationService.swift
//  Lunora
//
//  Created by Efnan Kadıoğlu on 21.08.2026.
//

import Foundation

// MARK: - Localization Firebase Model

struct AstroLocalizationFile: Decodable {

    let eventTypes: [String: String]
    let planets: [String: String]
    let signs: [String: String]
    let moonPhases: [String: String]
    let planetStatuses: [String: String]
    let aspectTypes: [String: String]
    let lunarConditions: [String: String]
    let eclipseEvents: [String: String]
    let moonNextAspectSignals: [String: String]
    let uiLabels: [String: String]
    let templates: [String: String]

    enum CodingKeys: String, CodingKey {
        case eventTypes = "event_types"
        case planets
        case signs
        case moonPhases = "moon_phases"
        case planetStatuses = "planet_statuses"
        case aspectTypes = "aspect_types"
        case lunarConditions = "lunar_conditions"
        case eclipseEvents = "eclipse_events"
        case moonNextAspectSignals = "moon_next_aspect_signals"
        case uiLabels = "ui_labels"
        case templates
    }
}


// MARK: - Localization Service

final class AstroLocalizationService {

    static let shared = AstroLocalizationService()

    private init() {}

    private var localization: AstroLocalizationFile?
    private var isLoading = false

    // MARK: - Firebase Load

    func loadIfNeeded() async {

        if localization != nil {
            return
        }

        if isLoading {
            while isLoading {
                try? await Task.sleep(
                    nanoseconds: 50_000_000
                )
            }

            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {

            let localizationFile: AstroLocalizationFile =
                try await SkyDataRepository.shared
                    .fetchAstroLocalization(
                        as: AstroLocalizationFile.self
                    )

            localization = localizationFile

            print(
                "🟢 Firebase Astro localization yüklendi"
            )

        } catch {

            print(
                "🔴 Firebase Astro localization yükleme hatası:",
                error
            )
        }
    }

    // MARK: - Basic Values

    func planet(_ value: String) -> String {
        localization?.planets[value] ?? value
    }

    func sign(_ value: String) -> String {
        localization?.signs[value] ?? value
    }

    func moonPhase(_ value: String) -> String {
        localization?.moonPhases[value] ?? value
    }

    func planetStatus(_ value: String) -> String {
        localization?.planetStatuses[value] ?? value
    }

    func aspectType(_ value: String) -> String {
        localization?.aspectTypes[value] ?? value
    }

    func lunarCondition(_ value: String) -> String {
        localization?.lunarConditions[value] ?? value
    }

    func eclipseEvent(_ value: String) -> String {
        localization?.eclipseEvents[value] ?? value
    }

    func moonNextAspectSignal(_ value: String) -> String {
        localization?.moonNextAspectSignals[value] ?? value
    }

    func eventType(_ value: String) -> String {
        localization?.eventTypes[value] ?? value
    }

    func uiLabel(_ value: String) -> String {
        localization?.uiLabels[value] ?? value
    }

    // MARK: - Templates

    func moonSignSingle(
        sign canonicalSign: String
    ) -> String {

        renderTemplate(
            key: "moon_sign_single",
            values: [
                "sign": sign(canonicalSign)
            ]
        )
    }

    func moonSignTransitionSummary(
        from: String,
        to: String
    ) -> String {

        renderTemplate(
            key: "moon_sign_transition_summary",
            values: [
                "from": sign(from),
                "to": sign(to)
            ]
        )
    }

    func moonTransitionPair(
        from: String,
        to: String
    ) -> String {

        renderTemplate(
            key: "moon_transition_pair",
            values: [
                "from": sign(from),
                "to": sign(to)
            ]
        )
    }

    func moonTransitionDescription(
        time: String,
        from: String,
        to: String
    ) -> String {

        renderTemplate(
            key: "moon_transition_description",
            values: [
                "time": time,
                "from": sign(from),
                "to": sign(to)
            ]
        )
    }

    func moonPhaseText(
        _ canonicalPhase: String
    ) -> String {

        renderTemplate(
            key: "moon_phase",
            values: [
                "phase": moonPhase(canonicalPhase)
            ]
        )
    }

    func planetStatusText(
        planet canonicalPlanet: String,
        status canonicalStatus: String
    ) -> String {

        renderTemplate(
            key: "planet_status",
            values: [
                "planet": planet(canonicalPlanet),
                "status": planetStatus(canonicalStatus)
            ]
        )
    }

    func aspectText(
        planet1: String,
        planet2: String,
        aspect: String
    ) -> String {

        renderTemplate(
            key: "aspect",
            values: [
                "planet1": planet(planet1),
                "planet2": planet(planet2),
                "aspect": aspectType(aspect)
            ]
        )
    }

    func lunarConditionText(
        _ canonicalCondition: String
    ) -> String {

        renderTemplate(
            key: "lunar_condition",
            values: [
                "condition": lunarCondition(
                    canonicalCondition
                )
            ]
        )
    }

    func eclipseText(
        _ canonicalEvent: String
    ) -> String {

        renderTemplate(
            key: "eclipse",
            values: [
                "event": eclipseEvent(
                    canonicalEvent
                )
            ]
        )
    }

    func moonNextAspectText(
        _ canonicalSignal: String
    ) -> String {

        renderTemplate(
            key: "moon_next_aspect",
            values: [
                "signal": moonNextAspectSignal(
                    canonicalSignal
                )
            ]
        )
    }

    // MARK: - Template Renderer

    private func renderTemplate(
        key: String,
        values: [String: String]
    ) -> String {

        guard var text =
                localization?.templates[key]
        else {
            return values.values.joined(
                separator: " "
            )
        }

        for (key, value) in values {

            text = text.replacingOccurrences(
                of: "{\(key)}",
                with: value
            )
        }

        return text
    }
}
